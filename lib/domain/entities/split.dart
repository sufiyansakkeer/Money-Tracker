import 'package:equatable/equatable.dart';

class Split extends Equatable {
  final String contactId;
  final double amount;
  final bool isPaid;

  const Split({
    required this.contactId,
    required this.amount,
    required this.isPaid,
  });

  @override
  List<Object?> get props => [contactId, amount, isPaid];
}
