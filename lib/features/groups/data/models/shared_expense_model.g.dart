// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_expense_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseParticipantModelAdapter
    extends TypeAdapter<ExpenseParticipantModel> {
  @override
  final typeId = 13;

  @override
  ExpenseParticipantModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseParticipantModel(
      memberId: fields[0] as String,
      memberName: fields[1] as String,
      amount: (fields[2] as num).toDouble(),
      paidAmount: fields[3] == null ? 0.0 : (fields[3] as num).toDouble(),
      isPayer: fields[4] == null ? false : fields[4] as bool,
      shares: (fields[5] as num?)?.toDouble(),
      percentage: (fields[6] as num?)?.toDouble(),
      notes: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseParticipantModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.memberId)
      ..writeByte(1)
      ..write(obj.memberName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.paidAmount)
      ..writeByte(4)
      ..write(obj.isPayer)
      ..writeByte(5)
      ..write(obj.shares)
      ..writeByte(6)
      ..write(obj.percentage)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseParticipantModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SharedExpenseModelAdapter extends TypeAdapter<SharedExpenseModel> {
  @override
  final typeId = 14;

  @override
  SharedExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SharedExpenseModel(
      id: fields[0] as String,
      groupId: fields[1] as String,
      title: fields[2] as String,
      totalAmount: (fields[4] as num).toDouble(),
      currency: fields[5] as String,
      category: fields[6] as CategoryModel,
      splitType: fields[7] as EnhancedSplitTypeModel,
      participants: (fields[8] as List).cast<ExpenseParticipantModel>(),
      createdBy: fields[9] as String,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
      description: fields[3] as String?,
      receiptUrls: (fields[12] as List?)?.cast<String>(),
      metadata: (fields[13] as Map?)?.cast<String, dynamic>(),
      isRecurring: fields[14] == null ? false : fields[14] as bool,
      recurringPattern: fields[15] as String?,
      recurringEndDate: fields[16] as DateTime?,
      isSettled: fields[17] == null ? false : fields[17] as bool,
      tags: fields[18] == null ? const [] : (fields[18] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SharedExpenseModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.groupId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.totalAmount)
      ..writeByte(5)
      ..write(obj.currency)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.splitType)
      ..writeByte(8)
      ..write(obj.participants)
      ..writeByte(9)
      ..write(obj.createdBy)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.receiptUrls)
      ..writeByte(13)
      ..write(obj.metadata)
      ..writeByte(14)
      ..write(obj.isRecurring)
      ..writeByte(15)
      ..write(obj.recurringPattern)
      ..writeByte(16)
      ..write(obj.recurringEndDate)
      ..writeByte(17)
      ..write(obj.isSettled)
      ..writeByte(18)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EnhancedSplitTypeModelAdapter
    extends TypeAdapter<EnhancedSplitTypeModel> {
  @override
  final typeId = 12;

  @override
  EnhancedSplitTypeModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EnhancedSplitTypeModel.equal;
      case 1:
        return EnhancedSplitTypeModel.exact;
      case 2:
        return EnhancedSplitTypeModel.percentage;
      case 3:
        return EnhancedSplitTypeModel.shares;
      case 4:
        return EnhancedSplitTypeModel.adjustment;
      default:
        return EnhancedSplitTypeModel.equal;
    }
  }

  @override
  void write(BinaryWriter writer, EnhancedSplitTypeModel obj) {
    switch (obj) {
      case EnhancedSplitTypeModel.equal:
        writer.writeByte(0);
      case EnhancedSplitTypeModel.exact:
        writer.writeByte(1);
      case EnhancedSplitTypeModel.percentage:
        writer.writeByte(2);
      case EnhancedSplitTypeModel.shares:
        writer.writeByte(3);
      case EnhancedSplitTypeModel.adjustment:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnhancedSplitTypeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
