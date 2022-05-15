import 'package:flutter_chat_app/control/database/database_helper.dart';
import 'package:flutter_chat_app/views/pages/chat/message/model/message.dart';
import 'package:sqflite/sqflite.dart';

class MessageDBHelper extends DatabaseHelper{
  static final table = 'message';

  static GetSchema()=>
      '''
  CREATE TABLE $table (
    ${MessageColumns.messageId} TEXT PRIMARY KEY,
    ${MessageColumns.roomId} Text NOT NULL,
    ${MessageColumns.senderId} TEXT NOT NULL,
    ${MessageColumns.senderPhone} TEXT,
    ${MessageColumns.text} TEXT,
    ${MessageColumns.type} INTEGER NOT NULL DEFAULT ${MessageType.text},
    ${MessageColumns.url} TEXT,
    ${MessageColumns.time} INTEGER NOT NULL,
    ${MessageColumns.state} INTEGER NOT NULL DEFAULT ${StateType.wait},
  );
  ''';


  MessageDBHelper._privateConstructor();
  static final MessageDBHelper instance = MessageDBHelper._privateConstructor();


  Future<int> insert(Message message) async {
    Database db = await instance.database;
    return await db.insert(table, message.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Message>> queryAllMessages() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(table);
    //if (maps.length > 0)
    return maps.map((e) => Message.fromJson(e)).toList();
    //return null;
  }

  Future<List<Message>> queryAllUserMessages(String roomId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(table, where: "${MessageColumns.roomId} = ?",
      whereArgs: [roomId], orderBy: "${MessageColumns.time}",);
    //if (maps.length > 0)
    return maps.map((e) => Message.fromJson(e)).toList();
    //return null;
  }

  Future<int?> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }


  Future<int> update(Message message) async {
    Database db = await instance.database;

    return await db.update(table, message.toJson(), where: '${MessageColumns.messageId} = ?', whereArgs: [message.messageId]);
  }

  Future<int> delete(String id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '${MessageColumns.messageId} = ?', whereArgs: [id]);
  }
}