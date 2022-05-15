// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 4;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      messageId: fields[0] as String,
      roomId: fields[1] as String,
      senderId: fields[2] as String,
      senderPhone: fields[3] as String?,
      senderPhoto: fields[4] as String,
      receiverId: fields[5] as String,
      text: fields[6] as String,
      type: fields[7] as int,
      url: fields[8] as String?,
      localPath: fields[9] as String?,
      time: fields[10] as int,
      fileInfo: (fields[12] as Map?)?.cast<String, dynamic>(),
    )..state = fields[11] as int;
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.messageId)
      ..writeByte(1)
      ..write(obj.roomId)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.senderPhone)
      ..writeByte(4)
      ..write(obj.senderPhoto)
      ..writeByte(5)
      ..write(obj.receiverId)
      ..writeByte(6)
      ..write(obj.text)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.url)
      ..writeByte(9)
      ..write(obj.localPath)
      ..writeByte(10)
      ..write(obj.time)
      ..writeByte(11)
      ..write(obj.state)
      ..writeByte(12)
      ..write(obj.fileInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      messageId: json['messageId'] as String,
      roomId: json['roomId'] as String,
      senderId: json['senderId'] as String,
      senderPhone: json['senderPhone'] as String?,
      senderPhoto: json['senderPhoto'] as String,
      receiverId: json['receiverId'] as String,
      text: json['text'] as String,
      type: json['type'] as int,
      url: json['url'] as String?,
      localPath: json['localPath'] as String?,
      time: json['time'] as int,
      fileInfo: json['fileInfo'] as Map<String, dynamic>?,
    )..state = json['state'] as int;

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'messageId': instance.messageId,
      'roomId': instance.roomId,
      'senderId': instance.senderId,
      'senderPhone': instance.senderPhone,
      'senderPhoto': instance.senderPhoto,
      'receiverId': instance.receiverId,
      'text': instance.text,
      'type': instance.type,
      'url': instance.url,
      'localPath': instance.localPath,
      'time': instance.time,
      'state': instance.state,
      'fileInfo': instance.fileInfo,
    };
