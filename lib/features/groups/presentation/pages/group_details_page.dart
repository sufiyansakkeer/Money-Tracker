import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';

import 'package:money_track/core/widgets/enhanced_widgets.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/presentation/bloc/group_bloc.dart';
import 'package:money_track/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:money_track/features/groups/presentation/widgets/group_activity_feed.dart';
import 'package:money_track/features/groups/presentation/widgets/group_balance_overview.dart';
import 'package:money_track/features/groups/presentation/widgets/group_member_list.dart';
import 'package:money_track/features/groups/presentation/widgets/group_settings_sheet.dart';
import 'package:money_track/features/groups/presentation/pages/add_shared_expense_page.dart';
import 'package:money_track/features/groups/presentation/pages/create_edit_group_page.dart';
import 'package:money_track/features/groups/presentation/pages/add_settlement_page.dart';
import 'package:money_track/features/groups/presentation/pages/settlement_history_page.dart';
import 'package:money_track/features/groups/presentation/pages/expense_details_page.dart';
import 'package:money_track/features/groups/presentation/pages/expense_history_page.dart';
import 'package:money_track/features/groups/presentation/widgets/settlement_list.dart';
import 'package:money_track/features/groups/domain/usecases/settlement/update_settlement_usecase.dart';
import 'package:money_track/app/di/injection_container.dart';
import 'package:money_track/core/extensions/result_extensions.dart';
import 'package:money_track/features/groups/presentation/widgets/shared_expense_list.dart';
import 'package:money_track/features/groups/presentation/widgets/export_dialog.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:money_track/core/use_cases/use_case.dart';

class GroupDetailsPage extends StatefulWidget {
  final String groupId;

  const GroupDetailsPage({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load group details and related data
    context.read<GroupBloc>().add(LoadGroupById(widget.groupId));
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
      body: BlocBuilder<GroupBloc, GroupState>(
        builder: (context, state) {
          if (state is GroupLoading) {
            return const AppLoadingWidget(message: 'Loading group details...');
          }

          if (state is GroupError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<GroupBloc>().add(LoadGroupById(widget.groupId)),
            );
          }

          if (state is GroupLoaded) {
            return _buildGroupDetails(context, state.group);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildGroupDetails(BuildContext context, GroupEntity group) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: ColorConstants.getThemeColor(context),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  group.name,
                  style: const TextStyle(
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
                        ColorConstants.getThemeColor(context),
                        ColorConstants.getThemeColor(context)
                            .withValues(alpha: 0.8),
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
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                child: const Icon(
                                  Icons.group,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${group.members.length} members',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (group.description != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        group.description!,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.file_download, color: Colors.white),
                  onPressed: () => _showExportDialog(context, group),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () => _editGroup(context, group),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () => _showGroupSettings(context, group),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Activity'),
                  Tab(text: 'Settlements'),
                  Tab(text: 'Members'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(context, group),
            _buildActivityTab(context, group),
            _buildSettlementsTab(context, group),
            _buildMembersTab(context, group),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context, group),
    );
  }

  Widget _buildOverviewTab(BuildContext context, GroupEntity group) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Overview
          GroupBalanceOverview(groupId: group.id),

          const SizedBox(height: 24),

          // Quick Stats
          _buildQuickStats(context, group),

          const SizedBox(height: 24),

          // Recent Activity Preview
          _buildRecentActivityPreview(context, group),

          const SizedBox(height: 24),

          // Recent Shared Expenses Preview
          _buildRecentExpensesPreview(context, group),
        ],
      ),
    );
  }

  Widget _buildActivityTab(BuildContext context, GroupEntity group) {
    return GroupActivityFeed(groupId: group.id);
  }

