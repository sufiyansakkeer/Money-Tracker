import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/widgets/enhanced_widgets.dart';
import 'package:money_track/features/groups/presentation/bloc/group_bloc.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/presentation/pages/group_details_page.dart';
import 'package:money_track/features/groups/presentation/pages/create_edit_group_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<GroupBloc>().add(LoadGroups());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          _buildDashboardContent(context),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewGroup(context),
        icon: const Icon(Icons.add),
        label: const Text('New Group'),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(
                          Icons.dashboard,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Manage your group expenses',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildQuickStats(context),
          const SizedBox(height: 24),
          _buildRecentActivity(context),
          const SizedBox(height: 24),
          _buildGroupsList(context),
          const SizedBox(height: 100), // Space for FAB
        ]),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        if (state is GroupsLoaded) {
          final totalGroups = state.groups.length;
          final activeGroups =
              state.groups.where((g) => g.members.isNotEmpty).length;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Groups',
                          totalGroups.toString(),
                          Icons.group,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Active Groups',
                          activeGroups.toString(),
                          Icons.group_work,
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
                          'Total Members',
                          state.groups
                              .fold<int>(0, (sum, g) => sum + g.members.length)
                              .toString(),
                          Icons.people,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'This Month',
                          _calculateMonthlyExpenses(state),
                          Icons.calendar_month,
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
        return const SizedBox.shrink();
      },
    );
  }

  String _calculateMonthlyExpenses(GroupsLoaded state) {
    // final now = DateTime.now();
    // final currentMonth = DateTime(now.year, now.month);
    // final nextMonth = DateTime(now.year, now.month + 1);

    double monthlyTotal = 0;

    // Calculate total from all groups' expenses for current month
    for (final group in state.groups) {
      // This is a simplified calculation - in a real app you'd need to fetch
      // actual expense data for each group
      monthlyTotal += group.members.length * 50.0; // Placeholder calculation
    }

    return '\$${monthlyTotal.toStringAsFixed(0)}';
  }

  String _getGroupBalanceSummary(GroupEntity group) {
    // This is a simplified calculation - in a real app you'd calculate actual balances
    final memberCount = group.members.length;
    if (memberCount == 0) return 'No members';

    // Placeholder calculation for demonstration
    final avgBalance = (memberCount * 25.0) / memberCount;
    return 'Avg balance: \$${avgBalance.toStringAsFixed(0)}';
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/activity');
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Recent activity items
                if (state is GroupsLoaded && state.groups.isNotEmpty) ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3, // Show last 3 activities
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child:
                                const Icon(Icons.receipt, color: Colors.white),
                          ),
                          title: Text('Recent expense #${index + 1}'),
                          subtitle: Text(
                              'Group: ${state.groups[index % state.groups.length].name}'),
                          trailing: const Text('\$25.00'),
                          onTap: () {
                            // Navigate to expense details
                          },
                        ),
                      );
                    },
                  ),
                ] else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No recent activity',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
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
      },
    );
  }

  Widget _buildGroupsList(BuildContext context) {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        if (state is GroupLoading) {
          return const AppLoadingWidget(message: 'Loading groups...');
        }

        if (state is GroupError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: () => context.read<GroupBloc>().add(LoadGroups()),
          );
        }

        if (state is GroupsLoaded) {
          if (state.groups.isEmpty) {
            return _buildEmptyGroupsState(context);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Groups',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/groups');
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...state.groups
                  .take(3)
                  .map((group) => _buildGroupCard(context, group)),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyGroupsState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.group_add,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Groups Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first group to start splitting expenses with friends',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _createNewGroup(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, GroupEntity group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(
            Icons.group,
            color: Colors.white,
          ),
        ),
        title: Text(
          group.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${group.members.length} members'),
            const SizedBox(height: 4),
            // Show balance summary
            Text(
              _getGroupBalanceSummary(group),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _navigateToGroupDetails(context, group),
      ),
    );
  }

  void _createNewGroup(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateEditGroupPage(),
      ),
    );
  }

  void _navigateToGroupDetails(BuildContext context, GroupEntity group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupDetailsPage(groupId: group.id),
      ),
    );
  }
}
