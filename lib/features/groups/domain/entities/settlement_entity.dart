import 'package:equatable/equatable.dart';

/// Settlement status enumeration
enum SettlementStatus {
  pending,     // Settlement recorded but not confirmed
  confirmed,   // Settlement confirmed by both parties
  cancelled,   // Settlement was cancelled
}

/// Payment method enumeration
enum PaymentMethod {
  cash,
  bankTransfer,
  digitalWallet,
  creditCard,
  other,
}

/// Settlement entity for recording payments between group members
class SettlementEntity extends Equatable {
  final String id;
  final String groupId;
  final String payerId;          // Member who made the payment
  final String payerName;
  final String receiverId;       // Member who received the payment
  final String receiverName;
  final double amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final SettlementStatus status;
  final String? description;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;   // When the settlement was confirmed
  final String? confirmedBy;     // Who confirmed the settlement
  final List<String>? relatedExpenseIds; // Expenses this settlement relates to
  final String? receiptUrl;      // Receipt/proof of payment
  final Map<String, dynamic>? metadata;

  const SettlementEntity({
    required this.id,
    required this.groupId,
    required this.payerId,
    required this.payerName,
    required this.receiverId,
    required this.receiverName,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.notes,
    this.confirmedAt,
    this.confirmedBy,
    this.relatedExpenseIds,
    this.receiptUrl,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        payerId,
        payerName,
        receiverId,
        receiverName,
        amount,
        currency,
        paymentMethod,
        status,
        description,
        notes,
        createdAt,
        updatedAt,
        confirmedAt,
        confirmedBy,
        relatedExpenseIds,
        receiptUrl,
        metadata,
      ];

  SettlementEntity copyWith({
    String? id,
    String? groupId,
    String? payerId,
    String? payerName,
    String? receiverId,
    String? receiverName,
    double? amount,
    String? currency,
    PaymentMethod? paymentMethod,
    SettlementStatus? status,
    String? description,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    String? confirmedBy,
    List<String>? relatedExpenseIds,
    String? receiptUrl,
    Map<String, dynamic>? metadata,
  }) {
    return SettlementEntity(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      payerId: payerId ?? this.payerId,
      payerName: payerName ?? this.payerName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      confirmedBy: confirmedBy ?? this.confirmedBy,
      relatedExpenseIds: relatedExpenseIds ?? this.relatedExpenseIds,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Whether the settlement is pending confirmation
  bool get isPending => status == SettlementStatus.pending;

  /// Whether the settlement is confirmed
  bool get isConfirmed => status == SettlementStatus.confirmed;

  /// Whether the settlement is cancelled
  bool get isCancelled => status == SettlementStatus.cancelled;

  /// Get a formatted description of the settlement
  String get formattedDescription {
    final baseDescription = description ?? 'Payment settlement';
    return '$payerName paid $receiverName $amount $currency - $baseDescription';
  }

  /// Get payment method display name
  String get paymentMethodDisplayName {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.digitalWallet:
        return 'Digital Wallet';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case SettlementStatus.pending:
        return 'Pending';
      case SettlementStatus.confirmed:
        return 'Confirmed';
      case SettlementStatus.cancelled:
        return 'Cancelled';
    }
  }
}
