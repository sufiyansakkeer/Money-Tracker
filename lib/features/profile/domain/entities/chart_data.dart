import 'package:flutter/material.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';

/// Data point for pie chart
class PieChartData {
  final String category;
  final double amount;
  final Color color;
  final CategoryType categoryType;
  final TransactionType transactionType;

  PieChartData({
    required this.category,
    required this.amount,
    required this.color,
    required this.categoryType,
    required this.transactionType,
  });
}

/// Data point for line chart
class LineChartData {
  final DateTime date;
  final double amount;
  final TransactionType transactionType;

  LineChartData({
    required this.date,
    required this.amount,
    required this.transactionType,
  });
}

/// Helper class to transform transaction data into chart data
class ChartDataTransformer {
  /// Transform transactions into pie chart data
  static List<PieChartData> transformToPieChartData(
    List<TransactionEntity> transactions,
    TransactionType? filterType,
  ) {
    // Filter transactions by type if specified
    final filteredTransactions = filterType != null
        ? transactions
            .where((transaction) => transaction.transactionType == filterType)
            .toList()
        : transactions;

    // Group transactions by category
    final Map<String, double> categoryAmounts = {};
    final Map<String, CategoryType> categoryTypes = {};
    final Map<String, TransactionType> transactionTypes = {};

    for (var transaction in filteredTransactions) {
      final categoryName = transaction.category.categoryName;
      categoryAmounts[categoryName] = (categoryAmounts[categoryName] ?? 0) + transaction.amount;
      categoryTypes[categoryName] = transaction.categoryType;
      transactionTypes[categoryName] = transaction.transactionType;
    }

    // Create color map (in a real app, you might want to use consistent colors for categories)
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];

    // Transform to pie chart data
    final List<PieChartData> pieChartData = [];
    int colorIndex = 0;

    categoryAmounts.forEach((category, amount) {
      pieChartData.add(
        PieChartData(
          category: category,
          amount: amount,
          color: colors[colorIndex % colors.length],
          categoryType: categoryTypes[category]!,
          transactionType: transactionTypes[category]!,
        ),
      );
      colorIndex++;
    });

    return pieChartData;
  }

  /// Transform transactions into line chart data grouped by day
  static List<LineChartData> transformToLineChartData(
    List<TransactionEntity> transactions,
    TransactionType? filterType,
  ) {
    // Filter transactions by type if specified
    final filteredTransactions = filterType != null
        ? transactions
            .where((transaction) => transaction.transactionType == filterType)
            .toList()
        : transactions;

    // Sort transactions by date
    filteredTransactions.sort((a, b) => a.date.compareTo(b.date));

    // Group transactions by day
    final Map<DateTime, double> dailyAmounts = {};

    for (var transaction in filteredTransactions) {
      // Remove time component to group by day
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      
      dailyAmounts[date] = (dailyAmounts[date] ?? 0) + transaction.amount;
    }

    // Transform to line chart data
    final List<LineChartData> lineChartData = [];

    dailyAmounts.forEach((date, amount) {
      lineChartData.add(
        LineChartData(
          date: date,
          amount: amount,
          transactionType: filterType ?? TransactionType.expense, // Default to expense if no filter
        ),
      );
    });

    // Sort by date
    lineChartData.sort((a, b) => a.date.compareTo(b.date));

    return lineChartData;
  }
}
