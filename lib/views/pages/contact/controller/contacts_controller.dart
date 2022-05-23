import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/control/constants/firebase_auth_constants.dart';
import 'package:flutter_chat_app/main.dart';
import 'package:flutter_chat_app/utilities/collection_enum.dart';
import 'package:flutter_chat_app/views/pages/chat/room/controller/room_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/room/model/room.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user_contact.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user_model.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';


class ContactsController extends GetxController{
  static ContactsController instance = Get.find();
  late List<Contact> _contacts;
  //Registered contacts
  //late RxList<UserContact> registeredContactsList = <UserContact>[].obs;
  //Unregistered contacts
  late RxList<UnregisteredUserContact> unregisteredContactsList=<UnregisteredUserContact>[].obs;
  late List<UnregisteredUserContact> _allContactsList=[];
  late Box<UserContact> contactsBox;
  late Box<UserModel> userModelBox;


  @override
  void onInit() async {
    super.onInit();

    //if(GetStorage().read('first_get')== null) {
    //var list=await UserModelDBHelper.instance.queryAllUsers();
    //registeredContactsList=RxList.of(list);
    userModelBox = getUserModelBox();
    contactsBox = getUserContactsBox();
    await getContact();

    FlutterContacts.addListener(() async {
      await getContact();
    });
    //unregisteredContactsList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),);
    //registeredContactsList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),);
  }

  Future<void> getContact() async {
    if (await FlutterContacts.requestPermission()) {
      _contacts = await FlutterContacts.getContacts(sorted: true,
          withProperties: true, );
      await extractContact();
      uploadContactToFirestore();
    }
  }

  Future<void> extractContact()async {
    _allContactsList.clear();
    _contacts.forEach((element) {
      element.phones.forEach((e) {
        if(e.number.isNotEmpty)
          _allContactsList.add(UnregisteredUserContact(element.displayName, e.number.replaceAll(' ', '')));
      });
    });
    var myPhone=auth.currentUser!.phoneNumber!.replaceAll(' ', '');
    _allContactsList.removeWhere((element) => element.phone==myPhone);
  }

  Future<void> uploadContactToFirestore()async {
    //registeredContactsList.clear();
    unregisteredContactsList.clear();

    _allContactsList.forEach((element)  async {
      var stream = firebaseFirestore.collection(Collections.USERS)
          .where('phone', isEqualTo: element.phone)
          .withConverter(
            fromFirestore: (snapshot, options) => UserContact.fromJson(snapshot.data()!),
            toFirestore: (UserContact user, _)=> user.toJson())
          .snapshots();

      stream.listen((event) {
        event.docChanges.forEach((e) {
          var user=e.doc.data();
          if (user!= null) {
            if (e.type == DocumentChangeType.modified) {
              user.name=element.name;
              contactsBox.put(e.doc.id, user);
            } else if (e.type == DocumentChangeType.added) {
              user.name=element.name;
              contactsBox.put(e.doc.id, user);
            }
          }
        });
      });
      /*stream.forEach((value) {
        if(value.docs.isNotEmpty) {
          var user=value.docs[0].data();
          user.name=element.name;
          //print("change");
          if (!box.containsKey(user.uid))
            box.put(user.uid, user);
          //registeredContactsList.addOrUpdate(user);
          //print("length = ${registeredContactsList.length}");
          //getMyUserDocRef().collection(Collection.CONTACTS).doc(value.docs[0].id).set(user.toJson());
          //UserModelDBHelper.instance.insert(user);
        } else {
          unregisteredContactsList.add(UnregisteredUserContact(element.name, element.phone));
        }
      });*/
    });

  }

  DocumentReference getMyUserDocRef()=> firebaseFirestore.collection(Collections.USERS)
      .doc(auth.currentUser!.uid);

  Room getRoomByUserId(uid){
    return RoomController.instance.findOrCreateRoomByUserId(uid);
  }
}


extension Moed on List{
  void addOrUpdate(UserContact item){
    bool exist=false;
    int index=0;
    for(int i=0; i<length; i++) {
      debugPrint("change___ i= $i");
      if(this[i].uid==item.uid) {
        exist=true;
        index=i;
        break;
      }
    }

    if (exist) {
      debugPrint("change___Update in index= $index");
      //this.insert(index, item);
      this[index]=item;
    } else {
      debugPrint("change___add");
      add(item);
    }
  }
}



class UnregisteredUserContact{
  String name;
  String phone;
  UnregisteredUserContact(this.name, this.phone,);
}