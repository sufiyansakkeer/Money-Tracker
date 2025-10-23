part of 'group_details_cubit.dart';

abstract class GroupDetailsState extends Equatable {
  const GroupDetailsState();

  @override
  List<Object?> get props => [];
}

class GroupDetailsInitial extends GroupDetailsState {}

class GroupDetailsLoading extends GroupDetailsState {}

class GroupDetailsRefreshing extends GroupDetailsState {
  final GroupDetailsLoaded previousState;

  const GroupDetailsRefreshing(this.previousState);

  @override
  List<Object?> get props => [previousState];
}

class GroupDetailsLoaded extends GroupDetailsState {
  final List<SharedExpenseEntity> expenses;
  final List<SettlementEntity> settlements;
  final List<GroupActivityEntity> activities;
  final GroupBalanceEntity? balance;
  final double totalExpenses;
  final int settlementsCount;

  const GroupDetailsLoaded({
    required this.expenses,
    required this.settlements,
    required this.activities,
    required this.balance,
    required this.totalExpenses,
    required this.settlementsCount,
  });

  @override
  List<Object?> get props => [
        expenses,
        settlements,
        activities,
        balance,
        totalExpenses,
        settlementsCount,
      ];

  GroupDetailsLoaded copyWith({
    List<SharedExpenseEntity>? expenses,
    List<SettlementEntity>? settlements,
    List<GroupActivityEntity>? activities,
    GroupBalanceEntity? balance,
    double? totalExpenses,
    int? settlementsCount,
  }) {
    return GroupDetailsLoaded(
      expenses: expenses ?? this.expenses,
      settlements: settlements ?? this.settlements,
      activities: activities ?? this.activities,
      balance: balance ?? this.balance,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      settlementsCount: settlementsCount ?? this.settlementsCount,
    );
  }
}

class GroupDetailsError extends GroupDetailsState {
  final String message;

  const GroupDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
