import 'package:flutter_chat_app/views/pages/chat/message/db_helper/message_db_helper.dart';
import 'package:flutter_chat_app/views/pages/chat/room/db_helper/room_db_helper.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class DatabaseHelper{
  String get databaseName => "chat_app.db";
  int get databaseVersion => 3;

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantiate the db the first time it is accessed
    _database = await initDatabase();
    return _database!;
  }

  initDatabase() async {
    String path = join(await getDatabasesPath(), databaseName);
    return await openDatabase(path,
        version: databaseVersion,
        onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE user (
            ${UserColumns.UId} TEXT PRIMARY KEY,
            ${UserColumns.Name} TEXT NULL,
            ${UserColumns.About} TEXT NULL,
            ${UserColumns.Phone} TEXT NULL,
            ${UserColumns.PhotoURL} INTEGER NULL
          )
          ''');

    await db.execute(MessageDBHelper.GetSchema());

    /*await db.execute('''
          CREATE TABLE chat (
            ${ChatColumns.User} TEXT PRIMARY KEY,
            ${ChatColumns.RecentSendMessage} TEXT NULL,
            ${ChatColumns.UnreadCount} INTEGER NULL
          )
          ''');*/

    await db.execute(RoomDBHelper.GetSchema());
  }

 Future<void> deleteDB()async{
    try{
      print('deleting Database...');
      await deleteDatabase(await getDatabasesPath());
    }catch(e){
      print(e.toString());
    }
    print('Database is deleted');
 }
}