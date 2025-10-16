import 'package:hive_ce/hive.dart';
import 'package:money_track/core/constants/db_constants.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/data/models/transaction_model.dart';
import 'package:money_track/features/groups/data/models/split_details_model.dart';

abstract class SplitDetailsLocalDataSource {
  Future<void> addSplitDetails(SplitDetailsModel details);
  Future<SplitDetailsModel?> getSplitDetailsByTransactionId(
      String transactionId);
  Future<List<SplitDetailsModel>> getSplitDetailsByGroupId(String groupId);
  Future<void> deleteSplitDetails(String transactionId);
}

class SplitDetailsLocalDataSourceImpl implements SplitDetailsLocalDataSource {
  final Box<SplitDetailsModel> _box;
  final HiveInterface _hive;

  SplitDetailsLocalDataSourceImpl(this._box, this._hive);

  @override
  Future<void> addSplitDetails(SplitDetailsModel details) async {
    try {
      await _box.put(details.transactionId, details);
    } catch (e) {
      throw DatabaseFailure(
          message: "Failed to add split details: ${e.toString()}");
    }
  }

  @override
  Future<SplitDetailsModel?> getSplitDetailsByTransactionId(
      String transactionId) async {
    try {
      return _box.get(transactionId);
    } catch (e) {
      throw DatabaseFailure(
          message: "Failed to get split details: ${e.toString()}");
    }
  }

  @override
  Future<List<SplitDetailsModel>> getSplitDetailsByGroupId(
      String groupId) async {
    try {
      // Get the transaction box to filter by groupId
      final transactionBox =
          await _hive.openBox<TransactionModel>(DBConstants.transactionDbName);

      // Get all transactions that belong to this group
      final groupTransactions = transactionBox.values
          .where((transaction) => transaction.groupId == groupId)
          .toList();

      // Extract transaction IDs
      final transactionIds = groupTransactions.map((t) => t.id).toSet();

      // Filter split details by transaction IDs
      final filteredSplitDetails = _box.values
          .where((splitDetails) =>
              transactionIds.contains(splitDetails.transactionId))
          .toList();

      return filteredSplitDetails;
    } catch (e) {
      throw DatabaseFailure(
          message: "Failed to get split details by group: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteSplitDetails(String transactionId) async {
    try {
      await _box.delete(transactionId);
    } catch (e) {
      throw DatabaseFailure(
          message: "Failed to delete split details: ${e.toString()}");
    }
  }
}
