// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TableDataAdapter extends TypeAdapter<TableData> {
  @override
  final int typeId = 0;

  @override
  TableData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TableData(
      id: fields[0] as int,
      capacity: fields[1] as int,
      status: fields[2] as TableStatus,
      items: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TableData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.capacity)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TableStatusAdapter extends TypeAdapter<TableStatus> {
  @override
  final int typeId = 1;

  @override
  TableStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TableStatus.available;
      case 1:
        return TableStatus.occupied;
      case 2:
        return TableStatus.unavailable;
      default:
        return TableStatus.available;
    }
  }

  @override
  void write(BinaryWriter writer, TableStatus obj) {
    switch (obj) {
      case TableStatus.available:
        writer.writeByte(0);
        break;
      case TableStatus.occupied:
        writer.writeByte(1);
        break;
      case TableStatus.unavailable:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
