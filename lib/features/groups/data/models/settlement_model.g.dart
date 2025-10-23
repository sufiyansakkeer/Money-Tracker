// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettlementModelAdapter extends TypeAdapter<SettlementModel> {
  @override
  final typeId = 17;

  @override
  SettlementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettlementModel(
      id: fields[0] as String,
      groupId: fields[1] as String,
      payerId: fields[2] as String,
      payerName: fields[3] as String,
      receiverId: fields[4] as String,
      receiverName: fields[5] as String,
      amount: (fields[6] as num).toDouble(),
      currency: fields[7] as String,
      paymentMethod: fields[8] as PaymentMethodModel,
      status: fields[9] as SettlementStatusModel,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
      description: fields[10] as String?,
      notes: fields[11] as String?,
      confirmedAt: fields[14] as DateTime?,
      confirmedBy: fields[15] as String?,
      relatedExpenseIds: (fields[16] as List?)?.cast<String>(),
      receiptUrl: fields[17] as String?,
      metadata: (fields[18] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, SettlementModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.groupId)
      ..writeByte(2)
      ..write(obj.payerId)
      ..writeByte(3)
      ..write(obj.payerName)
      ..writeByte(4)
      ..write(obj.receiverId)
      ..writeByte(5)
      ..write(obj.receiverName)
      ..writeByte(6)
      ..write(obj.amount)
      ..writeByte(7)
      ..write(obj.currency)
      ..writeByte(8)
      ..write(obj.paymentMethod)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.description)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.confirmedAt)
      ..writeByte(15)
      ..write(obj.confirmedBy)
      ..writeByte(16)
      ..write(obj.relatedExpenseIds)
      ..writeByte(17)
      ..write(obj.receiptUrl)
      ..writeByte(18)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettlementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SettlementStatusModelAdapter extends TypeAdapter<SettlementStatusModel> {
  @override
  final typeId = 15;

  @override
  SettlementStatusModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SettlementStatusModel.pending;
      case 1:
        return SettlementStatusModel.confirmed;
      case 2:
        return SettlementStatusModel.cancelled;
      default:
        return SettlementStatusModel.pending;
    }
  }

  @override
  void write(BinaryWriter writer, SettlementStatusModel obj) {
    switch (obj) {
      case SettlementStatusModel.pending:
        writer.writeByte(0);
      case SettlementStatusModel.confirmed:
        writer.writeByte(1);
      case SettlementStatusModel.cancelled:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettlementStatusModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentMethodModelAdapter extends TypeAdapter<PaymentMethodModel> {
  @override
  final typeId = 16;

  @override
  PaymentMethodModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMethodModel.cash;
      case 1:
        return PaymentMethodModel.bankTransfer;
      case 2:
        return PaymentMethodModel.digitalWallet;
      case 3:
        return PaymentMethodModel.creditCard;
      case 4:
        return PaymentMethodModel.other;
      default:
        return PaymentMethodModel.cash;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMethodModel obj) {
    switch (obj) {
      case PaymentMethodModel.cash:
        writer.writeByte(0);
      case PaymentMethodModel.bankTransfer:
        writer.writeByte(1);
      case PaymentMethodModel.digitalWallet:
        writer.writeByte(2);
      case PaymentMethodModel.creditCard:
        writer.writeByte(3);
      case PaymentMethodModel.other:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
