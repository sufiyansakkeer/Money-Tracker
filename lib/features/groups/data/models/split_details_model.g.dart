// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_details_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SplitDetailsModelAdapter extends TypeAdapter<SplitDetailsModel> {
  @override
  final typeId = 9;

  @override
  SplitDetailsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SplitDetailsModel(
      transactionId: fields[0] as String,
      payerMemberId: fields[1] as String,
      splitType: fields[2] as domain.SplitType,
      splitData: (fields[3] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, SplitDetailsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.transactionId)
      ..writeByte(1)
      ..write(obj.payerMemberId)
      ..writeByte(2)
      ..write(obj.splitType)
      ..writeByte(3)
      ..write(obj.splitData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitDetailsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
