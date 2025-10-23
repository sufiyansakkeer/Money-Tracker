import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/extensions/result_extensions.dart';
import 'package:money_track/features/groups/domain/entities/balance_entity.dart';
import 'package:money_track/features/groups/domain/entities/group_activity_entity.dart';
import 'package:money_track/features/groups/domain/entities/shared_expense_entity.dart';
import 'package:money_track/features/groups/domain/entities/settlement_entity.dart';
import 'package:money_track/features/groups/domain/usecases/shared_expense/get_group_shared_expenses_usecase.dart';
import 'package:money_track/features/groups/domain/usecases/shared_expense/delete_shared_expense_usecase.dart';
import 'package:money_track/features/groups/domain/usecases/settlement/get_group_settlements_usecase.dart';
import 'package:money_track/features/groups/domain/usecases/settlement/delete_settlement_usecase.dart';
import 'package:money_track/features/groups/domain/usecases/activity/get_group_activities_usecase.dart';
import 'package:money_track/features/groups/domain/usecases/balance/calculate_group_balance_usecase.dart';
import 'package:money_track/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:money_track/core/use_cases/use_case.dart';

part 'group_details_state.dart';

class GroupDetailsCubit extends Cubit<GroupDetailsState> {
  final GetGroupSharedExpensesUseCase getGroupSharedExpensesUseCase;
  final GetGroupSettlementsUseCase getGroupSettlementsUseCase;
  final GetGroupActivitiesUseCase getGroupActivitiesUseCase;
  final CalculateGroupBalanceUseCase calculateGroupBalanceUseCase;
  final DeleteSharedExpenseUseCase deleteSharedExpenseUseCase;
  final DeleteSettlementUseCase deleteSettlementUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  GroupDetailsCubit({
    required this.getGroupSharedExpensesUseCase,
    required this.getGroupSettlementsUseCase,
    required this.getGroupActivitiesUseCase,
    required this.calculateGroupBalanceUseCase,
    required this.deleteSharedExpenseUseCase,
    required this.deleteSettlementUseCase,
    required this.getCurrentUserUseCase,
  }) : super(GroupDetailsInitial());

  Future<void> loadGroupDetails(String groupId) async {
    emit(GroupDetailsLoading());

    try {
      // Load all group-related data in parallel
      final results = await Future.wait([
        getGroupSharedExpensesUseCase(
            params: GetGroupSharedExpensesParams(groupId: groupId)),
        getGroupSettlementsUseCase(
            params: GetGroupSettlementsParams(groupId: groupId)),
        getGroupActivitiesUseCase(
            params: GetGroupActivitiesParams(groupId: groupId)),
        calculateGroupBalanceUseCase(
            params: CalculateGroupBalanceParams(groupId: groupId)),
      ]);

      final expensesResult = results[0] as Result<List<SharedExpenseEntity>>;
      final settlementsResult = results[1] as Result<List<SettlementEntity>>;
      final activitiesResult = results[2] as Result<List<GroupActivityEntity>>;
      final balanceResult = results[3] as Result<GroupBalanceEntity?>;

      // Check if all results are successful
      if (expensesResult.isError ||
          settlementsResult.isError ||
          activitiesResult.isError ||
          balanceResult.isError) {
        final errorMessage = expensesResult.isError
            ? expensesResult.error?.message ?? 'Failed to load expenses'
            : settlementsResult.isError
                ? settlementsResult.error?.message ??
                    'Failed to load settlements'
                : activitiesResult.isError
                    ? activitiesResult.error?.message ??
                        'Failed to load activities'
                    : balanceResult.error?.message ??
                        'Failed to calculate balance';

        emit(GroupDetailsError(errorMessage));
        return;
      }

      final expenses = expensesResult.data ?? <SharedExpenseEntity>[];
      final settlements = settlementsResult.data ?? <SettlementEntity>[];
      final activities = activitiesResult.data ?? <GroupActivityEntity>[];
      final balance = balanceResult.data;

      // Calculate statistics
      final totalExpenses = expenses.fold<double>(
        0.0,
        (sum, expense) => sum + expense.totalAmount,
      );

      final settlementsCount = settlements.length;

      emit(GroupDetailsLoaded(
        expenses: expenses,
        settlements: settlements,
        activities: activities,
        balance: balance,
        totalExpenses: totalExpenses,
        settlementsCount: settlementsCount,
      ));
    } catch (e) {
      emit(GroupDetailsError('Failed to load group details: ${e.toString()}'));
    }
  }

