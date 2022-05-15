import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utilities/theme/my_theme.dart';
import 'package:flutter_chat_app/views/pages/chat/message/utilities/get_stat.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bubble/controller/bubble_audio_message_controller.dart';
import 'package:flutter_chat_app/views/pages/chat/message/model/message.dart';
import 'package:flutter_chat_app/views/pages/chat/room/controller/room_controller.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BubbleAudioMessage extends GetWidget<BubbleAudioMessageController> {
  final double bubbleRadius;
  final bool isSender;
  final Color color;
  final bool sent;
  final bool delivered;
  final bool seen;
  final TextStyle textStyle;
  final String time;
  final Message message;

  const BubbleAudioMessage({
    Key? key,
    this.bubbleRadius = 16.0,
    this.isSender = true,
    this.color = Colors.white70,
    this.sent = false,
    this.delivered = false,
    this.seen = false,
    this.textStyle = const TextStyle(
      color: Colors.white70,
      fontSize: 12,
    ),
    required this.time,
    required this.message,
  }) : super(key: key);

  /*{
    Get.put(BubbleNormalAudioController(), tag: message.messageId);
  }*/

  /*BubbleNormalAudioController get controller =>
     Get.find<BubbleNormalAudioController>(tag: message.messageId);*/


  @override
  Widget build(BuildContext context) {
    //MediaQuery.of(context).size.width
    debugPrint(
        "BubbleNormalAudio3 build()-> message.localPath= ${message.localPath}");
    controller.initAudioFile(message.localPath!);

    controller.download(isSender, message);


    return Obx(() {
      return SizedBox(
        height: 75,
        width: Get.width * .70,
        child: Stack(
          //alignment: getAlignment(),
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
                  child: Icon(Icons.replay, color: Colors.white, size: 28),
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
                height: 70,
                width: Get.width * .65,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(bubbleRadius),
                    topRight: Radius.circular(bubbleRadius),
                    bottomLeft: Radius.circular(isSender ? bubbleRadius : 0),
                    bottomRight: Radius.circular(isSender ? 0 : bubbleRadius),
                  ),
                ),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        CupertinoButton(
                          onPressed:() => controller.onPlayPauseButtonClick(isSender, message),
                          child: getPlayIcon(),
                          padding: EdgeInsetsDirectional.only(start: 15),
                        ),
                        Expanded(
                          child: Material(
                            type: MaterialType.transparency,
                            child: Slider(
                              min: 0.0,
                              max: controller.duration.value.inMilliseconds.toDouble(),
                              value: controller.position.value.inMilliseconds.toDouble(),
                              onChanged: controller.onSeekChanged,
                            ),
                          ),
                        ),
                      ],
                    ),

                    PositionedDirectional(
                        bottom: 2,
                        start: isSender ? 60 : null,
                        end: isSender ? null : 60,
                        child: Text(
                          controller.isDownloading.value ?
                          audioTimer(controller.duration.value.inSeconds.toDouble(),
                              controller.position.value.inSeconds.toDouble()) : message.fileInfo![MessageAudioInfoKey.size],
                          style: textStyle,
                        )),

                    PositionedDirectional(
                      bottom: 2,
                      end: isSender ? 5 : null,
                      start: isSender ? null : 5,
                      child: Row(
                        children: [
                          Text(time,
                            style: TextStyle(
                              color: dateAndStateColor,
                              fontSize: 10,
                            ),
                          ),
                          if(isSender)
                            ValueListenableBuilder(
                              valueListenable: RoomController.instance.messageBox.listenable(keys: [message.messageId]),
                              builder: (context, Box<Message> box, _) {
                                Message? mess = box.get(message.messageId, defaultValue: message);
                                return getStateIcon(mess!.state);
                              },
                            ),
                        ],
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

  String audioTimer(double duration, double position) {
    return '${(duration ~/ 60).toInt()}:${(duration % 60).toInt()
        .toString()
        .padLeft(2, '0')}'
        '/${position ~/ 60}:${(position % 60).toInt().toString().padLeft(2, '0')}';
  }

  Widget getPlayIcon() {
    if (controller.isDownloading.value) {
      if (controller.isPlaying.value) {
        return Icon(Icons.pause, size: 30.0);
      }
      else
        /*if(isPause)*/ {
        return Icon(Icons.play_arrow, size: 30.0);
      }
    }
    else if (controller.isLoading.value)
      return Stack(
          children: const [
            Icon(Icons.arrow_circle_down_sharp, size: 37.0),
            CircularProgressIndicator(),
          ]);
    else
      return Icon(Icons.arrow_circle_down, size: 30.0);
  }

  getDurationWidget() {

  }

  getTextDirection() => isSender ? TextDirection.rtl : TextDirection.ltr;

  getAlignment() =>
      isSender ? AlignmentDirectional.topStart : AlignmentDirectional.topEnd;
}
