import 'package:money_track/features/groups/domain/entities/split_details.dart';

abstract class SplitDetailsRepository {
  Future<void> addSplitDetails(SplitDetails details);
  Future<SplitDetails?> getSplitDetailsByTransactionId(String transactionId);
  Future<List<SplitDetails>> getSplitDetailsByGroupId(String groupId);
  Future<void> deleteSplitDetails(String transactionId);
}
