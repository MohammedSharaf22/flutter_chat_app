import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/main.dart';
import 'package:flutter_chat_app/utilities/collection_enum.dart';
import 'package:flutter_chat_app/views/pages/app.dart';
import 'package:flutter_chat_app/views/pages/chat/message/controller/message_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/room/controller/room_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/room/db_helper/room_db_helper.dart';
import 'package:flutter_chat_app/views/pages/contact/controller/contacts_controller.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user_contact.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user_model.dart';
import 'package:flutter_chat_app/views/register_page/profile_page.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_chat_app/control/bindings/app_binding.dart';
import 'package:flutter_chat_app/control/constants/firebase_auth_constants.dart';
import 'package:flutter_chat_app/views/register_page/otp_page.dart';
import 'package:flutter_chat_app/views/register_page/welcome_page.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_form_field/phone_form_field.dart';



class AuthController extends GetxController with GetSingleTickerProviderStateMixin {
  static AuthController instance = Get.find();
  late Rx<User?> firebaseUser;
  late PhoneNumber phoneNumber /*= PhoneNumber(isoCode: "YE", nsn: '736284642')*/;
  String verificationId = '';
  bool isLoading = false;
  late UserModel userModel;
  late PhoneController phoneController;
  String otp="";
  /*late TextEditingController phoneController;
  late TextEditingController countryCodeController;*/


  @override
  void onInit() async {
    super.onInit();

    //phoneNumber = PhoneNumber(isoCode: WidgetsBinding.instance!.window.locale.countryCode!, nsn: '');
    phoneNumber = PhoneNumber(isoCode: 'YE', nsn: '736284642');
  }

