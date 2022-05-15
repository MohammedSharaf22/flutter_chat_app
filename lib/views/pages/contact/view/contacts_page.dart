import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bottom_box/message_field_box_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bubble/controller/bubble_audio_message_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/controller/message_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bubble/controller/bubble_image_message_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bubble/controller/bubble_video_message_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/room/controller/room_controller.dart';
import 'package:flutter_chat_app/views/pages/contact/controller/contacts_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/view/message_page.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user_contact.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ContactsPage extends GetView<ContactsController> {
  final RefreshController _refreshController = RefreshController(
      initialRefresh: false);

  ContactsPage({Key? key}) : super(key: key);

  //final ContactsController controller = Get.find();


  @override
  Widget build(BuildContext context) {
    /*SmartRefresher(
      controller: _refreshController,
      enablePullUp: false,
      enablePullDown: true,
      //physics: BouncingScrollPhysics(),
      header: WaterDropMaterialHeader(),
      onRefresh: () async {
        await Future.delayed(Duration(milliseconds: 1000));
        await controller.getContact();
        _refreshController.refreshCompleted();
      },
      child: ,
    )*/
    return CupertinoPageScaffold(
      child: NestedScrollView(
        controller: ScrollController(),//PageScrollPhysics
        physics: const NeverScrollableScrollPhysics(),//NeverScrollableScrollPhysics
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            CupertinoSliverNavigationBar(
              //padding: EdgeInsetsDirectional.zero,
              backgroundColor: CupertinoTheme
                  .of(context)
                  .scaffoldBackgroundColor,
              stretch: true,
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text("edit".tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,),),
                onPressed: () {},
              ),
              middle: Text("contacts".tr),
              //border: Border.all(color: CColors.transparent),
              largeTitle: Container(width: double.infinity, height: 38,
                padding: EdgeInsetsDirectional.only(end: 10, top: 5),
                child: CupertinoSearchTextField(
                  padding: EdgeInsetsDirectional.only(start: 5),
                  prefixInsets: EdgeInsetsDirectional.only(start: 5),
                  placeholder: "search".tr,
                  style: TextStyle(fontSize: 14,),
                ),
              ),
              trailing: CupertinoButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                child: Icon(Ionicons.create_outline),
              ),
            ),
          ];
        },
        body: GetBuilder<ContactsController>(
          builder: (_) {
            return SafeArea(
              child: Theme(
                data: ThemeData(
                  brightness: CupertinoTheme.brightnessOf(context),
                  primaryColor: CupertinoTheme.of(context).primaryColor,
                  scaffoldBackgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
                ),
                child: Scaffold(
                  backgroundColor: CupertinoTheme
                      .of(context)
                      .scaffoldBackgroundColor,
                  body: SmartRefresher(
                    controller: _refreshController,
                    enablePullUp: false,
                    enablePullDown: true,
                    physics: PageScrollPhysics(),
                    header: WaterDropHeader(),
                    onRefresh: () async {
                      debugPrint("onRefresh");
                      await Future.delayed(Duration(milliseconds: 1000));
                      await controller.getContact();
                      _refreshController.refreshCompleted();
                    },
                    child: Column(
                      children: [
                        getBody(context),
                        Divider(height: 40,thickness: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CupertinoButton(
                              child: Text("invitation", style: TextStyle(color: Colors.blue),),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget getBody(context) {
    return ValueListenableBuilder(
        valueListenable: controller.contactsBox.listenable(),
      builder: (context,  Box<UserContact> box, _) {
          return ListView.separated(
            shrinkWrap: true,
            physics: PageScrollPhysics(),
            itemCount: box.length,
            separatorBuilder: (BuildContext context, int index) =>
                Divider(color: CupertinoColors.separator.darkColor, endIndent: 10, indent: 80),
            itemBuilder: (BuildContext c, int index) {
              UserContact userContact=box.getAt(index)!;
              return InkWell(
                child: ListTile(
                  leading: CircularProfileAvatar(//NetworkToFileImage
                    userContact.photoURL,
                    imageFit: BoxFit.cover,
                    radius: 29,
                    onTap:  (){
                      Get.snackbar("title", "message");
                    },
                    /*backgroundColor: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
                      initialsText: Text(userContact.name!.substring(0, 1),
                          style: TextStyle(fontSize: 20, color: CupertinoColors.white))*/
                  ),
                  title: Text(userContact.name!),
                  subtitle: Text(userContact.phone),
                ),
                onTap: () {
                  var room=RoomController.instance.findOrCreateRoomByUserId(userContact.uid);
                  Get.to(() => MessagePage(userContact: userContact, room: room),
                    binding: BindingsBuilder(() {
                      Get.put(MessageController(), tag: room.roomId);
                      Get.put(MessageFieldBoxController());
                      Get.create(() => BubbleAudioMessageController());
                      Get.create(() => BubbleImageMessageController());
                      Get.create(() => BubbleVideoMessageController());
                    }),
                    arguments: {"userContact":  userContact, "room": room},
                  );
                },
              );
            },
          );
      }
    );
    /*return Obx(() =>
        ,
    );*/
  }
}

/*return ListView(children: [
      Column(
        children: controller.registeredContactsList.map((e) {
          return Column(
            children: [
              InkWell(
                child: ListTile(
                  //NetworkToFileImage
                  leading: CircularProfileAvatar(
                    e.photoURL!,
                    imageFit: BoxFit.cover,
                    radius: 25,
                    backgroundColor: Color((math.Random().nextDouble() *
                        0xFFFFFF).toInt()).withOpacity(1.0),
                    initialsText: Text(
                      e.name!.substring(0, 1),
                      style: TextStyle(
                          fontSize: 20, color: CupertinoColors.white),
                    ),
                  ),
                  title: Text(e.name!),
                  subtitle: Text(e.phone!),
                ),
                onTap: () {

                },
              ),
              Divider(color: CupertinoColors.separator,
                  thickness: 1.5,
                  indent: 80,
                  endIndent: 10)
            ],
          );
        }).toList(),
      ),
      //Divider(height: 40,thickness: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CupertinoButton(
            child: Text("invitation", style: TextStyle(color: Colors.blue),),
            onPressed: () {},
          ),
        ],
      ),
      Divider(color: CupertinoColors.separator, thickness: 1.5,),
      //SizedBox(height: 100, child: ,),
      *//*Column(
        children: controller.unregisteredContactsList.map((e) {
          return Column(
            children: [
              ListTile(
                title: Text(e.name),
                subtitle: Text(e.phone, textDirection: TextDirection.ltr, textAlign: TextAlign.end),
                trailing: CupertinoButton(child: Text("invitation", style: TextStyle(color: CupertinoColors.systemGreen),), onPressed: (){}),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 45),
                child: Divider(height: 0, color: CupertinoColors.separator,),
              ),
            ],
          );
        }).toList(),
      ),*//*
    ],);*/


/*Expanded(
          child: ListView.separated(shrinkWrap: false,
            itemCount: controller.registeredContactsList.length,
            separatorBuilder: (BuildContext context, int index) =>
                Divider(color: CupertinoColors.separator.darkColor, endIndent: 10, indent: 70),
            itemBuilder: (BuildContext c, int index) =>ListTile(
              title: Text(controller.registeredContactsList[index].name),
              subtitle: Text(controller.registeredContactsList[index].phone),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: controller.unregisteredContactsList.length,
            separatorBuilder: (BuildContext context, int index) =>
                Divider(color: CupertinoColors.separator.darkColor, endIndent: 10, indent: 70),
            itemBuilder: (BuildContext c, int index) =>ListTile(
              title: Text(controller.unregisteredContactsList[index].name),
              subtitle: Directionality(textDirection: TextDirection.ltr,child: Text(controller.unregisteredContactsList[index].phone)),
              trailing: CupertinoButton(child: Text("invitation", style: TextStyle(color: CupertinoColors.systemGreen),), onPressed: (){}),
            ),
          ),
        ),*/
/*InkWell(
                onTap: () {},
                child: ListTile(
                  leading: CircularProfileAvatar(
                    '',
                    imageFit: BoxFit.cover,
                    radius: 25,
                    backgroundColor: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
                    initialsText: Text(
                      controller.contacts[index].displayName.substring(0, 1),
                      style: TextStyle(fontSize: 20, color: CupertinoColors.white),
                    ),
                  ),
                  title: Text(s
                      /*controller.contacts[index].displayName*/, style: TextStyle(color: CupertinoTheme.of(context).textTheme.textStyle.color)),
                ),
              ),*/