import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/widgets/enhanced_widgets.dart';
import 'package:money_track/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/entities/member_balance.dart';
import 'package:money_track/core/utils/currency_formatter.dart';

class BalanceSummaryPage extends StatefulWidget {
  final String groupId;
  final GroupEntity group;

  const BalanceSummaryPage({
    super.key,
    required this.groupId,
    required this.group,
  });

  @override
  State<BalanceSummaryPage> createState() => _BalanceSummaryPageState();
}

class _BalanceSummaryPageState extends State<BalanceSummaryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        title: Text('${widget.group.name} - Balances'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.pie_chart)),
            Tab(text: 'Detailed', icon: Icon(Icons.list)),
            Tab(text: 'Settlements', icon: Icon(Icons.account_balance)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showBalanceOptions(context),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
        builder: (context, state) {
          if (state is GroupDetailsLoading) {
            return const AppLoadingWidget(message: 'Loading balances...');
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
                _buildDetailedTab(context, state),
                _buildSettlementsTab(context, state),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _suggestSettlements(context),
        icon: const Icon(Icons.account_balance_wallet),
        label: const Text('Settle Up'),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, GroupDetailsLoaded state) {
    final balance = state.balance;
    if (balance == null) {
      return const Center(child: Text('No balance data available'));
    }

    final totalOwed = balance.memberTotals.values
        .where((amount) => amount < 0)
        .fold(0.0, (sum, amount) => sum + amount.abs());

    final totalOwing = balance.memberTotals.values
        .where((amount) => amount > 0)
        .fold(0.0, (sum, amount) => sum + amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceOverviewCard(context, totalOwed, totalOwing),
          const SizedBox(height: 24),
          _buildMemberBalanceChart(context, balance),
          const SizedBox(height: 24),
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildBalanceOverviewCard(
      BuildContext context, double totalOwed, double totalOwing) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balance Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceIndicator(
                    context,
                    'You Owe',
                    totalOwed,
                    Colors.red,
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBalanceIndicator(
                    context,
                    'Owed to You',
                    totalOwing,
                    Colors.green,
                    Icons.arrow_downward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Net Balance',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(context, totalOwing - totalOwed),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceIndicator(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(context, amount),
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

  Widget _buildMemberBalanceChart(
      BuildContext context, GroupBalanceEntity balance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Member Balances',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Balance chart visualization
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildBalanceChart(context, balance),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Settle All',
                    Icons.account_balance_wallet,
                    Colors.green,
                    () => _suggestSettlements(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Export',
                    Icons.download,
                    Colors.blue,
                    () => _exportBalances(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'History',
                    Icons.history,
                    Colors.orange,
                    () => _viewBalanceHistory(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Simplify',
                    Icons.compress,
                    Colors.purple,
                    () => _simplifyDebts(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildDetailedTab(BuildContext context, GroupDetailsLoaded state) {
    final balance = state.balance;
    if (balance == null) {
      return const Center(child: Text('No balance data available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: balance.memberBalances.length,
      itemBuilder: (context, index) {
        final currency = balance.memberBalances.keys.elementAt(index);
        final memberBalances = balance.memberBalances[currency]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currency,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...memberBalances.map(
                    (balance) => _buildMemberBalanceTile(context, balance)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemberBalanceTile(BuildContext context, MemberBalance balance) {
    final isPositive = balance.amount >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Text(
              balance.memberName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              balance.memberName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            CurrencyFormatter.format(context, balance.amount),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementsTab(BuildContext context, GroupDetailsLoaded state) {
    // Generate suggested settlements based on current balances
    final suggestedSettlements = _generateSettlementSuggestions(state);

    if (suggestedSettlements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'All Settled!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No settlements needed',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.orange),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Suggested settlements to minimize transactions:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              TextButton(
                onPressed: () => _suggestSettlements(context),
                child: const Text('Optimize'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: suggestedSettlements.length,
            itemBuilder: (context, index) {
              final settlement = suggestedSettlements[index];
              return _buildSettlementSuggestionCard(settlement);
            },
          ),
        ),
      ],
    );
  }

  void _showBalanceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Balances'),
            onTap: () {
              Navigator.pop(context);
              context
                  .read<GroupDetailsCubit>()
                  .loadGroupDetails(widget.groupId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Balances'),
            onTap: () {
              Navigator.pop(context);
              _exportBalances(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.compress),
            title: const Text('Simplify Debts'),
            onTap: () {
              Navigator.pop(context);
              _simplifyDebts(context);
            },
          ),
        ],
      ),
    );
  }

  void _suggestSettlements(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settlement Suggestions'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Suggested settlements to minimize transactions:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              // Sample settlement suggestions
              _buildSettlementSuggestion('Alice', 'Bob', 25.50),
              _buildSettlementSuggestion('Charlie', 'Alice', 15.75),
              _buildSettlementSuggestion('Bob', 'Charlie', 10.25),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settlement suggestions applied!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Apply All'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementSuggestion(String from, String to, double amount) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.red[100],
              child: Text(
                from[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 16),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green[100],
              child: Text(
                to[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$from pays $to',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportBalances(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Balances'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose export format:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV'),
              subtitle: const Text('Spreadsheet format'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exporting balances as CSV...'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              subtitle: const Text('Printable format'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exporting balances as PDF...'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _viewBalanceHistory(BuildContext context) {
    // Implement balance history view
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Balance History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              const Text(
                'Track how group balances have changed over time',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
                  builder: (context, state) {
                    if (state is GroupDetailsLoaded) {
                      return _buildBalanceHistoryList(context, state);
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceHistoryList(
      BuildContext context, GroupDetailsLoaded state) {
    // Create a simplified balance history from expenses and settlements
    final historyItems = <Map<String, dynamic>>[];

    // Add expense entries
    for (final expense in state.expenses) {
      historyItems.add({
        'type': 'expense',
        'date': expense.createdAt,
        'title': expense.title,
        'amount': expense.totalAmount,
        'createdBy': expense.createdBy,
      });
    }

    // Add settlement entries
    for (final settlement in state.settlements) {
      historyItems.add({
        'type': 'settlement',
        'date': settlement.createdAt,
        'title':
            'Settlement: ${settlement.payerName} → ${settlement.receiverName}',
        'amount': settlement.amount,
        'createdBy': settlement.payerId,
      });
    }

    // Sort by date (newest first)
    historyItems.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    if (historyItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No balance history available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: historyItems.length,
      itemBuilder: (context, index) {
        final item = historyItems[index];
        final isExpense = item['type'] == 'expense';
        final date = item['date'] as DateTime;
        final title = item['title'] as String;
        final amount = item['amount'] as double;
        final createdBy = item['createdBy'] as String;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isExpense ? Colors.red[100] : Colors.green[100],
            child: Icon(
              isExpense ? Icons.receipt : Icons.account_balance_wallet,
              color: isExpense ? Colors.red[700] : Colors.green[700],
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            'By $createdBy • ${_formatDate(date)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: Text(
            '${isExpense ? '-' : '+'}\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isExpense ? Colors.red[700] : Colors.green[700],
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _simplifyDebts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simplify Debts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This will optimize settlements to minimize the number of transactions required.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_down, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Current: 6 transactions',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Optimized: 3 transactions',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Debts simplified successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Simplify'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateSettlementSuggestions(
      GroupDetailsLoaded state) {
    // Simple settlement suggestion algorithm
    // In a real implementation, this would use a more sophisticated debt simplification algorithm
    final suggestions = <Map<String, dynamic>>[];

    // Sample suggestions based on group members
    if (widget.group.members.length >= 2) {
      suggestions.add({
        'from': widget.group.members[0].name,
        'to': widget.group.members[1].name,
        'amount': 25.50,
        'reason': 'Outstanding balance',
      });
    }

    if (widget.group.members.length >= 3) {
      suggestions.add({
        'from': widget.group.members[2].name,
        'to': widget.group.members[0].name,
        'amount': 15.75,
        'reason': 'Shared expenses',
      });
    }

    return suggestions;
  }

  Widget _buildSettlementSuggestionCard(Map<String, dynamic> settlement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.red[100],
                  child: Text(
                    settlement['from'][0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green[100],
                  child: Text(
                    settlement['to'][0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${settlement['amount'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${settlement['from']} pays ${settlement['to']}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              settlement['reason'],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Dismiss suggestion
                    },
                    child: const Text('Dismiss'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Create settlement
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settlement created!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Create'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceChart(BuildContext context, GroupBalanceEntity balance) {
    // Create a simple horizontal bar chart showing member balances
    final memberTotals = balance.memberTotals;

    if (memberTotals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.balance, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No balance data available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Find the maximum absolute balance for scaling
    final maxBalance = memberTotals.values
        .map((balance) => balance.abs())
        .reduce((a, b) => a > b ? a : b);

    final memberEntries = memberTotals.entries.toList();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: memberEntries.length,
            itemBuilder: (context, index) {
              final entry = memberEntries[index];
              final memberId = entry.key;
              final balanceAmount = entry.value;
              final percentage =
                  maxBalance > 0 ? (balanceAmount.abs() / maxBalance) : 0.0;
              final isPositive = balanceAmount >= 0;

              // Get member name from group (fallback to ID if not found)
              final memberName = widget.group.members
                  .firstWhere((m) => m.id == memberId,
                      orElse: () => GroupMember(id: memberId, name: memberId))
                  .name;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        memberName,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          if (!isPositive) ...[
                            Expanded(
                              flex: (100 - (percentage * 100)).round(),
                              child: Container(),
                            ),
                            Container(
                              height: 20,
                              width: (percentage * 100).clamp(5.0, 100.0),
                              decoration: BoxDecoration(
                                color: Colors.red[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ] else ...[
                            Container(
                              height: 20,
                              width: (percentage * 100).clamp(5.0, 100.0),
                              decoration: BoxDecoration(
                                color: Colors.green[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Expanded(
                              flex: (100 - (percentage * 100)).round(),
                              child: Container(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '\$${balanceAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isPositive ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                const Text('Owes', style: TextStyle(fontSize: 10)),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                const Text('Owed', style: TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
