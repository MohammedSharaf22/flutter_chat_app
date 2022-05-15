import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_app/control/database/database_helper.dart';
import 'package:flutter_chat_app/views/pages/contact/model/user.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite/sqflite.dart';

part 'user_model.g.dart';

abstract class UserColumns {
  static get UId => "uid";
  static get Name => "name";
  static get About => "about";
  static get Phone => "phone";
  static get PhotoURL => "photoURL";
}


@JsonSerializable()
@HiveType(typeId: 2)
class UserModel extends User{
  @HiveField(0)
  String uid;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? about;
  @HiveField(3)
  String phone;
  @HiveField(4)
  String photoURL;

  UserModel(this.uid, this.name, this.about, this.phone, this.photoURL) : super(uid, name, about, phone, photoURL);

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}


class UserModelDBHelper extends DatabaseHelper{
  static final table = 'user';

  UserModelDBHelper._privateConstructor();
  static final UserModelDBHelper instance = UserModelDBHelper._privateConstructor();


  Future<int> insert(UserModel userModel) async {
    Database db = await instance.database;
    return await db.insert(table, userModel.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<UserModel>> queryAllUsers() async{
    Database db = await instance.database;
    var users = await db.query(table,);
    //if(users.length > 0)
      return users.map((e) => UserModel.fromJson(e)).toList();
    //return null;
  }

  Future<UserModel?> queryUser(uid) async {
    Database db = await instance.database;
    var maps = await db.query(table, where: "${UserColumns.UId} = ? ",
      whereArgs: [uid],);
    if(maps.length > 0)
      return UserModel.fromJson(maps.first);
    return null;
  }

  Future<int> update(UserModel userModel) async {
    Database db = await instance.database;

    return await db.update(table, userModel.toJson(), where: '${UserColumns.UId} = ?', whereArgs: [userModel.uid]);
  }

  Future<int> delete(String uid) async {
    Database db = await instance.database;
    return await db.delete(table, where: '${UserColumns.UId} = ?', whereArgs: [uid]);
  }

  Future close() async {
    Database db = await instance.database;
    return db.close();
  }
}

