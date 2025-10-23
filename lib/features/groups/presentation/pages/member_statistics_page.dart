import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/widgets/enhanced_widgets.dart';
import 'package:money_track/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/core/utils/currency_formatter.dart';

class MemberStatisticsPage extends StatefulWidget {
  final String groupId;
  final GroupEntity group;

  const MemberStatisticsPage({
    super.key,
    required this.groupId,
    required this.group,
  });

  @override
  State<MemberStatisticsPage> createState() => _MemberStatisticsPageState();
}

class _MemberStatisticsPageState extends State<MemberStatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'All Time';
  final List<String> _periods = [
    'This Week',
    'This Month',
    'Last Month',
    'This Year',
    'All Time'
  ];

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
        title: Text('${widget.group.name} - Statistics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.analytics)),
            Tab(text: 'Members', icon: Icon(Icons.people)),
            Tab(text: 'Trends', icon: Icon(Icons.trending_up)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (period) => setState(() => _selectedPeriod = period),
            itemBuilder: (context) => _periods
                .map((period) => PopupMenuItem(
                      value: period,
                      child: Text(period),
                    ))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
        builder: (context, state) {
          if (state is GroupDetailsLoading) {
            return const AppLoadingWidget(message: 'Loading statistics...');
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
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, state),
                _buildMembersTab(context, state),
                _buildTrendsTab(context, state),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, GroupDetailsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroupOverviewCard(context, state),
          const SizedBox(height: 24),
          _buildExpenseBreakdownCard(context),
          const SizedBox(height: 24),
          _buildCategoryBreakdownCard(context, state),
        ],
      ),
    );
  }

  Widget _buildGroupOverviewCard(
      BuildContext context, GroupDetailsLoaded state) {
    final totalExpenses = state.expenses.length;
    final totalAmount =
        state.expenses.fold(0.0, (sum, expense) => sum + expense.totalAmount);
    final avgExpense = totalExpenses > 0 ? totalAmount / totalExpenses : 0.0;
    final activeMembers = widget.group.members.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Expenses',
                    totalExpenses.toString(),
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Amount',
                    CurrencyFormatter.format(context, totalAmount),
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Average Expense',
                    CurrencyFormatter.format(context, avgExpense),
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Active Members',
                    activeMembers.toString(),
                    Icons.people,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseBreakdownCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Expense breakdown chart (simplified visualization)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Monthly Expense Trend',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(6, (index) {
                          final height = (index + 1) * 20.0 + 40;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 30,
                                height: height,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'M${index + 1}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownCard(
      BuildContext context, GroupDetailsLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Show actual category breakdown from expenses
            ..._buildCategoryBreakdown(context, state),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryBreakdown(
      BuildContext context, GroupDetailsLoaded state) {
    if (state.expenses.isEmpty) {
      return [
        const Center(
          child: Text('No expenses to analyze'),
        ),
      ];
    }

    // Calculate category totals
    final Map<String, double> categoryTotals = {};
    final Map<String, Color> categoryColors = {
      'Food & Dining': Colors.red,
      'Transportation': Colors.blue,
      'Entertainment': Colors.green,
      'Shopping': Colors.orange,
      'Salary': Colors.teal,
      'Subscriptions': Colors.purple,
      'Other': Colors.grey,
    };

    double totalAmount = 0;
    for (final expense in state.expenses) {
      final categoryName = expense.category.categoryName;
      categoryTotals[categoryName] =
          (categoryTotals[categoryName] ?? 0) + expense.totalAmount;
      totalAmount += expense.totalAmount;
    }

    // Convert to percentages and create widgets
    final List<Widget> categoryItems = [];
    categoryTotals.entries.forEach((entry) {
      final percentage =
          totalAmount > 0 ? (entry.value / totalAmount) * 100 : 0.0;
      final color = categoryColors[entry.key] ?? Colors.grey;
      categoryItems
          .add(_buildCategoryItem(context, entry.key, percentage, color));
    });

    return categoryItems;
  }

  Widget _buildCategoryItem(
      BuildContext context, String category, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab(BuildContext context, GroupDetailsLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.group.members.length,
      itemBuilder: (context, index) {
        final member = widget.group.members[index];
        return _buildMemberStatCard(context, member.id, state);
      },
    );
  }

  Widget _buildMemberStatCard(
      BuildContext context, String member, GroupDetailsLoaded state) {
    // Calculate actual member statistics
    final memberExpenses =
        state.expenses.where((e) => e.createdBy == member).length;
    final totalPaid = state.expenses
        .where((e) => e.createdBy == member)
        .fold(0.0, (sum, expense) => sum + expense.totalAmount);
    final avgExpense = memberExpenses > 0 ? totalPaid / memberExpenses : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(
                    member.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Active member',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMemberStat(context, 'Expenses',
                      memberExpenses.toString(), Icons.receipt),
                ),
                Expanded(
                  child: _buildMemberStat(
                      context,
                      'Total Paid',
                      CurrencyFormatter.format(context, totalPaid),
                      Icons.payment),
                ),
                Expanded(
                  child: _buildMemberStat(
                      context,
                      'Average',
                      CurrencyFormatter.format(context, avgExpense),
                      Icons.trending_up),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberStat(
      BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendsTab(BuildContext context, GroupDetailsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSpendingTrendCard(context),
          const SizedBox(height: 24),
          _buildMonthlyComparisonCard(context),
          const SizedBox(height: 24),
          _buildTopSpendersCard(context, state),
        ],
      ),
    );
  }

  Widget _buildSpendingTrendCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Spending trend chart (simplified line chart visualization)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Weekly Spending Trend',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: CustomPaint(
                        size: const Size(double.infinity, double.infinity),
                        painter: SimpleLineChartPainter(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('W1', style: TextStyle(fontSize: 12)),
                        Text('W2', style: TextStyle(fontSize: 12)),
                        Text('W3', style: TextStyle(fontSize: 12)),
                        Text('W4', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyComparisonCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Comparison',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildComparisonItem(
                      context, 'This Month', '\$1,250', '+15%', Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildComparisonItem(
                      context, 'Last Month', '\$1,087', '-5%', Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem(BuildContext context, String period,
      String amount, String change, Color changeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: TextStyle(
              color: changeColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSpendersCard(BuildContext context, GroupDetailsLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Spenders',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...widget.group.members.take(3).map(
                (member) => _buildTopSpenderItem(context, member.id, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSpenderItem(
      BuildContext context, String member, GroupDetailsLoaded state) {
    // Calculate actual spending
    final totalSpent = state.expenses
        .where((e) => e.createdBy == member)
        .fold(0.0, (sum, expense) => sum + expense.totalAmount);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Text(
              member.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            CurrencyFormatter.format(context, totalSpent),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Simple line chart painter for spending trend visualization
class SimpleLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Sample data points for demonstration
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.33, size.height * 0.4),
      Offset(size.width * 0.66, size.height * 0.6),
      Offset(size.width, size.height * 0.2),
    ];

    // Draw the line
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
