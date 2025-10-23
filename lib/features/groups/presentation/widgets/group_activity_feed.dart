import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';

import 'package:money_track/core/utils/expense_currency_formatter.dart';
import 'package:money_track/core/utils/date_formatter.dart';
import 'package:money_track/core/widgets/enhanced_widgets.dart';
import 'package:money_track/features/groups/domain/entities/group_activity_entity.dart';
import 'package:money_track/features/groups/presentation/cubit/group_details_cubit.dart';

class GroupActivityFeed extends StatelessWidget {
  final String groupId;
  final bool isPreview;
  final int? maxItems;

  const GroupActivityFeed({
    super.key,
    required this.groupId,
    this.isPreview = false,
    this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
      builder: (context, state) {
        if (state is GroupDetailsLoading && !isPreview) {
          return const AppLoadingWidget(message: 'Loading activities...');
        }

        if (state is GroupDetailsError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: () =>
                context.read<GroupDetailsCubit>().loadGroupDetails(groupId),
          );
        }

        if (state is GroupDetailsLoaded) {
          return _buildActivityFeed(context, state.activities);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActivityFeed(
      BuildContext context, List<GroupActivityEntity> activities) {
    if (activities.isEmpty) {
      return _buildEmptyState(context);
    }

    final displayActivities =
        maxItems != null ? activities.take(maxItems!).toList() : activities;

    if (isPreview) {
      return Column(
        children: displayActivities
            .map((activity) => _buildActivityItem(context, activity))
            .toList(),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<GroupDetailsCubit>().refreshGroupDetails(groupId),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: displayActivities.length,
        itemBuilder: (context, index) {
          final activity = displayActivities[index];
          return _buildActivityItem(context, activity);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 64,
            color: ColorConstants.getTextColor(context).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No activity yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color:
                  ColorConstants.getTextColor(context).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Group activities will appear here',
            style: TextStyle(
              fontSize: 14,
              color:
                  ColorConstants.getTextColor(context).withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      BuildContext context, GroupActivityEntity activity) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActivityIcon(context, activity),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActivityTitle(context, activity),
                const SizedBox(height: 4),
                _buildActivityDescription(context, activity),
                const SizedBox(height: 8),
                _buildActivityTimestamp(context, activity),
              ],
            ),
          ),
          if (activity.amount != null) ...[
            const SizedBox(width: 12),
            _buildAmountChip(context, activity),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityIcon(
      BuildContext context, GroupActivityEntity activity) {
    IconData icon;
    Color color;

    switch (activity.type) {
      case GroupActivityType.expenseAdded:
        icon = Icons.receipt_long;
        color = Colors.blue;
        break;
      case GroupActivityType.expenseUpdated:
        icon = Icons.edit;
        color = Colors.blue;
        break;
      case GroupActivityType.expenseDeleted:
        icon = Icons.delete;
        color = Colors.red;
        break;
      case GroupActivityType.settlementAdded:
        icon = Icons.payment;
        color = Colors.green;
        break;
      case GroupActivityType.settlementConfirmed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case GroupActivityType.settlementCancelled:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case GroupActivityType.memberAdded:
        icon = Icons.person_add;
        color = Colors.orange;
        break;
      case GroupActivityType.memberRemoved:
        icon = Icons.person_remove;
        color = Colors.red;
        break;
      case GroupActivityType.groupUpdated:
        icon = Icons.edit;
        color = Colors.purple;
        break;
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildActivityTitle(
      BuildContext context, GroupActivityEntity activity) {
    String title;

    switch (activity.type) {
      case GroupActivityType.expenseAdded:
        title = 'Expense Added';
        break;
      case GroupActivityType.expenseUpdated:
        title = 'Expense Updated';
        break;
      case GroupActivityType.expenseDeleted:
        title = 'Expense Deleted';
        break;
      case GroupActivityType.settlementAdded:
        title = 'Payment Made';
        break;
      case GroupActivityType.settlementConfirmed:
        title = 'Payment Confirmed';
        break;
      case GroupActivityType.settlementCancelled:
        title = 'Payment Cancelled';
        break;
      case GroupActivityType.memberAdded:
        title = 'Member Added';
        break;
      case GroupActivityType.memberRemoved:
        title = 'Member Removed';
        break;
      case GroupActivityType.groupUpdated:
        title = 'Group Updated';
        break;
    }

    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildActivityDescription(
      BuildContext context, GroupActivityEntity activity) {
    String description;

    // Use the activity's description property directly
    description = activity.description;

    return Text(
      description,
      style: TextStyle(
        fontSize: 14,
        color: ColorConstants.getTextColor(context).withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildActivityTimestamp(
      BuildContext context, GroupActivityEntity activity) {
    return Text(
      DateFormatter.formatRelativeTime(activity.timestamp),
      style: TextStyle(
        fontSize: 12,
        color: ColorConstants.getTextColor(context).withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildAmountChip(BuildContext context, GroupActivityEntity activity) {
    if (activity.amount == null || activity.currency == null) {
      return const SizedBox.shrink();
    }

    Color chipColor;
    switch (activity.type) {
      case GroupActivityType.expenseAdded:
        chipColor = Colors.blue;
        break;
      case GroupActivityType.settlementAdded:
        chipColor = Colors.green;
        break;
      default:
        chipColor = ColorConstants.getThemeColor(context);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        ExpenseCurrencyFormatter.format(activity.amount!, activity.currency!),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: chipColor,
        ),
      ),
    );
  }
}
