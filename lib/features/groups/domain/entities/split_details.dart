import 'package:equatable/equatable.dart';

enum SplitType {
  equal,
  custom,
  percentage,
  shares, // New: Share-based split
  adjustment, // New: Manual adjustment
}

/// Enhanced split details with additional metadata and functionality
class SplitDetails extends Equatable {
  final String transactionId;
  final String payerMemberId;
  final SplitType splitType;
  final Map<String, double> splitData; // memberId -> amount or percentage
  final Map<String, double>?
      sharesData; // memberId -> shares (for share-based splits)
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final Map<String, dynamic>? metadata;

  const SplitDetails({
    required this.transactionId,
    required this.payerMemberId,
    required this.splitType,
    required this.splitData,
    this.sharesData,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        transactionId,
        payerMemberId,
        splitType,
        splitData,
        sharesData,
        notes,
        createdAt,
        updatedAt,
        createdBy,
        metadata,
      ];

  SplitDetails copyWith({
    String? transactionId,
    String? payerMemberId,
    SplitType? splitType,
    Map<String, double>? splitData,
    Map<String, double>? sharesData,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    Map<String, dynamic>? metadata,
  }) {
    return SplitDetails(
      transactionId: transactionId ?? this.transactionId,
      payerMemberId: payerMemberId ?? this.payerMemberId,
      splitType: splitType ?? this.splitType,
      splitData: splitData ?? this.splitData,
      sharesData: sharesData ?? this.sharesData,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get total amount being split
  double get totalAmount {
    return splitData.values.fold(0.0, (sum, amount) => sum + amount);
  }

  /// Get number of participants in the split
  int get participantCount {
    return splitData.length;
  }

  /// Get split type display name
  String get splitTypeDisplayName {
    switch (splitType) {
      case SplitType.equal:
        return 'Equal Split';
      case SplitType.custom:
        return 'Custom Amounts';
      case SplitType.percentage:
        return 'Percentage Split';
      case SplitType.shares:
        return 'Share-based Split';
      case SplitType.adjustment:
        return 'Manual Adjustment';
    }
  }

  /// Check if the split is valid (amounts add up correctly)
  bool isValid(double expectedTotal) {
    if (splitType == SplitType.percentage) {
      final totalPercentage =
          splitData.values.fold(0.0, (sum, pct) => sum + pct);
      return (totalPercentage - 100.0).abs() < 0.01;
    } else {
      return (totalAmount - expectedTotal).abs() < 0.01;
    }
  }
}
