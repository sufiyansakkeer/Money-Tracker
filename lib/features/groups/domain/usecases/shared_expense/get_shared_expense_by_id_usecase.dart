import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/features/groups/domain/repositories/shared_expense_repository.dart';

class GetSharedExpenseByIdUseCase
    implements UseCase<Result<SharedExpenseEntity?>, GetSharedExpenseByIdParams> {
  final SharedExpenseRepository repository;

  GetSharedExpenseByIdUseCase({
    required this.repository,
  });

  @override
  Future<Result<SharedExpenseEntity?>> call({GetSharedExpenseByIdParams? params}) async {
    if (params == null) {
      throw ArgumentError('GetSharedExpenseByIdParams cannot be null');
    }
    return await repository.getSharedExpenseById(params.expenseId);
  }
}

class GetSharedExpenseByIdParams {
  final String expenseId;

  GetSharedExpenseByIdParams({
    required this.expenseId,
  });
}
