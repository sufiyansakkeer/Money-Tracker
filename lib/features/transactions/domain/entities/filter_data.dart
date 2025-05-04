import 'package:money_track/domain/entities/category_entity.dart';

/// Entity class for filter data
class FilterData {
  TransactionType? transactionType;
  TransactionSortEnum? transactionSortEnum;
  
  void reset() {
    transactionType = null;
    transactionSortEnum = null;
  }
}

/// Enum for transaction sorting options
enum TransactionSortEnum {
  newest,
  oldest,
}
