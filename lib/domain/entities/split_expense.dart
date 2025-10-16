import 'package:equatable/equatable.dart';
import 'package:money_track/domain/entities/split.dart';

class SplitExpense extends Equatable {
  final String id;
  final String expenseId;
  final String groupId;
  final List<Split> splits;

  const SplitExpense({
    required this.id,
    required this.expenseId,
    required this.groupId,
    required this.splits,
  });

  @override
  List<Object?> get props => [id, expenseId, groupId, splits];
}
