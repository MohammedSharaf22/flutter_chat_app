import 'package:flutter_chat_app/control/database/database_helper.dart';
import 'package:flutter_chat_app/views/pages/chat/room/model/room.dart';
import 'package:sqflite/sqflite.dart';

class RoomDBHelper extends DatabaseHelper {
  static final table = 'room';

  static GetSchema()=>
  '''
  CREATE TABLE $table (
    ${RoomColumns.roomId} TEXT PRIMARY KEY,
    ${RoomColumns.createdAt} INTEGER NOT NULL,
    ${RoomColumns.imageUrl} TEXT,
    ${RoomColumns.metadata} TEXT,
    ${RoomColumns.name} TEXT,
    ${RoomColumns.type} INTEGER NOT NULL,
    ${RoomColumns.updatedAt} INTEGER,
    ${RoomColumns.name} userIds NOT NULL,
    ${RoomColumns.lastMessage} TEXT
  );
  ''';

  RoomDBHelper._privateConstructor();

  static final RoomDBHelper instance = RoomDBHelper._privateConstructor();

  Future<int> insert(Room room) async {
    Database db = await instance.database;
    return await db.insert(table, room.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Room>> queryAllRoom() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(table, orderBy: "${RoomColumns.updatedAt} DESC",);
    return maps.map((e) => Room.fromJson(e)).toList();
  }

  Future<int> update(Room room) async {
    Database db = await instance.database;
    return await db.update(table, room.toJson(), where: '${RoomColumns.roomId} = ?', whereArgs: [room.roomId]);
  }

  Future<int> delete(String id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '${RoomColumns.roomId} = ?', whereArgs: [id]);
  }

}