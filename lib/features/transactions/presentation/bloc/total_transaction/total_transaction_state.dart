part of 'total_transaction_cubit.dart';

/// Enhanced states with better immutability and error handling
abstract class TotalTransactionState extends Equatable {
  const TotalTransactionState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TotalTransactionInitial extends TotalTransactionState {
  const TotalTransactionInitial();
}

/// Loading state
class TotalTransactionLoading extends TotalTransactionState {
  const TotalTransactionLoading();
}

/// Success state with enhanced data
class TotalTransactionSuccess extends TotalTransactionState {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int transactionCount;

  const TotalTransactionSuccess({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
  });

  /// Copy with method for immutable updates
  TotalTransactionSuccess copyWith({
    double? totalIncome,
    double? totalExpense,
    double? balance,
    int? transactionCount,
  }) {
    return TotalTransactionSuccess(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }

  @override
  List<Object> get props => [
        totalIncome,
        totalExpense,
        balance,
        transactionCount,
      ];

  @override
  String toString() => 'TotalTransactionSuccess('
      'totalIncome: $totalIncome, '
      'totalExpense: $totalExpense, '
      'balance: $balance, '
      'transactionCount: $transactionCount)';
}

/// Error state with structured failure handling
class TotalTransactionError extends TotalTransactionState {
  final Failure failure;

  const TotalTransactionError({required this.failure});

  /// Get user-friendly error message
  String get userMessage {
    switch (failure) {
      case DatabaseFailure _:
        return 'Unable to load transaction data. Please try again.';
      case ValidationFailure _:
        return 'Invalid transaction data detected.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Legacy getter for backward compatibility
  String get message => failure.message;

  @override
  List<Object> get props => [failure];

  @override
  String toString() => 'TotalTransactionError(failure: $failure)';
}
