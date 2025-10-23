import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/extensions/result_extensions.dart';
import 'package:money_track/features/groups/domain/entities/group_activity_entity.dart';
import 'package:money_track/features/groups/domain/repositories/settlement_repository.dart';
import 'package:money_track/features/groups/domain/repositories/group_activity_repository.dart';

class DeleteSettlementUseCase
    implements UseCase<Result<void>, DeleteSettlementParams> {
  final SettlementRepository settlementRepository;
  final GroupActivityRepository activityRepository;

  DeleteSettlementUseCase({
    required this.settlementRepository,
    required this.activityRepository,
  });

  @override
  Future<Result<void>> call({DeleteSettlementParams? params}) async {
    if (params == null) {
      throw ArgumentError('DeleteSettlementParams cannot be null');
    }

    // Get the settlement details before deletion for activity logging
    final settlementResult =
        await settlementRepository.getSettlementById(params.settlementId);

    if (settlementResult.isError) {
      return Error(settlementResult.failure!);
    }

    final settlement = settlementResult.data;
    if (settlement == null) {
      return Error(DatabaseFailure(message: 'Settlement not found'));
    }

    // Delete the settlement
    final result =
        await settlementRepository.deleteSettlement(params.settlementId);

    if (result.isError) {
      return result;
    }

    // Create activity log entry
    final activity = GroupActivityEntity.settlementDeleted(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: settlement.groupId,
      actorId: params.deletedBy,
      actorName: params.deletedByName,
      receiverName: settlement.receiverName,
      amount: settlement.amount,
      currency: settlement.currency,
      settlementId: settlement.id,
    );

    // Add activity (don't fail the main operation if this fails)
    await activityRepository.addActivity(activity);

    return Success(null);
  }
}

class DeleteSettlementParams {
  final String settlementId;
  final String deletedBy;
  final String deletedByName;

  DeleteSettlementParams({
    required this.settlementId,
    required this.deletedBy,
    required this.deletedByName,
  });
}
