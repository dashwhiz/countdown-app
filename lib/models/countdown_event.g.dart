// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'countdown_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CountdownEventAdapter extends TypeAdapter<CountdownEvent> {
  @override
  final int typeId = 0;

  @override
  CountdownEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CountdownEvent(
      id: fields[0] as String,
      title: fields[1] as String,
      targetDate: fields[2] as DateTime,
      timezone: fields[3] as String,
      colorValue: fields[4] as int,
      emoji: fields[5] as String,
      isPinned: fields[6] as bool,
      shareSlug: fields[7] as String?,
      vanitySlug: fields[8] as String?,
      themeId: fields[9] as String?,
      createdAt: fields[10] as DateTime?,
      deletionToken: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CountdownEvent obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.targetDate)
      ..writeByte(3)
      ..write(obj.timezone)
      ..writeByte(4)
      ..write(obj.colorValue)
      ..writeByte(5)
      ..write(obj.emoji)
      ..writeByte(6)
      ..write(obj.isPinned)
      ..writeByte(7)
      ..write(obj.shareSlug)
      ..writeByte(8)
      ..write(obj.vanitySlug)
      ..writeByte(9)
      ..write(obj.themeId)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.deletionToken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountdownEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