  Widget _buildSettlementsTab(BuildContext context, GroupEntity group) {
    return BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
      builder: (context, state) {
        if (state is GroupDetailsLoaded) {
          return Column(
            children: [
              // Settlement summary card
              Padding(
                padding: const EdgeInsets.all(16),
                child: SettlementSummaryCard(
                  settlements: state.settlements,
                  onViewAll: () => _viewAllSettlements(context, group),
                ),
              ),
              // Settlement list
              Expanded(
                child: SettlementList(
                  settlements:
                      state.settlements.take(5).toList(), // Show only recent 5
                  onSettlementTap: (settlement) => _viewSettlement(settlement),
                  onSettlementEdit: (settlement) =>
                      _editSettlement(settlement, group),
                  onSettlementDelete: (settlement) =>
                      _deleteSettlement(settlement),
                  onSettlementConfirm: (settlement) =>
                      _confirmSettlement(settlement),
                  onSettlementCancel: (settlement) =>
                      _cancelSettlement(settlement),
                  showGroupedByStatus: false,
                  emptyMessage: 'No settlements recorded yet',
                ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildMembersTab(BuildContext context, GroupEntity group) {
    return GroupMemberList(group: group);
  }

  Widget _buildQuickStats(BuildContext context, GroupEntity group) {
    return BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
      builder: (context, state) {
        if (state is GroupDetailsLoaded) {
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Expenses',
                  '\$${state.totalExpenses.toStringAsFixed(2)}',
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Settlements',
                  '${state.settlementsCount}',
                  Icons.payment,
                  Colors.green,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return AppCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color:
                  ColorConstants.getTextColor(context).withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityPreview(BuildContext context, GroupEntity group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorConstants.getTextColor(context),
              ),
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: Text(
                'View All',
                style: TextStyle(
                  color: ColorConstants.getThemeColor(context),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GroupActivityFeed(
          groupId: group.id,
          isPreview: true,
          maxItems: 3,
        ),
      ],
    );
  }

  Widget _buildRecentExpensesPreview(BuildContext context, GroupEntity group) {
    return BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
      builder: (context, state) {
        if (state is GroupDetailsLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Expenses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.getTextColor(context),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _viewAllExpenses(context, group),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: ColorConstants.getThemeColor(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: SharedExpenseList(
                  expenses: state.expenses.take(3).toList(),
                  onExpenseTap: (expense) => _viewExpense(expense),
                  onExpenseEdit: (expense) => _editExpense(expense, group),
                  onExpenseDelete: (expense) => _deleteExpense(expense),
                  emptyMessage: 'No shared expenses yet',
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _editGroup(BuildContext context, GroupEntity group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateEditGroupPage(group: group),
      ),
    );
  }

  void _showGroupSettings(BuildContext context, GroupEntity group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GroupSettingsSheet(group: group),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, GroupEntity group) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () => _addSettlement(context, group),
          backgroundColor: Colors.green,
          heroTag: "settlement",
          child: const Icon(Icons.handshake, color: Colors.white),
        ),
        const SizedBox(height: 16),
        FloatingActionButton.extended(
          onPressed: () => _addExpense(context, group),
          backgroundColor: ColorConstants.getThemeColor(context),
          heroTag: "expense",
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add Expense',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _addExpense(BuildContext context, GroupEntity group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddSharedExpensePage(group: group),
      ),
    );
  }

  void _addSettlement(BuildContext context, GroupEntity group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddSettlementPage(group: group),
      ),
    );
  }

  void _viewAllSettlements(BuildContext context, GroupEntity group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettlementHistoryPage(group: group),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _viewSettlement(SettlementEntity settlement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settlement Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettlementDetailRow('From', settlement.payerName),
            _buildSettlementDetailRow('To', settlement.receiverName),
            _buildSettlementDetailRow(
                'Amount', '\$${settlement.amount.toStringAsFixed(2)}'),
            _buildSettlementDetailRow(
                'Status', settlement.status.toString().split('.').last),
            _buildSettlementDetailRow(
                'Created', _formatDate(settlement.createdAt)),
            if (settlement.description?.isNotEmpty == true)
              _buildSettlementDetailRow('Description', settlement.description!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (settlement.status == SettlementStatus.pending) ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmSettlement(settlement);
              },
              child: const Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelSettlement(settlement);
              },
              child: const Text('Cancel'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettlementDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _editSettlement(SettlementEntity settlement, GroupEntity group) {
    if (settlement.status != SettlementStatus.pending) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only pending settlements can be edited'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddSettlementPage(
          group: group,
          settlementToEdit: settlement,
        ),
      ),
    );
  }

  void _deleteSettlement(SettlementEntity settlement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Settlement'),
        content: const Text(
          'Are you sure you want to delete this settlement? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performDeleteSettlement(context, settlement);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmSettlement(SettlementEntity settlement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Settlement'),
        content: Text(
          'Are you sure you want to confirm this settlement of ${settlement.amount} ${settlement.currency} from ${settlement.payerName} to ${settlement.receiverName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performConfirmSettlement(context, settlement);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _cancelSettlement(SettlementEntity settlement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Settlement'),
        content: Text(
          'Are you sure you want to cancel this settlement of ${settlement.amount} ${settlement.currency} from ${settlement.payerName} to ${settlement.receiverName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performCancelSettlement(context, settlement);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Cancel Settlement',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _viewAllExpenses(BuildContext context, GroupEntity group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExpenseHistoryPage(
          groupId: widget.groupId,
          group: group,
        ),
      ),
    );
  }

  void _viewExpense(SharedExpenseEntity expense) {
    // Create a temporary group entity with the groupId
    final tempGroup = GroupEntity(
      id: widget.groupId,
      name: 'Group', // This will be loaded properly in the expense details page
      members: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: '',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExpenseDetailsPage(
          expenseId: expense.id,
          groupId: expense.groupId,
          group: tempGroup,
        ),
      ),
    );
  }

  void _editExpense(SharedExpenseEntity expense, GroupEntity group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddSharedExpensePage(
          group: group,
          expenseToEdit: expense,
        ),
      ),
    );
  }

  void _deleteExpense(SharedExpenseEntity expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content:
            Text('Are you sure you want to delete "${expense.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performDeleteExpense(context, expense);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Helper method to get current user information
  Future<Map<String, String>> _getCurrentUserInfo() async {
    try {
      final getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
      final result = await getCurrentUserUseCase();
      if (result.isSuccess && result.data != null) {
        final user = result.data!;
        return {
          'id': user.uid,
          'name': user.displayName ?? user.email.split('@')[0],
        };
      }
    } catch (e) {
      // Fallback to default values if user fetch fails
    }
    return {
      'id': 'unknown_user',
      'name': 'Unknown User',
    };
  }

  Future<void> _performConfirmSettlement(
      BuildContext context, SettlementEntity settlement) async {
    try {
      // Use the UpdateSettlementUseCase to confirm the settlement
      final updateSettlementUseCase = sl<UpdateSettlementUseCase>();
      final userInfo = await _getCurrentUserInfo();
      final confirmedSettlement = settlement.copyWith(
        status: SettlementStatus.confirmed,
        confirmedAt: DateTime.now(),
        confirmedBy: userInfo['id']!,
        updatedAt: DateTime.now(),
      );

      final result = await updateSettlementUseCase(
        params: UpdateSettlementParams(
          settlement: confirmedSettlement,
          updatedBy: userInfo['id']!,
          updatedByName: userInfo['name']!,
          actionType: SettlementActionType.confirmed,
        ),
      );

      if (result.isError) {
        throw Exception(
            result.error?.message ?? 'Failed to confirm settlement');
      }

      // Refresh the group details to show the updated settlement
      if (mounted) {
        final cubit = context.read<GroupDetailsCubit>();
        await cubit.refreshGroupDetails(widget.groupId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settlement confirmed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to confirm settlement: $e')),
        );
      }
    }
  }

  Future<void> _performCancelSettlement(
      BuildContext context, SettlementEntity settlement) async {
    try {
      // Use the UpdateSettlementUseCase to cancel the settlement
      final updateSettlementUseCase = sl<UpdateSettlementUseCase>();
      final userInfo = await _getCurrentUserInfo();
      final cancelledSettlement = settlement.copyWith(
        status: SettlementStatus.cancelled,
        updatedAt: DateTime.now(),
      );

      final result = await updateSettlementUseCase(
        params: UpdateSettlementParams(
          settlement: cancelledSettlement,
          updatedBy: userInfo['id']!,
          updatedByName: userInfo['name']!,
          actionType: SettlementActionType.cancelled,
        ),
      );

      if (result.isError) {
        throw Exception(result.error?.message ?? 'Failed to cancel settlement');
      }

      // Refresh the group details to show the updated settlement
      if (mounted) {
        final cubit = context.read<GroupDetailsCubit>();
        await cubit.refreshGroupDetails(widget.groupId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settlement cancelled successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel settlement: $e')),
        );
      }
    }
  }

  Future<void> _performDeleteSettlement(
      BuildContext context, SettlementEntity settlement) async {
    try {
      // Use the GroupDetailsCubit to delete the settlement
      final cubit = context.read<GroupDetailsCubit>();
      await cubit.deleteSettlement(settlement.id);

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
          const SnackBar(
            content: Text('Settlement deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete settlement: $e')),
        );
      }
    }
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
          const SnackBar(
            content: Text('Expense deleted successfully'),
            backgroundColor: Colors.green,
          ),
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

  void _showExportDialog(BuildContext context, GroupEntity group) {
    showDialog(
      context: context,
      builder: (context) => ExportDialog(
        group: group,
        onExportComplete: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data exported successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}
