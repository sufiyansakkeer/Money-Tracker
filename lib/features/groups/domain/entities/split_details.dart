import 'package:equatable/equatable.dart';

enum SplitType {
  equal,
  custom,
  percentage,
}

class SplitDetails extends Equatable {
  final String transactionId;
  final String payerMemberId;
  final SplitType splitType;
  final Map<String, double> splitData; // memberId -> amount or percentage

  const SplitDetails({
    required this.transactionId,
    required this.payerMemberId,
    required this.splitType,
    required this.splitData,
  });

  @override
  List<Object?> get props => [transactionId, payerMemberId, splitType, splitData];

  SplitDetails copyWith({
    String? transactionId,
    String? payerMemberId,
    SplitType? splitType,
    Map<String, double>? splitData,
  }) {
    return SplitDetails(
      transactionId: transactionId ?? this.transactionId,
      payerMemberId: payerMemberId ?? this.payerMemberId,
      splitType: splitType ?? this.splitType,
      splitData: splitData ?? this.splitData,
    );
  }
}