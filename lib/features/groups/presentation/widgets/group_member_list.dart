import 'package:flutter/material.dart';
import 'package:money_track/features/groups/domain/entities/group_entity.dart';
import 'package:money_track/features/groups/domain/entities/balance_entity.dart';
import 'package:money_track/core/utils/currency_formatter.dart';

class GroupMemberList extends StatelessWidget {
  final GroupEntity group;
  final GroupBalanceEntity? balance;
  final Function(String memberId)? onMemberTap;

  const GroupMemberList({
    super.key,
    required this.group,
    this.balance,
    this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    if (group.members.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: group.members.length,
      itemBuilder: (context, index) {
        final member = group.members[index];
        final memberBalance = _getMemberBalance(member.id);
        return _buildMemberTile(context, member, memberBalance);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No members in this group',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add members to start splitting expenses',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(
    BuildContext context,
    GroupMember member,
    MemberBalance? memberBalance,
  ) {
    final netBalance = balance?.memberTotals[member.id] ?? 0.0;
    final isOwed = netBalance > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor:
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Text(
            member.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (member.email?.isNotEmpty == true)
              Text(
                member.email!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 4),
            _buildBalanceInfo(context, memberBalance),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (netBalance != 0) ...[
              Text(
                CurrencyFormatter.format(context, netBalance.abs()),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isOwed ? Colors.green[700] : Colors.red[700],
                ),
              ),
              Text(
                isOwed ? 'is owed' : 'owes',
                style: TextStyle(
                  fontSize: 12,
                  color: isOwed ? Colors.green[600] : Colors.red[600],
                ),
              ),
            ] else ...[
              Text(
                'Settled up',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 16,
              ),
            ],
          ],
        ),
        onTap: () => onMemberTap?.call(member.id),
      ),
    );
  }

  Widget _buildBalanceInfo(BuildContext context, MemberBalance? memberBalance) {
    if (memberBalance == null) {
      return Text(
        'No transactions yet',
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
        ),
      );
    }

    return Text(
      'Last updated: ${memberBalance.lastUpdated.day}/${memberBalance.lastUpdated.month}',
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 12,
      ),
    );
  }

  MemberBalance? _getMemberBalance(String memberId) {
    if (balance == null) return null;

    final memberBalances = balance!.memberBalances[memberId];
    if (memberBalances != null && memberBalances.isNotEmpty) {
      return memberBalances.first;
    }
    return null;
  }
}
