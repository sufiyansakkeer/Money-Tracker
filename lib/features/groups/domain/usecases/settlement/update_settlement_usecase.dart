import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/extensions/result_extensions.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';
import 'package:money_track/features/groups/domain/entities/group_activity_entity.dart';
import 'package:money_track/features/groups/domain/repositories/settlement_repository.dart';
import 'package:money_track/features/groups/domain/repositories/group_activity_repository.dart';

class UpdateSettlementUseCase
    implements UseCase<Result<void>, UpdateSettlementParams> {
  final SettlementRepository settlementRepository;
  final GroupActivityRepository activityRepository;

  UpdateSettlementUseCase({
    required this.settlementRepository,
    required this.activityRepository,
  });

  @override
  Future<Result<void>> call({UpdateSettlementParams? params}) async {
    if (params == null) {
      throw ArgumentError('UpdateSettlementParams cannot be null');
    }

    // Update the settlement
    final result = await settlementRepository.updateSettlement(params.settlement);

    if (result.isError) {
      return result;
    }

    // Create activity log entry based on the action type
    GroupActivityEntity? activity;
    
    switch (params.actionType) {
      case SettlementActionType.confirmed:
        activity = GroupActivityEntity.settlementConfirmed(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          groupId: params.settlement.groupId,
          actorId: params.updatedBy,
          actorName: params.updatedByName,
          receiverName: params.settlement.receiverName,
          amount: params.settlement.amount,
          currency: params.settlement.currency,
          settlementId: params.settlement.id,
        );
        break;
      case SettlementActionType.cancelled:
        activity = GroupActivityEntity.settlementCancelled(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          groupId: params.settlement.groupId,
          actorId: params.updatedBy,
          actorName: params.updatedByName,
          receiverName: params.settlement.receiverName,
          amount: params.settlement.amount,
          currency: params.settlement.currency,
          settlementId: params.settlement.id,
        );
        break;
      case SettlementActionType.updated:
        activity = GroupActivityEntity.settlementUpdated(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          groupId: params.settlement.groupId,
          actorId: params.updatedBy,
          actorName: params.updatedByName,
          receiverName: params.settlement.receiverName,
          amount: params.settlement.amount,
          currency: params.settlement.currency,
          settlementId: params.settlement.id,
        );
        break;
    }

    // Add activity (don't fail the main operation if this fails)
    if (activity != null) {
      await activityRepository.addActivity(activity);
    }

    return Success(null);
  }
}

enum SettlementActionType {
  confirmed,
  cancelled,
  updated,
}

class UpdateSettlementParams {
  final SettlementEntity settlement;
  final String updatedBy;
  final String updatedByName;
  final SettlementActionType actionType;

  UpdateSettlementParams({
    required this.settlement,
    required this.updatedBy,
    required this.updatedByName,
    required this.actionType,
  });
}
