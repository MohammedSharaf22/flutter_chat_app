import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utilities/theme/my_theme.dart';
import 'package:flutter_chat_app/utilities/files.dart';
import 'package:flutter_chat_app/views/pages/chat/message/model/message.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'globals.dart';

class MessageFieldBoxController extends GetxController with GetSingleTickerProviderStateMixin{
  final double size = 55;
  final double lockerHeight = 200;
  double timerWidth = 0;
  double timerHeight = 55;

  late AnimationController animationController;
  late Animation<double> buttonScaleAnimation;
  late Animation<double> timerAnimation;
  late Animation<double> lockerAnimation;


  late StopWatchTimer stopWatchTimer;
  Record record = Record();

  bool isLocked = false;
  bool showLottie = false;
  Color? audioButtonColor;
  Color audioIconColor = iconColor;
  double slidePositionDx = 128;
  bool isCancel = false;

  /////
  TextEditingController textEditingController= TextEditingController();
  bool _messageFirstState = false;
  bool messageSecondState = true;

  bool isRecordBoxShowing = false;

  String second = "";
  String minute = "";


  @override
  void onInit() {
    super.onInit();
    stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countUp,
      onStop: () {
        debugPrint('onStop');
      },
      onEnded: () {
        debugPrint('onEnded');
      },
    );

    //stopWatchTimer.minuteTime.listen((value) => debugPrint('minuteTime $value'));
    //stopWatchTimer.secondTime.listen((value) => debugPrint('secondTime $value'));
    //stopWatchTimer.records.listen((value) => debugPrint('records ${value.length}'));
    //stopWatchTimer.fetchStop.listen((value) => debugPrint('stop from stream'));
    //stopWatchTimer.fetchEnded.listen((value) => debugPrint('ended from stream'));

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    buttonScaleAnimation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticInOut),
      ),
    );
    animationController.addListener(() {
      if(animationController.isAnimating) {
        audioButtonColor = primaryColor;
        audioIconColor = Colors.white;
        update();
      }
      else if(animationController.isDismissed) {
        audioButtonColor = null;
        audioIconColor = iconColor;
        update();
      }
    });

    timerWidth = Get.width /*- 2 * Globals.defaultPadding - 4*/;
    timerAnimation =
        Tween<double>(begin: timerWidth + Globals.defaultPadding, end: 0).animate(CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.2, 1, curve: Curves.easeIn),
        ));
    lockerAnimation =
        Tween<double>(begin: lockerHeight + Globals.defaultPadding, end: 0).animate(CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.2, 1, curve: Curves.easeIn),
        ));
  }

  void onChangeTextMessage(String value) {
    //messageSecondState = textEditingController.value.text.trim().isEmpty;
    messageSecondState = value.trim().isEmpty;
    if(_messageFirstState != messageSecondState) {
      _messageFirstState = messageSecondState;
    }
    update();
  }

  onLongPressMoveUpdate(details){
    if(!isCancel) {
      var width = Get.width * 0.7;
      var dx = details.localPosition.dx;
      if (dx > 50 && dx < width + 127)
        slidePositionDx = 127.0 + dx / 3;
      /*else
        slidePositionDx = 127;*/

      if (isCancel = isCancelled(Offset(slidePositionDx, 0))) {
        Vibrate.feedback(FeedbackType.heavy);
        stopWatchTimer.onExecute.add(StopWatchExecute.reset);

        showLottie = true;
        slidePositionDx = 127;

        Timer(const Duration(milliseconds: 1440), () async {
          animationController.reverse();
          debugPrint("Cancelled recording");
          var filePath = await record.stop();
          debugPrint(filePath);
          File(filePath!).delete();
          debugPrint("Deleted $filePath");
          showLottie = false;
        });
      }
      update();
    }
  }

  onLongPressDown(details){
    debugPrint("onLongPressDown");
    isRecordBoxShowing = true;
    //debugPrint("details.localPosition= ${details.localPosition.dx}");
    animationController.forward();
    update();
  }

  onLongPressEnd(details, Function(String?, Map<String, dynamic>) sendRequestFunction) async {
    debugPrint("onLongPressEnd");

    if (checkIsLocked(details.localPosition)) {
      timerHeight*=2;
      animationController.reverse();

      Vibrate.feedback(FeedbackType.heavy);
      debugPrint("Locked recording");
      debugPrint(details.localPosition.dy.toString());
      isLocked = true;
      update();
    }
    else if(!isCancel){
      debugPrint("_____________________________");
      animationController.reverse();
      sendRecord((filePath, fileInfo) => sendRequestFunction(filePath, fileInfo));
    }
    isCancel = false;

    if(!isLocked) {
     isRecordBoxShowing = false;
     update();
    }
  }

  onLongPressCancel(){
    debugPrint("onLongPressCancel");
    animationController.reverse();
  }

  onLongPress(roomId, messageId) async {
    debugPrint("onLongPress");
    Vibrate.feedback(FeedbackType.success);
    if (await Record().hasPermission()) {
      String audioPath = await getAudioPath(roomId, messageId, extension: ".wave");
      Timer(const Duration(milliseconds: 900), () {
        record.start(
          path: audioPath,
          encoder: AudioEncoder.AAC,
          bitRate: 128000,
          samplingRate: 44100,
        );
        stopWatchTimer.onExecute.add(StopWatchExecute.start);
      });
    }
  }

  resumeTimer(){
    stopWatchTimer.onExecute.add(StopWatchExecute.start);
    record.resume();
    update();
  }

  pauseTimer(){
    stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    record.pause();
    update();
  }

  bool checkIsLocked(Offset offset) {
    return (offset.dy < -35);
  }

  bool isCancelled(Offset offset) {
    return (offset.dx > (Get.width * 0.5));
  }


  void hideRecordBox() {
    isRecordBoxShowing = false;
    isLocked = false;
    timerHeight/=2;
    update();
  }

  void cancelRecord() async {
    Vibrate.feedback(FeedbackType.heavy);
    stopWatchTimer.onExecute.add(StopWatchExecute.reset);

    debugPrint("Cancelled recording");
    var filePath = await record.stop();
    debugPrint(filePath);
    File(filePath!).delete();
    debugPrint("Deleted $filePath");

    update();
  }

  void sendRecord(Function(String?, Map<String, dynamic>) sendRequestFunction) async {
    Vibrate.feedback(FeedbackType.success);

    String? filePath = await Record().stop();
    var duration = "$minute:$second";
    debugPrint("durationMs= $duration");
    Map<String, dynamic>? fileInfo={
      MessageAudioInfoKey.duration: duration,
      MessageAudioInfoKey.size: getFileSize(1, filePath),
    };
    sendRequestFunction(filePath, /*messageId, */ fileInfo);
    debugPrint("filePath= $filePath");
    stopWatchTimer.onExecute.add(StopWatchExecute.reset);
  }

  @override
  void dispose() {
    stopWatchTimer.dispose();
    isCancel = false;
    record.dispose();
    super.dispose();
  }
}