import 'package:money_track/domain/entities/category_entity.dart';

/// Entity class for filter data
class FilterData {
  TransactionType? transactionType;
  TransactionSortEnum? transactionSortEnum;
  DateFilterType? dateFilterType;
  DateTime? startDate;
  DateTime? endDate;

  void reset() {
    transactionType = null;
    transactionSortEnum = null;
    dateFilterType = null;
    startDate = null;
    endDate = null;
  }
}

/// Enum for transaction sorting options
enum TransactionSortEnum {
  newest,
  oldest,
}

/// Enum for date filtering options
enum DateFilterType {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
  all,
}
