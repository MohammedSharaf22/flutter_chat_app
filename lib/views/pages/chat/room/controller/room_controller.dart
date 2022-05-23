import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_app/control/constants/firebase_auth_constants.dart';
import 'package:flutter_chat_app/views/pages/chat/message/db_helper/message_db_helper.dart';
import 'package:flutter_chat_app/views/pages/chat/message/model/message.dart';
import 'package:flutter_chat_app/views/pages/chat/room/db_helper/room_db_helper.dart';
import 'package:flutter_chat_app/views/pages/chat/room/model/room.dart';
import 'package:flutter_chat_app/utilities/collection_enum.dart';
import 'package:flutter_chat_app/views/pages/contact/controller/contacts_controller.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user_contact.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user_model.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';



class RoomController extends GetxController{
  static RoomController instance = Get.find();
  //RxList<Chat> chatsList=<Chat>[].obs;
  //Rx<SortedMap<dynamic, Room>> roomsList=SortedMap<dynamic,Room>(comparator: (a, b) => b.value.updatedAt!.compareTo(a.value.updatedAt!)).obs;
  late Box<Room> roomBox;
  late Box<Message> messageBox;
  Function(DocumentChange<Message>)? _receiveMessages;
  String? _activeRoomId;

  RxList<FileImage?> imagesList = <FileImage?>[].obs;

  TextEditingController searchFieldController= TextEditingController();


  @override
  void onInit() {
    super.onInit();
    messageBox = Hive.box<Message>(MessageDBHelper.table);
    roomBox = Hive.box<Room>(RoomDBHelper.table);

    /*Query<Message> messageCollectionGroupWithConverter = firebaseFirestore
        .collectionGroup(Collections.MESSAGES)
        .withConverter<Message>(fromFirestore: (snapshot, _) => Message.fromJson(snapshot.data()!), toFirestore:  (Message? m, _) => m!.toJson(),);*/

    getRoomsStream();
    getMyMessageStream();
    getUserMessageStream();
  }


  @override
  void onReady() async {
    super.onReady();
    //PhotoManager.addChangeCallback()
    var assetPathList = await PhotoManager.getAssetPathList(type: RequestType.image);
    List<AssetEntity> assetList = await assetPathList[0].getAssetListRange(start: 0, end: 20);

    assetList.forEach((element) {
      element.file.then((value) => imagesList.add(FileImage(value!)));
    });
  }

  Stream<int> getUnSeanCount(String roomId) {
    //messageBox.values.where((element) => ).
    return messageBox.watch()
        .where((event) => event.value.roomId == roomId
        &&  event.value.senderId != auth.currentUser!.uid
        &&  event.value.state != StateType.seen).length.asStream();

    /*return Stream.value(
    messageBox.listenable().value.values.where((element) => element.roomId == roomId
        &&  element.senderId != auth.currentUser!.uid
        &&  element.state != StateType.seen).length);*/

  }

  getRoomsStream(){

    firebaseFirestore
        .collection(Collections.ROOMS)
        .where(RoomColumns.userIds, arrayContains: auth.currentUser!.uid)
        //.orderBy(RoomColumns.updatedAt, descending: true)
        .withConverter(fromFirestore: (snapshot, options) => Room.fromJson(snapshot.data()!), toFirestore: (Room _room, _) => _room.toJson())
        .snapshots().listen((event) {
      event.docChanges.forEach((element) {
        var _room = element.doc.data();
        if(_room != null) {

          //getUserMessageStream(element.doc.reference.collection(Collections.MESSAGES));

          if ( element.type == DocumentChangeType.added ){
            debugPrint("RoomController:____add_room_____");
            roomBox.put(_room.roomId, _room);
            firebaseFirestore
                .collection(Collections.USERS)
                .doc(_room.userIds.firstWhere((element) => element!=auth.currentUser!.uid))
                .snapshots()
                .listen((eventUser) {
                  var userContact = UserContact.fromJson(eventUser.data()!);
                  if(ContactsController.instance.contactsBox.containsKey(userContact.uid)){
                    userContact.name = ContactsController.instance.contactsBox.get(userContact.uid)!.name;
                    ContactsController.instance.contactsBox.put(userContact.uid, userContact);
                  }
                  else{
                    userContact.name = userContact.phone;
                    ContactsController.instance.userModelBox.put(userContact.uid, UserModel.fromJson(userContact.toJson()));
                  }
                },
            );
          }
          else if (element.type == DocumentChangeType.modified){
            debugPrint("RoomController:____modified_room_____");
            roomBox.put(_room.roomId, _room);
          }
        }
      });
    });
  }

