import 'package:hive/hive.dart';
part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String categoryName;
  @HiveField(2)
  final CategoryType categoryType;
  @HiveField(3)
  final TransactionType type;
  @HiveField(4)
  final bool isDeleted;

  CategoryModel({
    required this.id,
    required this.categoryName,
    required this.type,
    this.categoryType = CategoryType.other,
    this.isDeleted = false,
  });
}

@HiveType(typeId: 2)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 3)
enum CategoryType {
  @HiveField(0)
  salary,
  @HiveField(1)
  shopping,
  @HiveField(2)
  food,
  @HiveField(3)
  transportation,
  @HiveField(4)
  subscription,
  @HiveField(5)
  other,
}
