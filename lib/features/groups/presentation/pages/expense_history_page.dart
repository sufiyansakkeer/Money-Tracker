import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/widgets/enhanced_widgets.dart';
import 'package:money_track/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/features/groups/presentation/widgets/shared_expense_tile.dart';
import 'package:money_track/features/groups/presentation/widgets/search_filter_widget.dart';
import 'package:money_track/features/groups/presentation/pages/expense_details_page.dart';
import 'package:money_track/features/groups/presentation/pages/add_shared_expense_page.dart';
import 'package:money_track/core/utils/currency_formatter.dart';
import 'package:money_track/features/groups/domain/services/search_filter_service.dart';
import 'package:money_track/features/groups/presentation/widgets/export_dialog.dart';
import 'package:money_track/features/groups/presentation/pages/member_statistics_page.dart';

class ExpenseHistoryPage extends StatefulWidget {
  final String groupId;
  final GroupEntity group;

  const ExpenseHistoryPage({
    super.key,
    required this.groupId,
    required this.group,
  });

  @override
  State<ExpenseHistoryPage> createState() => _ExpenseHistoryPageState();
}

class _ExpenseHistoryPageState extends State<ExpenseHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SharedExpenseEntity> _filteredExpenses = [];
  bool _showFilters = false;
  ExpenseFilter _currentFilter = const ExpenseFilter();
  final SearchFilterService _searchFilterService = SearchFilterService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<GroupDetailsCubit>().loadGroupDetails(widget.groupId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.group.name} - Expenses'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.list)),
            Tab(text: 'Recent', icon: Icon(Icons.access_time)),
            Tab(text: 'Summary', icon: Icon(Icons.analytics)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _showFilters = !_showFilters),
            icon:
                Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
          ),
          IconButton(
            onPressed: () => _showExpenseOptions(context),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters)
            SearchFilterWidget(
              group: widget.group,
              onFilterChanged: (filters) => _applyFilters(filters),
            ),
          Expanded(
            child: BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
              builder: (context, state) {
                if (state is GroupDetailsLoading) {
                  return const AppLoadingWidget(message: 'Loading expenses...');
                }

                if (state is GroupDetailsError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () => context
                        .read<GroupDetailsCubit>()
                        .loadGroupDetails(widget.groupId),
                  );
                }

                if (state is GroupDetailsLoaded) {
                  _filteredExpenses = _filterExpenses(state.expenses);

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllExpensesTab(context, _filteredExpenses),
                      _buildRecentExpensesTab(context, _filteredExpenses),
                      _buildSummaryTab(context, state),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNewExpense(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  List<SharedExpenseEntity> _filterExpenses(
      List<SharedExpenseEntity> expenses) {
    // Apply the current filter using the SearchFilterService
    return _searchFilterService.filterExpenses(expenses, _currentFilter);
  }

  void _applyFilters(ExpenseFilter filters) {
    setState(() {
      _currentFilter = filters;
      // The filtering will be applied in _filterExpenses when the UI rebuilds
    });
  }

  Widget _buildAllExpensesTab(
      BuildContext context, List<SharedExpenseEntity> expenses) {
    if (expenses.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        _buildExpenseSummaryHeader(context, expenses),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return SharedExpenseTile(
                expense: expense,
                onTap: () => _viewExpenseDetails(context, expense),
                onEdit: () => _editExpense(context, expense),
                onDelete: () => _deleteExpense(context, expense),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseSummaryHeader(
      BuildContext context, List<SharedExpenseEntity> expenses) {
    final totalAmount =
        expenses.fold(0.0, (sum, expense) => sum + expense.totalAmount);
    final avgAmount = expenses.isNotEmpty ? totalAmount / expenses.length : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Expenses',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                Text(
                  expenses.length.toString(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Amount',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                Text(
                  CurrencyFormatter.format(context, totalAmount),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                Text(
                  CurrencyFormatter.format(context, avgAmount),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExpensesTab(
      BuildContext context, List<SharedExpenseEntity> expenses) {
    final recentExpenses = expenses.take(10).toList(); // Show last 10 expenses

    if (recentExpenses.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recentExpenses.length,
      itemBuilder: (context, index) {
        final expense = recentExpenses[index];
        return SharedExpenseTile(
          expense: expense,
          onTap: () => _viewExpenseDetails(context, expense),
          onEdit: () => _editExpense(context, expense),
          onDelete: () => _deleteExpense(context, expense),
        );
      },
    );
  }

  Widget _buildSummaryTab(BuildContext context, GroupDetailsLoaded state) {
    final expenses = state.expenses;
    final totalAmount =
        expenses.fold(0.0, (sum, expense) => sum + expense.totalAmount);
    final avgAmount = expenses.isNotEmpty ? totalAmount / expenses.length : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context, 'Overview', [
            _buildSummaryItem('Total Expenses', expenses.length.toString(),
                Icons.receipt_long),
            _buildSummaryItem(
                'Total Amount',
                CurrencyFormatter.format(context, totalAmount),
                Icons.attach_money),
            _buildSummaryItem(
                'Average Expense',
                CurrencyFormatter.format(context, avgAmount),
                Icons.trending_up),
          ]),
          const SizedBox(height: 16),
          _buildSummaryCard(context, 'By Category', [
            _buildSummaryItem('Food & Dining', '45%', Icons.restaurant),
            _buildSummaryItem('Transportation', '25%', Icons.directions_car),
            _buildSummaryItem('Entertainment', '20%', Icons.movie),
            _buildSummaryItem('Other', '10%', Icons.more_horiz),
          ]),
          const SizedBox(height: 16),
          _buildSummaryCard(context, 'Top Spenders', [
            ...widget.group.members.take(3).map((member) => _buildSummaryItem(
                member.name,
                CurrencyFormatter.format(
                    context, totalAmount / widget.group.members.length),
                Icons.person)),
          ]),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, String title, List<Widget> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start adding expenses to see them here',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showExpenseOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh'),
            onTap: () {
              Navigator.pop(context);
              context
                  .read<GroupDetailsCubit>()
                  .loadGroupDetails(widget.groupId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Expenses'),
            onTap: () {
              Navigator.pop(context);
              _exportExpenses(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('View Statistics'),
            onTap: () {
              Navigator.pop(context);
              _viewStatistics(context);
            },
          ),
        ],
      ),
    );
  }

  void _addNewExpense(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddSharedExpensePage(
          group: widget.group,
        ),
      ),
    );
  }

  void _viewExpenseDetails(BuildContext context, SharedExpenseEntity expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExpenseDetailsPage(
          expenseId: expense.id,
          groupId: widget.groupId,
          group: widget.group,
        ),
      ),
    );
  }

  void _editExpense(BuildContext context, SharedExpenseEntity expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddSharedExpensePage(
          group: widget.group,
          expenseToEdit: expense,
        ),
      ),
    );
  }

  void _deleteExpense(BuildContext context, SharedExpenseEntity expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content:
            Text('Are you sure you want to delete "${expense.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDeleteExpense(context, expense);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteExpense(
      BuildContext context, SharedExpenseEntity expense) async {
    try {
      // Use the GroupDetailsCubit to delete the expense
      final cubit = context.read<GroupDetailsCubit>();
      await cubit.deleteSharedExpense(expense.id);

      // Check if deletion was successful by checking the cubit state
      final state = cubit.state;
      if (state is GroupDetailsError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete expense: $e')),
        );
      }
    }
  }

  void _exportExpenses(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExportDialog(
        group: widget.group,
        onExportComplete: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _viewStatistics(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemberStatisticsPage(
          groupId: widget.groupId,
          group: widget.group,
        ),
      ),
    );
  }
}
