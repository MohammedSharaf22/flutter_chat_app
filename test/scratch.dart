

import 'dart:io';
import 'dart:math';

import 'package:intl/intl.dart';


void main() async {
  //var dateTime = DateTime.fromMillisecondsSinceEpoch(1652037297872);
  /*var dateTime = DateTime.now().subtract(Duration(seconds: 3));

  var x = DateFormatterTools.getVerboseDateTimeRepresentation(dateTime);
  //print(x);
  var xx = DateFormatterTools.formatMessageTime(timeInMilliseconds: dateTime.millisecondsSinceEpoch);
  //print(xx);*/
  print(DateTime.now().millisecondsSinceEpoch);


}

class DateFormatterTools {
  //Get.locale!.languageCode
  static String formatMessageTime({required int timeInMilliseconds}){
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
    return DateFormat(' a h:mm',  Platform.localeName).format(dateTime);
  }

  static String getVerboseDateTimeRepresentation( DateTime dateTime,
      {bool timeOnly = false}) {
    DateTime now = DateTime.now();
    //DateTime justNow = now.subtract(Duration(minutes: 1));
    DateTime localDateTime = dateTime.toLocal();

    /*if (!localDateTime.difference(justNow).isNegative) {
      return "just_now";
    }*/

    String roughTimeString = DateFormat('jm').format(dateTime);

    if (timeOnly ||
        (localDateTime.day == now.day &&
            localDateTime.month == now.month &&
            localDateTime.year == now.year)) {
      return roughTimeString;
    }

    DateTime yesterday = now.subtract(Duration(days: 1));

    if (localDateTime.day == yesterday.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return "yesterday";
    }

    if (now.difference(localDateTime).inDays < 4) {//Localizations.localeOf(context).toLanguageTag()
      //String weekday = DateFormat('E', 'en').format(localDateTime);
      String weekday= "";
      try{
        weekday = DateFormat('EEEE'/*, 'en'*/).format(localDateTime);
      }catch(e){
        print(e.toString());
      }

      //return '$weekday, $roughTimeString';
      return weekday;
    }

    return DateFormat('yMMMd', 'en').format(dateTime);
  }
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

getFileSize(bytes, int decimals) async {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
}

enum FileMediaType{
  image,
  video,
  audio,
}




class F{
  init(){
    A a=A();
    a.setListener((x) {
      print("F class= $x");
    });
  }
}

class A {
  late Listener listener;
  void setListener(void onClick(int x)) {
    onClick.call(10);
    print("A class");
  }

  printOnClick(){
    listener.onClick();
  }
}

abstract class Listener{

  void onClick();
}