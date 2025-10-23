import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/extensions/result_extensions.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';
import 'package:money_track/features/groups/domain/entities/group_activity_entity.dart';
import 'package:money_track/features/groups/domain/repositories/settlement_repository.dart';
import 'package:money_track/features/groups/domain/repositories/group_activity_repository.dart';

class AddSettlementUseCase
    implements UseCase<Result<void>, AddSettlementParams> {
  final SettlementRepository settlementRepository;
  final GroupActivityRepository activityRepository;

  AddSettlementUseCase({
    required this.settlementRepository,
    required this.activityRepository,
  });

  @override
  Future<Result<void>> call({AddSettlementParams? params}) async {
    if (params == null) {
      throw ArgumentError('AddSettlementParams cannot be null');
    }
    // Add the settlement
    final result = await settlementRepository.addSettlement(params.settlement);

    if (result.isError) {
      return result;
    }

    // Create activity log entry
    final activity = GroupActivityEntity.settlementAdded(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: params.settlement.groupId,
      actorId: params.settlement.payerId,
      actorName: params.settlement.payerName,
      receiverName: params.settlement.receiverName,
      amount: params.settlement.amount,
      currency: params.settlement.currency,
      settlementId: params.settlement.id,
    );

    // Add activity (don't fail the main operation if this fails)
    await activityRepository.addActivity(activity);

    return Success(null);
  }
}

class AddSettlementParams {
  final SettlementEntity settlement;

  AddSettlementParams({
    required this.settlement,
  });
}
