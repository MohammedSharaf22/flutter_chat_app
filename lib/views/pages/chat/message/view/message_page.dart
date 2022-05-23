import 'dart:developer';
import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utilities/theme/my_theme.dart';
import 'package:flutter_chat_app/utilities/widgets/nav_bar.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bottom_box/message_field_box.dart';
import 'package:flutter_chat_app/utilities/files.dart';
import 'package:flutter_chat_app/utilities/widgets/MyCheckBox.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/calls/video_call.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bubble/bubble_audio_message.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bubble/bubble_image_message.dart';
import 'package:flutter_chat_app/views/pages/chat/message/controller/message_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/model/message.dart';
import 'package:flutter_chat_app/utilities/date_formatter_tools.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bubble/bubble_text_message.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bubble/bubble_video_message.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/square_camera_widget.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/top_box/user_info_widget.dart';
import 'package:flutter_chat_app/views/pages/chat/room/controller/room_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/room/model/room.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user_contact.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:video_compress/video_compress.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:path/path.dart' as p;

class MessagePage extends GetView<MessageController> {
  final Room room;
  final UserContact userContact;

  @override
  String? get tag => room.roomId;

  const MessagePage({
    Key? key,
    required this.room,
    required this.userContact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (controller.isSelectionMode) {
          controller.disableSelectionMode();
          return false;
        }
        return true;
      },
      child: CupertinoPageScaffold(
        backgroundColor: MyDarkTheme.scaffoldBackgroundColor,
        navigationBar: getAppBar(context),
        child: Stack(
          children: [
            /*Image.asset(
              "assets/images/bg_chat.jpg",
              height: Get.height,
              width: Get.width,
              fit: BoxFit.cover,
            ),*/
            getBody(),
            Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: getBottomSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  MyCupertinoNavigationBar getAppBar(context) {
    return MyCupertinoNavigationBar(
      padding: EdgeInsetsDirectional.only(top: 5, bottom: 5),
      leading: GetBuilder<MessageController>(tag: tag, builder: (_) {
        if (controller.isSelectionMode) {
          return CupertinoButton(
              child: Text("cancel".tr),
              onPressed: () {
                controller.disableSelectionMode();
              });
        } else {
          return MyCupertinoNavigationBarBackButton(
            onPressed: () => Get.back(),
          );
        }
      }),
      middle: GetBuilder<MessageController>(tag: tag, builder: (_) {
        var count = controller.selectedMessages.length;
        var selectedText= "selected".tr;
        return controller.isSelectionMode
            ? Text("$count $selectedText")
            : UserInfoWidget(userContact: userContact,);
      }),
      trailing: GetBuilder<MessageController>(tag: tag, builder: (_) {
        if (controller.isSelectionMode)
          return CupertinoButton(
            child: Text("Clear Chat"),
            onPressed: () {},
          );
        else
        return getAppBarTrailing();
      }),
    );
  }

  getAppBarTrailing(){
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CupertinoButton(
          child: Icon(Ionicons.call_outline, size: 27,),
          onPressed: () {
            //controller.sendMessageFromAnotherUser('welcome');
          },
        ),
        CupertinoButton(
          child: Icon(Ionicons.videocam_outline, size: 27,),
          onPressed: () => Get.to(() => VideoCall()),
        ),
      ],
    );
  }


  Widget getBottomSheet(context) {
    //var size = Get.size;
    //debugPrint("brightness= ${AdaptiveThemeMode.system.isLight}");
    //debugPrint("brightness= ${CupertinoAdaptiveTheme.of(context).brightness}");
    var backgroundColor = CupertinoTheme.of(context).barBackgroundColor;

    return GetBuilder<MessageController>(
      //id: appBarId,
      tag: tag,
      builder: (_) {
        return Stack(
          alignment: Alignment.center,
          children: [
            AbsorbPointer(
              absorbing: controller.isSelectionMode,
              child: MessageFieldBox(
                roomId: room.roomId,
                messageId: controller.messageCollection
                    .doc()
                    .id,
                onSendTextMessage: (text) {
                  controller.sendMessage(text);
                },
                onSendAudioMessage: (filePath, messageUID, fileInfo) {
                  if (filePath != null)
                    controller.sendMessageAudio(filePath, messageUID, fileInfo);
                },
                onLeadingBtnPressed: () {
                  getCupertinoActionSheet(context);
                },
              ),
            ),
            Visibility(
              visible: controller.isSelectionMode,
              child: Container(
                width: Get.width,
                height: 65,
                color: backgroundColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Icon(CupertinoIcons.reply),
                      onPressed: () {

                      },
                    ),
                    CupertinoButton(
                      child: Icon(CupertinoIcons.delete, color: Colors.pink),
                      onPressed: () {
                        String messageText = "delete_single_mess".tr;
                        if (controller.selectedMessages.length > 1) {
                          messageText = "delete_multi_mess".tr;
                        }
                        showCupertinoDialog<void>(
                          context: context,
                          builder: (BuildContext context) =>
                              CupertinoAlertDialog(
                                title: Text('warning'.tr),
                                content: Text(messageText),
                                actions: <CupertinoDialogAction>[
                                  CupertinoDialogAction(
                                    child: Text('delete'.tr),
                                    isDestructiveAction: true,
                                    onPressed: () {
                                      controller.deleteMessages();
                                      Get.back();
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: Text('cancel'.tr),
                                    onPressed: () {
                                      controller.disableSelectionMode();
                                      Get.back();
                                    },
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget getBody() {
    return ValueListenableBuilder(
      valueListenable: RoomController.instance.messageBox.listenable(),
      builder: (context, Box<Message> box, _) {
        var sortedList = box.values
            .where((element) => element.roomId == room.roomId)
            .toList();
        sortedList.sort((a, b) => a.time.compareTo(b.time));
        try {
          //sortedList=sortedList.reversed.toList();
          return ListView.builder(
            /*physics: AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            controller: controller.listViewScrollController,*/
            reverse: true,
            itemCount: sortedList.length,
            padding: EdgeInsets.only(top: 20, bottom: 80),
            itemBuilder: (context, index) {
              final reversedIndex = sortedList.length - 1 - index;
              Message message = sortedList[reversedIndex];

              var isMe = controller.isMe(message.senderId);
              String time = DateFormatterTools(message.time).formatMessageTime();

              var bubbleColor = isMe ?myBubbleColor : anotherBubbleColor;

              dynamic bubble;
              if (message.type == MessageType.audio) {
                bubble = BubbleAudioMessage(
                  key: ValueKey(message.messageId),
                  time: time,
                  isSender: isMe,
                  sent: message.state == StateType.sent,
                  delivered: message.state == StateType.delivered,
                  seen: message.state == StateType.seen,
                  color: bubbleColor,
                  message: message,
                );
              }
              else if (message.type == MessageType.image) {
                bubble = BubbleImageMessage(
                  key: ValueKey(message.messageId),
                  time: time,
                  message: message,
                  isSender: isMe,
                  sent: message.state == StateType.sent,
                  delivered: message.state == StateType.delivered,
                  seen: message.state == StateType.seen,
                  color: bubbleColor,
                );
              }
              else if (message.type == MessageType.video) {
                bubble = BubbleVideoMessage(
                  key: ValueKey(message.messageId),
                  time: time,
                  message: message,
                  isSender: isMe,
                  sent: message.state == StateType.sent,
                  delivered: message.state == StateType.delivered,
                  seen: message.state == StateType.seen,
                  color: bubbleColor,
                );
              }
              else {
                bubble = BubbleTextMessage(
                  key: ValueKey(message.messageId),
                  text: message.text,
                  time: time,
                  isSender: isMe,
                  state: message.state,
                  color: bubbleColor,
                );
              }
              return GestureDetector(
                onTap: () {
                  if (!controller.selectedMessages.contains(message.messageId))
                    controller.addToSelectedMessages(message.messageId);
                  else
                    controller.removeFromSelectedMessages(message.messageId);
                },
                onLongPress: () {
                  controller.showSelectionMode(message.messageId);
                },
                child: GetBuilder<MessageController>(
                  tag: tag,
                  builder: (_) =>
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: AbsorbPointer(
                              child: bubble,
                              absorbing: controller.isSelectionMode,
                            ),
                          ),
                          Visibility(
                            visible: controller.isSelectionMode,
                            child: MyCheckBox(
                              value: controller.selectedMessages.contains(
                                  message.messageId),
                              onChanged: (value) {
                                if (value)
                                  controller
                                      .addToSelectedMessages(message.messageId);
                                else
                                  controller.removeFromSelectedMessages(
                                      message.messageId);
                              },
                            ),
                          ),
                        ],
                      ),
                ),
              );
            },
          );
        } catch (e) {
          log("Error MessagePage -> $e");
        }
        return Container();
      },
    );
  }

  iconButInMessBox({
    required BuildContext context,
    required IconData iconData,
    Icon? icon,
    Color? color,
    double? size,
    Color? background,
    required VoidCallback onPressed,
  }) {
    icon ??= Icon(iconData,
        size: size ?? 28, color: color ?? Colors.purple.shade200);
    return CupertinoButton(
      minSize: 10,
      padding: EdgeInsets.zero,
      color: background,
      child: icon,
      onPressed: onPressed,
    );
  }

  ThemeData getThemeData(BuildContext context, ThemeData light,
      ThemeData dark) {
    //return Theme.of(context).brightness == Brightness.light ? light : dark;
    return AdaptiveThemeMode.system.isLight ? light : dark;
  }


  getCupertinoActionSheet(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actions: [
            Obx(() {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    CupertinoActionSheetAction(
                      child: SquareCameraWidget(
                        borderColor: CupertinoColors.opaqueSeparator,
                        size: Size.square(100),
                        borderWidth: 1.0,
                        borderRadius: 10,
                      ),
                      onPressed: () {

                      },
                    ),
                    Row(
                      children: List.generate(
                          RoomController.instance.imagesList.length, (index) {
                        FileImage fileImage = RoomController.instance
                            .imagesList[index]!;
                        return CupertinoActionSheetAction(
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1,
                                  color: CupertinoColors.opaqueSeparator),
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: fileImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          onPressed: () {

                          },
                        );
                      }),
                    ),
                  ],
                ),
              );
            }),

            CupertinoActionSheetAction(
              child: Text("photo_or_video".tr),
              onPressed: () async {
                var state = await AssetPicker.permissionCheck();
                if (state != PermissionState.authorized) {
                  //Permission.photos.request().isGranted;
                  return;
                }

                final List<AssetEntity>? result = await AssetPicker
                    .pickAssets(
                  context,
                  pickerConfig: const AssetPickerConfig(),
                );
                Get.back();
                debugPrint("photo_or_video_under_Get.back");
                for (AssetEntity asset in result!) {
                  var file = await asset.file;
                  if (file == null)
                    continue;
                  var messageId = controller.messageCollection
                      .doc()
                      .id;
                  var _extension = p.extension(file.path);

                  if (asset.type == AssetType.image) {
                    compressAndSendImage(
                      assetEntity: asset,
                      imageFile: file,
                      messageId: messageId,
                      extension: ".jpg",
                    );
                  }
                  else if (asset.type == AssetType.video) {
                    compressAndSendVideo(
                      assetEntity: asset,
                      videoFile: file,
                      messageId: messageId,
                      extension: _extension,
                    );
                  }
                }
              },
            ),

            CupertinoActionSheetAction(
              child: Text("file".tr),
              onPressed: () {
                Get.back();
              },
            ),

            CupertinoActionSheetAction(
              child: Text("location".tr),
              onPressed: () {
                Get.back();
              },
            ),

            CupertinoActionSheetAction(
              child: Text("contact".tr),
              onPressed: () {
                Get.back();
              },
            ),
          ],
          cancelButton: CupertinoButton(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10),
            onPressed: () => Get.back(),
            child: Text("cancel".tr, style: TextStyle(fontSize: 17)),
          ),
        );
      },
    );
  }

  void compressAndSendImage({
    required AssetEntity assetEntity,
    required File imageFile,
    required String messageId,
    required String extension
  }) async {
    var path = await getImagePath(room.roomId, messageId, extension: extension);
    debugPrint("OriginImagePath= ${imageFile.path}");
    debugPrint("compressImagePath= $path}");

    await imageFile.copy(path);

    var thumbnailPath = await getImageThumbnailPath(room.roomId, messageId);

    await FlutterImageCompress.compressAndGetFile(
      path,
      thumbnailPath,
      minHeight: assetEntity.height,
      minWidth: assetEntity.width,
      quality: 10,
      format: CompressFormat.jpeg,
    );

    var fileInfo = {
      MessageImageInfoKey.size: getFileSize(1, path),
      MessageImageInfoKey.height: assetEntity.height,
      MessageImageInfoKey.width: assetEntity.width,
      MessageImageInfoKey.extension: extension,
      MessageImageInfoKey.thumbLocal: thumbnailPath,
    };
    controller.sendMessageImage(path, messageId, fileInfo);
  }

  void compressAndSendVideo({
    required AssetEntity assetEntity,
    required File videoFile,
    required String messageId,
    required String extension,
  }) async {
    var path = await getVideoPath(room.roomId, messageId, extension: extension);
    await videoFile.copy(path);

    var fileThumbnail = await VideoCompress.getFileThumbnail(path, quality: 20);
    var thumbnailPath = await getVideoThumbnailPath(
        room.roomId, messageId, extension: ".jpg");
    await fileThumbnail.copy(thumbnailPath);

    debugPrint("originFileSize= ${getFileSize(1, videoFile.path)}");
    var fileInfo = {
      MessageVideoInfoKey.duration: formatDuration(assetEntity.videoDuration),
      MessageVideoInfoKey.size: getFileSize(1, path),
      MessageVideoInfoKey.height: assetEntity.height,
      MessageVideoInfoKey.width: assetEntity.width,
      MessageVideoInfoKey.extension: extension,
      MessageVideoInfoKey.thumbLocal: thumbnailPath,
    };
    controller.sendMessageVideo(path, messageId, fileInfo);
  }
}




