import 'package:json_annotation/json_annotation.dart';
import 'package:money_track/data/models/split/split_model.dart';

part 'split_expense_model.g.dart';

@JsonSerializable()
class SplitExpenseModel {
  final String id;
  final String expenseId;
  final String groupId;
  final List<SplitModel> splits;

  SplitExpenseModel({
    required this.id,
    required this.expenseId,
    required this.groupId,
    required this.splits,
  });

  factory SplitExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$SplitExpenseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SplitExpenseModelToJson(this);
}
