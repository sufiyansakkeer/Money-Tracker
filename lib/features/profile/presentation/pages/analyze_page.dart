import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/features/profile/domain/entities/chart_data.dart';
import 'package:money_track/features/profile/domain/entities/graph_filter_data.dart';
import 'package:money_track/features/profile/presentation/widgets/chart_widgets.dart';
import 'package:money_track/features/profile/presentation/widgets/custom_app_bar.dart';
import 'package:money_track/features/profile/presentation/widgets/filter_icon_widget.dart';
import 'package:money_track/features/profile/presentation/widgets/graph_filter_widget.dart';
import 'package:money_track/features/transactions/presentation/bloc/transaction_bloc.dart';

class AnalyzePage extends StatefulWidget {
  const AnalyzePage({super.key});

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  GraphFilterData _filterData = GraphFilterData();
  List<TransactionEntity> _transactions = [];

  @override
  void initState() {
    super.initState();
    // Load transactions when the page is initialized
    context.read<TransactionBloc>().add(GetAllTransactionsEvent());
  }

  // Filter transactions based on time period
  List<TransactionEntity> _getFilteredTransactions() {
    if (_transactions.isEmpty) return [];

    final now = DateTime.now();
    DateTime? startDate;

    // Filter by time period
    switch (_filterData.timePeriod) {
      case GraphTimePeriod.day:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case GraphTimePeriod.week:
        startDate = DateTime(now.year, now.month, now.day - 7);
        break;
      case GraphTimePeriod.month:
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case GraphTimePeriod.year:
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case GraphTimePeriod.all:
        startDate = null;
        break;
    }

    if (startDate == null) {
      return _transactions;
    }

    return _transactions
        .where((transaction) => transaction.date.isAfter(startDate!))
        .toList();
  }

  // Get chart title based on filter settings
  String _getChartTitle() {
    String typeText = _filterData.transactionType == null
        ? "All Transactions"
        : _filterData.transactionType == TransactionType.income
            ? "Income"
            : "Expense";

    String periodText = "";
    switch (_filterData.timePeriod) {
      case GraphTimePeriod.day:
        periodText = "Today";
        break;
      case GraphTimePeriod.week:
        periodText = "Last 7 Days";
        break;
      case GraphTimePeriod.month:
        periodText = "Last 30 Days";
        break;
      case GraphTimePeriod.year:
        periodText = "Last Year";
        break;
      case GraphTimePeriod.all:
        periodText = "All Time";
        break;
    }

    return "$typeText - $periodText";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: customAppBar(context, title: "Analyze"),
        body: BlocConsumer<TransactionBloc, TransactionState>(
          listener: (context, state) {
            if (state is TransactionLoaded) {
              setState(() {
                _transactions = state.transactionList;
              });
            }
          },
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TransactionLoaded) {
              final filteredTransactions = _getFilteredTransactions();

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Filter row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getChartTitle(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        GraphFilterIcon(
                          onTap: () {
                            showModalBottomSheet(
                              showDragHandle: true,
                              isScrollControlled: true,
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (context) => Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: GraphFilterWidget(
                                  filterData: _filterData,
                                  onFilterChanged: (newFilter) {
                                    setState(() {
                                      _filterData = newFilter;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    20.height(),

                    // Chart
                    Expanded(
                      child: filteredTransactions.isEmpty
                          ? const Center(
                              child: Text(
                                "No transactions found for the selected filters",
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : _filterData.chartType == ChartType.pie
                              ? PieChartWidget(
                                  chartData: ChartDataTransformer
                                      .transformToPieChartData(
                                    filteredTransactions,
                                    _filterData.transactionType,
                                  ),
                                  title: _getChartTitle(),
                                )
                              : LineChartWidget(
                                  chartData: ChartDataTransformer
                                      .transformToLineChartData(
                                    filteredTransactions,
                                    _filterData.transactionType,
                                  ),
                                  title: _getChartTitle(),
                                  transactionType: _filterData.transactionType,
                                ),
                    ),

                    // Summary
                    if (filteredTransactions.isNotEmpty) ...[
                      20.height(),
                      _buildSummary(filteredTransactions),
                    ],
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text("Something went wrong. Please try again"),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSummary(List<TransactionEntity> transactions) {
    double totalIncome = 0;
    double totalExpense = 0;

    for (var transaction in transactions) {
      if (transaction.transactionType == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    final balance = totalIncome - totalExpense;
    final formatter = NumberFormat.currency(symbol: '\$');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Text(
            "Summary",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          10.height(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Income:"),
              Text(
                formatter.format(totalIncome),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          5.height(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Expense:"),
              Text(
                formatter.format(totalExpense),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          5.height(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Balance:"),
              Text(
                formatter.format(balance),
                style: TextStyle(
                  color: balance >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
