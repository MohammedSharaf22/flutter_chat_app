import 'dart:async';

import 'package:badges/badges.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/control/constants/firebase_auth_constants.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bottom_box/message_field_box_controller.dart';
import 'package:flutter_chat_app/utilities/date_formatter_tools.dart';
import 'package:flutter_chat_app/views/pages/chat/message/model/message.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bubble/controller/bubble_audio_message_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/controller/message_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/view/message_page.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bubble/controller/bubble_image_message_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bubble/controller/bubble_video_message_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/room/controller/room_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/room/model/room.dart';
import 'package:flutter_chat_app/views/pages/contact/controller/contacts_controller.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user_contact.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class RoomItem extends StatefulWidget {
  final Room room;

  //late int unSeanCount;

  const RoomItem({ Key? key, required this.room, /*required this.unSeanCount*/
  }) : super(key: key);

  @override
  State<RoomItem> createState() => _RoomItemState();

}

class _RoomItemState extends State<RoomItem> {

  UserContact? _userContact;
  String? imgUrl;
  String? name;
  RxInt unSeanCount = 0.obs;
  late StreamSubscription<BoxEvent> listen;

  @override
  void initState() {
    super.initState();
    listen = RoomController.instance.messageBox.watch().listen((event) {
      if (mounted) {
        Message value = event.value;
        if (value.roomId == widget.room.roomId)
          unSeanCount.value = RoomController.instance
              .messageBox.values.where((e) => e.senderId != auth.currentUser!.uid)
              .where((e) => e.state != StateType.seen).length;

      }
    });

    //debugPrint("room_toString = ${widget.room.toJson().toString()}");
    var userId = widget.room.userIds.singleWhere((element) => element != auth.currentUser!.uid);
    if (widget.room.type == RoomType.CHAT) {
      _userContact = getUser(userId) as UserContact;
      //setState(() {
      imgUrl = _userContact!.photoURL;
      name = _userContact!.name!;
      //});
    } else {
      //setState(() {
      imgUrl = widget.room.imageUrl!;
      name = widget.room.name!;
      //});
    }
  }

  @override
  void dispose() {
    listen.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getChild(context);
  }


  User? getUser(userId) {
    var _contactBox = ContactsController.instance.contactsBox;
    var _userModelBox = ContactsController.instance.userModelBox;
    if (_contactBox.containsKey(userId)) {
      return _contactBox.get(userId);
    }
    else {
      return _userModelBox.get(userId);
    }
  }

