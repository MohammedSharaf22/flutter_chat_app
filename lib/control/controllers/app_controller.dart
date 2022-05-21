import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


const tabIndexKey = 'tab_index';

class AppController extends GetxController {
  static AppController instance = Get.find();
  var tabIndex = 0;
  late CupertinoTabController tabController;

  List labelItems = [
    "chats".tr,
    "status".tr,
    "contacts".tr,
    "settings".tr,
  ];

  List iconItems = [
    CupertinoIcons.chat_bubble_2_fill, //chat_bubble_fill
    CupertinoIcons.circle_fill,
    CupertinoIcons.person_crop_circle_fill, //person_alt_circle_fill
    CupertinoIcons.settings_solid,
  ];

  List iconItemsOutline = [
    CupertinoIcons.chat_bubble_2, //chat_bubble
    CupertinoIcons.circle,
    CupertinoIcons.person_crop_circle, //person_alt_circle
    CupertinoIcons.settings,
  ];


  @override
  void onInit() {
    super.onInit();
    var storage = GetStorage();
    if (storage.hasData(tabIndexKey)) {
      tabIndex = storage.read(tabIndexKey);
    }
    tabController = CupertinoTabController(initialIndex: tabIndex);
  }

  void changeTabIndex(int index) {
    tabIndex = index;
    update();
    GetStorage().write(tabIndexKey, tabIndex);
  }
}