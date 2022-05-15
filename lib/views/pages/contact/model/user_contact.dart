import 'package:flutter_chat_app/views/pages/contact/model/user.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part "user_contact.g.dart";

final String userContactBox="userContact";

@JsonSerializable()
@HiveType(typeId: 3)
class UserContact extends User{
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

  UserContact(this.uid, this.name, this.about, this.phone, this.photoURL) : super(uid, name, about, phone, photoURL);

  factory UserContact.fromJson(Map<String, dynamic> json) => _$UserContactFromJson(json);
  Map<String, dynamic> toJson() => _$UserContactToJson(this);
}