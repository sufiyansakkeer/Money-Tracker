import 'package:money_track/features/groups/data/datasources/split_details_local_data_source.dart';
import 'package:money_track/features/groups/data/models/split_details_model.dart';
import 'package:money_track/features/groups/domain/entities/split_details.dart';
import 'package:money_track/features/groups/domain/repositories/split_details_repository.dart';

class SplitDetailsRepositoryImpl implements SplitDetailsRepository {
  final SplitDetailsLocalDataSource localDataSource;

  SplitDetailsRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addSplitDetails(SplitDetails details) async {
    final model = SplitDetailsModel.fromEntity(details);
    await localDataSource.addSplitDetails(model);
  }

  @override
  Future<SplitDetails?> getSplitDetailsByTransactionId(String transactionId) async {
    final model = await localDataSource.getSplitDetailsByTransactionId(transactionId);
    return model?.toEntity();
  }

  @override
  Future<List<SplitDetails>> getSplitDetailsByGroupId(String groupId) async {
    final models = await localDataSource.getSplitDetailsByGroupId(groupId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> deleteSplitDetails(String transactionId) async {
    await localDataSource.deleteSplitDetails(transactionId);
  }
}
