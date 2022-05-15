
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class DateFormatterTools {

  late DateTime _dateTime;
  late DateTime _now;
  late DateTime _localDateTime;

  DateFormatterTools(int timeInMilliseconds){
    _dateTime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
    _now = DateTime.now();
    _localDateTime = _dateTime.toLocal();
  }

  String get _yesterday =>"yesterday".tr;

  bool _inThisDay(){
    return _localDateTime.day == _now.day &&
        _localDateTime.month == _now.month &&
        _localDateTime.year == _now.year;
  }

  String formatStateTime(){
    DateFormat.useNativeDigitsByDefaultFor(Get.deviceLocale!.languageCode, false);
    /*Localizations.localeOf(context).toLanguageTag()*/
    String roughTimeString = DateFormat('jm', Get.deviceLocale!.languageCode).format(_dateTime);

    if (_inThisDay()) {
      return roughTimeString;
    }
    else{
      var date="";
      if (inYesterday()) {
        date = _yesterday;
      }
      else if (_now.difference(_localDateTime).inDays < 4) {
        String weekday =
        DateFormat('EEEE', Get.deviceLocale!.languageCode).format(_localDateTime);
        date = weekday;
      }
      else{
        //yMMMd
        date = DateFormat('yMd', Get.deviceLocale!.languageCode).format(_dateTime);
      }
      return '$date, $roughTimeString';
    }
  }

  String formatMessageTime(){
    DateFormat.useNativeDigitsByDefaultFor(Get.deviceLocale!.languageCode, false);
    /*Localizations.localeOf(context).toLanguageTag()*/
    return DateFormat(' a h:mm',  Get.deviceLocale!.languageCode).format(_dateTime);
  }

  String formatRoomTime({bool timeOnly = false}) {

    DateFormat.useNativeDigitsByDefaultFor(Get.deviceLocale!.languageCode, false);
    String roughTimeString = DateFormat('jm', Get.deviceLocale!.languageCode).format(_dateTime);

    if (timeOnly || _inThisDay()){
      return roughTimeString;
    }

    if (inYesterday()) {
      return _yesterday;
    }
    if (_now.difference(_localDateTime).inDays < 4) {
      String weekday =
      DateFormat('EEEE', Get.deviceLocale!.languageCode).format(_localDateTime);
      //return '$weekday, $roughTimeString';
      return weekday;
    }
    //yMMMd
    return DateFormat('yMd', Get.deviceLocale!.languageCode).format(_dateTime);
  }

  bool inYesterday() {
    DateTime yesterday = _now.subtract(Duration(days: 1));
    return _localDateTime.day == yesterday.day &&
        _localDateTime.month == _now.month &&
        _localDateTime.year == _now.year;
  }

}