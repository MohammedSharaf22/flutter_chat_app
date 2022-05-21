import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bottom_box/message_field_box_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bubble/controller/bubble_audio_message_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/controller/message_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bubble/controller/bubble_image_message_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bubble/controller/bubble_video_message_controller.dart';
import 'package:flutter_chat_app/views/pages/contact/controller/contacts_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/view/message_page.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user_contact.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../utilities/theme/my_theme.dart';
import 'contact_item.dart';

class ContactsPage extends GetView<ContactsController> {
  ContactsPage({Key? key}) : super(key: key);

  final RefreshController _refreshController = RefreshController(
      initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ContactsController>(builder: (_) {
      return CupertinoPageScaffold(
        child: NestedScrollView(
          controller: ScrollController(),
          //PageScrollPhysics
          physics: const NeverScrollableScrollPhysics(),
          //NeverScrollableScrollPhysics
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              CupertinoSliverNavigationBar(
                stretch: true,
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text("sort".tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {},
                ),
                middle: Text("contacts".tr),
                border: Border.all(color: Colors.transparent),
                largeTitle: Container(width: double.infinity, height: 38,
                  padding: EdgeInsetsDirectional.only(end: 15,/* top: 5*/),
                  child: CupertinoSearchTextField(
                    backgroundColor: fieldBackgroundColor,
                    padding: EdgeInsetsDirectional.only(start: 5),
                    prefixInsets: EdgeInsetsDirectional.only(start: 5),
                    placeholder: "search".tr,
                    style: TextStyle(fontSize: 14,),
                  ),
                ),
                trailing: CupertinoButton(
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.add),
                ),
              ),
            ];
          },
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
            child: ListView(
              shrinkWrap: true,
              physics: PageScrollPhysics(),
              children: [
                getBody(context),
                Divider(height: 40, thickness: 20),
                CupertinoButton(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text("invite_friends".tr,
                    //style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget getBody(context) {
    return ValueListenableBuilder(
        valueListenable: controller.contactsBox.listenable(),
        builder: (context, Box<UserContact> box, _) {
          var lastIndex = box.length-1;
          return Column(
            children: List.generate(box.length, (index){
              var userContact = box.getAt(index)!;
              return ContactItem(
                name: userContact.name ?? '',
                photoURL: userContact.photoURL,
                phone: userContact.phone,
                isLastItem: index == lastIndex,
                onClick: (){
                  var room = controller.getRoomByUserId(userContact.uid);
                  Get.to(() => MessagePage(userContact: userContact, room: room),
                    binding: BindingsBuilder(() {
                      Get.put(MessageController(), tag: room.roomId);
                      Get.put(MessageFieldBoxController());
                      Get.create(() => BubbleAudioMessageController());
                      Get.create(() => BubbleImageMessageController());
                      Get.create(() => BubbleVideoMessageController());
                    }),
                    arguments: {"userContact": userContact, "room": room},
                  );
                },
              );
            }),
          );
        }
    );
  }
}



