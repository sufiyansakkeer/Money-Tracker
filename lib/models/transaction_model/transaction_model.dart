import 'package:hive/hive.dart';

import '../categories_model/category_model.dart';
part 'transaction_model.g.dart';

@HiveType(typeId: 4)
class TransactionModel {
  @HiveField(0)
  final double amount;
  @HiveField(1)
  String? notes;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final CategoryType categoryType;
  @HiveField(4)
  final TransactionType transactionType;
  @HiveField(5)
  final CategoryModel categoryModel;
  @HiveField(6)
  String? id;
  TransactionModel({
    required this.amount,
    required this.date,
    required this.categoryType,
    required this.transactionType,
    required this.categoryModel,
    required this.id,
    this.notes,
  });
}
