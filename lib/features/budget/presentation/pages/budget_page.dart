import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/features/budget/domain/entities/budget_entity.dart';
import 'package:money_track/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:money_track/features/budget/presentation/pages/add_edit_budget_page.dart';
import 'package:money_track/features/budget/presentation/widgets/budget_list_item.dart';
import 'package:money_track/features/budget/presentation/widgets/empty_budget_list.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load budgets when the page is opened
    context.read<BudgetBloc>().add(const LoadBudgets());
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
        title: const Text('Budget Planning'),
        backgroundColor: ColorConstants.getThemeColor(context),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BudgetsLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                // Active budgets tab
                _buildBudgetList(
                  context,
                  state.budgets.where((b) => b.isActive).toList(),
                  state.transactions,
                ),

                // All budgets tab
                _buildBudgetList(
                  context,
                  state.budgets,
                  state.transactions,
                ),
              ],
            );
          }

          if (state is BudgetError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditBudgetPage(),
            ),
          );
        },
        backgroundColor: ColorConstants.getThemeColor(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetList(
    BuildContext context,
    List<BudgetEntity> budgets,
    List<TransactionEntity> transactions,
  ) {
    if (budgets.isEmpty) {
      return EmptyBudgetList(
        onAddBudget: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditBudgetPage(),
            ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: budgets.length,
      itemBuilder: (context, index) {
        final budget = budgets[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BudgetListItem(
            budget: budget,
            transactions: transactions,
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditBudgetPage(budget: budget),
                ),
              );
            },
            onDelete: () {
              _showDeleteConfirmationDialog(context, budget);
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, BudgetEntity budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text(
            'Are you sure you want to delete the "${budget.name}" budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BudgetBloc>().add(DeleteBudget(budget.id));
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
