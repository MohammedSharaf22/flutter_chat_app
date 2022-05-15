import 'package:flutter_chat_app/views/pages/chat/room/controller/room_controller.dart';
import 'package:flutter_chat_app/views/pages/contact/controller/contacts_controller.dart';
import 'package:flutter_chat_app/control/controllers/app_controller.dart';
import 'package:flutter_chat_app/views/pages/setting/controller/settings_controller.dart';
import 'package:get/get.dart';

class AppBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<AppController>(AppController());
    Get.put<ContactsController>(ContactsController());
    Get.put<SettingsController>(SettingsController());
    Get.put<RoomController>(RoomController());
  }

}