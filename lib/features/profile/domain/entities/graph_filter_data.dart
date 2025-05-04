import 'package:money_track/domain/entities/category_entity.dart';

/// Time period options for graph filtering
enum GraphTimePeriod {
  day,
  week,
  month,
  year,
  all,
}

/// Chart type options
enum ChartType {
  pie,
  line,
}

/// Entity class for graph filter data
class GraphFilterData {
  TransactionType? transactionType;
  GraphTimePeriod timePeriod;
  ChartType chartType;
  DateTime? startDate;
  DateTime? endDate;
  String? categoryId;
  
  GraphFilterData({
    this.transactionType,
    this.timePeriod = GraphTimePeriod.month,
    this.chartType = ChartType.pie,
    this.startDate,
    this.endDate,
    this.categoryId,
  });
  
  void reset() {
    transactionType = null;
    timePeriod = GraphTimePeriod.month;
    chartType = ChartType.pie;
    startDate = null;
    endDate = null;
    categoryId = null;
  }
}
