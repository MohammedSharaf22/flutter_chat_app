// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserContactAdapter extends TypeAdapter<UserContact> {
  @override
  final int typeId = 3;

  @override
  UserContact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserContact(
      fields[0] as String,
      fields[1] as String?,
      fields[2] as String?,
      fields[3] as String,
      fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserContact obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.about)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.photoURL);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserContact _$UserContactFromJson(Map<String, dynamic> json) => UserContact(
      json['uid'] as String,
      json['name'] as String?,
      json['about'] as String?,
      json['phone'] as String,
      json['photoURL'] as String,
    );

Map<String, dynamic> _$UserContactToJson(UserContact instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'about': instance.about,
      'phone': instance.phone,
      'photoURL': instance.photoURL,
    };
