import 'package:money_track/domain/entities/split_expense.dart';

abstract class ExpenseRepository {
  Future<void> splitExpense(SplitExpense splitExpense);
}
