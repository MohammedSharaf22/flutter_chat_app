import 'dart:async';

import 'package:badges/badges.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/control/constants/firebase_auth_constants.dart';
import 'package:flutter_chat_app/utilities/theme/my_theme.dart';
import 'package:flutter_chat_app/utilities/widgets/item_detector.dart';
import 'package:flutter_chat_app/views/pages/chat/message/utilities/get_stat.dart';
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

  const RoomItem({
    Key? key,
    required this.room,
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
  late TextStyle nameTextStyle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    nameTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  void initState() {
    super.initState();
    listen = RoomController.instance.messageBox.watch().listen((event) {
      Message value = event.value;
      if (mounted) {
        if (value.roomId == widget.room.roomId)
          unSeanCount.value = RoomController.instance.messageBox.values
              .where((e) => e.senderId != auth.currentUser!.uid)
              .where((e) => e.state != StateType.seen)
              .length;
      }
    });

    //debugPrint("room_toString = ${widget.room.toJson().toString()}");
    var userId = widget.room.userIds
        .singleWhere((element) => element != auth.currentUser!.uid);
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

  User? getUser(userId) {
    var _contactBox = ContactsController.instance.contactsBox;
    var _userModelBox = ContactsController.instance.userModelBox;
    if (_contactBox.containsKey(userId)) {
      return _contactBox.get(userId);
    } else {
      return _userModelBox.get(userId);
    }
  }

  @override
  void dispose() {
    listen.cancel();
    super.dispose();
  }

  void goToMessagePage(){
    if (_userContact != null)
      Get.to(() => MessagePage(room: widget.room, userContact: _userContact!),
        binding: BindingsBuilder(
              () {
            Get.put(MessageController(), tag: widget.room.roomId);
            Get.put(MessageFieldBoxController());
            Get.create(() => BubbleAudioMessageController());
            Get.create(() => BubbleImageMessageController());
            Get.create(() => BubbleVideoMessageController());
          },
        ),
        arguments: {"userContact": _userContact, "room": widget.room},
      );
  }

  @override
  Widget build(BuildContext context) {
    var dateTextStyle = TextStyle(
      fontSize: 12,
      color: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.color,
    );
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          ItemDetector(
            //onLongPressed: () {},
            onPressed: goToMessagePage,
            child: getSlide(widget.room,
              Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 10, end: 10, top: 10),
                child: Row(
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: (Get.width - 40) * 0.6,
                              height: 20,
                              child: Text(
                                name!,
                                overflow: TextOverflow.ellipsis,
                                style: nameTextStyle,
                              ),
                            ),
                            Text(
                              DateFormatterTools(widget.room.updatedAt!).formatRoomTime(),
                              style: dateTextStyle,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Obx(() {
                          debugPrint("widget.room.lastMessageId= ${widget.room.lastMessageId}");
                          Message? message = getLastMessage();
                          if (message == null) return Container();
                          debugPrint("unSeanCount= ${unSeanCount.value}");

                          return SizedBox(
                            width: Get.width * 0.66,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (message.senderId ==auth.currentUser!.uid)...[
                                      getStateIcon(message.state),
                                      SizedBox(width: 10),
                                    ],
                                    if(message.type != MessageType.text)
                                      getMessageWidget(message),
                                    SizedBox(
                                      width: Get.width * .46,
                                      child: getMessageText(message),
                                    ),
                                  ],
                                ),
                                Badge(
                                  animationType: BadgeAnimationType.fade,
                                  showBadge: unSeanCount.value > 0,
                                  shape: BadgeShape.circle,
                                  padding: EdgeInsets.all(7),
                                  //position: BadgePosition.center(),
                                  badgeColor: primaryDynamicColor,
                                  borderRadius: BorderRadius.circular(5),
                                  badgeContent: Text(
                                    '${unSeanCount.value}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Divider(
            color: CupertinoColors.separator.darkColor,
            indent: 80,
            endIndent: 10,
          ),
        ],
      ),
    );
  }

  Text getMessageText(Message message) {
    String text = message.text;
    switch (message.type) {
      case MessageType.audio:
          text = message.fileInfo![MessageAudioInfoKey.duration];
        break;
      case MessageType.image:
          text = "photo".tr;
        break;
      case MessageType.video:
          text = message.fileInfo![MessageVideoInfoKey.duration];
        break;
    }
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        //height: 1.3,
        color: getColor(),
      ),
    );
  }

  Color? getColor(){
    if (unSeanCount > 0)
      return CupertinoColors.systemBlue;

    return CupertinoTheme.of(context).textTheme.tabLabelTextStyle.color;
  }

  Widget getMessageWidget(Message message) {

    IconData? iconData;
    switch (message.type) {
      case MessageType.audio:
        iconData = CupertinoIcons.mic;
        break;
      case MessageType.image:
        iconData = CupertinoIcons.photo;
        break;
      case MessageType.video:
        iconData = CupertinoIcons.video_camera_solid;
        break;
    }

    return Row(
      children: [
        Icon(
          iconData,
          size: 20,
          color: getColor(),
        ),
        SizedBox(width: 5),
      ],
    );
  }

  getSlide(Room room,Widget child) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Slidable(
        closeOnScroll: true,
        useTextDirection: true,
        key: ValueKey(room.roomId),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(
            onDismissed: () {},
            closeOnCancel: true,
            motion: const ScrollMotion(),
          ),
          children: [
            SlidableAction(
              autoClose: true,
              onPressed: (context) {
                RoomController.instance.deleteRoom(widget.room.roomId);
              },
              backgroundColor: Color(0xFFFE4A49),
              foregroundColor: CupertinoColors.white,
              icon: CupertinoIcons.delete_solid,
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
              icon: CupertinoIcons.archivebox_fill,
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

  Message? getLastMessage() {
    return RoomController
        .instance.messageBox
        .get(widget.room.lastMessageId);
  }
}
