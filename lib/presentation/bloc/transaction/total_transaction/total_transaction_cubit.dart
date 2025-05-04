// import 'dart:developer';

// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:money_track/models/categories_model/category_model.dart';
// import 'package:money_track/models/transaction_model/transaction_model.dart';
// import 'package:money_track/repository/transaction_repository.dart';

// part 'total_transaction_state.dart';

// class TotalTransactionCubit extends Cubit<TotalTransactionState> {
//   TotalTransactionCubit() : super(TotalTransactionInitial());

//   getTotalAmount() async {
//     double income = 0;
//     double expense = 0;
//     List<TransactionModel>? transactionList =
//         await TransactionRepository().getAllTransaction();
//     if (transactionList != null) {
//       for (var transaction in transactionList) {
//         if (transaction.transactionType == TransactionType.expense) {
//           expense = expense + transaction.amount;
//         } else {
//           income = income + transaction.amount;
//         }
//       }
//       log(income.toString(), name: "total income");
//       emit(TotalTransactionSuccess(totalIncome: income, totalExpense: expense));
//     }
//   }
// }
