// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoomAdapter extends TypeAdapter<Room> {
  @override
  final int typeId = 1;

  @override
  Room read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Room(
      roomId: fields[0] as String,
      createdAt: fields[1] as int,
      imageUrl: fields[2] as String?,
      metadata: fields[3] as String?,
      name: fields[4] as String?,
      type: fields[5] as int,
      updatedAt: fields[6] as int?,
      userIds: (fields[7] as List).cast<dynamic>(),
      lastMessageId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Room obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.roomId)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.metadata)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.userIds)
      ..writeByte(8)
      ..write(obj.lastMessageId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
      roomId: json['roomId'] as String,
      createdAt: json['createdAt'] as int,
      imageUrl: json['imageUrl'] as String?,
      metadata: json['metadata'] as String?,
      name: json['name'] as String?,
      type: json['type'] as int,
      updatedAt: json['updatedAt'] as int?,
      userIds: json['userIds'] as List<dynamic>,
      lastMessageId: json['lastMessageId'] as String?,
    );

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'roomId': instance.roomId,
      'createdAt': instance.createdAt,
      'imageUrl': instance.imageUrl,
      'metadata': instance.metadata,
      'name': instance.name,
      'type': instance.type,
      'updatedAt': instance.updatedAt,
      'userIds': instance.userIds,
      'lastMessageId': instance.lastMessageId,
    };
