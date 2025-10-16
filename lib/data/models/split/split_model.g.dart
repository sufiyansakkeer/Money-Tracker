// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SplitModel _$SplitModelFromJson(Map<String, dynamic> json) => SplitModel(
      contactId: json['contactId'] as String,
      amount: (json['amount'] as num).toDouble(),
      isPaid: json['isPaid'] as bool,
    );

Map<String, dynamic> _$SplitModelToJson(SplitModel instance) =>
    <String, dynamic>{
      'contactId': instance.contactId,
      'amount': instance.amount,
      'isPaid': instance.isPaid,
    };
