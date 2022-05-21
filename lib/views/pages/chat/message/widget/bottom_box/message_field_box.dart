import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utilities/theme/my_theme.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bottom_box/globals.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bottom_box/lottie_animation.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bottom_box/flow_shader.dart';
import 'package:flutter_chat_app/views/pages/chat/message/widget/bottom_box/message_field_box_controller.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';


class MessageFieldBox extends GetView<MessageFieldBoxController> {
  const MessageFieldBox({
    Key? key,
    required this.roomId,
    required this.messageId,
    required this.onSendAudioMessage,
    required this.onSendTextMessage,
    required this.onLeadingBtnPressed,
  }) : super(key: key);

  final String roomId;
  final String messageId;
  final Function(String text) onSendTextMessage;
  final Function(String? filePath, String messageUID, Map<String, dynamic> fileInfo) onSendAudioMessage;
  final Function() onLeadingBtnPressed;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageFieldBoxController>(builder: (_) {
      return Container(
        width: Get.width,
        color: CupertinoTheme.of(context).barBackgroundColor,
        constraints: BoxConstraints(
          minHeight: 50,
          maxHeight: 300,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            lockSlider(context),
            PositionedDirectional(
              start: 0,
              child: CupertinoButton(
                minSize: 10,
                padding: EdgeInsets.zero,
                child: Icon(Ionicons.attach, size: 28,
                    color: iconDynamicColor),
                onPressed: onLeadingBtnPressed,
              ),
            ),

             AbsorbPointer(
              absorbing: controller.isRecordBoxShowing,
              child: getTextField(context),
            ),

            cancelSlider(context),

            PositionedDirectional(
              end: 0,
              child: Visibility(
                visible: controller.messageSecondState,
                replacement: CupertinoButton(
                  color: primaryDynamicColor,
                  borderRadius: BorderRadius.circular(30),
                  minSize: 45,
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 24,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (!controller.messageSecondState)
                      onSendTextMessage(controller.textEditingController.value.text);
                    controller.textEditingController.clear();
                    controller.onChangeTextMessage('');
                  },
                ),
                child: audioButton(),
              ),
            ),

            Visibility(
              visible: controller.isLocked,
              child: timerLocked(context),
            ),
          ],
        ).paddingOnly(top: 10, right: 10, left: 10, bottom: 10),
      );
    });
  }

  Widget lockSlider(context) {
    return PositionedDirectional(
      end: 0,
      bottom: -controller.lockerAnimation.value,
      child: Container(
        height: controller.lockerHeight,
        width: controller.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          color: CupertinoTheme.of(context).barBackgroundColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const FaIcon(FontAwesomeIcons.lock, size: 20),
            const SizedBox(height: 8),
            FlowShader(
              direction: Axis.vertical,
              child: Column(
                children: const [
                  Icon(Icons.keyboard_arrow_up),
                  Icon(Icons.keyboard_arrow_up),
                  Icon(Icons.keyboard_arrow_up),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cancelSlider(context) {
    return PositionedDirectional(
      end: -controller.timerAnimation.value, //-timerAnimation.value,
      child: Container(
        height: controller.size,
        width: controller.timerWidth,
        color: CupertinoTheme.of(context).barBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Stack(
          children: [
            PositionedDirectional(
              start: 10,
              child: controller.showLottie
                  ? const LottieAnimation(
                  lottieName: "dustbin_red_2.json", height: 35, width: 35)
                  : Row(
                children: [
                  const LottieAnimation(lottieName: "recording_circle.json",
                      height: 15,
                      width: 15),
                  SizedBox(width: 10),
                  StreamBuilder<int>(
                      stream: controller.stopWatchTimer.secondTime,
                      initialData: controller.stopWatchTimer.secondTime.value,
                      builder: (context, snapshot) {
                        controller.second = snapshot.data.toString();
                        if(snapshot.data! < 10)
                          controller.second = "0${controller.second}";
                        return Text(controller.second);
                      }
                  ),
                  Text(":"),
                  StreamBuilder<int>(
                    stream: controller.stopWatchTimer.minuteTime,
                    initialData: controller.stopWatchTimer.minuteTime.value,
                    builder: (context, snapshot) {
                      controller.minute = snapshot.data.toString();
                      if(snapshot.data! < 10)
                        controller.minute = "0${controller.minute}";
                      return Text(controller.minute);
                    },
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              end: controller.slidePositionDx,
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios, size: 15),
                  Text("swipe_to_cancel".tr),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget timerLocked(context) {
    return Container(
      height: controller.timerHeight,
      width: controller.timerWidth,
      color: CupertinoTheme.of(context).barBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const LottieAnimation(lottieName: "recording_circle.json", height: 15, width: 15),
                  SizedBox(width: 10),
                  StreamBuilder<int>(
                    stream: controller.stopWatchTimer.secondTime,
                    initialData: controller.stopWatchTimer.secondTime.value,
                    builder: (context, snapshot) {

                      controller.second = snapshot.data.toString();
                      if(snapshot.data! < 10)
                        controller.second = "0${controller.second}";
                      return Text(controller.second);
                    }
                  ),
                  Text(":"),
                  StreamBuilder<int>(
                      stream: controller.stopWatchTimer.minuteTime,
                      initialData: controller.stopWatchTimer.minuteTime.value,
                      builder: (context, snapshot) {
                         controller.minute = snapshot.data.toString();
                        if(snapshot.data! < 10)
                          controller.minute = "0${controller.minute}";
                        return Text(controller.minute);
                      }
                  ),
                ],
              ),
              //SizedBox(width: 30),
              Lottie.asset('assets/images/recording_bar.json', height: 50),
              //LottieAnimation(lottieName: "recording_bar.json", height: timerWidth * 0.10, width: timerWidth * 0.10),
              //
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.delete, size: 25, color: Colors.pink),
                onPressed: () {
                  debugPrint("Cancelled");
                  controller.cancelRecord();
                  controller.hideRecordBox();
                },
              ),

              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(controller.stopWatchTimer.isRunning
                    ? CupertinoIcons.stop_fill
                    : CupertinoIcons.pause_fill, size: 25,),
                onPressed: ()  {
                  if(controller.stopWatchTimer.isRunning){
                    debugPrint("Timer pause");
                    controller.pauseTimer();
                  }else {
                    debugPrint("Timer resume");
                    controller.resumeTimer();
                  }

                },
              ),

              CupertinoButton(
                color: primaryDynamicColor,
                borderRadius: BorderRadius.circular(30),
                minSize: 45,
                padding: EdgeInsets.zero,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 24,
                  color: Colors.white,
                ),
                onPressed: () {
                  controller.sendRecord((filePath, fileInfo) {
                    onSendAudioMessage(filePath, messageId, fileInfo);
                  },);
                  controller.hideRecordBox();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget audioButton() {
    return GestureDetector(
      child: Transform.scale(
        scale: controller.buttonScaleAnimation.value,
        child: Container(
          child: Icon(Icons.mic_none, color: controller.audioIconColor),
          height: controller.size,
          width: controller.size,
          //padding: EdgeInsets.all(5),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: controller.audioButtonColor,
          ),
        ),
      ),
      onLongPressMoveUpdate: controller.onLongPressMoveUpdate,
      onLongPressDown: controller.onLongPressDown,
      onLongPressEnd: (details) {
        controller.onLongPressEnd(details,
                (filePath, fileInfo) =>
                    onSendAudioMessage(filePath, messageId, fileInfo));
      },
      onLongPressCancel: controller.onLongPressCancel,
      onLongPress: ()=> controller.onLongPress(roomId, messageId),
    );
  }


  getTextField(context) {
    return Container(
      width: Get.width * 0.65,
      constraints: BoxConstraints(minHeight: 45, maxHeight: 70),
      //height: 45,
      margin: EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: CupertinoTextField(
        controller: controller.textEditingController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        autofocus: true,
        cursorHeight: 20,
        padding: EdgeInsets.symmetric(horizontal: 10),
        placeholder: "type_a_message".tr,
        suffix: CupertinoButton(
          child: Icon(Ionicons.document, size: 20, color: iconDynamicColor),
          padding: EdgeInsets.all(5),
          onPressed: () {},
        ),
        decoration: BoxDecoration(
          border: Border.all(width: 0),
          color: fieldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        onChanged: (value) {
          controller.onChangeTextMessage(value);
        },
      ),
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
        size: size ?? 28, color: color ?? primaryDynamicColor);
    return CupertinoButton(
      minSize: 10,
      padding: EdgeInsets.zero,
      color: background,
      child: icon,
      onPressed: onPressed,
    );
  }

}


