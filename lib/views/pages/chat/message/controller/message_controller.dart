import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_app/control/constants/firebase_auth_constants.dart';
import 'package:flutter_chat_app/views/pages/chat/room/controller/room_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/room/model/room.dart';
import 'package:flutter_chat_app/views/pages/chat/message/model/message.dart';
import 'package:flutter_chat_app/utilities/collection_enum.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user_contact.dart';
import 'package:get/get.dart';

class MessageController extends GetxController with GetSingleTickerProviderStateMixin{
  static MessageController instance(roomId) => Get.find(tag: roomId);
  RxList<Message> messagesList = <Message>[].obs;
  bool _messageFirstState = false;
  RxBool messageSecondState = true.obs;
  TextEditingController textEditingController= TextEditingController();
  late UserContact otherUser;
  late CollectionReference messageCollection;
  late Room room;
  ScrollController listViewScrollController = ScrollController();
  RxBool isPageShowing = false.obs;

  bool isSelectionMode = false;
  List<String> selectedMessages = <String>[];



  @override
  void onClose() {
    RoomController.instance.disableReceiveMessages();
    isPageShowing.value = false;
    super.onClose();
  }

  @override
  void dispose() {
    selectedMessages.clear();
    //isPageShowing.value = false;
    super.dispose();
  }

  @override
  void onInit() async {
    // hide keyboard when enter in the room but cursor in the textField
    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
    super.onInit();

    isPageShowing.value=true;

    var arguments = Get.arguments as Map<String, dynamic>;
    otherUser = arguments['userContact'] as UserContact;
    room = arguments['room'] as Room;
    messageCollection = firebaseFirestore.collection(Collections.ROOMS)
        .doc(room.roomId).collection(Collections.MESSAGES);
    /*messagesList.bindStream(stream);
    RoomController.instance.messageBox.values.toList();
    RoomController.instance.messageBox.watch().listen((event) {
      Message message = event.value;
    });*/
  }


  @override
  void onReady() {
    super.onReady();
    RoomController.instance
        .setReceiveMessages(room.roomId, (DocumentChange<Message> element) {
          var message = element.doc.data();
          if (message == null) return;
          //debugPrint("MessageController:message= ${message.toString()}");
          /*debugPrint("MessageController:message.senderId=${message.senderId}");
          debugPrint("MessageController:message.receiverId=${message.receiverId}");*/
          if (element.type == DocumentChangeType.added) {
            if (message.senderId == otherUser.uid
                && isPageShowing.value) {
              debugPrint("MessageController:____add_message_____seen");
              message.state = StateType.seen;
              RoomController.instance.messageBox.put(message.messageId, message);
              element.doc.reference.update({
                MessageColumns.state: StateType.seen
              });
            }
          }
          else if (element.type == DocumentChangeType.modified) {

          }
    });
    /*RoomController.instance.setReceiveMessages(room.roomId,
            (QuerySnapshot<Message> event) {
      event.docChanges.forEach((element) {
        var _message = element.doc.data();
        if (_message == null) return;
        if(_message.roomId == room.roomId) {
          if (element.type == DocumentChangeType.added) {
            if (_message.senderId == otherUser.uid && isPageShowing.value) {
              debugPrint("____added_____ seen");
              _message.state = StateType.seen;
              element.doc.reference.update(_message.toJson());
            }
          }
          else if (element.type == DocumentChangeType.modified) {

          }
        }
      });
    });*/
    seenAllAnotherUserMessagesBatch();
  }



  bool isMe(String uid) => uid == authController.firebaseUser.value!.uid;

  showSelectionMode(messageId){
    isSelectionMode = true;
    selectedMessages.add(messageId);
    update();
  }

  disableSelectionMode(){
    selectedMessages.clear();
    isSelectionMode = false;
    update();
  }

  addToSelectedMessages(String messageId){
    selectedMessages.add(messageId);
    update();
  }

  removeFromSelectedMessages(String messageId){
    selectedMessages.remove(messageId);
    update();
  }

  deleteMessages() {
    if (selectedMessages.isNotEmpty) {
      var sortedList = RoomController.instance.messageBox.values
          .where((element) => element.roomId == room.roomId)
          .toList();
      if(selectedMessages.length == sortedList.length) {
        RoomController.instance.deleteRoom(room.roomId);
      }else{
        sortedList = sortedList.skipWhile((value) => selectedMessages.contains(value.messageId))
            .toList()..sort((a, b) => a.time.compareTo(b.time));
        debugPrint("sortedList.length= ${sortedList.length}");
        debugPrint("delete selectedMessages= $selectedMessages");
        Message message = sortedList[sortedList.length - 1];
        room.lastMessageId = message.messageId;
        debugPrint("message.messageId= ${message.messageId}");
        RoomController.instance.roomBox.put(room.roomId, room);
        RoomController.instance.messageBox.deleteAll(selectedMessages);
      }
    }
    disableSelectionMode();
  }


