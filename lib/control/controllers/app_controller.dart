import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/control/constants/firebase_auth_constants.dart';
import 'package:flutter_chat_app/utilities/tabs.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppController extends GetxController with GetSingleTickerProviderStateMixin {
  static AppController instance = Get.find();
  late List textItems ;
  var tabIndex=0;
  late TabController tabController;

  List iconItems = [
    CupertinoIcons.chat_bubble_fill,
    CupertinoIcons.circle_fill,
    CupertinoIcons.person_alt_circle_fill,
    CupertinoIcons.settings,
  ];

  List iconItemsOutline = [
    CupertinoIcons.chat_bubble,
    CupertinoIcons.circle,
    CupertinoIcons.person_alt_circle,
    CupertinoIcons.settings,
  ];


  @override
  void onInit() {
    super.onInit();

    /*tabController = TabController(
      initialIndex: tabIndex=0,
      length: Tabs.values.length,
      vsync: this,
    );
    tabController.addListener(() => changeTabIndex(tabController.index));*/
    //print("tabController index= ${tabController.index},  _controller index= $tabIndex");

    textItems = ["status".tr, "calls".tr, "camera".tr, "chats".tr, "settings".tr];
    //PresenceService

  }

  void changeTabIndex(int index) {
    tabIndex = index;
    update();
  }
   @override
  void onClose() {
    super.onClose();
  }
}