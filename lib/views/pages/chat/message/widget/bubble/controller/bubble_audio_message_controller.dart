import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/control/constants/firebase_auth_constants.dart';
import 'package:flutter_chat_app/utilities/files.dart';
import 'package:flutter_chat_app/views/pages/chat/message/model/message.dart';
import 'package:flutter_chat_app/views/pages/chat/room/controller/room_controller.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class BubbleAudioMessageController extends GetxController {

  late AudioPlayer audioPlayer;
  late Rx<Duration> duration;
  late Rx<Duration> position;
  RxBool isDownloading = false.obs;
  RxBool isPlaying = false.obs;
  RxBool isLoading = false.obs;
  RxBool isPause = false.obs;
  RxBool isFailure = false.obs;
  late File soundFile;
  final FlutterFFprobe flutterFFProbe =  FlutterFFprobe();
  UploadTask? _uploadTask;
  DownloadTask? _downloadTask;



  @override
  void onInit() {
    super.onInit();
    audioPlayer = AudioPlayer();
    duration = Duration.zero.obs;
    position = Duration().obs;
    //download();
  }

  Future<void> download(bool isSender, Message message) async {
    try {
      log("BubbleNormalAudioController -> download();");
      isFailure.value = false;
      if (isSender) {
        if(message.url == null  ||   message.url!.isEmpty){
          log("download() -> if(widget.message.url==null || widget.message.url!.isEmpty)");
           uploadAudio(isSender, message);
        }
        else
          setAudioToPlayer(isSender, message);
      }
      else {
        if (!await soundFile.exists()) {
          downloadAudio(isSender, message);
        }
        else
          setAudioToPlayer(isSender, message);
      }
    } on firebase_core.FirebaseException catch (e) {
      isFailure.value = true;
      isLoading.value = false;
      isDownloading.value = false;
      debugPrint("BubbleNormalAudioController -> download() isFailure= ${isFailure.value}");
      log("BubbleNormalAudioController -> download() Exception: \n ${e.message}");
    }
    catch (e){
      isFailure.value = true;
      isLoading.value = false;
      isDownloading.value = false;
      debugPrint("BubbleNormalAudioController -> download() isFailure= ${isFailure.value}");
      log("BubbleNormalAudioController -> download() Exception: \n $e");
    }
  }

  Future<void> uploadAudio(isSender, Message message) async {

    isLoading.value = true;
    log("BubbleNormalAudioController -> uploadAudio();");
    //Stopwatch stopwatch = Stopwatch()..start();
    String path = p.join(FileMediaType.audio.name, message.roomId);
    _uploadTask = firebaseStorage.ref(path)
        .child(p.basename(soundFile.path))
        .putFile(soundFile, SettableMetadata(customMetadata: {
      'uploaded_by': '${message.senderPhone}',
    }));
    _uploadTask?.timeout(Duration(minutes: 1)).then((p0) async {
      //debugPrint("soundFile.lengthSync()= ${soundFile.lengthSync()}");
      //debugPrint("stopwatch.elapsed.inSeconds = ${stopwatch.elapsed.inSeconds}");
      if(p0.state == TaskState.success) {
        debugPrint("uploaded File");
        message.url = await p0.ref.getDownloadURL();
        //RoomController.instance.messageBox.put(message.messageId, message);
        RoomController.instance.sendMessageToFirestore(message);
        setAudioToPlayer(isSender, message);
      }
      if(p0.state==TaskState.error || p0.state==TaskState.canceled || p0.state==TaskState.paused) {
        isFailure.value = true;
        isLoading.value = false;
        isDownloading.value = false;
        debugPrint("BubbleNormalAudioController -> uploadAudio() isFailure= ${isFailure.value}");
      }
    }).catchError((e, stackTrace){
      isFailure.value=true;
      isLoading.value = false;
      isDownloading.value = false;
      debugPrint("BubbleNormalAudioController -> uploadAudio() isFailure= ${isFailure.value}");
      log("BubbleNormalAudioController -> uploadAudio() $e", stackTrace: stackTrace);
    });
  }

  Future<void> downloadAudio(isSender, Message message) async {
    log("BubbleNormalAudioController -> downloadAudio();");
    isLoading.value = true;

    soundFile = File(await getAudioPath(message.roomId, message.messageId));
    _downloadTask = firebaseStorage.refFromURL(message.url!).writeToFile(soundFile);
    _downloadTask?.timeout(Duration(minutes: 1)).then((p0) {
      setAudioToPlayer(isSender, message);
    }).catchError((e, stackTrace){
      isFailure.value=true;
      isLoading.value = false;
      isDownloading.value = false;
      debugPrint("BubbleNormalAudioController -> downloadAudio() isFailure= ${isFailure.value}");
      log("BubbleNormalAudioController -> downloadAudio() $e", stackTrace: stackTrace);
    });
  }

  void setAudioToPlayer(isSender, Message message) async {
    log("BubbleNormalAudioController -> setAudioToPlayer();");

    await audioPlayer.setUrl(soundFile.path, isLocal: true);
    duration.value = extractDurationFromString(message.fileInfo![MessageAudioInfoKey.duration]);
    /*flutterFFProbe.getMediaInformation(soundFile.path).then((value) {
      var mediaProperties=value.getMediaProperties();
      //debugPrint("audioDuration= ${value.getMediaProperties()!['duration']}");
      if(mediaProperties!=null) {
        int audioDuration =double.parse(mediaProperties['duration']).round();
        debugPrint("audioDuration= $audioDuration");
        duration.value = Duration(seconds: audioDuration);
      }
    }).catchError((e, stackTrace){
      debugPrint("Error BubbleNormalAudioController setAudioToPlayer() -> $e");
      debugPrint("StackTrace BubbleNormalAudioController setAudioToPlayer() -> $stackTrace");
    });*/
    isDownloading.value = true;
    isLoading.value = false;

    audioPlayer.onDurationChanged.listen((Duration d) {
      log("onDurationChanged= $d");
      duration.value = d;
      isLoading.value = false;
    });

    audioPlayer.onAudioPositionChanged.listen((Duration p) {
      position.value = Duration(microseconds: p.inMicroseconds);
      log("position: ${position.value.inMilliseconds}");
    });

    audioPlayer.onPlayerCompletion.listen((event) {
      isPlaying.value = false;
      position.value = Duration.zero;
    });


    /*audioPlayer.getDuration().then((value) {
      duration.value = Duration(milliseconds: value);

      return value;
    });*/
  }

  onSeekChanged(double value) {
    position.value = Duration(milliseconds: value.toInt());
    audioPlayer.seek(position.value);
  }

  onPlayPauseButtonClick(isSender, Message message) async {
    if(isDownloading.value) {
      if (isPause.value) {
        await audioPlayer.resume();
        isPlaying.value = true;
        isPause.value = false;

      } else if (isPlaying.value) {
        await audioPlayer.pause();
        isPlaying.value = false;
        isPause.value = true;
      } else {
        await audioPlayer.play(soundFile.path, isLocal: true);
        isPlaying.value = true;
      }
    }
    else if(isFailure.value){
      download(isSender, message);
    }
    else if(isLoading.value){
      if(isSender)
        _uploadTask?.pause();
      else
        _downloadTask?.pause();
      isFailure.value = true;
      isLoading.value = false;
      isDownloading.value = false;
    }
    else {
      if(isSender && _uploadTask != null)
        _uploadTask?.resume();
      else if(_downloadTask != null)
        _downloadTask?.resume();
      isFailure.value = false;
      isLoading.value = true;
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }



  Color invertColor(Color color) {
    final r = 255 - color.red;
    final g = 255 - color.green;
    final b = 255 - color.blue;

    return Color.fromARGB((color.opacity * 255).round(), r, g, b);
  }

  void initAudioFile(String path){
    soundFile = File(path);
  }
}