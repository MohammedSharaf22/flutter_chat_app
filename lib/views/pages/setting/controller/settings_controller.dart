import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/control/controllers/auth_controller.dart';
import 'package:flutter_chat_app/utilities/files.dart';
import 'package:flutter_chat_app/utilities/widgets/setting_item.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class SettingsController extends GetxController {
  AuthController authController = Get.find();
  late List<SettingItem> listSettingsSectionOne;
  late List<SettingItem> listSettingsSectionTwo;


  @override
  void onInit() {
    listSettingsSectionOne=[
      SettingItem(title: "saved_messages".tr, leadingIcon: Ionicons.bookmark, bgIconColor: Colors.blue,
        onTap: (){
          Get.snackbar("title", "message");
        },
      ),
      SettingItem(title: "recent_calls".tr, leadingIcon: Ionicons.call, bgIconColor: Colors.green,
        onTap: (){
        },
      ),
      SettingItem(title: "devices".tr, leadingIcon: Icons.devices, bgIconColor: Colors.orange,
        onTap: (){
        },
      ),
      SettingItem(title: "chat_folders".tr, leadingIcon: Icons.folder_open_outlined, bgIconColor: Colors.lightBlue.shade300, isLast: true,
        onTap: (){
        },
      ),
      /*SettingItem(title: "notifi_and_sounds".tr, leadingIcon: Icons.notifications_on_outlined, bgIconColor: Colors.red,
          onTap: (){

          }
      ),*/
    ];

    listSettingsSectionTwo=[
      SettingItem(title: "notifi_and_sounds".tr, leadingIcon: Icons.notifications_on_outlined, bgIconColor: Colors.red,
          onTap: (){

          }
      ),
      SettingItem(title: "privacy_and_security".tr, leadingIcon: Icons.lock_outline, bgIconColor: Colors.grey,
          onTap: (){
          }
      ),
      SettingItem(title: "data_and_storage".tr, leadingIcon: Icons.storage_outlined, bgIconColor: Colors.lightGreen,
          onTap: (){
          }
      ),

      SettingItem(title: "appearance".tr, leadingIcon: Icons.dark_mode_outlined, bgIconColor: Colors.lightBlue,isLast: true,
          onTap: (){
          }
      ),
    ];
    super.onInit();

  }
  @override
  void onReady() {
    super.onReady();
  }

  getUserProfilePhoto() {
    return fileFromDocsDir('myProfilePhoto.jpg');
  }

  String getUsername(){
    return authController.firebaseUser.value!.displayName.toString();
  }

  void signOut(){
    authController.signOut();
  }
}