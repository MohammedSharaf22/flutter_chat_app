import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/views/pages/chat/message/model/message.dart';
import 'package:flutter_chat_app/views/pages/chat/message/utilities/get_stat.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bubble/controller/bubble_video_message_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/viewer/video_player_view.dart';
import 'package:flutter_chat_app/views/pages/chat/room/controller/room_controller.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BubbleVideoMessage extends GetWidget<BubbleVideoMessageController> {

  final double bubbleRadius;
  final bool isSender;
  final Color color;
  final bool sent;
  final bool delivered;
  final bool seen;
  final TextStyle textStyle;
  final String time;
  final Message message;

  const BubbleVideoMessage({
    Key? key,
    this.bubbleRadius = 15.0,
    this.isSender = true,
    this.color = Colors.white70,
    this.sent = false,
    this.delivered = false,
    this.seen = false,
    this.textStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 12,
    ),
    required this.time,
    required this.message,
  }) : super(key: key);

  void openVideo(){
    if (controller.isDownloading.value) {
      Get.to(() => VideoPlayerView(),
        arguments: {
          "message": message,
          "videoFile": controller.videoFile,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("BubbleVideoMessage build()-> message.localPath= ${message.localPath}");
    debugPrint("BubbleVideoMessage build()-> message.fileInfo= ${message.toString()}");

    String thumbPath = message.fileInfo![MessageVideoInfoKey.thumbLocal];
    controller.initVideoFile(message.localPath!, thumbPath);
    controller.download(isSender, message);

    debugPrint("MessageVideoInfoKey.height= ${message.fileInfo![MessageVideoInfoKey.height]}");
    debugPrint("MessageVideoInfoKey.width= ${message.fileInfo![MessageVideoInfoKey.width]}");

    var height = message.fileInfo![MessageVideoInfoKey.height];
    var width = message.fileInfo![MessageVideoInfoKey.width];
    debugPrint("MessageVideoInfoKey.(height/width)*200= ${(height/width) * 200 }");

    return Obx(() {
      return Container(
        width: Get.width /* * .70*/,
        constraints: BoxConstraints(
          maxHeight: 300,
        ),
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Stack(
          alignment: Alignment.center,
          textDirection: getTextDirection(),
          children: <Widget>[
            PositionedDirectional(
              start: isSender ? 0 : null,
              end: isSender ? null : 0,
              child: Visibility(
                visible: controller.isFailure.value,
                child: CupertinoButton(
                  minSize: 10,
                  padding: EdgeInsets.zero,
                  color: Colors.pink,
                  child: Icon(Icons.replay, color: Colors.white, size: 24),
                  onPressed: () => controller.download(isSender, message),
                ),
              ),
            ),
            AnimatedPositionedDirectional(
              //top: 0,
              start: isSender ? controller.isFailure.value ? 28 : 0 : null,
              end: isSender ? null : controller.isFailure.value ? 28 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                //height: 70,
                //width: 200,//Get.width * .65,
                constraints: BoxConstraints(
                  maxWidth: 200,
                  maxHeight: 300,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: getBorderRadius(),
                ),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        openVideo();
                      },
                      child: Hero(
                        tag: 'VideoMessage_${message.messageId}',
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if(isSender)...[
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: getBorderRadius(),
                                  image: DecorationImage(
                                    image: FileImage(File(thumbPath)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ]
                            else if(controller.isDownloading.value)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: getBorderRadius(),
                                  image: DecorationImage(
                                    image: FileImage(controller.thumbnailFile),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),


                            if(controller.isDownloading.isFalse)...[
                              // message.fileInfo![MessageImageInfoKey.size]
                              CupertinoButton(
                                child: getLoadIcon(),
                                minSize: 50,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  controller.onDownloadOrUploadButtonClick(
                                      isSender, message);
                                },
                                color: CupertinoColors.black.withOpacity(.5),
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ]
                            else
                              CupertinoButton(
                                child: Icon(CupertinoIcons.play_fill),
                                minSize: 50,
                                padding: EdgeInsets.zero,
                                onPressed: () => openVideo(),
                                color: CupertinoColors.black.withOpacity(.5),
                                borderRadius: BorderRadius.circular(30),
                              ),
                          ],
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 20,
                        width: 200,
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 15.0,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      bottom: 3,
                      end: isSender ? null : 6,
                      start: isSender ? 6 : null,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 15.0,
                              offset: Offset(isSender ?0.0 : 5, 0),
                            ),
                          ],
                        ),
                        child: Text(message.fileInfo![MessageVideoInfoKey.duration]),
                      ),
                    ),
                    PositionedDirectional(
                      bottom: 3,
                      end: isSender ? 6 : null,
                      start: isSender ? null : 6,
                      child: Container(
                        //padding: EdgeInsets.only(top: 5, ),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 15.0,
                              offset: Offset(isSender ?0.0 : 5, 0),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(time,
                              style: TextStyle(
                                color: Colors.white.withOpacity(.8),//controller.invertColor(color),
                                fontSize: 12,
                              ),
                            ),
                            if(isSender)...[
                              SizedBox(width: 2),
                              ValueListenableBuilder(
                                valueListenable: RoomController.instance.messageBox
                                    .listenable(keys: [message.messageId]),
                                builder: (context, Box<Message> box, _) {
                                  Message? mess = box.get(
                                      message.messageId, defaultValue: message);
                                  return getStateIcon(mess!.state);
                                },
                              ),
                            ]
                            else
                              SizedBox(width: 15),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget getLoadIcon() {
    if (controller.isLoading.value)
      return Stack(
        alignment: Alignment.center,
        children: const [
          Icon(CupertinoIcons.clear, size: 25.0, color: CupertinoColors.white),
          CircularProgressIndicator(color: CupertinoColors.white),
        ],
      );
    else {
      if (isSender) {
        return Icon(
            CupertinoIcons.up_arrow, size: 30.0, color: CupertinoColors.white);
      }
      else {
        return Icon(CupertinoIcons.down_arrow, size: 30.0,
            color: CupertinoColors.white);
      }
    }
  }

  getTextDirection() => isSender ? TextDirection.rtl : TextDirection.ltr;

  getBorderRadius() {
    return BorderRadius.only(
      topLeft: Radius.circular(bubbleRadius),
      topRight: Radius.circular(bubbleRadius),
      bottomLeft: Radius.circular(isSender ? bubbleRadius : 0),
      bottomRight: Radius.circular(isSender ? 0 : bubbleRadius),
    );
  }
}
