
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/control/constants/firebase_auth_constants.dart';
import 'package:flutter_chat_app/utilities/theme/my_theme.dart';
import 'package:flutter_chat_app/views/pages/chat/message/view/temp/TempPage.dart';
import 'package:flutter_chat_app/views/pages/chat/room/controller/room_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/room/model/room.dart';
import 'package:flutter_chat_app/views/pages/chat/room/view/room_item.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:ionicons/ionicons.dart';


class RoomPage extends GetView<RoomController> {
  const RoomPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus)
          currentFocus.unfocus();
      },
      child: CupertinoPageScaffold(
        child: NestedScrollView(
          controller: ScrollController(),//PageScrollPhysics
          physics: const NeverScrollableScrollPhysics(),//NeverScrollableScrollPhysics
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [ //CupertinoSliverRefreshControl()
              CupertinoSliverNavigationBar(
                stretch: true,
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text("edit".tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Get.to(()=> TempPage());
                  },
                ),
                middle: Text("chats".tr),
                border: Border.all(color: Colors.transparent),
                largeTitle: Container(width: double.infinity, height: 38,
                  padding: EdgeInsetsDirectional.only(end: 15, /*top: 5,*/),
                  child: CupertinoSearchTextField(
                    backgroundColor: fieldBackgroundColor,
                    padding: EdgeInsetsDirectional.only(start: 5),
                    prefixInsets: EdgeInsetsDirectional.only(start: 5),
                    placeholder: "search".tr,
                    style: TextStyle(fontSize: 14,),
                    controller: controller.searchFieldController,
                    onSubmitted: (value){

                    },
                    suffixIcon: Icon(CupertinoIcons.arrow_up),
                    onSuffixTap: (){
                      var anotherId = "10CfP4xhvLPcSzdb4EOPhbQ4lOM2";
                      var room = controller.roomBox.values
                          .firstWhere((element) {
                        return element.userIds.contains(anotherId)
                            && element.userIds.contains(auth.currentUser?.uid);
                      });
                      var text = controller.searchFieldController.value.text.trim();
                      if (text.isNotEmpty) {
                        controller.sendMessageFromAnotherUser(text, room, anotherId);
                      }
                    },
                  ),
                ),
                trailing: CupertinoButton(
                  onPressed: () {
                    //Get.to(()=>TempPage2());
                  },
                  padding: EdgeInsets.zero,
                  child: Icon(Ionicons
                      .create_outline, /*color: MyColors.primaryColorLight,*/),
                ),
              ),
            ];
          },
          body: SafeArea(
            child: Theme(
              data: ThemeData(
                brightness: CupertinoTheme.brightnessOf(context),
                primaryColor: CupertinoTheme
                    .of(context)
                    .primaryColor,
                scaffoldBackgroundColor: CupertinoTheme
                    .of(context)
                    .scaffoldBackgroundColor,
                textTheme: TextTheme(
                  labelMedium: TextStyle(color: CupertinoTheme
                      .of(context)
                      .textTheme
                      .textStyle
                      .color),
                  labelSmall: TextStyle(color: CupertinoTheme
                      .of(context)
                      .textTheme
                      .textStyle
                      .color!
                      .withOpacity(0.6)),
                ),
              ),
              child: GetBuilder<RoomController>(
                  builder: (_) {
                    return Scaffold(
                      body: getBody(context),
                    );
                  },
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget getBody(context) {
    //var size = MediaQuery.of(context).size;
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 15, left: 15,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text("broadcast_lists".tr,
                        style: TextStyle(color: CupertinoTheme
                            .of(context)
                            .primaryColor)),
                    onPressed: () {},
                  ),
                  CupertinoButton(
                    child: Text(
                        "new_group".tr,
                        style: TextStyle(color: CupertinoTheme
                            .of(context)
                            .primaryColor)),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
          child: Divider(color: CupertinoColors.separator, thickness: 3.5),
        ),
        SizedBox(
          height: 10,
        ),
        ValueListenableBuilder<Box<Room>>(
          valueListenable: controller.roomBox.listenable(),
          builder: (context, Box<Room> box, _) {
            var list = box.values.toList();
            list.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));

            debugPrint("box.length= ${box.length}");

            return ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: box.length,
              itemBuilder: (context, index) {
                //var room = box.getAt(index)!;
                var room = list[index];

                // var unSeanCount = controller.messageBox.values
                //     .where((element) =>
                // element.roomId == room.roomId &&
                //     element.senderId != auth.currentUser!.uid &&
                //     (element.state == StateType.delivered ||
                //         element.state == StateType.sent)).length;
                //print("box.length= ${box.length}");
                //print("unSeanCount= $unSeanCount");
                return RoomItem(room: room);
              },
            );
          },
        ),
        /*Obx(() {
          return ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: controller.roomsList.value.length,
            itemBuilder: (context, index) {
              print("Obx => ListView = ${controller.roomsList.value.values.elementAt(index)}");
              Room room = controller.roomsList.value.values.elementAt(index);
              // var unSeanCount = controller.messageBox.values
              //     .where((element) =>
              // element.roomId == room.roomId &&
              //     element.senderId != auth.currentUser!.uid &&
              //     (element.state == StateType.delivered ||
              //         element.state == StateType.sent)).length;
              //print("box.length= ${box.length}");
              //print("unSeanCount= $unSeanCount");
              return RoomItem(room: room);
            },
          );
        },)*/
      ],
    );
  }

}