import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/main.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/media_information.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;


enum FileMediaType{
  image,
  video,
  audio,
}

Duration extractDurationFromString(String durString) {
  var splitList = durString.split(':');
  List<int> cast = [for(var i in splitList) int.parse(i)];

  if (cast.length == 3) {
    debugPrint("durString source= $durString");
    debugPrint("durString extract= ${Duration(hours: cast[0], minutes: cast[1], seconds: cast[2])}");
    return Duration(hours: cast[0], minutes: cast[1], seconds: cast[2]);
  }
  else {
    debugPrint("durString source= $durString");
    debugPrint("durString extract= ${Duration(minutes: cast[0], seconds: cast[1])}");
    return Duration(minutes: cast[0], seconds: cast[1]);
  }

  debugPrint("durString= $durString");
  int m = int.parse(durString.substring(0, 2));
  int s = int.parse(durString.substring(3));
  debugPrint("m= $m");
  debugPrint("s= $s");
  return Duration(minutes: m, seconds: s);
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String value= "";
  //String temp = twoDigits(duration.inHours);
  int temp = duration.inHours.remainder(60);
  if (temp != 0) {
    value = "$temp:";
    value += "${twoDigits(duration.inMinutes.remainder(60))}:";
  }
  else
    value += "${duration.inMinutes.remainder(60)}:";

  value += twoDigits(duration.inSeconds.remainder(60));
  return value;
}

String getFileSize(int decimals, path) {
  var file = File(path);
  int bytes = file.lengthSync();
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (math.log(bytes) / math.log(1024)).floor();
  return((bytes / math.pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
}


void deleteRoomResources(FileMediaType mediaType, String roomId) async {
  String _sdPath = await getDirectory(fileMediaType: mediaType, roomId: roomId);

  var d = Directory(_sdPath);
  debugPrint("delete path= ${d.path}");
  if (d.existsSync()) {
    d.deleteSync(recursive: true);
    debugPrint("delete done roomId= $roomId");
  }
}

void deleteMessageResources(FileMediaType mediaType, String roomId, String messageId) async {
  String _sdPath = await getDirectory(fileMediaType: mediaType, roomId: roomId);

  var d = File(_sdPath);
  debugPrint("delete File= ${d.path}");
  if (d.existsSync()) {
    d.deleteSync(recursive: true);
    debugPrint("delete done roomId= $roomId");
  }
}

Future<String> getImageThumbnailPath(String roomId, String messageId, {String extension = ".jpg"}) async {
  String _sdPath = await getDirectory(fileMediaType: FileMediaType.image, roomId: roomId);
  _sdPath = p.join(_sdPath, "thumbnail");
  var d = Directory(_sdPath);
  if (!d.existsSync()) {
    d.createSync(recursive: true);
  }
  return p.join(_sdPath, messageId+extension);
}

Future<String> getVideoThumbnailPath(String roomId, String messageId, {String extension = ".jpg"}) async {
  String _sdPath = await getDirectory(fileMediaType: FileMediaType.video, roomId: roomId);
  _sdPath = p.join(_sdPath, "thumbnail");
  var d = Directory(_sdPath);
  if (!d.existsSync()) {
    d.createSync(recursive: true);
  }
  return p.join(_sdPath, messageId+extension);
}

Future<String> getVideoPath(String roomId, String messageId, {String extension = ".mp4"}) async {
  String _sdPath = await getDirectory(fileMediaType: FileMediaType.video, roomId: roomId);
  var d = Directory(_sdPath);
  if (!d.existsSync()) {
    d.createSync(recursive: true);
  }
  return p.join(_sdPath,messageId+extension);
}

Future<String> getImagePath(String roomId, String messageId, {String extension = ".jpg"}) async {
  String _sdPath = await getDirectory(fileMediaType: FileMediaType.image, roomId: roomId);
  var d = Directory(_sdPath);
  if (!d.existsSync()) {
    d.createSync(recursive: true);
  }
  return p.join(_sdPath,messageId+extension);
}

Future<String> getAudioPath(String roomId, String messageId, {String extension = ".m4a"}) async {
  String _sdPath = await getDirectory(fileMediaType: FileMediaType.audio, roomId: roomId);
  var d = Directory(_sdPath);
  if (!d.existsSync()) {
    d.createSync(recursive: true);
  }

  return p.join(_sdPath, /*"$messageId.m4a", */messageId+extension);
}

Future<String> getDirectory({
  required FileMediaType fileMediaType,
  required String roomId,
}) async{
  if (Platform.isIOS) {
    //Directory tempDir = await getTemporaryDirectory();
    return "${(await getTemporaryDirectory()).path}/${fileMediaType.name}/$roomId";
  } else {
    var appName = "app_name".tr;
    return "/storage/emulated/0/$appName/${fileMediaType.name}/$roomId";
  }
}

File getAndCreateFile({
  required FileMediaType fileMediaType,
  required String folderName,
  required String filename,}) {

  String pathName = p.join(dir.path, fileMediaType.name, folderName, filename);

  return File(pathName);
}

File fileFromDocsDir(String filename)  {
  String pathName = p.join(dir.path, filename);
  return File(pathName);
}


Future<File> getImageFileFromAssets(String assetsPath, String filePath) async {
  final byteData = await rootBundle.load('assets/$assetsPath');

  //final file = File('${(await getTemporaryDirectory()).path}/$filePath');
  final file = File(filePath);
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}