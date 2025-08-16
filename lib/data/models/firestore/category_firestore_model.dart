import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_track/data/models/category_model.dart' as model;
import 'package:money_track/domain/entities/category_entity.dart';

/// Firestore-compatible category model
class CategoryFirestoreModel {
  final String id;
  final String categoryName;
  final String categoryType;
  final String type;
  final bool isDeleted;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version; // For conflict resolution

  const CategoryFirestoreModel({
    required this.id,
    required this.categoryName,
    required this.categoryType,
    required this.type,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.isDeleted = false,
  });

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'categoryName': categoryName,
      'categoryType': categoryType,
      'type': type,
      'isDeleted': isDeleted,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'version': version,
    };
  }

  /// Create from Firestore document data
  factory CategoryFirestoreModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Document data is null');
    }

    return CategoryFirestoreModel(
      id: data['id'] as String,
      categoryName: data['categoryName'] as String,
      categoryType: data['categoryType'] as String,
      type: data['type'] as String,
      isDeleted: data['isDeleted'] as bool? ?? false,
      userId: data['userId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      version: data['version'] as int,
    );
  }

  /// Create from Map (for nested objects)
  factory CategoryFirestoreModel.fromMap(Map<String, dynamic> data) {
    return CategoryFirestoreModel(
      id: data['id'] as String,
      categoryName: data['categoryName'] as String,
      categoryType: data['categoryType'] as String,
      type: data['type'] as String,
      isDeleted: data['isDeleted'] as bool? ?? false,
      userId: data['userId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      version: data['version'] as int,
    );
  }

  /// Convert from local Hive model
  factory CategoryFirestoreModel.fromHiveModel(
    model.CategoryModel hiveModel,
    String userId,
  ) {
    final now = DateTime.now();
    return CategoryFirestoreModel(
      id: hiveModel.id,
      categoryName: hiveModel.categoryName,
      categoryType: hiveModel.categoryType.name,
      type: hiveModel.type.name,
      isDeleted: hiveModel.isDeleted,
      userId: userId,
      createdAt: now,
      updatedAt: now,
      version: 1,
    );
  }

  /// Convert to local Hive model
  model.CategoryModel toHiveModel() {
    return model.CategoryModel(
      id: id,
      categoryName: categoryName,
      categoryType: _stringToCategoryType(categoryType),
      type: _stringToTransactionType(type),
      isDeleted: isDeleted,
    );
  }

  /// Convert to domain entity
  CategoryEntity toEntity() {
    return toHiveModel().toEntity();
  }

  /// Create updated version with new data
  CategoryFirestoreModel copyWith({
    String? id,
    String? categoryName,
    String? categoryType,
    String? type,
    bool? isDeleted,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return CategoryFirestoreModel(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      categoryType: categoryType ?? this.categoryType,
      type: type ?? this.type,
      isDeleted: isDeleted ?? this.isDeleted,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }

  /// Helper method to convert string to CategoryType enum
  model.CategoryType _stringToCategoryType(String categoryType) {
    return model.CategoryType.values.firstWhere(
      (e) => e.name == categoryType,
      orElse: () => model.CategoryType.other,
    );
  }

  /// Helper method to convert string to TransactionType enum
  model.TransactionType _stringToTransactionType(String type) {
    return model.TransactionType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => model.TransactionType.expense,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryFirestoreModel &&
        other.id == id &&
        other.categoryName == categoryName &&
        other.categoryType == categoryType &&
        other.type == type &&
        other.isDeleted == isDeleted &&
        other.userId == userId &&
        other.version == version;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      categoryName,
      categoryType,
      type,
      isDeleted,
      userId,
      version,
    );
  }

  @override
  String toString() {
    return 'CategoryFirestoreModel(id: $id, categoryName: $categoryName, userId: $userId, version: $version)';
  }
}
