import 'package:flutter/material.dart';
import 'package:flutter_chat_app/control/language/ar.dart';
import 'package:flutter_chat_app/control/language/en.dart';
import 'package:get/get.dart';



class TranslationService extends Translations {
  static Locale? get locale => Get.deviceLocale;
  static final fallbackLocale = Locale('en');
  @override
  Map<String, Map<String, String>> get keys => {
    'en': en,
    'ar': ar,
  };
}