  getMyMessageStream(){
    firebaseFirestore
        .collectionGroup(Collections.MESSAGES)
        .where(MessageColumns.senderId, isEqualTo: auth.currentUser!.uid)
        .withConverter<Message>(fromFirestore: (snapshot, _) => Message.fromJson(snapshot.data()!), toFirestore:  (Message? m, _) => m!.toJson(),)
        .snapshots().listen((event) {
      event.docChanges.forEach((element) {
        var _message = element.doc.data();
        if(_message == null) return;
        if (element.type == DocumentChangeType.added) {

        }
        else if(element.type == DocumentChangeType.modified) {
          if(_message.senderId == auth.currentUser!.uid){
            debugPrint("RoomController:____modified_message_____");
            if(_message.state == StateType.seen) {

              debugPrint("RoomController:____modified_message_____ delete seen");
              element.doc.reference.delete();

              if(_message.type == MessageType.audio
                  || _message.type == MessageType.image
                  ||  _message.type == MessageType.image) {

                if(_message.url != null && _message.url!.isNotEmpty)
                  firebaseStorage.refFromURL(_message.url!).delete().then((value) {
                    debugPrint("Successful: delete seen File from firebaseStorage");
                  }).catchError((e, stackTrace) {
                    debugPrint("Failed: Error delete seen File from firebaseStorage -> $e");
                    debugPrintStack(stackTrace: stackTrace);
                  });
              }
            }
            messageBox.put(_message.messageId, _message);
          }
        }
      });
    });
  }

  getUserMessageStream() {
    firebaseFirestore
        .collectionGroup(Collections.MESSAGES)
        .where(MessageColumns.receiverId, isEqualTo: auth.currentUser!.uid)
        .withConverter<Message>(fromFirestore: (snapshot, _) => Message.fromJson(snapshot.data()!), toFirestore:  (Message? m, _) => m!.toJson(),)
        .snapshots().listen((event) {
      event.docChanges.forEach((element) {
        var _message = element.doc.data();
        if(_message == null) return;

        if (element.type == DocumentChangeType.added) {
          if (_message.senderId != auth.currentUser!.uid
              && _message.state != StateType.seen) {
            if (_receiveMessages != null && _message.roomId == _activeRoomId) {
              _receiveMessages?.call(element);
            }
            else{
              debugPrint("RoomController:____add_message_____delivered");
              _message.state = StateType.delivered;
              messageBox.put(_message.messageId, _message);
              element.doc.reference.update({
                MessageColumns.state: StateType.delivered
              });
            }
          }
        }
        else if(element.type == DocumentChangeType.modified) {

        }
      });
    });
  }


  void deleteRoom(String roomId){
    messageBox.values.forEach((element) {
      if (element.roomId == roomId) {
        messageBox.delete(element.messageId);
      }
    });
    roomBox.delete(roomId);
    var documentReference = firebaseFirestore.collection(Collections.ROOMS).doc(roomId);
    documentReference.collection(Collections.MESSAGES)
        .get()
        .then((value) {
          if(value.size < 1){
            documentReference.collection(Collections.MESSAGES).get().then((value) {
              value.docs.forEach((element) {
                documentReference.collection(Collections.MESSAGES).doc(element.id).delete();
              });
            }).then((value) => documentReference.delete());
          }
    });
    //deleteRoomResources(FileMediaType.audio, roomId);
    //deleteRoomResources(FileMediaType.image, roomId);
    //deleteRoomResources(FileMediaType.video, roomId);
    /*update();*/
  }

