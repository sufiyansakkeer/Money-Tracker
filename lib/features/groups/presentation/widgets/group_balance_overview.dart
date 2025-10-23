import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';

import 'package:money_track/core/utils/expense_currency_formatter.dart';
import 'package:money_track/core/widgets/enhanced_widgets.dart';
import 'package:money_track/features/groups/domain/entities/balance_entity.dart';
import 'package:money_track/features/groups/presentation/cubit/group_details_cubit.dart';

class GroupBalanceOverview extends StatelessWidget {
  final String groupId;

  const GroupBalanceOverview({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
      builder: (context, state) {
        if (state is GroupDetailsLoading) {
          return const AppLoadingWidget(message: 'Loading balance...');
        }

        if (state is GroupDetailsError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: () =>
                context.read<GroupDetailsCubit>().loadGroupDetails(groupId),
          );
        }

        if (state is GroupDetailsLoaded) {
          return _buildBalanceOverview(context, state.balance);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBalanceOverview(
      BuildContext context, GroupBalanceEntity? balance) {
    if (balance == null) {
      return AppCard(
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color:
                  ColorConstants.getTextColor(context).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No expenses yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color:
                    ColorConstants.getTextColor(context).withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first expense to see balance overview',
              style: TextStyle(
                fontSize: 14,
                color:
                    ColorConstants.getTextColor(context).withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Balance Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorConstants.getTextColor(context),
          ),
        ),
        const SizedBox(height: 16),

        // Total Group Spending
        AppCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorConstants.getThemeColor(context)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: ColorConstants.getThemeColor(context),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Group Spending',
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorConstants.getTextColor(context)
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ExpenseCurrencyFormatter.format(
                        balance.totalGroupExpenses,
                        balance.currency,
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Member Balances
        if (balance.memberBalances.isNotEmpty) ...[
          Text(
            'Member Balances',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorConstants.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          ...balance.memberBalances.entries.expand((entry) => entry.value).map(
              (memberBalance) => _buildMemberBalanceCard(
                  context, memberBalance, balance.currency)),
        ],

        const SizedBox(height: 16),

        // Simplified Debts
        if (balance.simplifiedDebts.isNotEmpty) ...[
          Text(
            'Who Owes Whom',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorConstants.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          ...balance.simplifiedDebts
              .map((debt) => _buildDebtCard(context, debt, balance.currency)),
        ],
      ],
    );
  }

  Widget _buildMemberBalanceCard(
    BuildContext context,
    MemberBalance memberBalance,
    String currency,
  ) {
    final isPositive = memberBalance.amount >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;
    final statusText = isPositive ? 'Gets back' : 'Owes';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memberBalance.memberName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorConstants.getTextColor(context)
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            ExpenseCurrencyFormatter.format(
              memberBalance.amount.abs(),
              currency,
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(
    BuildContext context,
    SimplifiedDebt debt,
    String currency,
  ) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  radius: 16,
                  child: Text(
                    debt.debtorName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  debt.debtorName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward,
            color: ColorConstants.getTextColor(context).withValues(alpha: 0.4),
            size: 16,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  debt.creditorName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  radius: 16,
                  child: Text(
                    debt.creditorName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  ColorConstants.getThemeColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              ExpenseCurrencyFormatter.format(debt.amount, currency),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ColorConstants.getThemeColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
