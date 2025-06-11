import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/logging/app_logger.dart';
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
    AppLogger().info('TransactionBloc initialized', tag: 'TRANSACTION_BLOC');
    
    on<GetAllTransactionsEvent>((event, emit) async {
      AppLogger().blocEvent('TransactionBloc', 'GetAllTransactionsEvent');
      emit(TransactionLoading());
      final result = await getAllTransactionsUseCase();

      result.fold(
        (success) {
          _allTransactions = success;
          AppLogger().blocState('TransactionBloc', 'TransactionLoaded', 
            data: {'transactionCount': success.length});
          emit(TransactionLoaded(transactionList: success));
        },
        (error) {
          AppLogger().error('Failed to get all transactions: ${error.message}', 
            tag: 'TRANSACTION_BLOC');
          emit(TransactionError(message: error.message));
        },
      );
    });

    on<AddTransactionEvent>((event, emit) async {
      AppLogger().blocEvent('TransactionBloc', 'AddTransactionEvent', 
        data: {'amount': event.amount, 'isExpense': event.isExpense});
      
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

        AppLogger().debug('Creating transaction with ID: ${transaction.id}', 
          tag: 'TRANSACTION_BLOC');

        final result = await addTransactionUseCase(params: transaction);

        result.fold(
          (success) {
            AppLogger().info('Transaction added successfully', tag: 'TRANSACTION_BLOC');
            add(GetAllTransactionsEvent());
          },
          (error) {
            AppLogger().error('Failed to add transaction: ${error.message}', 
              tag: 'TRANSACTION_BLOC');
            emit(TransactionError(message: error.message));
          },
        );
      } catch (e) {
        AppLogger().error('Exception in AddTransactionEvent: $e', 
          tag: 'TRANSACTION_BLOC', error: e);
        emit(TransactionError(message: e.toString()));
      }
    });

    on<FilterTransactionEvent>((event, emit) async {
      var filter = event.filterData;

      AppLogger().blocEvent('TransactionBloc', 'FilterTransactionEvent', 
        data: {
          'dateFilterType': filter.dateFilterType?.toString(),
          'transactionType': filter.transactionType?.toString(),
          'sortType': filter.transactionSortEnum?.toString()
        });

      if (filter.transactionSortEnum == null &&
          filter.transactionType == null &&
          filter.dateFilterType == null) {
        AppLogger().debug('No filters applied, getting all transactions', 
          tag: 'TRANSACTION_BLOC');
        add(GetAllTransactionsEvent());
        return;
      }

      List<TransactionEntity> filteredList = List.from(_allTransactions);
      AppLogger().debug('Starting with ${filteredList.length} transactions', 
        tag: 'TRANSACTION_BLOC');

      // Filter by transaction type
      if (filter.transactionType != null) {
        filteredList = filteredList
            .where(
                (element) => element.transactionType == filter.transactionType)
            .toList();
        AppLogger().debug('After type filter: ${filteredList.length} transactions', 
          tag: 'TRANSACTION_BLOC');
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
          AppLogger().debug('Using custom date range: $startDate to $endDate', 
            tag: 'TRANSACTION_BLOC');
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
          AppLogger().debug('Filtering by date range: $startDate to $endDate', 
            tag: 'TRANSACTION_BLOC');

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

          AppLogger().debug('After date filter: ${filteredList.length} transactions', 
            tag: 'TRANSACTION_BLOC');
        }
      }

      // Sort by date
      if (filter.transactionSortEnum != null) {
        if (filter.transactionSortEnum == TransactionSortEnum.newest) {
          filteredList.sort((a, b) => b.date.compareTo(a.date));
          AppLogger().debug('Sorted by newest first', tag: 'TRANSACTION_BLOC');
        } else {
          filteredList.sort((a, b) => a.date.compareTo(b.date));
          AppLogger().debug('Sorted by oldest first', tag: 'TRANSACTION_BLOC');
        }
      } else {
        // Default sort by newest
        filteredList.sort((a, b) => b.date.compareTo(a.date));
        AppLogger().debug('Applied default sort (newest first)', tag: 'TRANSACTION_BLOC');
      }

      AppLogger().blocState('TransactionBloc', 'TransactionLoaded (Filtered)', 
        data: {'filteredCount': filteredList.length});
      emit(TransactionLoaded(transactionList: filteredList));
    });

    on<EditTransactionEvent>((event, emit) async {
      AppLogger().blocEvent('TransactionBloc', 'EditTransactionEvent', 
        data: {'transactionId': event.id, 'amount': event.amount});
      
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

        AppLogger().debug('Editing transaction with ID: ${transaction.id}', 
          tag: 'TRANSACTION_BLOC');

        final result = await editTransactionUseCase(
            params: transaction); // Use edit use case

        result.fold(
          (success) {
            AppLogger().info('Transaction edited successfully', tag: 'TRANSACTION_BLOC');
            add(GetAllTransactionsEvent()); // Refresh list on success
          },
          (error) {
            AppLogger().error('Failed to edit transaction: ${error.message}', 
              tag: 'TRANSACTION_BLOC');
            emit(TransactionError(message: error.message));
          },
        );
      } catch (e) {
        AppLogger().error('Exception in EditTransactionEvent: $e', 
          tag: 'TRANSACTION_BLOC', error: e);
        emit(TransactionError(message: e.toString()));
      }
    });

    on<DeleteTransactionEvent>((event, emit) async {
      AppLogger().blocEvent('TransactionBloc', 'DeleteTransactionEvent', 
        data: {'transactionId': event.transactionId});
      
      try {
        emit(TransactionLoading());

        final result =
            await deleteTransactionUseCase(params: event.transactionId);

        result.fold(
          (success) {
            AppLogger().info('Transaction deleted successfully', tag: 'TRANSACTION_BLOC');
            add(GetAllTransactionsEvent()); // Refresh list on success
          },
          (error) {
            AppLogger().error('Failed to delete transaction: ${error.message}', 
              tag: 'TRANSACTION_BLOC');
            emit(TransactionError(message: error.message));
          },
        );
      } catch (e) {
        AppLogger().error('Exception in DeleteTransactionEvent: $e', 
          tag: 'TRANSACTION_BLOC', error: e);
        emit(TransactionError(message: e.toString()));
      }
    });
  }
}