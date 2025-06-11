// import 'package:bloc_test/bloc_test.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:money_track/core/error/failures.dart';
// import 'package:money_track/core/error/result.dart';
// import 'package:money_track/domain/entities/category_entity.dart';
// import 'package:money_track/domain/entities/transaction_entity.dart';
// import 'package:money_track/domain/usecases/transaction/get_all_transactions_usecase.dart';
// import 'package:money_track/features/transactions/presentation/bloc/total_transaction/total_transaction_cubit.dart';

// import 'total_transaction_cubit_test.mocks.dart';

// @GenerateMocks([GetAllTransactionsUseCase])
// void main() {
//   group('TotalTransactionCubit', () {
//     late TotalTransactionCubit cubit;
//     late MockGetAllTransactionsUseCase mockGetAllTransactionsUseCase;

//     setUp(() {
//       mockGetAllTransactionsUseCase = MockGetAllTransactionsUseCase();
//       cubit = TotalTransactionCubit(
//         getAllTransactionsUseCase: mockGetAllTransactionsUseCase,
//       );
//     });

//     tearDown(() {
//       cubit.close();
//     });

//     test('initial state should be TotalTransactionInitial', () {
//       expect(cubit.state, equals(const TotalTransactionInitial()));
//     });

//     group('calculateTotalAmounts', () {
//       final tTransactions = [
//         TransactionEntity(
//           id: '1',
//           title: 'Income 1',
//           amount: 1000.0,
//           date: DateTime.now(),
//           transactionType: TransactionType.income,
//           category: CategoryEntity(
//             id: '1',
//             name: 'Salary',
//             icon: 'salary_icon',
//             color: 0xFF4CAF50,
//             type: TransactionType.income,
//           ),
//         ),
//         TransactionEntity(
//           id: '2',
//           title: 'Expense 1',
//           amount: 500.0,
//           date: DateTime.now(),
//           transactionType: TransactionType.expense,
//           category: CategoryEntity(
//             id: '2',
//             name: 'Food',
//             icon: 'food_icon',
//             color: 0xFFF44336,
//             type: TransactionType.expense,
//           ),
//         ),
//         TransactionEntity(
//           id: '3',
//           title: 'Income 2',
//           amount: 2000.0,
//           date: DateTime.now(),
//           transactionType: TransactionType.income,
//           category: CategoryEntity(
//             id: '1',
//             name: 'Salary',
//             icon: 'salary_icon',
//             color: 0xFF4CAF50,
//             type: TransactionType.income,
//           ),
//         ),
//       ];

//       blocTest<TotalTransactionCubit, TotalTransactionState>(
//         'emits [loading, success] when calculateTotalAmounts is called successfully',
//         build: () {
//           when(mockGetAllTransactionsUseCase.call())
//               .thenAnswer((_) async => Success(tTransactions));
//           return cubit;
//         },
//         act: (cubit) => cubit.calculateTotalAmounts(),
//         expect: () => [
//           const TotalTransactionLoading(),
//           const TotalTransactionSuccess(
//             totalIncome: 3000.0,
//             totalExpense: 500.0,
//             balance: 2500.0,
//             transactionCount: 3,
//           ),
//         ],
//         verify: (_) {
//           verify(mockGetAllTransactionsUseCase.call()).called(1);
//         },
//       );

//       blocTest<TotalTransactionCubit, TotalTransactionState>(
//         'emits [loading, error] when calculateTotalAmounts fails',
//         build: () {
//           when(mockGetAllTransactionsUseCase.call())
//               .thenAnswer((_) async => const Error(
//                     DatabaseFailure(message: 'Database error'),
//                   ));
//           return cubit;
//         },
//         act: (cubit) => cubit.calculateTotalAmounts(),
//         expect: () => [
//           const TotalTransactionLoading(),
//           const TotalTransactionError(
//             failure: DatabaseFailure(message: 'Database error'),
//           ),
//         ],
//         verify: (_) {
//           verify(mockGetAllTransactionsUseCase.call()).called(1);
//         },
//       );

//       blocTest<TotalTransactionCubit, TotalTransactionState>(
//         'emits [loading, error] when calculateTotalAmounts throws exception',
//         build: () {
//           when(mockGetAllTransactionsUseCase.call())
//               .thenThrow(Exception('Unexpected error'));
//           return cubit;
//         },
//         act: (cubit) => cubit.calculateTotalAmounts(),
//         expect: () => [
//           const TotalTransactionLoading(),
//           isA<TotalTransactionError>()
//               .having((state) => state.failure, 'failure', isA<DatabaseFailure>())
//               .having((state) => state.failure.message, 'message',
//                   contains('Unexpected error')),
//         ],
//         verify: (_) {
//           verify(mockGetAllTransactionsUseCase.call()).called(1);
//         },
//       );

//       blocTest<TotalTransactionCubit, TotalTransactionState>(
//         'does not emit new loading state when already loading',
//         build: () {
//           when(mockGetAllTransactionsUseCase.call())
//               .thenAnswer((_) async => Success(tTransactions));
//           return cubit;
//         },
//         seed: () => const TotalTransactionLoading(),
//         act: (cubit) => cubit.calculateTotalAmounts(),
//         expect: () => [],
//         verify: (_) {
//           verifyNever(mockGetAllTransactionsUseCase.call());
//         },
//       );

