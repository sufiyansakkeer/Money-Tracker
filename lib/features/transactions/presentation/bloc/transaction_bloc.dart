import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/domain/usecases/transaction/add_transaction_usecase.dart';
import 'package:money_track/domain/usecases/transaction/delete_transaction_usecase.dart';
import 'package:money_track/domain/usecases/transaction/edit_transaction_usecase.dart';
import 'package:money_track/domain/usecases/transaction/get_all_transactions_usecase.dart';
import 'package:money_track/features/transactions/domain/entities/filter_data.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetAllTransactionsUseCase getAllTransactionsUseCase;
  final AddTransactionUseCase addTransactionUseCase;
  final EditTransactionUseCase editTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;
  List<TransactionEntity> _allTransactions = [];

  TransactionBloc({
    required this.getAllTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.editTransactionUseCase,
    required this.deleteTransactionUseCase,
  }) : super(TransactionInitial()) {
    on<GetAllTransactionsEvent>((event, emit) async {
      emit(TransactionLoading());
      final result = await getAllTransactionsUseCase();

      result.fold(
        (success) {
          _allTransactions = success;
          emit(TransactionLoaded(transactionList: success));
        },
        (error) {
          emit(TransactionError(message: error.message));
        },
      );
    });

    on<AddTransactionEvent>((event, emit) async {
      try {
        double amount = double.tryParse(event.amount) ?? 0;

        final transaction = TransactionEntity(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          amount: amount,
          date: event.date,
          categoryType: event.categoryType,
          transactionType: event.isExpense
              ? TransactionType.expense
              : TransactionType.income,
          category: event.categoryModel,
          notes: event.description,
        );

        final result = await addTransactionUseCase(params: transaction);

        result.fold(
          (success) {
            add(GetAllTransactionsEvent());
          },
          (error) {
            emit(TransactionError(message: error.message));
          },
        );
      } catch (e) {
        emit(TransactionError(message: e.toString()));
      }
    });

    on<FilterTransactionEvent>((event, emit) async {
      var filter = event.filterData;

      if (filter.transactionSortEnum == null &&
          filter.transactionType == null &&
          filter.dateFilterType == null) {
        add(GetAllTransactionsEvent());
        return;
      }

      List<TransactionEntity> filteredList = List.from(_allTransactions);

      // Filter by transaction type
      if (filter.transactionType != null) {
        filteredList = filteredList
            .where(
                (element) => element.transactionType == filter.transactionType)
            .toList();
      }

      // Filter by date
      if (filter.dateFilterType != null) {
        final now = DateTime.now();
        DateTime? startDate;
        DateTime? endDate;

        // Use the dates directly from the filter if they're set
        if (filter.startDate != null && filter.endDate != null) {
          startDate = filter.startDate;
          endDate = filter.endDate;
        } else {
          // Otherwise calculate based on the filter type
          switch (filter.dateFilterType!) {
            case DateFilterType.today:
              startDate = DateTime(now.year, now.month, now.day);
              endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
              break;
            case DateFilterType.yesterday:
              startDate = DateTime(now.year, now.month, now.day - 1);
              endDate = DateTime(now.year, now.month, now.day - 1, 23, 59, 59);
              break;
            case DateFilterType.thisWeek:
              // Calculate the start of the week (assuming Sunday is the first day)
              final daysToSubtract = now.weekday % 7;
              startDate =
                  DateTime(now.year, now.month, now.day - daysToSubtract);
              endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
              break;
            case DateFilterType.thisMonth:
              startDate = DateTime(now.year, now.month, 1);
              endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
              break;
            case DateFilterType.thisYear:
              startDate = DateTime(now.year, 1, 1);
              endDate = DateTime(now.year, 12, 31, 23, 59, 59);
              break;
            case DateFilterType.custom:
              // For custom, we should already have the dates from the filter
              break;
            case DateFilterType.all:
              // No date filtering
              break;
          }
        }

        if (startDate != null && endDate != null) {
          filteredList = filteredList.where((transaction) {
            final transactionDate = DateTime(
              transaction.date.year,
              transaction.date.month,
              transaction.date.day,
            );

            // Check if transaction date is within the range (inclusive)
            bool isInRange = (transactionDate.isAfter(startDate!) ||
                    transactionDate.isAtSameMomentAs(startDate)) &&
                (transactionDate.isBefore(endDate!) ||
                    transactionDate.isAtSameMomentAs(endDate));

            return isInRange;
          }).toList();
        }
      }

      // Sort by date
      if (filter.transactionSortEnum != null) {
        if (filter.transactionSortEnum == TransactionSortEnum.newest) {
          filteredList.sort((a, b) => b.date.compareTo(a.date));
        } else {
          filteredList.sort((a, b) => a.date.compareTo(b.date));
        }
      } else {
        // Default sort by newest
        filteredList.sort((a, b) => b.date.compareTo(a.date));
      }

      emit(TransactionLoaded(transactionList: filteredList));
    });

    on<EditTransactionEvent>((event, emit) async {
      try {
        double amount = double.tryParse(event.amount) ?? 0;

        final transaction = TransactionEntity(
          id: event.id, // Use the ID from the event
          amount: amount,
          date: event.date,
          categoryType: event.categoryType,
          transactionType: event.isExpense
              ? TransactionType.expense
              : TransactionType.income,
          category: event.categoryModel,
          notes: event.description,
        );

        final result = await editTransactionUseCase(
            params: transaction); // Use edit use case

        result.fold(
          (success) {
            add(GetAllTransactionsEvent()); // Refresh list on success
          },
          (error) {
            emit(TransactionError(message: error.message));
          },
        );
      } catch (e) {
        emit(TransactionError(message: e.toString()));
      }
    });

    on<DeleteTransactionEvent>((event, emit) async {
      try {
        emit(TransactionLoading());

        final result =
            await deleteTransactionUseCase(params: event.transactionId);

        result.fold(
          (success) {
            add(GetAllTransactionsEvent()); // Refresh list on success
          },
          (error) {
            emit(TransactionError(message: error.message));
          },
        );
      } catch (e) {
        emit(TransactionError(message: e.toString()));
      }
    });
  }
}
