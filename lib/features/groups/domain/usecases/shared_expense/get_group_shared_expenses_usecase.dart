import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/features/groups/domain/repositories/shared_expense_repository.dart';

class GetGroupSharedExpensesUseCase
    implements
        UseCase<Result<List<SharedExpenseEntity>>,
            GetGroupSharedExpensesParams> {
  final SharedExpenseRepository repository;

  GetGroupSharedExpensesUseCase({
    required this.repository,
  });

  @override
  Future<Result<List<SharedExpenseEntity>>> call(
      {GetGroupSharedExpensesParams? params}) async {
    if (params == null) {
      throw ArgumentError('GetGroupSharedExpensesParams cannot be null');
    }
    return await repository.getSharedExpensesByGroup(params.groupId);
  }
}

class GetGroupSharedExpensesParams {
  final String groupId;

  GetGroupSharedExpensesParams({
    required this.groupId,
  });
}
