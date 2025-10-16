import 'package:hive_ce/hive.dart';
import 'package:money_track/features/groups/domain/entities/split_details.dart';

class SplitTypeAdapter extends TypeAdapter<SplitType> {
  @override
  final typeId = 11;

  @override
  SplitType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SplitType.equal;
      case 1:
        return SplitType.custom;
      case 2:
        return SplitType.percentage;
      default:
        return SplitType.equal;
    }
  }

  @override
  void write(BinaryWriter writer, SplitType obj) {
    switch (obj) {
      case SplitType.equal:
        writer.writeByte(0);
        break;
      case SplitType.custom:
        writer.writeByte(1);
        break;
      case SplitType.percentage:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}