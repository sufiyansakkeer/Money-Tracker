import 'package:json_annotation/json_annotation.dart';

part 'split_model.g.dart';

@JsonSerializable()
class SplitModel {
  final String contactId;
  final double amount;
  final bool isPaid;

  SplitModel({
    required this.contactId,
    required this.amount,
    required this.isPaid,
  });

  factory SplitModel.fromJson(Map<String, dynamic> json) =>
      _$SplitModelFromJson(json);

  Map<String, dynamic> toJson() => _$SplitModelToJson(this);
}
