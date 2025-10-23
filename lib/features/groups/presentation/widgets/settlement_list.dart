import 'package:flutter/material.dart';
import 'package:money_track/core/widgets/enhanced_widgets.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';
import 'package:money_track/features/groups/presentation/widgets/settlement_tile.dart';

class SettlementList extends StatelessWidget {
  final List<SettlementEntity> settlements;
  final VoidCallback? onRefresh;
  final Function(SettlementEntity)? onSettlementTap;
  final Function(SettlementEntity)? onSettlementEdit;
  final Function(SettlementEntity)? onSettlementDelete;
  final Function(SettlementEntity)? onSettlementConfirm;
  final Function(SettlementEntity)? onSettlementCancel;
  final bool isLoading;
  final String? emptyMessage;
  final bool showGroupedByStatus;

  const SettlementList({
    super.key,
    required this.settlements,
    this.onRefresh,
    this.onSettlementTap,
    this.onSettlementEdit,
    this.onSettlementDelete,
    this.onSettlementConfirm,
    this.onSettlementCancel,
    this.isLoading = false,
    this.emptyMessage,
    this.showGroupedByStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const AppLoadingWidget(message: 'Loading settlements...');
    }

    if (settlements.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: showGroupedByStatus
          ? _buildGroupedSettlementList()
          : _buildSimpleSettlementList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return AppEmptyWidget(
      title: 'No Settlements Yet',
      subtitle: emptyMessage ??
          'Record settlements to track payments between group members',
      icon: Icons.handshake_outlined,
    );
  }

  Widget _buildSimpleSettlementList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: settlements.length,
      itemBuilder: (context, index) {
        final settlement = settlements[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SettlementTile(
            settlement: settlement,
            onTap: () => onSettlementTap?.call(settlement),
            onEdit: () => onSettlementEdit?.call(settlement),
            onDelete: () => onSettlementDelete?.call(settlement),
            onConfirm: () => onSettlementConfirm?.call(settlement),
            onCancel: () => onSettlementCancel?.call(settlement),
          ),
        );
      },
    );
  }

  Widget _buildGroupedSettlementList() {
    final groupedSettlements = _groupSettlementsByStatus(settlements);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (groupedSettlements[SettlementStatus.pending]?.isNotEmpty == true)
          _buildStatusSection(
            'Pending Settlements',
            groupedSettlements[SettlementStatus.pending]!,
            Icons.pending_actions,
            Colors.orange,
          ),
        if (groupedSettlements[SettlementStatus.confirmed]?.isNotEmpty == true)
          _buildStatusSection(
            'Confirmed Settlements',
            groupedSettlements[SettlementStatus.confirmed]!,
            Icons.check_circle,
            Colors.green,
          ),
        if (groupedSettlements[SettlementStatus.cancelled]?.isNotEmpty == true)
          _buildStatusSection(
            'Cancelled Settlements',
            groupedSettlements[SettlementStatus.cancelled]!,
            Icons.cancel,
            Colors.red,
          ),
      ],
    );
  }

  Widget _buildStatusSection(
    String title,
    List<SettlementEntity> statusSettlements,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${statusSettlements.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...statusSettlements.map((settlement) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SettlementTile(
                settlement: settlement,
                onTap: () => onSettlementTap?.call(settlement),
                onEdit: () => onSettlementEdit?.call(settlement),
                onDelete: () => onSettlementDelete?.call(settlement),
                onConfirm: () => onSettlementConfirm?.call(settlement),
                onCancel: () => onSettlementCancel?.call(settlement),
              ),
            )),
        const SizedBox(height: 16),
      ],
    );
  }

  Map<SettlementStatus, List<SettlementEntity>> _groupSettlementsByStatus(
      List<SettlementEntity> settlements) {
    final grouped = <SettlementStatus, List<SettlementEntity>>{
      SettlementStatus.pending: [],
      SettlementStatus.confirmed: [],
      SettlementStatus.cancelled: [],
    };

    for (final settlement in settlements) {
      grouped[settlement.status]!.add(settlement);
    }

    // Sort each group by date (newest first)
    for (final statusList in grouped.values) {
      statusList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return grouped;
  }
}

class SettlementSummaryCard extends StatelessWidget {
  final List<SettlementEntity> settlements;
  final VoidCallback? onViewAll;

  const SettlementSummaryCard({
    super.key,
    required this.settlements,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        settlements.where((s) => s.status == SettlementStatus.pending).length;
    final confirmedCount = settlements
        .where((s) => s.status == SettlementStatus.confirmed)
        .length;
    final totalAmount = settlements
        .where((s) => s.status == SettlementStatus.confirmed)
        .fold<double>(0.0, (sum, settlement) => sum + settlement.amount);

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.handshake, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Settlements',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Pending',
                    pendingCount.toString(),
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Confirmed',
                    confirmedCount.toString(),
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Settled',
                    '\$${totalAmount.toStringAsFixed(2)}',
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
