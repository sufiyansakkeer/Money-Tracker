import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/models/transaction_model/transaction_model.dart';
import 'package:money_track/repository/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(TransactionInitial()) {
    on<GetAllTransaction>((event, emit) async {
      emit(TransactionLoading());
      List<TransactionModel>? res =
          await TransactionRepository().getAllTransaction();
      if (res != null) {
        emit(TransactionLoaded(transactionList: res));
      } else {
        emit(TransactionError());
      }
    });
  }
}
