import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/control/constants/firebase_auth_constants.dart';
import 'package:flutter_chat_app/utilities/files.dart';
import 'package:flutter_chat_app/views/pages/chat/message/model/message.dart';
import 'package:flutter_chat_app/views/pages/chat/room/controller/room_controller.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:video_compress/video_compress.dart';

class BubbleVideoMessageController extends GetxController {
  RxBool isDownloading = false.obs;
  RxBool isLoading = false.obs;
  RxBool isFailure = false.obs;
  late File videoFile;
  late File thumbnailFile;
  UploadTask? _uploadTask;
  DownloadTask? _downloadTask;

  Future<void> download(bool isSender, Message message) async {
    try {
      log("BubbleVideoMessageController -> download();");
      isFailure.value = false;
      if (isSender) {
        if(message.url == null  ||   message.url!.isEmpty){
          log("download() -> if(widget.message.url==null || widget.message.url!.isEmpty)");
          uploadVideo(isSender, message);
        }
        else {
          setVideoToFile(isSender, message);
        }
      }
      else {
        if (!await videoFile.exists()) {
          downloadVideo(isSender, message);
        }
        else {
          setVideoToFile(isSender, message);
        }
      }
    } on firebase_core.FirebaseException catch (e) {
      isFailure.value = true;
      isLoading.value = false;
      isDownloading.value = false;
      debugPrint("BubbleVideoMessageController -> download() isFailure= $isFailure");
      log("BubbleVideoMessageController -> download() Exception: \n ${e.message}");
    }
    catch (e){
      isFailure.value = true;
      isLoading.value = false;
      isDownloading.value = false;
      debugPrint("BubbleVideoMessageController -> download() isFailure= $isFailure");
      log("BubbleVideoMessageController -> download() Exception: \n $e");
    }
  }

  Future<void> uploadVideo(isSender, Message message) async {
    isLoading.value = true;
    log("BubbleVideoMessageController -> uploadVideo();");

    String videoPath = p.join(FileMediaType.video.name, message.roomId);

    ///upload thumbnailFile
    await firebaseStorage.ref(p.join(videoPath, "thumbnail")).child(p.basename(thumbnailFile.path))
        .putFile(thumbnailFile, SettableMetadata(customMetadata: {
      'uploaded_by': '${message.senderPhone}',
    })).then((p0) async{
      message.fileInfo![MessageVideoInfoKey.thumbUrl] = await p0.ref.getDownloadURL();
    });

    ///Compress videoFile
    MediaInfo? mediaInfo = await VideoCompress.compressVideo(
      message.localPath!,
      quality: VideoQuality.MediumQuality,
      //deleteOrigin: true,
    );
    videoFile = (await mediaInfo?.file?.copy(message.localPath!))!;

    ///upload videoFile
    //Stopwatch stopwatch = Stopwatch()..start();
    _uploadTask = firebaseStorage.ref(videoPath).child(p.basename(videoFile.path))
        .putFile(videoFile, SettableMetadata(customMetadata: {
      'uploaded_by': '${message.senderPhone}',
    }));
    _uploadTask?.snapshotEvents.listen((event) {
      if (event.state==TaskState.running) {
        debugPrint("bytesTransferred= %${event.bytesTransferred/event.totalBytes*100}");
      }
    });
    _uploadTask?.timeout(Duration(minutes: 1)).then((p0) async {
      if(p0.state == TaskState.success) {
        debugPrint("uploaded File");
        message.url = await p0.ref.getDownloadURL();
        RoomController.instance.sendMessageToFirestore(message);
        setVideoToFile(isSender, message);
      }
      if(p0.state==TaskState.error || p0.state==TaskState.canceled || p0.state==TaskState.paused) {
        isFailure.value = true;
        isLoading.value = false;
        isDownloading.value = false;
        debugPrint("BubbleVideoMessageController -> uploadVideo() isFailure= $isFailure");
      }
    }).catchError((e, stackTrace){
      isFailure.value = true;
      isLoading.value = false;
      isDownloading.value = false;
      debugPrint("BubbleVideoMessageController -> uploadVideo() isFailure= $isFailure");
      log("BubbleVideoMessageController -> uploadVideo() $e", stackTrace: stackTrace);
    });
    VideoCompress.deleteAllCache();
  }

  Future<void> downloadVideo(isSender, Message message) async {
    log("BubbleVideoMessageController -> downloadVideo();");
    isLoading.value  = true;
    try {
      ///download thumbnailFile
      thumbnailFile = File(await getVideoThumbnailPath(message.roomId, message.messageId));
      var thumbUrl = message.fileInfo![MessageVideoInfoKey.thumbUrl];
      await firebaseStorage.refFromURL(thumbUrl).writeToFile(thumbnailFile)
          .then((p0) {
            message.fileInfo![MessageVideoInfoKey.thumbLocal] = thumbnailFile.path;
          });

      ///download videoFile
      videoFile = File(await getVideoPath(message.roomId, message.messageId,
          extension: message.fileInfo![MessageVideoInfoKey.extension]));
      _downloadTask = firebaseStorage.refFromURL(message.url!).writeToFile(videoFile);
      _downloadTask?.timeout(Duration(minutes: 1)).then((p0) {
        message.localPath = videoFile.path;
        RoomController.instance.messageBox.put(message.messageId, message);
        setVideoToFile(isSender, message);
      }).catchError((e, stackTrace) {
        isFailure.value = true;
        isLoading.value = false;
        isDownloading.value = false;
        debugPrint(
            "BubbleVideoMessageController -> downloadVideo() isFailure= $isFailure");
        log("BubbleVideoMessageController -> downloadVideo() $e",
            stackTrace: stackTrace);
        debugPrint("message.url= ${message.url}");
      });
    }on firebase_core.FirebaseException catch (e) {
      isFailure.value = true;
      isLoading.value = false;
      isDownloading.value = false;
      debugPrint("BubbleVideoMessageController -> downloadVideo() isFailure= $isFailure");
      debugPrint("BubbleVideoMessageController -> downloadVideo() Exception: \n ${e.message}");
      debugPrint("BubbleVideoMessageController -> downloadVideo() stackTrace: \n ${e.stackTrace}");
    }
  }

  void setVideoToFile(isSender, Message message) async {
    log("BubbleVideoMessageController -> setVideoToPlayer();");

    isDownloading.value = true;
    isLoading.value  = false;
    videoFile = File(message.localPath!);

  }

  void onDownloadOrUploadButtonClick(isSender, Message message) async {
    if(isLoading.value){
      if(isSender)
        _uploadTask?.pause();
      else
        _downloadTask?.pause();
      isFailure.value = true;
      isLoading.value = false;
      isDownloading.value = false;
    }
    else if(isFailure.value){
      download(isSender, message);
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

  Color invertColor(Color color) {
    final r = 255 - color.red;
    final g = 255 - color.green;
    final b = 255 - color.blue;

    return Color.fromARGB((color.opacity * 255).round(), r, g, b);
  }

  initVideoFile(String path, thumbPath){
    videoFile = File(path);
    thumbnailFile = File(thumbPath);
  }
}