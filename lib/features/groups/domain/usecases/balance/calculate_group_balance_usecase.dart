import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/extensions/result_extensions.dart';
import 'package:money_track/features/groups/domain/entities/balance_entity.dart';
import 'package:money_track/features/groups/domain/repositories/shared_expense_repository.dart';
import 'package:money_track/features/groups/domain/repositories/settlement_repository.dart';
import 'package:money_track/features/groups/domain/repositories/group_repository.dart';
import 'package:money_track/features/groups/domain/utils/balance_calculator.dart';

class CalculateGroupBalanceUseCase
    implements
        UseCase<Result<GroupBalanceEntity>, CalculateGroupBalanceParams> {
  final SharedExpenseRepository sharedExpenseRepository;
  final SettlementRepository settlementRepository;
  final GroupRepository groupRepository;

  CalculateGroupBalanceUseCase({
    required this.sharedExpenseRepository,
    required this.settlementRepository,
    required this.groupRepository,
  });

  @override
  Future<Result<GroupBalanceEntity>> call(
      {CalculateGroupBalanceParams? params}) async {
    if (params == null) {
      throw ArgumentError('CalculateGroupBalanceParams cannot be null');
    }
    // Get group details
    final groupResult = await groupRepository.getGroupById(params.groupId);
    if (groupResult.isError) {
      return Error(groupResult.error!);
    }

    final group = groupResult.data;
    if (group == null) {
      return Error(DatabaseFailure(message: 'Group not found'));
    }

    // Get shared expenses for the group
    final expensesResult =
        await sharedExpenseRepository.getSharedExpensesByGroup(params.groupId);
    if (expensesResult.isError) {
      return Error(expensesResult.error!);
    }

    // Get settlements for the group
    final settlementsResult =
        await settlementRepository.getSettlementsByGroup(params.groupId);
    if (settlementsResult.isError) {
      return Error(settlementsResult.error!);
    }

    // Calculate balance
    final balance = BalanceCalculator.calculateGroupBalance(
      group: group,
      expenses: expensesResult.data!,
      settlements: settlementsResult.data!,
      currency: params.currency ?? 'USD',
    );

    return Success(balance);
  }
}

class CalculateGroupBalanceParams {
  final String groupId;
  final String? currency;

  CalculateGroupBalanceParams({
    required this.groupId,
    this.currency,
  });
}
