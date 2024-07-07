import 'package:money_track/models/categories_model/category_model.dart';

class FilterData {
  TransactionType? transactionType;
  TransactionSortEnum? transactionSortEnum;
  void reset() {
    transactionType = null;
    transactionSortEnum = null;
  }
}

enum TransactionSortEnum {
  newest,
  oldest,
  highest,
  lowest,
}
