import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utilities/files.dart';
import 'package:flutter_chat_app/views/pages/chat/message/model/message.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({Key? key}) : super(key: key);

  @override
  _VideoPlayerViewState createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late Message message;
  late File videoFile;
  late VideoPlayerController controller;
  late Duration duration;
  Duration? position = Duration();

  late String time;

  @override
  void initState() {
    super.initState();
    var arguments = Get.arguments as Map<String, dynamic>;
    message = arguments['message'];
    time = DateTime.fromMillisecondsSinceEpoch(message.time).toIso8601String();
    videoFile = arguments['videoFile'];
    duration = extractDurationFromString(message.fileInfo![MessageVideoInfoKey.duration]);
    controller = VideoPlayerController.file(videoFile)
      ..initialize()
      ..setLooping(true)
      ..play();
    controller.addListener(updateSlider);
  }

  void updateSlider() async{
    final newPosition = await controller.position;
    //debugPrint("newPosition!.compareTo(duration)= ${newPosition!.compareTo(duration)}");
    if(newPosition!.compareTo(duration) < 0) {
      if(mounted)
        setState(() {
          position = newPosition;
        });
    }
    else if(newPosition.compareTo(duration) >= 0){
      controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    //RotatedBox(quarterTurns: quarterTurns);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.black.withOpacity(.1),
        middle: Text(time),
      ),
      child: Stack(
        children: [
          GestureDetector(
            onTap: playPause,
            child: Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                CupertinoButton(
                  child: Icon(controller.value.isPlaying ? CupertinoIcons.pause : CupertinoIcons.play_arrow_solid),
                  minSize: 50,
                  padding: EdgeInsets.zero,
                  onPressed: playPause,
                ),
                Expanded(
                  child: CupertinoSlider(
                    max:duration.inMilliseconds.toDouble(),
                    value: position?.inMilliseconds.toDouble() ?? 0.0,
                    onChanged: (double value) {
                      controller.seekTo(value.milliseconds);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.removeListener(updateSlider);
    controller.dispose();
    super.dispose();
  }

  playPause() {
    setState(() {
      controller.value.isPlaying
          ? controller.pause()
          : controller.play();
    });
  }
}
