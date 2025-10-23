import 'package:hive_ce/hive.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';

part 'settlement_model.g.dart';

@HiveType(typeId: 15)
enum SettlementStatusModel {
  @HiveField(0)
  pending,
  @HiveField(1)
  confirmed,
  @HiveField(2)
  cancelled,
}

@HiveType(typeId: 16)
enum PaymentMethodModel {
  @HiveField(0)
  cash,
  @HiveField(1)
  bankTransfer,
  @HiveField(2)
  digitalWallet,
  @HiveField(3)
  creditCard,
  @HiveField(4)
  other,
}

@HiveType(typeId: 17)
class SettlementModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String groupId;
  @HiveField(2)
  final String payerId;
  @HiveField(3)
  final String payerName;
  @HiveField(4)
  final String receiverId;
  @HiveField(5)
  final String receiverName;
  @HiveField(6)
  final double amount;
  @HiveField(7)
  final String currency;
  @HiveField(8)
  final PaymentMethodModel paymentMethod;
  @HiveField(9)
  final SettlementStatusModel status;
  @HiveField(10)
  final String? description;
  @HiveField(11)
  final String? notes;
  @HiveField(12)
  final DateTime createdAt;
  @HiveField(13)
  final DateTime updatedAt;
  @HiveField(14)
  final DateTime? confirmedAt;
  @HiveField(15)
  final String? confirmedBy;
  @HiveField(16)
  final List<String>? relatedExpenseIds;
  @HiveField(17)
  final String? receiptUrl;
  @HiveField(18)
  final Map<String, dynamic>? metadata;

  SettlementModel({
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

  factory SettlementModel.fromEntity(SettlementEntity entity) {
    return SettlementModel(
      id: entity.id,
      groupId: entity.groupId,
      payerId: entity.payerId,
      payerName: entity.payerName,
      receiverId: entity.receiverId,
      receiverName: entity.receiverName,
      amount: entity.amount,
      currency: entity.currency,
      paymentMethod: _mapPaymentMethodToModel(entity.paymentMethod),
      status: _mapStatusToModel(entity.status),
      description: entity.description,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      confirmedAt: entity.confirmedAt,
      confirmedBy: entity.confirmedBy,
      relatedExpenseIds: entity.relatedExpenseIds,
      receiptUrl: entity.receiptUrl,
      metadata: entity.metadata,
    );
  }

  SettlementEntity toEntity() {
    return SettlementEntity(
      id: id,
      groupId: groupId,
      payerId: payerId,
      payerName: payerName,
      receiverId: receiverId,
      receiverName: receiverName,
      amount: amount,
      currency: currency,
      paymentMethod: _mapPaymentMethodFromModel(paymentMethod),
      status: _mapStatusFromModel(status),
      description: description,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      confirmedAt: confirmedAt,
      confirmedBy: confirmedBy,
      relatedExpenseIds: relatedExpenseIds,
      receiptUrl: receiptUrl,
      metadata: metadata,
    );
  }

  static PaymentMethodModel _mapPaymentMethodToModel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return PaymentMethodModel.cash;
      case PaymentMethod.bankTransfer:
        return PaymentMethodModel.bankTransfer;
      case PaymentMethod.digitalWallet:
        return PaymentMethodModel.digitalWallet;
      case PaymentMethod.creditCard:
        return PaymentMethodModel.creditCard;
      case PaymentMethod.other:
        return PaymentMethodModel.other;
    }
  }

  static PaymentMethod _mapPaymentMethodFromModel(PaymentMethodModel method) {
    switch (method) {
      case PaymentMethodModel.cash:
        return PaymentMethod.cash;
      case PaymentMethodModel.bankTransfer:
        return PaymentMethod.bankTransfer;
      case PaymentMethodModel.digitalWallet:
        return PaymentMethod.digitalWallet;
      case PaymentMethodModel.creditCard:
        return PaymentMethod.creditCard;
      case PaymentMethodModel.other:
        return PaymentMethod.other;
    }
  }

  static SettlementStatusModel _mapStatusToModel(SettlementStatus status) {
    switch (status) {
      case SettlementStatus.pending:
        return SettlementStatusModel.pending;
      case SettlementStatus.confirmed:
        return SettlementStatusModel.confirmed;
      case SettlementStatus.cancelled:
        return SettlementStatusModel.cancelled;
    }
  }

  static SettlementStatus _mapStatusFromModel(SettlementStatusModel status) {
    switch (status) {
      case SettlementStatusModel.pending:
        return SettlementStatus.pending;
      case SettlementStatusModel.confirmed:
        return SettlementStatus.confirmed;
      case SettlementStatusModel.cancelled:
        return SettlementStatus.cancelled;
    }
  }
}
