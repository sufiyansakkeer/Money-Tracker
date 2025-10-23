import 'package:hive_ce/hive.dart';
import 'package:money_track/data/models/category_model.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';

part 'shared_expense_model.g.dart';

@HiveType(typeId: 12)
enum EnhancedSplitTypeModel {
  @HiveField(0)
  equal,
  @HiveField(1)
  exact,
  @HiveField(2)
  percentage,
  @HiveField(3)
  shares,
  @HiveField(4)
  adjustment,
}

@HiveType(typeId: 13)
class ExpenseParticipantModel {
  @HiveField(0)
  final String memberId;
  @HiveField(1)
  final String memberName;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final double paidAmount;
  @HiveField(4)
  final bool isPayer;
  @HiveField(5)
  final double? shares;
  @HiveField(6)
  final double? percentage;
  @HiveField(7)
  final String? notes;

  ExpenseParticipantModel({
    required this.memberId,
    required this.memberName,
    required this.amount,
    this.paidAmount = 0.0,
    this.isPayer = false,
    this.shares,
    this.percentage,
    this.notes,
  });

  factory ExpenseParticipantModel.fromEntity(ExpenseParticipant entity) {
    return ExpenseParticipantModel(
      memberId: entity.memberId,
      memberName: entity.memberName,
      amount: entity.amount,
      paidAmount: entity.paidAmount,
      isPayer: entity.isPayer,
      shares: entity.shares,
      percentage: entity.percentage,
      notes: entity.notes,
    );
  }

  ExpenseParticipant toEntity() {
    return ExpenseParticipant(
      memberId: memberId,
      memberName: memberName,
      amount: amount,
      paidAmount: paidAmount,
      isPayer: isPayer,
      shares: shares,
      percentage: percentage,
      notes: notes,
    );
  }
}

@HiveType(typeId: 14)
class SharedExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String groupId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String? description;
  @HiveField(4)
  final double totalAmount;
  @HiveField(5)
  final String currency;
  @HiveField(6)
  final CategoryModel category;
  @HiveField(7)
  final EnhancedSplitTypeModel splitType;
  @HiveField(8)
  final List<ExpenseParticipantModel> participants;
  @HiveField(9)
  final String createdBy;
  @HiveField(10)
  final DateTime createdAt;
  @HiveField(11)
  final DateTime updatedAt;
  @HiveField(12)
  final List<String>? receiptUrls;
  @HiveField(13)
  final Map<String, dynamic>? metadata;
  @HiveField(14)
  final bool isRecurring;
  @HiveField(15)
  final String? recurringPattern;
  @HiveField(16)
  final DateTime? recurringEndDate;
  @HiveField(17)
  final bool isSettled;
  @HiveField(18)
  final List<String> tags;

  SharedExpenseModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.totalAmount,
    required this.currency,
    required this.category,
    required this.splitType,
    required this.participants,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.receiptUrls,
    this.metadata,
    this.isRecurring = false,
    this.recurringPattern,
    this.recurringEndDate,
    this.isSettled = false,
    this.tags = const [],
  });

  factory SharedExpenseModel.fromEntity(SharedExpenseEntity entity) {
    return SharedExpenseModel(
      id: entity.id,
      groupId: entity.groupId,
      title: entity.title,
      description: entity.description,
      totalAmount: entity.totalAmount,
      currency: entity.currency,
      category: CategoryModel.fromEntity(entity.category),
      splitType: _mapSplitTypeToModel(entity.splitType),
      participants: entity.participants.map((p) => ExpenseParticipantModel.fromEntity(p)).toList(),
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      receiptUrls: entity.receiptUrls,
      metadata: entity.metadata,
      isRecurring: entity.isRecurring,
      recurringPattern: entity.recurringPattern,
      recurringEndDate: entity.recurringEndDate,
      isSettled: entity.isSettled,
      tags: entity.tags,
    );
  }

  SharedExpenseEntity toEntity() {
    return SharedExpenseEntity(
      id: id,
      groupId: groupId,
      title: title,
      description: description,
      totalAmount: totalAmount,
      currency: currency,
      category: category.toEntity(),
      splitType: _mapSplitTypeFromModel(splitType),
      participants: participants.map((p) => p.toEntity()).toList(),
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      receiptUrls: receiptUrls,
      metadata: metadata,
      isRecurring: isRecurring,
      recurringPattern: recurringPattern,
      recurringEndDate: recurringEndDate,
      isSettled: isSettled,
      tags: tags,
    );
  }

  static EnhancedSplitTypeModel _mapSplitTypeToModel(EnhancedSplitType type) {
    switch (type) {
      case EnhancedSplitType.equal:
        return EnhancedSplitTypeModel.equal;
      case EnhancedSplitType.exact:
        return EnhancedSplitTypeModel.exact;
      case EnhancedSplitType.percentage:
        return EnhancedSplitTypeModel.percentage;
      case EnhancedSplitType.shares:
        return EnhancedSplitTypeModel.shares;
      case EnhancedSplitType.adjustment:
        return EnhancedSplitTypeModel.adjustment;
    }
  }

  static EnhancedSplitType _mapSplitTypeFromModel(EnhancedSplitTypeModel type) {
    switch (type) {
      case EnhancedSplitTypeModel.equal:
        return EnhancedSplitType.equal;
      case EnhancedSplitTypeModel.exact:
        return EnhancedSplitType.exact;
      case EnhancedSplitTypeModel.percentage:
        return EnhancedSplitType.percentage;
      case EnhancedSplitTypeModel.shares:
        return EnhancedSplitType.shares;
      case EnhancedSplitTypeModel.adjustment:
        return EnhancedSplitType.adjustment;
    }
  }
}
