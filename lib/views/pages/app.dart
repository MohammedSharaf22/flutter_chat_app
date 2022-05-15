import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_app/control/controllers/app_controller.dart';
import 'package:flutter_chat_app/utilities/tabs.dart';
import 'package:flutter_chat_app/views/pages/chat/room/view/room_page.dart';
import 'package:flutter_chat_app/views/pages/contact/view/contacts_page.dart';
import 'package:flutter_chat_app/views/pages/setting/view/setting_page.dart';
import 'package:flutter_chat_app/views/pages/status/status_page.dart';
import 'package:get/get.dart';


class App extends GetView<AppController> {
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (_) {
      //authController.isFirstTime? getStretchedDotsLoading() :
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
            currentIndex: controller.tabIndex,
            onTap: (value) => controller.changeTabIndex(value),
            //backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
            items: Tabs.values.map((Tabs tabs) {
              return BottomNavigationBarItem(
                  //backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
                  activeIcon: Icon(controller.iconItems[tabs.index]),
                  icon: Icon(controller.iconItemsOutline[tabs.index])
              );
            }).toList()
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            builder: (context) =>pages[index]);
        },
      );
    });
  }

  final pages = [
    RoomPage(), //
    StatusPage(),
    ContactsPage(), //  UsersPage
    SettingPage(),
  ];
}
