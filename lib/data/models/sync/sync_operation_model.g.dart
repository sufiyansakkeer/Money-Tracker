// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_operation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncOperationModelAdapter extends TypeAdapter<SyncOperationModel> {
  @override
  final int typeId = 12;

  @override
  SyncOperationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncOperationModel(
      id: fields[0] as String,
      operationType: fields[1] as SyncOperationType,
      dataType: fields[2] as SyncDataType,
      dataId: fields[3] as String,
      data: (fields[4] as Map).cast<String, dynamic>(),
      createdAt: fields[5] as DateTime,
      userId: fields[8] as String,
      retryCount: fields[6] as int,
      error: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncOperationModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.operationType)
      ..writeByte(2)
      ..write(obj.dataType)
      ..writeByte(3)
      ..write(obj.dataId)
      ..writeByte(4)
      ..write(obj.data)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.retryCount)
      ..writeByte(7)
      ..write(obj.error)
      ..writeByte(8)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncOperationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncOperationTypeAdapter extends TypeAdapter<SyncOperationType> {
  @override
  final int typeId = 10;

  @override
  SyncOperationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncOperationType.create;
      case 1:
        return SyncOperationType.update;
      case 2:
        return SyncOperationType.delete;
      default:
        return SyncOperationType.create;
    }
  }

  @override
  void write(BinaryWriter writer, SyncOperationType obj) {
    switch (obj) {
      case SyncOperationType.create:
        writer.writeByte(0);
        break;
      case SyncOperationType.update:
        writer.writeByte(1);
        break;
      case SyncOperationType.delete:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncOperationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncDataTypeAdapter extends TypeAdapter<SyncDataType> {
  @override
  final int typeId = 11;

  @override
  SyncDataType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncDataType.transaction;
      case 1:
        return SyncDataType.category;
      default:
        return SyncDataType.transaction;
    }
  }

  @override
  void write(BinaryWriter writer, SyncDataType obj) {
    switch (obj) {
      case SyncDataType.transaction:
        writer.writeByte(0);
        break;
      case SyncDataType.category:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncDataTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
