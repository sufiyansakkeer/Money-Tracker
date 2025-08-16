import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/data/models/firestore/transaction_firestore_model.dart';

/// Abstract class for transaction remote data source
abstract class TransactionRemoteDataSource {
  /// Get all transactions for a user
  Future<List<TransactionFirestoreModel>> getAllTransactions(String userId);

  /// Add a new transaction
  Future<String> addTransaction(TransactionFirestoreModel transaction);

  /// Update an existing transaction
  Future<String> updateTransaction(TransactionFirestoreModel transaction);

  /// Delete a transaction
  Future<void> deleteTransaction(String transactionId, String userId);

  /// Get a specific transaction by ID
  Future<TransactionFirestoreModel?> getTransaction(String transactionId, String userId);

  /// Stream of real-time transaction updates for a user
  Stream<List<TransactionFirestoreModel>> getTransactionsStream(String userId);

  /// Batch operations for sync
  Future<void> batchWrite(List<TransactionFirestoreModel> transactions, String userId);
}

/// Implementation of transaction remote data source using Firebase Firestore
class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String collectionName = 'transactions';

  TransactionRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<TransactionFirestoreModel>> getAllTransactions(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionFirestoreModel.fromFirestore(doc, null))
          .toList();
    } catch (e) {
      log(e.toString(), name: "TransactionRemoteDataSource getAllTransactions");
      throw NetworkFailure(message: "Failed to get transactions: ${e.toString()}");
    }
  }

  @override
  Future<String> addTransaction(TransactionFirestoreModel transaction) async {
    try {
      await firestore
          .collection(collectionName)
          .doc(transaction.id)
          .set(transaction.toFirestore());

      return "success";
    } catch (e) {
      log(e.toString(), name: "TransactionRemoteDataSource addTransaction");
      throw NetworkFailure(message: "Failed to add transaction: ${e.toString()}");
    }
  }

  @override
  Future<String> updateTransaction(TransactionFirestoreModel transaction) async {
    try {
      final updatedTransaction = transaction.copyWith(
        updatedAt: DateTime.now(),
        version: transaction.version + 1,
      );

      await firestore
          .collection(collectionName)
          .doc(transaction.id)
          .update(updatedTransaction.toFirestore());

      return "success";
    } catch (e) {
      log(e.toString(), name: "TransactionRemoteDataSource updateTransaction");
      throw NetworkFailure(message: "Failed to update transaction: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId, String userId) async {
    try {
      await firestore
          .collection(collectionName)
          .doc(transactionId)
          .delete();
    } catch (e) {
      log(e.toString(), name: "TransactionRemoteDataSource deleteTransaction");
      throw NetworkFailure(message: "Failed to delete transaction: ${e.toString()}");
    }
  }

  @override
  Future<TransactionFirestoreModel?> getTransaction(String transactionId, String userId) async {
    try {
      final docSnapshot = await firestore
          .collection(collectionName)
          .doc(transactionId)
          .get();

      if (!docSnapshot.exists) {
        return null;
      }

      final transaction = TransactionFirestoreModel.fromFirestore(docSnapshot, null);
      
      // Verify the transaction belongs to the user
      if (transaction.userId != userId) {
        throw NetworkFailure(message: "Unauthorized access to transaction");
      }

      return transaction;
    } catch (e) {
      log(e.toString(), name: "TransactionRemoteDataSource getTransaction");
      if (e is NetworkFailure) rethrow;
      throw NetworkFailure(message: "Failed to get transaction: ${e.toString()}");
    }
  }

  @override
  Stream<List<TransactionFirestoreModel>> getTransactionsStream(String userId) {
    try {
      return firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => TransactionFirestoreModel.fromFirestore(doc, null))
            .toList();
      });
    } catch (e) {
      log(e.toString(), name: "TransactionRemoteDataSource getTransactionsStream");
      throw NetworkFailure(message: "Failed to get transactions stream: ${e.toString()}");
    }
  }

  @override
  Future<void> batchWrite(List<TransactionFirestoreModel> transactions, String userId) async {
    try {
      final batch = firestore.batch();

      for (final transaction in transactions) {
        // Verify the transaction belongs to the user
        if (transaction.userId != userId) {
          throw NetworkFailure(message: "Unauthorized batch operation");
        }

        final docRef = firestore.collection(collectionName).doc(transaction.id);
        batch.set(docRef, transaction.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      log(e.toString(), name: "TransactionRemoteDataSource batchWrite");
      if (e is NetworkFailure) rethrow;
      throw NetworkFailure(message: "Failed to batch write transactions: ${e.toString()}");
    }
  }
}
