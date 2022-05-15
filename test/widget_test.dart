// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/views/pages/chat/message/db_helper/message_db_helper.dart';
import 'package:flutter_chat_app/views/pages/chat/message/model/message.dart';
import 'package:flutter_chat_app/views/pages/chat/room/db_helper/room_db_helper.dart';
import 'package:flutter_chat_app/views/pages/chat/room/model/room.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_chat_app/main.dart';
import 'package:hive/hive.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'dart:io';
import 'package:path/path.dart';

void main() {

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    //AnimatedSwitcherLayoutBuilder();
    if (await FlutterContacts.requestPermission()) {
      List<Contact> contacts =
      await FlutterContacts.getContacts(withProperties: true, withPhoto: true);
      var x=contacts.expand((element) => {element.displayName, element.phones.map((e) => e.number)}).toList();
      print("x=${x.toString()}");
    }
  });

  test("", () {
    var messageBox = Hive.box<Message>(MessageDBHelper.table);
    var roomBox = Hive.box<Room>(RoomDBHelper.table);
    print(roomBox.values.toString());
  },);
}
