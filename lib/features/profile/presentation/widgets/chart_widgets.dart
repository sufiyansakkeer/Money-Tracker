import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/currency_formatter.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/features/profile/domain/entities/chart_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PieChartWidget extends StatelessWidget {
  final List<PieChartData> chartData;
  final String title;

  const PieChartWidget({
    super.key,
    required this.chartData,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const Center(
        child: Text(
          "No data available for the selected filters",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return SfCircularChart(
      title: ChartTitle(
        text: title,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        position: LegendPosition.bottom,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        DoughnutSeries<PieChartData, String>(
          dataSource: chartData,
          xValueMapper: (PieChartData data, _) => data.category,
          yValueMapper: (PieChartData data, _) => data.amount,
          pointColorMapper: (PieChartData data, _) => data.color,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            connectorLineSettings: ConnectorLineSettings(
              type: ConnectorType.curve,
              length: '15%',
            ),
          ),
          dataLabelMapper: (PieChartData data, _) =>
              '${data.category}: ${CurrencyFormatter.format(context, data.amount)}',
          enableTooltip: true,
        ),
      ],
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final List<LineChartData> chartData;
  final String title;
  final TransactionType? transactionType;

  const LineChartWidget({
    super.key,
    required this.chartData,
    required this.title,
    this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const Center(
        child: Text(
          "No data available for the selected filters",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Determine line color based on transaction type
    Color lineColor = transactionType == TransactionType.income
        ? Colors.green
        : transactionType == TransactionType.expense
            ? Colors.red
            : ColorConstants.themeColor;

    return SfCartesianChart(
      title: ChartTitle(
        text: title,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat('MMM dd'),
        intervalType: DateTimeIntervalType.auto,
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.currency(
            symbol: CurrencyFormatter.getCurrencySymbol(context)),
        majorGridLines: const MajorGridLines(width: 0.5),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<LineChartData, DateTime>>[
        LineSeries<LineChartData, DateTime>(
          dataSource: chartData,
          xValueMapper: (LineChartData data, _) => data.date,
          yValueMapper: (LineChartData data, _) => data.amount,
          name: transactionType == null
              ? 'All Transactions'
              : transactionType == TransactionType.income
                  ? 'Income'
                  : 'Expense',
          color: lineColor,
          markerSettings: const MarkerSettings(isVisible: true),
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          enableTooltip: true,
        ),
      ],
    );
  }
}