  Future<void> refreshGroupDetails(String groupId) async {
    // Keep current data while refreshing
    if (state is GroupDetailsLoaded) {
      final currentState = state as GroupDetailsLoaded;
      emit(GroupDetailsRefreshing(currentState));
    }

    await loadGroupDetails(groupId);
  }

  void updateExpenses(List<SharedExpenseEntity> expenses) {
    if (state is GroupDetailsLoaded) {
      final currentState = state as GroupDetailsLoaded;
      final totalExpenses = expenses.fold<double>(
        0.0,
        (sum, expense) => sum + expense.totalAmount,
      );

      emit(currentState.copyWith(
        expenses: expenses,
        totalExpenses: totalExpenses,
      ));
    }
  }

  void updateSettlements(List<SettlementEntity> settlements) {
    if (state is GroupDetailsLoaded) {
      final currentState = state as GroupDetailsLoaded;
      emit(currentState.copyWith(
        settlements: settlements,
        settlementsCount: settlements.length,
      ));
    }
  }

  void updateActivities(List<GroupActivityEntity> activities) {
    if (state is GroupDetailsLoaded) {
      final currentState = state as GroupDetailsLoaded;
      emit(currentState.copyWith(activities: activities));
    }
  }

  void updateBalance(GroupBalanceEntity? balance) {
    if (state is GroupDetailsLoaded) {
      final currentState = state as GroupDetailsLoaded;
      emit(currentState.copyWith(balance: balance));
    }
  }

  void addExpense(SharedExpenseEntity expense) {
    if (state is GroupDetailsLoaded) {
      final currentState = state as GroupDetailsLoaded;
      final updatedExpenses = [...currentState.expenses, expense];
      updateExpenses(updatedExpenses);
    }
  }

  void addSettlement(SettlementEntity settlement) {
    if (state is GroupDetailsLoaded) {
      final currentState = state as GroupDetailsLoaded;
      final updatedSettlements = [...currentState.settlements, settlement];
      updateSettlements(updatedSettlements);
    }
  }

  void addActivity(GroupActivityEntity activity) {
    if (state is GroupDetailsLoaded) {
      final currentState = state as GroupDetailsLoaded;
      final updatedActivities = [activity, ...currentState.activities];
      updateActivities(updatedActivities);
    }
  }

  /// Helper method to get current user information
  Future<Map<String, String>> _getCurrentUserInfo() async {
    try {
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

  Future<void> deleteSharedExpense(String expenseId) async {
    try {
      final userInfo = await _getCurrentUserInfo();
      final result = await deleteSharedExpenseUseCase(
        params: DeleteSharedExpenseParams(
          expenseId: expenseId,
          deletedBy: userInfo['id']!,
          deletedByName: userInfo['name']!,
        ),
      );

      if (result.isError) {
        emit(GroupDetailsError(
            result.error?.message ?? 'Failed to delete expense'));
        return;
      }

      // Reload the group details to reflect the changes
      if (state is GroupDetailsLoaded) {
        final currentState = state as GroupDetailsLoaded;
        // Remove the expense from the current state
        final updatedExpenses = currentState.expenses
            .where((expense) => expense.id != expenseId)
            .toList();
        emit(currentState.copyWith(expenses: updatedExpenses));
      }
    } catch (e) {
      emit(GroupDetailsError('Failed to delete expense: $e'));
    }
  }

  Future<void> deleteSettlement(String settlementId) async {
    try {
      final userInfo = await _getCurrentUserInfo();
      final result = await deleteSettlementUseCase(
        params: DeleteSettlementParams(
          settlementId: settlementId,
          deletedBy: userInfo['id']!,
          deletedByName: userInfo['name']!,
        ),
      );

      if (result.isError) {
        emit(GroupDetailsError(
            result.error?.message ?? 'Failed to delete settlement'));
        return;
      }

      // Reload the group details to reflect the changes
      if (state is GroupDetailsLoaded) {
        final currentState = state as GroupDetailsLoaded;
        // Remove the settlement from the current state
        final updatedSettlements = currentState.settlements
            .where((settlement) => settlement.id != settlementId)
            .toList();
        emit(currentState.copyWith(settlements: updatedSettlements));
      }
    } catch (e) {
      emit(GroupDetailsError('Failed to delete settlement: $e'));
    }
  }
}
