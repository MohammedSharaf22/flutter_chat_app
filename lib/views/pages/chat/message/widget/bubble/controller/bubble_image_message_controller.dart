import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/control/constants/firebase_auth_constants.dart';
import 'package:flutter_chat_app/utilities/files.dart';
import 'package:flutter_chat_app/views/pages/chat/message/model/message.dart';
import 'package:flutter_chat_app/views/pages/chat/room/controller/room_controller.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class BubbleImageMessageController extends GetxController {
  RxBool isDownloading = false.obs;
  RxBool isLoading = false.obs;
  RxBool isFailure = false.obs;
  late File imageFile;
  late File thumbnailFile;
  UploadTask? _uploadTask;
  DownloadTask? _downloadTask;

  Future<void> download(bool isSender, Message message) async {
    try {
      log("BubbleImageMessageController -> download();");
      isFailure.value = false;
      if (isSender) {
        if(message.url == null  ||   message.url!.isEmpty){
          log("download() -> if(widget.message.url==null || widget.message.url!.isEmpty)");
          uploadImage(isSender, message);
        }
        else {
          setImageToFile(isSender, message);
        }
      }
      else {
        if (!await imageFile.exists()) {
          downloadImage(isSender, message);
        }
        else {
          setImageToFile(isSender, message);
        }
      }
    } on firebase_core.FirebaseException catch (e) {
      isFailure.value = true;
      isLoading.value = false;
      isDownloading.value = false;
      debugPrint("BubbleImageMessageController -> download() isFailure= $isFailure");
      log("BubbleImageMessageController -> download() Exception: \n ${e.message}");
    }
    catch (e){
      isFailure.value = true;
      isLoading.value = false;
      isDownloading.value = false;
      debugPrint("BubbleImageMessageController -> download() isFailure= $isFailure");
      log("BubbleImageMessageController -> download() Exception: \n $e");
    }
  }

  Future<void> uploadImage(isSender, Message message) async {
    isLoading.value = true;
    log("BubbleImageMessageController -> uploadImage();");

    String imagePath = p.join(FileMediaType.image.name, message.roomId);

    log("BubbleImageMessageController -> upload thumbnailFile");
    ///upload thumbnailFile
    await firebaseStorage.ref(p.join(imagePath, "thumbnail")).child(p.basename(thumbnailFile.path))
        .putFile(thumbnailFile, SettableMetadata(customMetadata: {
      'uploaded_by': '${message.senderPhone}',
    })).then((p0) async{
      message.fileInfo![MessageImageInfoKey.thumbUrl] = await p0.ref.getDownloadURL();
    });

    log("BubbleImageMessageController -> compress imageFile");
    ///Compress imageFile
    CompressFormat format = CompressFormat.jpeg;
    /*if (extension != ".jpg" && extension != ".jpeg"){
      var ex = extension.substring(1).toLowerCase();
      format = CompressFormat.values.singleWhere((element) => element.name == ex);
    }*/
    Uint8List? uint8list = await FlutterImageCompress.compressWithFile(
      imageFile.path,
      minHeight: message.fileInfo![MessageImageInfoKey.height],
      minWidth: message.fileInfo![MessageImageInfoKey.width],
      quality: 50,
      format: format,
    );
    imageFile = await imageFile.writeAsBytes(uint8list!);

    log("BubbleImageMessageController -> upload imageFile");
    ///upload imageFile
    //Stopwatch stopwatch = Stopwatch()..start();
    _uploadTask = firebaseStorage.ref(imagePath).child(p.basename(imageFile.path))
        .putFile(imageFile, SettableMetadata(customMetadata: {
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
        setImageToFile(isSender, message);
      }
      if(p0.state==TaskState.error || p0.state==TaskState.canceled || p0.state==TaskState.paused) {
        isFailure.value = true;
        isLoading.value = false;
        isDownloading.value = false;
        debugPrint("BubbleImageMessageController -> uploadImage() isFailure= $isFailure");
      }
    }).catchError((e, stackTrace){
      isFailure.value = true;
      isLoading.value = false;
      isDownloading.value = false;
      debugPrint("BubbleImageMessageController -> uploadImage() isFailure= $isFailure");
      log("BubbleImageMessageController -> uploadImage() $e", stackTrace: stackTrace);
    });
  }

  Future<void> downloadImage(isSender, Message message) async {
    log("BubbleImageMessageController -> downloadImage();");
    isLoading.value  = true;
    try {
      imageFile = File(await getImagePath(message.roomId, message.messageId,
          extension: message.fileInfo![MessageImageInfoKey.extension]));
      _downloadTask = firebaseStorage.refFromURL(message.url!).writeToFile(imageFile);
      _downloadTask?.timeout(Duration(minutes: 1)).then((p0) {
        setImageToFile(isSender, message);
      }).catchError((e, stackTrace) {
        isFailure.value = true;
        isLoading.value = false;
        isDownloading.value = false;
        debugPrint(
            "BubbleImageMessageController -> downloadImage() isFailure= $isFailure");
        log("BubbleImageMessageController -> downloadImage() $e",
            stackTrace: stackTrace);
        debugPrint("message.url= ${message.url}");
      });
    }on firebase_core.FirebaseException catch (e) {
      isFailure.value = true;
      isLoading.value = false;
      isDownloading.value = false;
      debugPrint("BubbleImageMessageController -> downloadImage() isFailure= $isFailure");
      debugPrint("BubbleImageMessageController -> downloadImage() Exception: \n ${e.message}");
      debugPrint("BubbleImageMessageController -> downloadImage() stackTrace: \n ${e.stackTrace}");
    }
  }

  void setImageToFile(isSender, Message message) async {
    log("BubbleImageMessageController -> setImageToPlayer();");

    isDownloading.value = true;
    isLoading.value  = false;
    imageFile = File(message.localPath!);

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

  void initImageFile(String path, thumbPath){
    imageFile = File(path);
    thumbnailFile = File(thumbPath);
  }
}