  Future<bool> getStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.storage.request().isDenied) {
      await openAppSettings();
    }
    return false;
  }

  Future<bool> getContactsPermission() async {
    if (await Permission.contacts.request().isGranted) {
      return true;
    } else if (await Permission.contacts.request().isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.contacts.request().isDenied) {
      await openAppSettings();
    }
    return false;
  }


  onChangeNumber(phone) {
    phoneNumber = phone;/*PhoneNumber(isoCode: myCountry.isoCode, nsn: nsn)*/
    update();
  }

  onChangeOtp(otp) {
    this.otp=otp;
    update();
  }



  void showLoading() {
    isLoading = true;
  }

  void hideLoading() {
    isLoading = false;
  }

  void closeLoading() {
    hideLoading();
    update();
  }


  @override
  void onReady() {
    super.onReady();
    userModel = UserModel("", "", "", "", "");
    firebaseUser = Rx<User?>(auth.currentUser);

    firebaseUser.bindStream(auth.userChanges());
    //signOut();
    ever(firebaseUser, _setInitialScreen);
  }


  _setInitialScreen(User? user) {

    if (user == null) {
      Get.offAll(() => WelcomePage(),);
    } else {
      //Get.offAll(() => RootApp(), binding: RootBinding());
      if (GetStorage().read('otp_is_done') == '1' && GetStorage().read('profile_is_done') == '1') {
        print("offAll App");
        Get.offAll(() => App(), binding: AppBinding());
      }
      else if (GetStorage().read('otp_is_done') == '1' && !GetStorage().hasData('profile_is_done')) {
        Get.offAll(() => ProfilePage(), /*binding: BindingsBuilder(()=> Get.lazyPut<ContactsController>(()=>ContactsController()))*/);
        hideLoading();
        update();
      }
    }
  }

  void verifyPhoneNumber(String phone) async {
    try {
      showLoading();
      update();
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            debugPrint('The provided phone number is not valid.= $e');

          }
        },
        codeSent: (String _verificationId, int? resendToken) {
          verificationId = _verificationId;
          Timer.periodic(Duration(seconds: 1), (timer) {
            Get.to(() => OtpPage());
            hideLoading();
            update();
            timer.cancel();
          });
        },
        codeAutoRetrievalTimeout: (String _verificationId) {
          verificationId = _verificationId;
          Timer.periodic(Duration(seconds: 1), (timer) {
            hideLoading();
            update();
            timer.cancel();
          });
        },
      );
    } catch (firebaseAuthException) {
      hideLoading();
      update();
    }
  }

  void signInWithPhoneNumber(String otp) async {
    try {
      showLoading();
      update();
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await auth.signInWithCredential(credential);
      /*await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          id: userCredential.user!.uid, // UID from Firebase Authentication
        ),
      );*/
      //final User? user = signInUser.user;
      //Get.snackbar('',"Sign in Successfully, User UID ${user!.displayName}");
      GetStorage().write('otp_is_done', '1');
      Get.offAll(() => ProfilePage(), /*binding: BindingsBuilder(()=> Get.lazyPut<ContactsController>(() =>ContactsController()))*/);
      hideLoading();
      update();
    } catch (e) {
      hideLoading();
      update();
      Get.snackbar('', 'Error Occured: $e');
    }
  }

  Future<void> uploadPhoto(String path) async {
    try {
      //isLoadingPhoto = true;
      File file = File(path);

      try {
        UploadTask uploadTask = firebaseStorage.ref('profilePhoto/').child(
            "${firebaseUser.value!.phoneNumber.toString()}.jpg")
            .putFile(file,
            SettableMetadata(customMetadata: {
              'uploaded_by': '${firebaseUser.value?.phoneNumber}',
            }));

        userModel.photoURL = await (await uploadTask).ref.getDownloadURL();
        print('event.ref.getDownloadURL() =  ${userModel.photoURL}');
        //isLoadingPhoto = false;
      } on FirebaseException catch (error) {
        if (kDebugMode) print(error);
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  void setProfileData(name, about) async {
    showLoading();
    update();
    userModel.about = about;
    var user = firebaseUser.value!;
    user.updateDisplayName(userModel.name = name);
    user.updatePhotoURL(userModel.photoURL);
    userModel.phone = user.phoneNumber!;
    userModel.uid = user.uid;
    /*await FirebaseChatCore.instance.createUserInFirestore(
      types.User(
        firstName: userModel.name,
        id: userModel.uid, // UID from Firebase Authentication
        imageUrl: userModel.photoURL,
        metadata: {'phone': userModel.phone},
      ),
    );*/
    await firebaseFirestore.collection('user').doc(userModel.uid).set(userModel.toJson());
    GetStorage().write('profile_is_done', '1');
    /*await firebaseFirestore.collection('user')
        .where('uid', isEqualTo: user.uid).limit(1).get()
        .then((value) {
      if (value.docs.isEmpty)
        firebaseFirestore.collection('user').doc(userModel.uid).set(
            userModel.toJson());
      else {
        value.docs.first.reference.update(userModel.toJson());
      }
    }).whenComplete(() {
      GetStorage().write('profile_is_done', '1');
      //isFirstTime=true;
      //GetStorage().write('is_first_time', '1');
      //hideLoading();
      *//*
      update();*//*
      //Get.offAll(() => App(), binding: RootBinding());
    }).catchError((error) {
      hideLoading();
      update();
      print("setProfileData= $error");
    });*/
  }

  Future<dynamic> getUserPhoto() async {
    var phone = firebaseUser.value!.phoneNumber.toString();
    String url="";
    try{
      url = await firebaseStorage.ref('profilePhoto/$phone.jpg')
          .getDownloadURL();
    }catch(e){}


    if(url.isEmpty)
      url = await firebaseStorage.ref('profilePhoto/profile_placeholder.jpg').getDownloadURL();
    print("url $url");
    userModel.photoURL = url;
    print('userModel.photoURL =  ${userModel.photoURL}');
    return url;
  }


  Future<Map<String, dynamic>> getUserName() async {
    var usr = await firebaseFirestore.collection(Collections.USERS).where(
        'uid', isEqualTo: firebaseUser.value!.uid).get();
    return usr.docs[0].data();
  }

  void signOut() async {
    RoomController.instance.roomBox.clear();
    ContactsController.instance.userModelBox.clear();
    ContactsController.instance.contactsBox.clear();
    RoomController.instance.messageBox.clear();
    GetStorage().remove('profile_is_done');
    GetStorage().remove('otp_is_done');
    //await UserModelDBHelper.instance.deleteDB();
    auth.signOut();
  }

}

