import 'package:equatable/equatable.dart';
import 'package:money_track/domain/entities/category_entity.dart';

/// Enhanced split type with additional options for comprehensive expense splitting
enum EnhancedSplitType {
  equal,           // Split equally among all participants
  exact,           // Exact amounts specified for each participant
  percentage,      // Percentage-based split
  shares,          // Share-based split (e.g., 2:1:3 ratio)
  adjustment,      // Manual adjustment to existing split
}

/// Expense participant with detailed split information
class ExpenseParticipant extends Equatable {
  final String memberId;
  final String memberName;
  final double amount;           // Amount this participant owes
  final double paidAmount;       // Amount this participant paid
  final bool isPayer;            // Whether this participant paid for the expense
  final double? shares;          // For share-based splits
  final double? percentage;      // For percentage-based splits
  final String? notes;           // Participant-specific notes

  const ExpenseParticipant({
    required this.memberId,
    required this.memberName,
    required this.amount,
    this.paidAmount = 0.0,
    this.isPayer = false,
    this.shares,
    this.percentage,
    this.notes,
  });

  @override
  List<Object?> get props => [
        memberId,
        memberName,
        amount,
        paidAmount,
        isPayer,
        shares,
        percentage,
        notes,
      ];

  ExpenseParticipant copyWith({
    String? memberId,
    String? memberName,
    double? amount,
    double? paidAmount,
    bool? isPayer,
    double? shares,
    double? percentage,
    String? notes,
  }) {
    return ExpenseParticipant(
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      isPayer: isPayer ?? this.isPayer,
      shares: shares ?? this.shares,
      percentage: percentage ?? this.percentage,
      notes: notes ?? this.notes,
    );
  }

  /// Calculate the net balance for this participant (negative = owes, positive = owed)
  double get netBalance => paidAmount - amount;

  /// Whether this participant owes money
  bool get owes => netBalance < 0;

  /// Whether this participant is owed money
  bool get isOwed => netBalance > 0;
}

/// Comprehensive shared expense entity
class SharedExpenseEntity extends Equatable {
  final String id;
  final String groupId;
  final String title;
  final String? description;
  final double totalAmount;
  final String currency;
  final CategoryEntity category;
  final EnhancedSplitType splitType;
  final List<ExpenseParticipant> participants;
  final String createdBy;           // Member ID who created the expense
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? receiptUrls;  // URLs to receipt images
  final Map<String, dynamic>? metadata; // Additional metadata
  final bool isRecurring;
  final String? recurringPattern;   // For recurring expenses
  final DateTime? recurringEndDate;
  final bool isSettled;            // Whether all balances are settled
  final List<String> tags;         // Expense tags for categorization

  const SharedExpenseEntity({
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

  @override
  List<Object?> get props => [
        id,
        groupId,
        title,
        description,
        totalAmount,
        currency,
        category,
        splitType,
        participants,
        createdBy,
        createdAt,
        updatedAt,
        receiptUrls,
        metadata,
        isRecurring,
        recurringPattern,
        recurringEndDate,
        isSettled,
        tags,
      ];

  SharedExpenseEntity copyWith({
    String? id,
    String? groupId,
    String? title,
    String? description,
    double? totalAmount,
    String? currency,
    CategoryEntity? category,
    EnhancedSplitType? splitType,
    List<ExpenseParticipant>? participants,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? receiptUrls,
    Map<String, dynamic>? metadata,
    bool? isRecurring,
    String? recurringPattern,
    DateTime? recurringEndDate,
    bool? isSettled,
    List<String>? tags,
  }) {
    return SharedExpenseEntity(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      splitType: splitType ?? this.splitType,
      participants: participants ?? this.participants,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      receiptUrls: receiptUrls ?? this.receiptUrls,
      metadata: metadata ?? this.metadata,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      recurringEndDate: recurringEndDate ?? this.recurringEndDate,
      isSettled: isSettled ?? this.isSettled,
      tags: tags ?? this.tags,
    );
  }

  /// Get the primary payer (participant who paid the most)
  ExpenseParticipant? get primaryPayer {
    if (participants.isEmpty) return null;
    return participants.reduce((a, b) => a.paidAmount > b.paidAmount ? a : b);
  }

  /// Get all participants who paid something
  List<ExpenseParticipant> get payers {
    return participants.where((p) => p.paidAmount > 0).toList();
  }

  /// Get all participants who owe money
  List<ExpenseParticipant> get debtors {
    return participants.where((p) => p.owes).toList();
  }

  /// Get all participants who are owed money
  List<ExpenseParticipant> get creditors {
    return participants.where((p) => p.isOwed).toList();
  }

  /// Calculate total amount paid by all participants
  double get totalPaid {
    return participants.fold(0.0, (sum, p) => sum + p.paidAmount);
  }

  /// Calculate total amount owed by all participants
  double get totalOwed {
    return participants.fold(0.0, (sum, p) => sum + p.amount);
  }

  /// Check if the expense split is balanced (total paid = total owed)
  bool get isBalanced {
    return (totalPaid - totalOwed).abs() < 0.01; // Allow for small rounding errors
  }

  /// Get participant by member ID
  ExpenseParticipant? getParticipant(String memberId) {
    try {
      return participants.firstWhere((p) => p.memberId == memberId);
    } catch (e) {
      return null;
    }
  }
}
