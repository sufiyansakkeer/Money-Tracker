// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SplitExpenseModel _$SplitExpenseModelFromJson(Map<String, dynamic> json) =>
    SplitExpenseModel(
      id: json['id'] as String,
      expenseId: json['expenseId'] as String,
      groupId: json['groupId'] as String,
      splits: (json['splits'] as List<dynamic>)
          .map((e) => SplitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SplitExpenseModelToJson(SplitExpenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'expenseId': instance.expenseId,
      'groupId': instance.groupId,
      'splits': instance.splits,
    };
