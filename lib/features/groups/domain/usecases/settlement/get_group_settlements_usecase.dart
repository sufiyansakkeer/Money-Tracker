import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';
import 'package:money_track/features/groups/domain/repositories/settlement_repository.dart';

class GetGroupSettlementsUseCase
    implements
        UseCase<Result<List<SettlementEntity>>, GetGroupSettlementsParams> {
  final SettlementRepository repository;

  GetGroupSettlementsUseCase({required this.repository});

  @override
  Future<Result<List<SettlementEntity>>> call(
      {GetGroupSettlementsParams? params}) async {
    if (params == null) {
      return Error(ValidationFailure(message: 'Group ID is required'));
    }

    return await repository.getSettlementsByGroup(params.groupId);
  }
}

class GetGroupSettlementsParams {
  final String groupId;

  GetGroupSettlementsParams({required this.groupId});
}
