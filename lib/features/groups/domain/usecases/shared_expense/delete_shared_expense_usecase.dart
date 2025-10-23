import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/extensions/result_extensions.dart';
import 'package:money_track/features/groups/domain/entities/group_activity_entity.dart';
import 'package:money_track/features/groups/domain/repositories/shared_expense_repository.dart';
import 'package:money_track/features/groups/domain/repositories/group_activity_repository.dart';

class DeleteSharedExpenseUseCase
    implements UseCase<Result<void>, DeleteSharedExpenseParams> {
  final SharedExpenseRepository sharedExpenseRepository;
  final GroupActivityRepository activityRepository;

  DeleteSharedExpenseUseCase({
    required this.sharedExpenseRepository,
    required this.activityRepository,
  });

  @override
  Future<Result<void>> call({DeleteSharedExpenseParams? params}) async {
    if (params == null) {
      throw ArgumentError('DeleteSharedExpenseParams cannot be null');
    }

    // Get the expense details before deletion for activity logging
    final expenseResult =
        await sharedExpenseRepository.getSharedExpenseById(params.expenseId);

    if (expenseResult.isError) {
      return Error(expenseResult.failure!);
    }

    final expense = expenseResult.data;
    if (expense == null) {
      return Error(DatabaseFailure(message: 'Expense not found'));
    }

    // Delete the shared expense
    final result =
        await sharedExpenseRepository.deleteSharedExpense(params.expenseId);

    if (result.isError) {
      return result;
    }

    // Create activity log entry
    final activity = GroupActivityEntity.expenseDeleted(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: expense.groupId,
      actorId: params.deletedBy,
      actorName: params.deletedByName,
      expenseTitle: expense.title,
      amount: expense.totalAmount,
      currency: expense.currency,
      expenseId: expense.id,
    );

    // Add activity (don't fail the main operation if this fails)
    await activityRepository.addActivity(activity);

    return Success(null);
  }
}

class DeleteSharedExpenseParams {
  final String expenseId;
  final String deletedBy;
  final String deletedByName;

  DeleteSharedExpenseParams({
    required this.expenseId,
    required this.deletedBy,
    required this.deletedByName,
  });
}