//       blocTest<TotalTransactionCubit, TotalTransactionState>(
//         'calculates correct totals with only income transactions',
//         build: () {
//           final incomeOnlyTransactions = [
//             TransactionEntity(
//               id: '1',
//               title: 'Income 1',
//               amount: 1000.0,
//               date: DateTime.now(),
//               transactionType: TransactionType.income,
//               category: CategoryEntity(
//                 id: '1',
//                 name: 'Salary',
//                 icon: 'salary_icon',
//                 color: 0xFF4CAF50,
//                 type: TransactionType.income,
//               ),
//             ),
//             TransactionEntity(
//               id: '2',
//               title: 'Income 2',
//               amount: 500.0,
//               date: DateTime.now(),
//               transactionType: TransactionType.income,
//               category: CategoryEntity(
//                 id: '1',
//                 name: 'Salary',
//                 icon: 'salary_icon',
//                 color: 0xFF4CAF50,
//                 type: TransactionType.income,
//               ),
//             ),
//           ];
//           when(mockGetAllTransactionsUseCase.call())
//               .thenAnswer((_) async => Success(incomeOnlyTransactions));
//           return cubit;
//         },
//         act: (cubit) => cubit.calculateTotalAmounts(),
//         expect: () => [
//           const TotalTransactionLoading(),
//           const TotalTransactionSuccess(
//             totalIncome: 1500.0,
//             totalExpense: 0.0,
//             balance: 1500.0,
//             transactionCount: 2,
//           ),
//         ],
//       );

//       blocTest<TotalTransactionCubit, TotalTransactionState>(
//         'calculates correct totals with empty transaction list',
//         build: () {
//           when(mockGetAllTransactionsUseCase.call())
//               .thenAnswer((_) async => const Success([]));
//           return cubit;
//         },
//         act: (cubit) => cubit.calculateTotalAmounts(),
//         expect: () => [
//           const TotalTransactionLoading(),
//           const TotalTransactionSuccess(
//             totalIncome: 0.0,
//             totalExpense: 0.0,
//             balance: 0.0,
//             transactionCount: 0,
//           ),
//         ],
//       );
//     });

//     group('refreshTotals', () {
//       blocTest<TotalTransactionCubit, TotalTransactionState>(
//         'calls calculateTotalAmounts when refreshTotals is called',
//         build: () {
//           when(mockGetAllTransactionsUseCase.call())
//               .thenAnswer((_) async => const Success([]));
//           return cubit;
//         },
//         act: (cubit) => cubit.refreshTotals(),
//         expect: () => [
//           const TotalTransactionLoading(),
//           const TotalTransactionSuccess(
//             totalIncome: 0.0,
//             totalExpense: 0.0,
//             balance: 0.0,
//             transactionCount: 0,
//           ),
//         ],
//         verify: (_) {
//           verify(mockGetAllTransactionsUseCase.call()).called(1);
//         },
//       );
//     });

//     group('reset', () {
//       blocTest<TotalTransactionCubit, TotalTransactionState>(
//         'emits initial state when reset is called',
//         build: () => cubit,
//         seed: () => const TotalTransactionSuccess(
//           totalIncome: 1000.0,
//           totalExpense: 500.0,
//           balance: 500.0,
//           transactionCount: 2,
//         ),
//         act: (cubit) => cubit.reset(),
//         expect: () => [const TotalTransactionInitial()],
//       );
//     });
//   });

//   group('TotalTransactionSuccess', () {
//     test('copyWith should return new instance with updated values', () {
//       const original = TotalTransactionSuccess(
//         totalIncome: 1000.0,
//         totalExpense: 500.0,
//         balance: 500.0,
//         transactionCount: 2,
//       );

//       final updated = original.copyWith(
//         totalIncome: 2000.0,
//         transactionCount: 3,
//       );

//       expect(updated.totalIncome, equals(2000.0));
//       expect(updated.totalExpense, equals(500.0)); // unchanged
//       expect(updated.balance, equals(500.0)); // unchanged
//       expect(updated.transactionCount, equals(3));
//     });

//     test('props should contain all properties', () {
//       const state = TotalTransactionSuccess(
//         totalIncome: 1000.0,
//         totalExpense: 500.0,
//         balance: 500.0,
//         transactionCount: 2,
//       );

//       expect(state.props, equals([1000.0, 500.0, 500.0, 2]));
//     });
//   });

//   group('TotalTransactionError', () {
//     test('userMessage should return appropriate message for DatabaseFailure', () {
//       const state = TotalTransactionError(
//         failure: DatabaseFailure(message: 'Database error'),
//       );

//       expect(state.userMessage, equals('Unable to load transaction data. Please try again.'));
//     });

//     test('userMessage should return appropriate message for ValidationFailure', () {
//       const state = TotalTransactionError(
//         failure: ValidationFailure(message: 'Invalid data'),
//       );

//       expect(state.userMessage, equals('Invalid transaction data detected.'));
//     });

//     test('userMessage should return generic message for unknown failure', () {
//       const state = TotalTransactionError(
//         failure: ServerFailure(message: 'Server error'),
//       );

//       expect(state.userMessage, equals('Something went wrong. Please try again.'));
//     });
//   });
// }
