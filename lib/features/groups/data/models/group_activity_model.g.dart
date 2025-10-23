// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_activity_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GroupActivityModelAdapter extends TypeAdapter<GroupActivityModel> {
  @override
  final typeId = 19;

  @override
  GroupActivityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupActivityModel(
      id: fields[0] as String,
      groupId: fields[1] as String,
      type: fields[2] as GroupActivityTypeModel,
      actorId: fields[3] as String,
      actorName: fields[4] as String,
      title: fields[5] as String,
      description: fields[6] as String,
      timestamp: fields[7] as DateTime,
      metadata: (fields[8] as Map?)?.cast<String, dynamic>(),
      relatedEntityId: fields[9] as String?,
      amount: (fields[10] as num?)?.toDouble(),
      currency: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GroupActivityModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.groupId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.actorId)
      ..writeByte(4)
      ..write(obj.actorName)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.timestamp)
      ..writeByte(8)
      ..write(obj.metadata)
      ..writeByte(9)
      ..write(obj.relatedEntityId)
      ..writeByte(10)
      ..write(obj.amount)
      ..writeByte(11)
      ..write(obj.currency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupActivityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GroupActivityTypeModelAdapter
    extends TypeAdapter<GroupActivityTypeModel> {
  @override
  final typeId = 18;

  @override
  GroupActivityTypeModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GroupActivityTypeModel.expenseAdded;
      case 1:
        return GroupActivityTypeModel.expenseUpdated;
      case 2:
        return GroupActivityTypeModel.expenseDeleted;
      case 3:
        return GroupActivityTypeModel.settlementAdded;
      case 4:
        return GroupActivityTypeModel.settlementConfirmed;
      case 5:
        return GroupActivityTypeModel.settlementCancelled;
      case 6:
        return GroupActivityTypeModel.memberAdded;
      case 7:
        return GroupActivityTypeModel.memberRemoved;
      case 8:
        return GroupActivityTypeModel.groupUpdated;
      default:
        return GroupActivityTypeModel.expenseAdded;
    }
  }

  @override
  void write(BinaryWriter writer, GroupActivityTypeModel obj) {
    switch (obj) {
      case GroupActivityTypeModel.expenseAdded:
        writer.writeByte(0);
      case GroupActivityTypeModel.expenseUpdated:
        writer.writeByte(1);
      case GroupActivityTypeModel.expenseDeleted:
        writer.writeByte(2);
      case GroupActivityTypeModel.settlementAdded:
        writer.writeByte(3);
      case GroupActivityTypeModel.settlementConfirmed:
        writer.writeByte(4);
      case GroupActivityTypeModel.settlementCancelled:
        writer.writeByte(5);
      case GroupActivityTypeModel.memberAdded:
        writer.writeByte(6);
      case GroupActivityTypeModel.memberRemoved:
        writer.writeByte(7);
      case GroupActivityTypeModel.groupUpdated:
        writer.writeByte(8);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupActivityTypeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
