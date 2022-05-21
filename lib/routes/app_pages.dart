import 'package:flutter_chat_app/views/pages/contact/controller/contacts_controller.dart';
import 'package:flutter_chat_app/views/pages/setting/controller/settings_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/view/message_page.dart';
import 'package:flutter_chat_app/views/pages/chat/room/view/room_page.dart';
import 'package:flutter_chat_app/views/pages/contact/view/contacts_page.dart';
import 'package:flutter_chat_app/views/pages/setting/view/setting_page.dart';
import 'package:flutter_chat_app/views/pages/status/view/status_page.dart';
import 'package:flutter_chat_app/views/splash_ui.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashUI(),
    ),
    GetPage(
      name: Routes.CHAT,
      page: () => RoomPage(),
      /*binding: ,*/
      children: [
        //GetPage(name: Routes.CHAT_DETAIL, page: ()=> ChatDetailPage(),)
      ]
    ),

    GetPage(
      name: Routes.STATUS,
      page: () => StatusPage(),
    ),
    GetPage(
      name: Routes.CONTACTS,
      page: () => ContactsPage(),
      binding: BindingsBuilder(() => Get.put<ContactsController>(ContactsController()),),
    ),
    GetPage(
      name: Routes.SETTING,
      page: () => SettingPage(),
      binding: BindingsBuilder(() => Get.put<SettingsController>(SettingsController()),),
    ),
  ];
}