  Room findOrCreateRoomByUserId(userId){
    var meToOther = "${auth.currentUser!.uid}_$userId";
    var otherToMe = "${userId}_${auth.currentUser!.uid}";

    return roomBox.get(meToOther,
        defaultValue: roomBox.get(
          otherToMe,
          defaultValue: Room(
            roomId: meToOther,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            imageUrl: null,
            metadata: null,
            name: null,
            type: RoomType.CHAT,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
            userIds: [auth.currentUser!.uid, userId],
            lastMessageId: '',
          ),
        ),
    )!;
  }

  /*Room _createAndGetNewRoom(roomId, userId){
    var room = Room(
      roomId,
      DateTime.now().millisecondsSinceEpoch,
      null, null, null,
      RoomType.CHAT,
      DateTime.now().millisecondsSinceEpoch,
      [auth.currentUser!.uid, userId], '',
    );
    roomBox.put(room.roomId, room);
    return room;
  }*/

  void setReceiveMessages(String activeRoomId, Function(DocumentChange<Message>) receiveMessages){
    _activeRoomId = activeRoomId;
    _receiveMessages = receiveMessages;
  }

  disableReceiveMessages(){
    _receiveMessages = null;
    _activeRoomId = null;
  }

  sendMessageToFirestore(Message mess) async{
    Room room = roomBox.get(mess.roomId)!;
    var roomDoc = firebaseFirestore.collection(Collections.ROOMS).doc(room.roomId);

    var json = mess.toJson();
    json[MessageColumns.state] = StateType.sent;

    roomDoc.collection(Collections.MESSAGES)
        .doc(mess.messageId)
        .set(json)
        .then((value) {
          roomDoc.set(room.toJson());
          mess.state = StateType.sent;
          messageBox.put(mess.messageId, mess);
          roomBox.put(room.roomId, room);
    }, onError: (e){
      mess.state = StateType.wait;
      messageBox.put(mess.messageId, mess);
    });
  }






  void sendMessageFromAnotherUser(text, Room room, String anotherUserId) async {
    var id = firebaseFirestore.collection(Collections.ROOMS)
        .doc(room.roomId).collection(Collections.MESSAGES).doc().id;

    var time = DateTime.now().millisecondsSinceEpoch;
    User? anotherUser = await _getAnotherUser(anotherUserId);
    debugPrint("myUser!.uid= ${auth.currentUser!.uid}");
    var mess = Message(
      messageId: id,
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

    room.lastMessageId = mess.messageId;
    room.updatedAt = time;

    var roomDoc = firebaseFirestore.collection(Collections.ROOMS).doc(room.roomId);
    mess.state = StateType.sent;
    roomDoc.collection(Collections.MESSAGES)
        .doc(mess.messageId)
        .set(mess.toJson())
        .then((value) {
      debugPrint("Send Success!");
      roomDoc.set(room.toJson());
    });
  }

  Future<User?>? _getAnotherUser(userId) async{
    var _contactBox = ContactsController.instance.contactsBox;
    var _userModelBox = ContactsController.instance.userModelBox;
    if (_contactBox.containsKey(userId)) {
      return _contactBox.get(userId);
    }
    else if (_userModelBox.containsKey(userId)){
      return _userModelBox.get(userId);
    }
    else{
      var documentSnapshot = await firebaseFirestore
          .collection(Collections.USERS)
          .doc(userId)//10CfP4xhvLPcSzdb4EOPhbQ4lOM2
          .withConverter(
          fromFirestore: (snapshot, options) => UserContact.fromJson(snapshot.data()!),
          toFirestore: (UserContact user, _)=> user.toJson()).get();
      return documentSnapshot.data();
    }
  }
}


