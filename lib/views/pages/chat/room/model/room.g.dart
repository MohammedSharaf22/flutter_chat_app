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
      fields[0] as String,
      fields[1] as int,
      fields[2] as String?,
      fields[3] as String?,
      fields[4] as String?,
      fields[5] as int,
      fields[6] as int?,
      (fields[7] as List).cast<dynamic>(),
      fields[8] as String?,
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
      json['roomId'] as String,
      json['createdAt'] as int,
      json['imageUrl'] as String?,
      json['metadata'] as String?,
      json['name'] as String?,
      json['type'] as int,
      json['updatedAt'] as int?,
      json['userIds'] as List<dynamic>,
      json['lastMessage'] as String?,
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
      'lastMessage': instance.lastMessageId,
    };
