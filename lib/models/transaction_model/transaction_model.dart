import 'package:hive/hive.dart';
import '../categories_model/category_model.dart';
part 'transaction_model.g.dart';

@HiveType(typeId: 3)
class TransactionModel {
  @HiveField(0)
  final double amount;
  @HiveField(1)
  final String notes;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final CategoryType type;
  @HiveField(4)
  final CategoryModel categoryModel;
  @HiveField(5)
  String? id;

  TransactionModel({
    required this.categoryModel,
    required this.amount,
    required this.notes,
    required this.date,
    required this.type,
  }) {
    id = DateTime.now().microsecondsSinceEpoch.toString();
  }
}
