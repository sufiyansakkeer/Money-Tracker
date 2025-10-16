import 'package:money_track/features/groups/domain/entities/split_details.dart';

class SplitCalculator {
  /// Calculate equal split among members
  static Map<String, double> calculateEqualSplit(
    double totalAmount,
    List<String> memberIds,
  ) {
    if (memberIds.isEmpty) {
      throw ArgumentError('Cannot split expense with no members');
    }
    if (totalAmount <= 0) {
      throw ArgumentError('Total amount must be greater than zero');
    }

    final double amountPerMember = totalAmount / memberIds.length;
    return Map.fromEntries(
      memberIds.map((id) => MapEntry(id, amountPerMember)),
    );
  }

  /// Calculate custom split with specified amounts
  static Map<String, double> calculateCustomSplit(
    Map<String, double> customAmounts,
  ) {
    if (customAmounts.isEmpty) {
      throw ArgumentError('Custom amounts cannot be empty');
    }

    // Validate that no amount is negative
    for (final entry in customAmounts.entries) {
      if (entry.value < 0) {
        throw ArgumentError('Split amounts cannot be negative');
      }
    }

    return Map.from(customAmounts);
  }

  /// Calculate percentage-based split
  static Map<String, double> calculatePercentageSplit(
    double totalAmount,
    Map<String, double> percentages,
  ) {
    if (percentages.isEmpty) {
      throw ArgumentError('Percentages cannot be empty');
    }
    if (totalAmount <= 0) {
      throw ArgumentError('Total amount must be greater than zero');
    }

    // Validate that no percentage is negative
    for (final entry in percentages.entries) {
      if (entry.value < 0) {
        throw ArgumentError('Percentages cannot be negative');
      }
      if (entry.value > 100) {
        throw ArgumentError('Individual percentage cannot exceed 100%');
      }
    }

    final Map<String, double> result = {};

    for (final entry in percentages.entries) {
      result[entry.key] = totalAmount * (entry.value / 100);
    }

    return result;
  }

  /// Validate split amounts equal total
  static bool validateSplitAmounts(
    double totalAmount,
    Map<String, double> splitAmounts,
  ) {
    final double splitTotal =
        splitAmounts.values.fold(0.0, (sum, amount) => sum + amount);
    return (splitTotal - totalAmount).abs() <
        0.01; // Allow small rounding differences
  }

  /// Validate percentages equal 100%
  static bool validatePercentages(Map<String, double> percentages) {
    final double totalPercentage =
        percentages.values.fold(0.0, (sum, percentage) => sum + percentage);
    return (totalPercentage - 100.0).abs() < 0.01;
  }

  /// Create SplitDetails from calculation
  static SplitDetails createSplitDetails({
    required String transactionId,
    required String payerMemberId,
    required SplitType splitType,
    required double totalAmount,
    required List<String> memberIds,
    Map<String, double>? customAmounts,
    Map<String, double>? percentages,
  }) {
    Map<String, double> splitData;

    switch (splitType) {
      case SplitType.equal:
        splitData = calculateEqualSplit(totalAmount, memberIds);
        break;
      case SplitType.custom:
        if (customAmounts == null) {
          throw ArgumentError('Custom amounts required for custom split');
        }
        if (!validateSplitAmounts(totalAmount, customAmounts)) {
          throw ArgumentError('Custom amounts do not equal total amount');
        }
        splitData = calculateCustomSplit(customAmounts);
        break;
      case SplitType.percentage:
        if (percentages == null) {
          throw ArgumentError('Percentages required for percentage split');
        }
        if (!validatePercentages(percentages)) {
          throw ArgumentError('Percentages do not equal 100%');
        }
        splitData = calculatePercentageSplit(totalAmount, percentages);
        break;
    }

    return SplitDetails(
      transactionId: transactionId,
      payerMemberId: payerMemberId,
      splitType: splitType,
      splitData: splitData,
    );
  }
}
