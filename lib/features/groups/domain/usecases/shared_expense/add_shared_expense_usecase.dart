import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/extensions/result_extensions.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/features/groups/domain/entities/group_activity_entity.dart';
import 'package:money_track/features/groups/domain/repositories/shared_expense_repository.dart';
import 'package:money_track/features/groups/domain/repositories/group_activity_repository.dart';

class AddSharedExpenseUseCase
    implements UseCase<Result<void>, AddSharedExpenseParams> {
  final SharedExpenseRepository sharedExpenseRepository;
  final GroupActivityRepository activityRepository;

  AddSharedExpenseUseCase({
    required this.sharedExpenseRepository,
    required this.activityRepository,
  });

  @override
  Future<Result<void>> call({AddSharedExpenseParams? params}) async {
    if (params == null) {
      throw ArgumentError('AddSharedExpenseParams cannot be null');
    }
    // Add the shared expense
    final result =
        await sharedExpenseRepository.addSharedExpense(params.expense);

    if (result.isError) {
      return result;
    }

    // Create activity log entry
    final activity = GroupActivityEntity.expenseAdded(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: params.expense.groupId,
      actorId: params.expense.createdBy,
      actorName: params.expense.participants
          .firstWhere((p) => p.memberId == params.expense.createdBy)
          .memberName,
      expenseTitle: params.expense.title,
      amount: params.expense.totalAmount,
      currency: params.expense.currency,
      expenseId: params.expense.id,
    );

    // Add activity (don't fail the main operation if this fails)
    await activityRepository.addActivity(activity);

    return Success(null);
  }
}

class AddSharedExpenseParams {
  final SharedExpenseEntity expense;

  AddSharedExpenseParams({
    required this.expense,
  });
}
