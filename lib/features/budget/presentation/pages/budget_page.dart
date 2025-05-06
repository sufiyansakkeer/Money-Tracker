import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/features/budget/domain/entities/budget_entity.dart';
import 'package:money_track/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:money_track/features/budget/presentation/pages/add_edit_budget_page.dart';
import 'package:money_track/features/budget/presentation/widgets/budget_list_item.dart';
import 'package:money_track/features/budget/presentation/widgets/empty_budget_list.dart';
import 'package:svg_flutter/svg.dart';

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
    // Reset system UI when leaving this page
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar color to match the custom AppBar
    final themeColor = ColorConstants.getThemeColor(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: themeColor,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Column(
          children: [
            Container(
              color: themeColor,
              child: Column(
                children: [
                  // Custom AppBar
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context)
                            .padding
                            .top), // Account for status bar
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: SvgPicture.asset(
                            "assets/svg/common/arrow_left_white.svg",
                            height: 20,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Budget Planning',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: const [
                      Tab(text: 'Active'),
                      Tab(text: 'All'),
                    ],
                  ),
                ],
              ),
            ),
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
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
