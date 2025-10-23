import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';
import 'package:money_track/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:money_track/features/groups/presentation/widgets/settlement_list.dart';
import 'package:money_track/features/groups/presentation/widgets/settlement_confirmation_dialog.dart';
import 'package:money_track/features/groups/presentation/pages/add_settlement_page.dart';
import 'package:money_track/features/groups/domain/usecases/settlement/update_settlement_usecase.dart';
import 'package:money_track/app/di/injection_container.dart';
import 'package:money_track/core/extensions/result_extensions.dart';
import 'package:money_track/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:money_track/core/use_cases/use_case.dart';

class SettlementHistoryPage extends StatefulWidget {
  final GroupEntity group;

  const SettlementHistoryPage({
    super.key,
    required this.group,
  });

  @override
  State<SettlementHistoryPage> createState() => _SettlementHistoryPageState();
}

class _SettlementHistoryPageState extends State<SettlementHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SettlementEntity> _settlements = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSettlements();
  }

  void _loadSettlements() {
    // Load settlements from cubit state
    final state = context.read<GroupDetailsCubit>().state;
    if (state is GroupDetailsLoaded) {
      setState(() {
        _settlements = state.settlements;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.group.name} Settlements'),
        backgroundColor: ColorConstants.getThemeColor(context),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          tabs: [
            Tab(
              text: 'All',
              icon: Badge(
                label: Text('${_settlements.length}'),
                child: const Icon(Icons.list),
              ),
            ),
            Tab(
              text: 'Pending',
              icon: Badge(
                label: Text('${_getPendingCount()}'),
                child: const Icon(Icons.pending_actions),
              ),
            ),
            Tab(
              text: 'Confirmed',
              icon: Badge(
                label: Text('${_getConfirmedCount()}'),
                child: const Icon(Icons.check_circle),
              ),
            ),
            Tab(
              text: 'Cancelled',
              icon: Badge(
                label: Text('${_getCancelledCount()}'),
                child: const Icon(Icons.cancel),
              ),
            ),
          ],
        ),
      ),
      body: BlocListener<GroupDetailsCubit, GroupDetailsState>(
        listener: (context, state) {
          if (state is GroupDetailsLoaded) {
            setState(() {
              _settlements = state.settlements;
            });
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAllSettlementsTab(),
            _buildPendingSettlementsTab(),
            _buildConfirmedSettlementsTab(),
            _buildCancelledSettlementsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSettlement,
        backgroundColor: ColorConstants.getThemeColor(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Record Settlement',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAllSettlementsTab() {
    return SettlementList(
      settlements: _settlements,
      onRefresh: _loadSettlements,
      onSettlementTap: _viewSettlement,
      onSettlementEdit: _editSettlement,
      onSettlementDelete: _deleteSettlement,
      onSettlementConfirm: _confirmSettlement,
      onSettlementCancel: _cancelSettlement,
      showGroupedByStatus: true,
    );
  }

  Widget _buildPendingSettlementsTab() {
    final pendingSettlements = _settlements
        .where((s) => s.status == SettlementStatus.pending)
        .toList();

    return SettlementList(
      settlements: pendingSettlements,
      onRefresh: _loadSettlements,
      onSettlementTap: _viewSettlement,
      onSettlementEdit: _editSettlement,
      onSettlementDelete: _deleteSettlement,
      onSettlementConfirm: _confirmSettlement,
      onSettlementCancel: _cancelSettlement,
      showGroupedByStatus: false,
      emptyMessage: 'No pending settlements',
    );
  }

  Widget _buildConfirmedSettlementsTab() {
    final confirmedSettlements = _settlements
        .where((s) => s.status == SettlementStatus.confirmed)
        .toList();

    return SettlementList(
      settlements: confirmedSettlements,
      onRefresh: _loadSettlements,
      onSettlementTap: _viewSettlement,
      onSettlementEdit: _editSettlement,
      onSettlementDelete: _deleteSettlement,
      showGroupedByStatus: false,
      emptyMessage: 'No confirmed settlements',
    );
  }

  Widget _buildCancelledSettlementsTab() {
    final cancelledSettlements = _settlements
        .where((s) => s.status == SettlementStatus.cancelled)
        .toList();

    return SettlementList(
      settlements: cancelledSettlements,
      onRefresh: _loadSettlements,
      onSettlementTap: _viewSettlement,
      onSettlementEdit: _editSettlement,
      onSettlementDelete: _deleteSettlement,
      showGroupedByStatus: false,
      emptyMessage: 'No cancelled settlements',
    );
  }

  int _getPendingCount() {
    return _settlements
        .where((s) => s.status == SettlementStatus.pending)
        .length;
  }

  int _getConfirmedCount() {
    return _settlements
        .where((s) => s.status == SettlementStatus.confirmed)
        .length;
  }

  int _getCancelledCount() {
    return _settlements
        .where((s) => s.status == SettlementStatus.cancelled)
        .length;
  }

  void _addSettlement() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => AddSettlementPage(group: widget.group),
      ),
    )
        .then((result) {
      if (result != null) {
        _loadSettlements();
      }
    });
  }

  void _viewSettlement(SettlementEntity settlement) {
    // Implement settlement details view
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settlement Details'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Amount',
                  '\$${settlement.amount.toStringAsFixed(2)} ${settlement.currency}'),
              const SizedBox(height: 8),
              _buildDetailRow('From', settlement.payerName),
              const SizedBox(height: 8),
              _buildDetailRow('To', settlement.receiverName),
              const SizedBox(height: 8),
              _buildDetailRow('Payment Method',
                  _getPaymentMethodName(settlement.paymentMethod)),
              const SizedBox(height: 8),
              _buildDetailRow('Status', _getStatusName(settlement.status)),
              const SizedBox(height: 8),
              _buildDetailRow('Created', _formatDateTime(settlement.createdAt)),
              if (settlement.updatedAt != settlement.createdAt) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                    'Updated', _formatDateTime(settlement.updatedAt)),
              ],
              if (settlement.confirmedAt != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                    'Confirmed', _formatDateTime(settlement.confirmedAt!)),
              ],
              if (settlement.confirmedBy != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Confirmed By', settlement.confirmedBy!),
              ],
              if (settlement.description != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(settlement.description!),
              ],
              if (settlement.notes != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Notes:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(settlement.notes!),
              ],
              if (settlement.relatedExpenseIds != null &&
                  settlement.relatedExpenseIds!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Related Expenses:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text('${settlement.relatedExpenseIds!.length} expense(s)'),
              ],
            ],
          ),
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
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.digitalWallet:
        return 'Digital Wallet';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  String _getStatusName(SettlementStatus status) {
    switch (status) {
      case SettlementStatus.pending:
        return 'Pending';
      case SettlementStatus.confirmed:
        return 'Confirmed';
      case SettlementStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _editSettlement(SettlementEntity settlement) {
    if (settlement.status != SettlementStatus.pending) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only pending settlements can be edited'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => AddSettlementPage(
          group: widget.group,
          settlementToEdit: settlement,
        ),
      ),
    )
        .then((result) {
      if (result != null) {
        _loadSettlements();
      }
    });
  }

  void _deleteSettlement(SettlementEntity settlement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Settlement'),
        content: Text(
          'Are you sure you want to delete this settlement? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performDeleteSettlement(settlement);
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
      builder: (context) => SettlementConfirmationDialog(
        settlement: settlement,
        onConfirm: () => _performConfirmSettlement(settlement),
      ),
    );
  }

  void _cancelSettlement(SettlementEntity settlement) {
    showDialog(
      context: context,
      builder: (context) => SettlementCancellationDialog(
        settlement: settlement,
        onConfirm: () => _performCancelSettlement(settlement),
      ),
    );
  }

  Future<void> _performDeleteSettlement(SettlementEntity settlement) async {
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
        _loadSettlements();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete settlement: $e')),
        );
      }
    }
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

  void _performConfirmSettlement(SettlementEntity settlement) async {
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
        await cubit.refreshGroupDetails(widget.group.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settlement confirmed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to confirm settlement: $e')),
        );
      }
    }
  }

  void _performCancelSettlement(SettlementEntity settlement) async {
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
        await cubit.refreshGroupDetails(widget.group.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settlement cancelled successfully'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel settlement: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
