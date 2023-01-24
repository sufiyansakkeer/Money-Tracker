// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive/hive.dart';

import '../categories_model/category_model.dart';
part 'transaction_model.g.dart';

@HiveType(typeId: 3)
class TransactionModel {
  @HiveField(0)
  final double amount;
  @HiveField(1)
  String? notes;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final CategoryType type;
  @HiveField(4)
  final CategoryModel categoryModel;
  @HiveField(5)
  String? id;
  TransactionModel({
    required this.amount,
    required this.date,
    required this.type,
    required this.categoryModel,
    required this.id,
    this.notes,
  });
}
