import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/data/models/firestore/category_firestore_model.dart';

/// Abstract class for category remote data source
abstract class CategoryRemoteDataSource {
  /// Get all categories for a user
  Future<List<CategoryFirestoreModel>> getAllCategories(String userId);

  /// Add a new category
  Future<String> addCategory(CategoryFirestoreModel category);

  /// Update an existing category
  Future<String> updateCategory(CategoryFirestoreModel category);

  /// Delete a category (soft delete)
  Future<void> deleteCategory(String categoryId, String userId);

  /// Get a specific category by ID
  Future<CategoryFirestoreModel?> getCategory(String categoryId, String userId);

  /// Stream of real-time category updates for a user
  Stream<List<CategoryFirestoreModel>> getCategoriesStream(String userId);

  /// Batch operations for sync
  Future<void> batchWrite(List<CategoryFirestoreModel> categories, String userId);

  /// Set default categories for a new user
  Future<void> setDefaultCategories(String userId);
}

/// Implementation of category remote data source using Firebase Firestore
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String collectionName = 'categories';

  CategoryRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<CategoryFirestoreModel>> getAllCategories(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('categoryName')
          .get();

      return querySnapshot.docs
          .map((doc) => CategoryFirestoreModel.fromFirestore(doc, null))
          .toList();
    } catch (e) {
      log(e.toString(), name: "CategoryRemoteDataSource getAllCategories");
      throw NetworkFailure(message: "Failed to get categories: ${e.toString()}");
    }
  }

  @override
  Future<String> addCategory(CategoryFirestoreModel category) async {
    try {
      await firestore
          .collection(collectionName)
          .doc(category.id)
          .set(category.toFirestore());

      return "success";
    } catch (e) {
      log(e.toString(), name: "CategoryRemoteDataSource addCategory");
      throw NetworkFailure(message: "Failed to add category: ${e.toString()}");
    }
  }

  @override
  Future<String> updateCategory(CategoryFirestoreModel category) async {
    try {
      final updatedCategory = category.copyWith(
        updatedAt: DateTime.now(),
        version: category.version + 1,
      );

      await firestore
          .collection(collectionName)
          .doc(category.id)
          .update(updatedCategory.toFirestore());

      return "success";
    } catch (e) {
      log(e.toString(), name: "CategoryRemoteDataSource updateCategory");
      throw NetworkFailure(message: "Failed to update category: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteCategory(String categoryId, String userId) async {
    try {
      // Soft delete by setting isDeleted to true
      await firestore
          .collection(collectionName)
          .doc(categoryId)
          .update({
        'isDeleted': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      log(e.toString(), name: "CategoryRemoteDataSource deleteCategory");
      throw NetworkFailure(message: "Failed to delete category: ${e.toString()}");
    }
  }

  @override
  Future<CategoryFirestoreModel?> getCategory(String categoryId, String userId) async {
    try {
      final docSnapshot = await firestore
          .collection(collectionName)
          .doc(categoryId)
          .get();

      if (!docSnapshot.exists) {
        return null;
      }

      final category = CategoryFirestoreModel.fromFirestore(docSnapshot, null);
      
      // Verify the category belongs to the user
      if (category.userId != userId) {
        throw NetworkFailure(message: "Unauthorized access to category");
      }

      return category;
    } catch (e) {
      log(e.toString(), name: "CategoryRemoteDataSource getCategory");
      if (e is NetworkFailure) rethrow;
      throw NetworkFailure(message: "Failed to get category: ${e.toString()}");
    }
  }

  @override
  Stream<List<CategoryFirestoreModel>> getCategoriesStream(String userId) {
    try {
      return firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => CategoryFirestoreModel.fromFirestore(doc, null))
            .toList();
      });
    } catch (e) {
      log(e.toString(), name: "CategoryRemoteDataSource getCategoriesStream");
      throw NetworkFailure(message: "Failed to get categories stream: ${e.toString()}");
    }
  }

  @override
  Future<void> batchWrite(List<CategoryFirestoreModel> categories, String userId) async {
    try {
      final batch = firestore.batch();

      for (final category in categories) {
        // Verify the category belongs to the user
        if (category.userId != userId) {
          throw NetworkFailure(message: "Unauthorized batch operation");
        }

        final docRef = firestore.collection(collectionName).doc(category.id);
        batch.set(docRef, category.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      log(e.toString(), name: "CategoryRemoteDataSource batchWrite");
      if (e is NetworkFailure) rethrow;
      throw NetworkFailure(message: "Failed to batch write categories: ${e.toString()}");
    }
  }

  @override
  Future<void> setDefaultCategories(String userId) async {
    try {
      // Check if user already has categories
      final existingCategories = await getAllCategories(userId);
      if (existingCategories.isNotEmpty) {
        return; // User already has categories
      }

      // Create default categories
      final defaultCategories = _getDefaultCategories(userId);
      await batchWrite(defaultCategories, userId);
    } catch (e) {
      log(e.toString(), name: "CategoryRemoteDataSource setDefaultCategories");
      throw NetworkFailure(message: "Failed to set default categories: ${e.toString()}");
    }
  }

  /// Get default categories for a new user
  List<CategoryFirestoreModel> _getDefaultCategories(String userId) {
    final now = DateTime.now();
    
    return [
      CategoryFirestoreModel(
        id: '${DateTime.now().microsecondsSinceEpoch}_salary',
        categoryName: 'Salary',
        categoryType: 'salary',
        type: 'income',
        userId: userId,
        createdAt: now,
        updatedAt: now,
        version: 1,
      ),
      CategoryFirestoreModel(
        id: '${DateTime.now().microsecondsSinceEpoch + 1}_food',
        categoryName: 'Food',
        categoryType: 'food',
        type: 'expense',
        userId: userId,
        createdAt: now,
        updatedAt: now,
        version: 1,
      ),
      CategoryFirestoreModel(
        id: '${DateTime.now().microsecondsSinceEpoch + 2}_transportation',
        categoryName: 'Transportation',
        categoryType: 'transportation',
        type: 'expense',
        userId: userId,
        createdAt: now,
        updatedAt: now,
        version: 1,
      ),
      CategoryFirestoreModel(
        id: '${DateTime.now().microsecondsSinceEpoch + 3}_shopping',
        categoryName: 'Shopping',
        categoryType: 'shopping',
        type: 'expense',
        userId: userId,
        createdAt: now,
        updatedAt: now,
        version: 1,
      ),
      CategoryFirestoreModel(
        id: '${DateTime.now().microsecondsSinceEpoch + 4}_subscription',
        categoryName: 'Subscription',
        categoryType: 'subscription',
        type: 'expense',
        userId: userId,
        createdAt: now,
        updatedAt: now,
        version: 1,
      ),
      CategoryFirestoreModel(
        id: '${DateTime.now().microsecondsSinceEpoch + 5}_other',
        categoryName: 'Other',
        categoryType: 'other',
        type: 'expense',
        userId: userId,
        createdAt: now,
        updatedAt: now,
        version: 1,
      ),
    ];
  }
}