  Future<void> seenAllAnotherUserMessagesBatch(){
    WriteBatch batch = firebaseFirestore.batch();
    /*var list = RoomController.instance.messageBox.values.where((e) {
      return e.roomId == room.roomId
          && e.senderId == otherUser.uid
          && e.state != StateType.seen;
    }).toList();

    list.forEach((element) =>element.state = StateType.seen);
    var entries= { for (var m in list) m.messageId : m };
    RoomController.instance.messageBox.putAll(entries);*/
    return messageCollection
        .where(MessageColumns.senderId, isEqualTo: otherUser.uid)
        .where(MessageColumns.state, isNotEqualTo: StateType.seen)
        .withConverter(fromFirestore: (snapshot, _) => Message.fromJson(snapshot.data()!), toFirestore: (Message? m, _) => m!.toJson())
        .get()
        .then((querySnapshot) {
          querySnapshot.docs.forEach((element) {
            //if (element.exists) {
              batch.update(element.reference, {
                MessageColumns.state: StateType.seen
              });
              var message = element.data();
              message.state = StateType.seen;
              RoomController.instance.messageBox.put(message.messageId, message);
            //}
          });
          return batch.commit();
        });
  }



  RxBool onChangeSendText(String value) {
    messageSecondState.value=textEditingController.value.text.trim().isEmpty;
    if(_messageFirstState!=messageSecondState.value) {
      _messageFirstState=messageSecondState.value;
    }
    return messageSecondState;
  }

  void sendMessage(text) async {
    //var text=textEditingController.value.text;
    var time = DateTime.now().millisecondsSinceEpoch;
    User? myUser = auth.currentUser;
    debugPrint("myUser!.uid= ${auth.currentUser!.uid}");
    var mess = Message(
      messageId: messageCollection.doc().id,
      roomId: room.roomId,
      senderId: myUser!.uid,
      senderPhone: myUser.phoneNumber,
      senderPhoto: myUser.photoURL!,
      receiverId: otherUser.uid,
      text: text,
      type: MessageType.text,
      url: '',
      localPath: '',
      time: time,);
    room.updatedAt = mess.time;
    room.lastMessageId = mess.messageId;

    RoomController.instance.messageBox.put(mess.messageId, mess);
    RoomController.instance.roomBox.put(room.roomId, room);
    RoomController.instance.sendMessageToFirestore(mess);
    textEditingController.clear();
    onChangeSendText('');
  }


  void sendMessageAudio(String filePath, String uid, Map<String, dynamic> fileInfo) {
    var time = DateTime.now().millisecondsSinceEpoch;
    User? myUser=auth.currentUser;
    var mess = Message(
      messageId: uid,
      roomId: room.roomId,
      senderId: myUser!.uid,
      senderPhone: myUser.phoneNumber,
      senderPhoto: myUser.photoURL!,
      receiverId: otherUser.uid,
      text: '', //fileInfo[MessageAudioInfoKey.duration],
      type: MessageType.audio,
      url: '',
      localPath: filePath,
      time: time,
      fileInfo: fileInfo,
    );
    room.updatedAt = mess.time;
    room.lastMessageId = mess.messageId;
    RoomController.instance.messageBox.put(mess.messageId, mess);
    RoomController.instance.roomBox.put(room.roomId, room);
    /*if(isPageShowing.value)
      animateToListViewScroll();*/
  }

  void sendMessageImage(String filePath, String uid, Map<String, dynamic> fileInfo) {
    var time = DateTime.now().millisecondsSinceEpoch;
    User? myUser=auth.currentUser;
    var mess = Message(
      messageId: uid,
      roomId: room.roomId,
      senderId: myUser!.uid,
      senderPhone: myUser.phoneNumber,
      senderPhoto: myUser.photoURL!,
      receiverId: otherUser.uid,
      text: '',
      type: MessageType.image,
      url: '',
      localPath: filePath,
      time: time,
      fileInfo: fileInfo,
    );
    room.updatedAt = mess.time;
    room.lastMessageId = mess.messageId;
    RoomController.instance.messageBox.put(mess.messageId, mess);
    RoomController.instance.roomBox.put(room.roomId, room);
  }




