import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_app/control/controllers/app_controller.dart';
import 'package:flutter_chat_app/utilities/tabs.dart';
import 'package:flutter_chat_app/utilities/theme/my_theme.dart';
import 'package:flutter_chat_app/views/pages/chat/room/view/room_page.dart';
import 'package:flutter_chat_app/views/pages/contact/view/contacts_page.dart';
import 'package:flutter_chat_app/views/pages/setting/view/setting_page.dart';
import 'package:flutter_chat_app/views/pages/status/view/status_page.dart';
import 'package:get/get.dart';


class App extends GetView<AppController> {
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (_) {
      return CupertinoTabScaffold(
        controller: controller.tabController,
        tabBar: CupertinoTabBar(
          inactiveColor: iconDynamicColor.withOpacity(.8),
          iconSize: 24,
          onTap: (value) => controller.changeTabIndex(value),
          items: Tabs.values.map((Tabs tabs) {
            return BottomNavigationBarItem(
              label: controller.labelItems[tabs.index],
              activeIcon: Icon(controller.iconItems[tabs.index]),
              icon: Icon(controller.iconItemsOutline[tabs.index]),
            );
          }).toList(),
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            builder: (context) => pages[index],
          );
        },
      );
    });
  }

  final pages = [
    RoomPage(), //
    StatusPage(),
    ContactsPage(),
    SettingPage(),
  ];
}
