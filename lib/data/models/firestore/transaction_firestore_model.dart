import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_track/data/models/category_model.dart' as category_model;
import 'package:money_track/data/models/firestore/category_firestore_model.dart';
import 'package:money_track/data/models/transaction_model.dart' as model;
import 'package:money_track/domain/entities/transaction_entity.dart';

/// Firestore-compatible transaction model
class TransactionFirestoreModel {
  final String id;
  final double amount;
  final String? notes;
  final DateTime date;
  final String categoryType;
  final String transactionType;
  final CategoryFirestoreModel category;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version; // For conflict resolution

  const TransactionFirestoreModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.categoryType,
    required this.transactionType,
    required this.category,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.notes,
  });

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'amount': amount,
      'notes': notes,
      'date': Timestamp.fromDate(date),
      'categoryType': categoryType,
      'transactionType': transactionType,
      'category': category.toFirestore(),
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'version': version,
    };
  }

  /// Create from Firestore document data
  factory TransactionFirestoreModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Document data is null');
    }

    return TransactionFirestoreModel(
      id: data['id'] as String,
      amount: (data['amount'] as num).toDouble(),
      notes: data['notes'] as String?,
      date: (data['date'] as Timestamp).toDate(),
      categoryType: data['categoryType'] as String,
      transactionType: data['transactionType'] as String,
      category: CategoryFirestoreModel.fromMap(
          data['category'] as Map<String, dynamic>),
      userId: data['userId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      version: data['version'] as int,
    );
  }

  /// Create from Map (for nested objects)
  factory TransactionFirestoreModel.fromMap(Map<String, dynamic> data) {
    return TransactionFirestoreModel(
      id: data['id'] as String,
      amount: (data['amount'] as num).toDouble(),
      notes: data['notes'] as String?,
      date: (data['date'] as Timestamp).toDate(),
      categoryType: data['categoryType'] as String,
      transactionType: data['transactionType'] as String,
      category: CategoryFirestoreModel.fromMap(
          data['category'] as Map<String, dynamic>),
      userId: data['userId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      version: data['version'] as int,
    );
  }

  /// Convert from local Hive model
  factory TransactionFirestoreModel.fromHiveModel(
    model.TransactionModel hiveModel,
    String userId,
  ) {
    final now = DateTime.now();
    return TransactionFirestoreModel(
      id: hiveModel.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      amount: hiveModel.amount,
      notes: hiveModel.notes,
      date: hiveModel.date,
      categoryType: hiveModel.categoryType.name,
      transactionType: hiveModel.transactionType.name,
      category:
          CategoryFirestoreModel.fromHiveModel(hiveModel.categoryModel, userId),
      userId: userId,
      createdAt: now,
      updatedAt: now,
      version: 1,
    );
  }

  /// Convert to local Hive model
  model.TransactionModel toHiveModel() {
    return model.TransactionModel(
      id: id,
      amount: amount,
      notes: notes,
      date: date,
      categoryType: _stringToCategoryType(categoryType),
      transactionType: _stringToTransactionType(transactionType),
      categoryModel: category.toHiveModel(),
    );
  }

  /// Convert to domain entity
  TransactionEntity toEntity() {
    return toHiveModel().toEntity();
  }

  /// Create updated version with new data
  TransactionFirestoreModel copyWith({
    String? id,
    double? amount,
    String? notes,
    DateTime? date,
    String? categoryType,
    String? transactionType,
    CategoryFirestoreModel? category,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return TransactionFirestoreModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      categoryType: categoryType ?? this.categoryType,
      transactionType: transactionType ?? this.transactionType,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }

  /// Helper method to convert string to CategoryType enum
  category_model.CategoryType _stringToCategoryType(String categoryType) {
    return category_model.CategoryType.values.firstWhere(
      (e) => e.name == categoryType,
      orElse: () => category_model.CategoryType.other,
    );
  }

  /// Helper method to convert string to TransactionType enum
  category_model.TransactionType _stringToTransactionType(
      String transactionType) {
    return category_model.TransactionType.values.firstWhere(
      (e) => e.name == transactionType,
      orElse: () => category_model.TransactionType.expense,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionFirestoreModel &&
        other.id == id &&
        other.amount == amount &&
        other.notes == notes &&
        other.date == date &&
        other.categoryType == categoryType &&
        other.transactionType == transactionType &&
        other.category == category &&
        other.userId == userId &&
        other.version == version;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      amount,
      notes,
      date,
      categoryType,
      transactionType,
      category,
      userId,
      version,
    );
  }

  @override
  String toString() {
    return 'TransactionFirestoreModel(id: $id, amount: $amount, date: $date, userId: $userId, version: $version)';
  }
}
