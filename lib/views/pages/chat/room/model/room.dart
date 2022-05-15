
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part "room.g.dart";

abstract class RoomColumns {
  static get roomId => "roomId";
  static get createdAt => "createdAt";
  static get imageUrl => "imageUrl";
  static get metadata => "metadata";
  static get name => "name";
  static get type => "type";
  static get updatedAt => "updatedAt";
  static get userIds => "userIds";
  static get lastMessage => "lastMessage";
}

abstract class RoomType {
  static int get CHAT => 0;
  static int get GROUP => 1;
  static int get BROADCAST => 2;
}

@JsonSerializable()
@HiveType(typeId: 1)
class Room /*extends HiveObject*/{
  @HiveField(0)
  late final String roomId;
  @HiveField(1)
  late final int createdAt;
  @HiveField(2)
  String? imageUrl;
  @HiveField(3)
  String? metadata;
  @HiveField(4)
  String? name;
  @HiveField(5)
  late final int type;
  @HiveField(6)
  int? updatedAt;
  @HiveField(7)
  late List<dynamic> userIds;
  @HiveField(8)
  String? lastMessageId;

  Room(this.roomId, this.createdAt, this.imageUrl, this.metadata, this.name,
      this.type, this.updatedAt, this.userIds, this.lastMessageId);

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  Map<String, dynamic> toJson() => _$RoomToJson(this);

}