  void sendMessageVideo(String filePath, String uid, Map<String, dynamic> fileInfo) {
    var time = DateTime.now().millisecondsSinceEpoch;
    User? myUser=auth.currentUser;
    var mess = Message(
      messageId: uid,
      roomId: room.roomId,
      senderId: myUser!.uid,
      senderPhone: myUser.phoneNumber,
      senderPhoto: myUser.photoURL!,
      receiverId: otherUser.uid,
      text: '',
      type: MessageType.video,
      url: '',
      localPath: filePath,
      time: time,
      fileInfo: fileInfo,
    );
    room.updatedAt = mess.time;
    room.lastMessageId = mess.messageId;
    RoomController.instance.messageBox.put(mess.messageId, mess);
    RoomController.instance.roomBox.put(room.roomId, room);
  }


  /*sendMessageToFirestore(Message mess) async{
    firebaseFirestore.collection(Collections.ROOMS).doc(room.roomId).set(room.toJson());
    messageCollection.doc(mess.messageId).set(mess.toJson()).then((value) {
      mess.state=StateType.sent;
      RoomController.instance.messageBox.put(mess.messageId, mess);
    }, onError: (e){
      mess.state=StateType.wait;
      RoomController.instance.messageBox.put(mess.messageId, mess);
    });
  }*/

  void animateToListViewScroll() {
    listViewScrollController.animateTo(listViewScrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    //listViewScrollController.jumpTo(listViewScrollController.position.maxScrollExtent);
  }




  void sendMessageImageFromAnotherUser(String filePath, String uid, Map<String, dynamic> fileInfo)async {
    var time = DateTime.now().millisecondsSinceEpoch;
    UserContact? user;
    await firebaseFirestore
        .collection(Collections.USERS)
        .doc("10CfP4xhvLPcSzdb4EOPhbQ4lOM2")
        .withConverter(
        fromFirestore: (snapshot, options) => UserContact.fromJson(snapshot.data()!),
        toFirestore: (UserContact user, _)=> user.toJson())
        .get().then((value) => user=value.data());

    var mess = Message(
      messageId: uid,
      roomId: room.roomId,
      senderId: user!.uid,//10CfP4xhvLPcSzdb4EOPhbQ4lOM2
      senderPhone: user?.phone,
      senderPhoto: user!.photoURL,
      receiverId: auth.currentUser!.uid,
      text: '',
      type: MessageType.image,
      url: 'https://firebasestorage.googleapis.com/v0/b/flutter-chat-app-338817.appspot.com/o/image%2FKUP2csE0BhRoqaGXFyo1xNLjKPA2_10CfP4xhvLPcSzdb4EOPhbQ4lOM2%2Fyemen.jpg?alt=media&token=3a78b1fe-aad5-48bd-a1a6-0c2d4e452782',
      localPath: filePath,
      time: time,
      fileInfo: fileInfo,
    );
    mess.state = StateType.sent;
    room.lastMessageId = mess.messageId;
    firebaseFirestore.collection(Collections.ROOMS).doc(room.roomId).set(room.toJson());
    messageCollection.doc(mess.messageId).set(mess.toJson());
  }

  void sendMessageFromAnotherUser(text) async {
    var time = DateTime.now().millisecondsSinceEpoch;
    UserContact? anotherUser = await _getAnotherUser();
    debugPrint("myUser!.uid= ${auth.currentUser!.uid}");
    var mess = Message(
      messageId: messageCollection.doc().id,
      roomId: room.roomId,
      senderId: anotherUser!.uid,
      senderPhone: anotherUser.phone,
      senderPhoto: anotherUser.photoURL,
      receiverId: auth.currentUser!.uid,
      text: text,
      type: MessageType.text,
      url: '',
      localPath: '',
      time: time,
    );

    var roomDoc = firebaseFirestore.collection(Collections.ROOMS).doc(room.roomId);
    mess.state = StateType.sent;
    roomDoc.collection(Collections.MESSAGES)
        .doc(mess.messageId)
        .set(mess.toJson())
        .then((value) {
      roomDoc.set(room.toJson());
    });
  }


  Future<UserContact?> _getAnotherUser()async{
    var documentSnapshot = await firebaseFirestore
        .collection(Collections.USERS)
        .doc("10CfP4xhvLPcSzdb4EOPhbQ4lOM2")
        .withConverter(
        fromFirestore: (snapshot, options) => UserContact.fromJson(snapshot.data()!),
        toFirestore: (UserContact user, _)=> user.toJson()).get();

    return documentSnapshot.data();

  }

}

