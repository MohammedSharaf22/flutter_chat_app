
import 'package:flutter_chat_app/control/database/database_helper.dart';
import 'package:flutter_chat_app/views/pages/chat/message/model/message.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class ChatColumns {
  static get User => "user";
  static get RecentSendMessage => "recentSendMessage";
  static get UnreadCount => "unreadCount";
}

class Chat{
  late UserModel user;
  late Message recentSendMessage;
  int unreadCount=0;

  /*final RxList<Message> messages = <Message>[].obs;*/
  Chat({required this.user, required this.recentSendMessage, required this.unreadCount});

  Map<String, dynamic> toMap() => {
    ChatColumns.User: user.uid,
    ChatColumns.RecentSendMessage: recentSendMessage.messageId,
    ChatColumns.UnreadCount: unreadCount,
  };

  Chat.fromMap(Map<String, dynamic> map) {
    user = UserModel.fromJson(map);//map[ChatColumns.User]
    recentSendMessage = Message.fromJson(map);//map[ChatColumns.RecentSendMessage]
    unreadCount = map[ChatColumns.UnreadCount];
  }

}


class ChatDBHelper extends DatabaseHelper{
  static final table = 'chat';

  ChatDBHelper._privateConstructor();
  static final ChatDBHelper instance = ChatDBHelper._privateConstructor();


  Future<int> insert(Chat chat) async {
    Database db = await instance.database;
    return await db.insert(table, chat.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /*Future<List<Chat>> queryAllChats() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(table);
    //if (maps.length > 0)
    return maps.map((e) => Chat.fromMap(e)).toList();
    //return null;
  }*/

  Future<List<Chat>> queryAllChats() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT
       u.uid, u.name, u.about, u.phone, u.photoURL,
       messageId,
       senderId,
       senderPhone,
       senderPhoto,
       receiverId,
       text,
       type,
       url,
       MAX(time) as time,
       isSent,
       isDelivered,
       Count((SELECT mm.isSeen
        FROM Message m Where m.isSeen=mm.isSeen And m.isSeen=0)) as unreadCount
  FROM
  Message mm LEFT JOIN (SELECT uid, name, about, phone, photoURL From user) as u
  ON u.uid= mm.senderID
   group by mm.senderId ;
      '''
    );
    //if (maps.length > 0)
    return maps.map((e) => Chat.fromMap(e)).toList();
    //return null;
  }

  Future<List<Chat>> queryAllUserChats(userId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(table, where: "${ChatColumns.User} = ? ",//OR  ${ChatColumns.RecentSendMessage} = ?
      whereArgs: [userId],);
    //if (maps.length > 0)
    return maps.map((e) => Chat.fromMap(e)).toList();
    //return null;
  }

  Future<int?> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }


  Future<int> update(Chat chat) async {
    Database db = await instance.database;

    return await db.update(table, chat.toMap(), where: '${ChatColumns.User} = ?', whereArgs: [chat.user.uid]);
  }

  Future<int> delete(String id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '${ChatColumns.User} = ?', whereArgs: [id]);
  }
}



