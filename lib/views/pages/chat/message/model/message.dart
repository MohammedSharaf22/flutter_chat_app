import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';


abstract class MessageColumns{
  static get messageId => "messageId";
  static get roomId => "roomId";
  static get senderId => "senderId";
  static get senderPhone => "senderPhone";
  static get senderPhoto => "senderPhoto";
  static get receiverId => "receiverId";
  static get text => "text";
  static get type => "type";
  static get url => "url";
  static get localPath => "localPath";
  static get time => "time";
  static get state => "state";
  static get fileInfo => "fileInfo";
}

abstract class MessageType {
  static const int text = 0;
  static const int image = 1;
  static const int video = 2;
  static const int audio = 3;
}

abstract class StateType {
  static const int wait = 0;
  static const int sent = 1;
  static const int delivered = 2;
  static const int seen = 3;
}

abstract class MessageAudioInfoKey {
  static const String duration = "duration";
  static const String size = "size";
}

abstract class MessageImageInfoKey {
  static const String size = "size";
  static const String height = "height";
  static const String width = "width";
  static const String extension = "extension";
  static const String thumbLocal = "thumbLocal";
  static const String thumbUrl = "thumbUrl";
}

abstract class MessageVideoInfoKey {
  static const String duration = "duration";
  static const String size = "size";
  static const String height = "height";
  static const String width = "width";
  static const String extension = "extension";
  static const String thumbLocal = "thumbLocal";
  static const String thumbUrl = "thumbUrl";
}

@JsonSerializable()
@HiveType(typeId: 4)
class Message {
  @HiveField(0)
  late final String messageId;
  @HiveField(1)
  late final String roomId;
  @HiveField(2)
  late final String senderId;
  @HiveField(3)
  String? senderPhone;
  @HiveField(4)
  late String senderPhoto;
  @HiveField(5)
  late String receiverId;
  @HiveField(6)
  late String text;
  @HiveField(7)
  late final int type;
  @HiveField(8)
  String? url;
  @HiveField(9)
  String? localPath;
  @HiveField(10)
  late int time;
  @HiveField(11)
  late int state = StateType.wait;
  @HiveField(12)
  Map<String, dynamic>? fileInfo;

  Message({
    required this.messageId,
    required this.roomId,
    required this.senderId,
    this.senderPhone,
    required this.senderPhoto,
    required this.receiverId,
    required this.text,
    required this.type,
    this.url,
    this.localPath,
    required this.time,
    this.fileInfo,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
  /*Map<String, dynamic> toMap() => {
    MessageColumns.messageId: messageId,
    MessageColumns.senderId: senderId,
    MessageColumns.senderPhone: senderPhone,
    MessageColumns.text: text,
    MessageColumns.type: type,
    MessageColumns.url: url,
    MessageColumns.time: time,
    MessageColumns.state: state,
  };

  Message.fromMap(Map<String, dynamic> map) {
    messageId = map[MessageColumns.messageId];
    senderId = map[MessageColumns.senderId];
    senderPhone = map[MessageColumns.senderPhone];
    text = map[MessageColumns.text];
    type = map[MessageColumns.type];
    url = map[MessageColumns.url];
    time = map[MessageColumns.time];
    state = map[MessageColumns.state];
  }*/
}



