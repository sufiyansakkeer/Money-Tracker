// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetModelAdapter extends TypeAdapter<BudgetModel> {
  @override
  final typeId = 6;

  @override
  BudgetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetModel(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: (fields[2] as num).toDouble(),
      category: fields[3] as CategoryModel,
      periodType: fields[4] as BudgetPeriodType,
      startDate: fields[5] as DateTime,
      isActive: fields[6] == null ? true : fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.periodType)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BudgetPeriodTypeAdapter extends TypeAdapter<BudgetPeriodType> {
  @override
  final typeId = 7;

  @override
  BudgetPeriodType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BudgetPeriodType.weekly;
      case 1:
        return BudgetPeriodType.monthly;
      default:
        return BudgetPeriodType.weekly;
    }
  }

  @override
  void write(BinaryWriter writer, BudgetPeriodType obj) {
    switch (obj) {
      case BudgetPeriodType.weekly:
        writer.writeByte(0);
      case BudgetPeriodType.monthly:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetPeriodTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
