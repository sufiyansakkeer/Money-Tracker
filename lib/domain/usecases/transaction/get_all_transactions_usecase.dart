import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/logging/app_logger.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/domain/entities/transaction_entity.dart';
import 'package:money_track/domain/repositories/transaction_repository.dart';

/// Use case for getting all transactions
class GetAllTransactionsUseCase
    implements UseCase<Result<List<TransactionEntity>>, NoParams> {
  final TransactionRepository repository;

  GetAllTransactionsUseCase(this.repository) {
    AppLogger().debug('GetAllTransactionsUseCase initialized', tag: 'GET_ALL_TRANSACTIONS_USECASE');
  }

  @override
  Future<Result<List<TransactionEntity>>> call({NoParams? params}) async {
    final stopwatch = Stopwatch()..start();
    AppLogger().debug('Executing GetAllTransactionsUseCase', tag: 'GET_ALL_TRANSACTIONS_USECASE');
    
    try {
      final result = await repository.getAllTransactions();
      stopwatch.stop();
      
      result.fold(
        (transactions) {
          AppLogger().performance(
            'GetAllTransactionsUseCase execution',
            stopwatch.elapsed,
            metrics: {
              'success': true,
              'transactionCount': transactions.length
            }
          );
        },
        (failure) {
          AppLogger().performance(
            'GetAllTransactionsUseCase execution (failed)',
            stopwatch.elapsed,
            metrics: {'success': false, 'error': failure.message}
          );
        },
      );
      
      return result;
    } catch (e) {
      stopwatch.stop();
      AppLogger().error('Exception in GetAllTransactionsUseCase: $e', 
        tag: 'GET_ALL_TRANSACTIONS_USECASE', error: e);
      AppLogger().performance(
        'GetAllTransactionsUseCase execution (exception)',
        stopwatch.elapsed,
        metrics: {'success': false, 'error': e.toString()}
      );
      rethrow;
    }
  }
}