  Widget getChild(context) {
    var size = Get.size;

    return Container(
      padding: EdgeInsets.only(bottom: 10),
      /*height: 100,*/
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                //widget.unSeanCount=0;
                //RoomController.instance.messageBox.put
              });
              if (_userContact != null)
                Get.to(() =>
                    MessagePage(room: widget.room, userContact: _userContact!),
                    binding: BindingsBuilder(() {
                      Get.put(MessageController(), tag: widget.room.roomId);
                      Get.put(MessageFieldBoxController());
                      Get.create(() => BubbleAudioMessageController());
                      Get.create(() => BubbleImageMessageController());
                      Get.create(() => BubbleVideoMessageController());
                    },),
                    arguments: {
                      "userContact": _userContact,
                      "room": widget.room
                    },
                );
            },
            child: getSlide(Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 15, end: 15, top: 15, /*bottom: 5*/),
              child: Row(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircularProfileAvatar(
                    imgUrl!,
                    animateFromOldImageOnUrlChange: false,
                    imageFit: BoxFit.cover,
                    radius: 29,
                    onTap: () {
                      Get.snackbar("title", "message");
                    },
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: (size.width - 40) * 0.6,
                              child: Text(name!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).textTheme.labelMedium!.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                DateFormatterTools(widget.room.updatedAt!).formatRoomTime(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).textTheme.labelSmall!.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        /*StreamBuilder<BoxEvent>(
                          stream: RoomController.instance.getUnSeanCount(widget.room.roomId),
                          builder: (context, snapshot) {*/
                        Obx(() {
                            debugPrint("widget.room.lastMessageId= ${widget.room.lastMessageId}");
                            Message? message = RoomController.instance.messageBox.get(widget.room.lastMessageId);
                            if(message == null)
                              return Container();
                            /*if(snapshot.hasData)
                              unSeanCount.value = snapshot.data!.value.length;*/

                            debugPrint("unSeanCount= ${unSeanCount.value }");
                            debugPrint("message.state= ${getState(message.state)}");
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: (size.width - 200) * 1,
                                  child: Row(
                                    children: [
                                      if(message.senderId == auth.currentUser!.uid)...[
                                        setStateIcon(message.state, Theme.of(context).textTheme.labelSmall!.color),
                                        SizedBox(width: 10),
                                      ],
                                      getMessageWidget(message),
                                    ],
                                  ),
                                ),
                                Badge(
                                  animationType: BadgeAnimationType.fade,
                                  showBadge: unSeanCount > 0,
                                  shape: BadgeShape.circle,
                                  //position: BadgePosition.center(),
                                  badgeColor: Colors.purple.shade200,
                                  borderRadius: BorderRadius.circular(5),
                                  badgeContent: Text('${unSeanCount.value}',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            );
                          }
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ),

          Divider(color: CupertinoColors.separator.darkColor,
              indent: 80,
              endIndent: 10),
        ],
      ),
    );
  }

  String getState(int state){
    switch(state){
      case StateType.wait: return "wait";
      case StateType.sent: return "sent";
      case StateType.delivered: return "delivered";
      case StateType.seen: return "seen";
      default: return "error";
    }
  }

  Text getMessageText(String text){
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 15,
        height: 1.3,
        color: unSeanCount > 0
            ? Colors.blue
            :Theme.of(context).textTheme.labelSmall!.color,
      ),
    );
  }

  Widget getMessageWidget(Message message) {
    if (message.type == MessageType.audio) {
      return Row(
        children: [
          Icon(Icons.mic, size: 20, color: Theme.of(context).textTheme.labelSmall!.color),
          getMessageText(message.fileInfo![MessageAudioInfoKey.duration]),
        ],
      );
    }
    else if (message.type == MessageType.image) {
      return Row(
        children: [
          Icon(Icons.photo),
          getMessageText("photo".tr),
        ],
      );
    }
    else if (message.type == MessageType.video) {
      return Row(
        children: [
          Icon(CupertinoIcons.videocam_fill),//Icon(Ionicons.ios_videocam),
          SizedBox(width: 5),
          getMessageText(message.fileInfo![MessageVideoInfoKey.duration]),
        ],
      );
    }
    else{
      return getMessageText(message.text);
    }
  }

  Icon setStateIcon(int state, color) {
    IconData iconData = Icons.watch_later_outlined;
    Color iconColor = color;//invertColor(color);

    if (state == StateType.sent) {
      iconData=CupertinoIcons.check_mark_circled;
    }
    else if (state == StateType.delivered) {
      iconData = CupertinoIcons.check_mark_circled_solid;
    }
    else if (state == StateType.seen) {
      iconData = CupertinoIcons.check_mark_circled_solid;
      iconColor = CupertinoColors.link;
    }
    else {
      iconData = Icons.watch_later_outlined;
    }

    return Icon(
      iconData,
      size: 15,
      color: iconColor,
    );
  }

  getSlide(Widget child){

    return Container(
      margin: EdgeInsets.only(/*top: 10,*/ right: 10, left: 10),
      child: Slidable(
        closeOnScroll: true,
        useTextDirection: true,
        key: const ValueKey(0),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(onDismissed: () {},
              /*closeOnCancel: true, */
              motion: const ScrollMotion()),
          children: [
            SlidableAction(
              autoClose: true,
              onPressed: (context) {
                RoomController.instance.deleteRoom(widget.room.roomId);
              },
              backgroundColor: Color(0xFFFE4A49),
              foregroundColor: CupertinoColors.white,
              icon: Icons.delete,
              label: 'حذف',
            ),
          ],
        ),
        endActionPane: const ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              autoClose: true,
              flex: 2,
              onPressed: null,
              backgroundColor: Color(0xFF7BC043),
              foregroundColor: CupertinoColors.white,
              icon: Icons.archive,
              label: 'ارشفه',
            ),
            SlidableAction(
              autoClose: true,
              onPressed: null,
              backgroundColor: Color(0xFF0392CF),
              foregroundColor: CupertinoColors.white,
              icon: Ionicons.save,
              label: 'حفظ',
            ),
          ],
        ),
        child: child,
      ),
    );
  }




}


