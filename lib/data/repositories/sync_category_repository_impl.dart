import 'dart:developer';
import 'package:money_track/core/error/failures.dart';
import 'package:money_track/core/error/result.dart';
import 'package:money_track/core/services/sync_service.dart';
import 'package:money_track/data/datasources/local/category_local_datasource.dart';
import 'package:money_track/data/models/category_model.dart' as model;
import 'package:money_track/data/models/firestore/category_firestore_model.dart';
import 'package:money_track/data/models/sync/sync_operation_model.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/repositories/category_repository.dart';

/// Enhanced category repository with sync capabilities
class SyncCategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;
  final SyncService syncService;

  SyncCategoryRepositoryImpl({
    required this.localDataSource,
    required this.syncService,
  });

  @override
  Future<Result<List<CategoryEntity>>> getAllCategories() async {
    try {
      final categoryModels = await localDataSource.getAllCategories();
      final categories =
          categoryModels.map((model) => model.toEntity()).toList();
      return Success(categories);
    } catch (e) {
      log('Error getting all categories: $e', name: 'SyncCategoryRepository');
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<String>> addCategory(CategoryEntity category) async {
    try {
      // Add to local storage first
      final categoryModel = model.CategoryModel.fromEntity(category);
      final result = await localDataSource.addCategory(categoryModel);

      // Queue sync operation
      await _queueSyncOperation(
        SyncOperationType.create,
        category.id,
        categoryModel,
      );

      return Success(result);
    } catch (e) {
      log('Error adding category: $e', name: 'SyncCategoryRepository');
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteCategory(String categoryId) async {
    try {
      // Delete from local storage first (soft delete)
      await localDataSource.deleteCategory(categoryId);

      // Queue sync operation
      await _queueDeleteSyncOperation(categoryId);

      return const Success(null);
    } catch (e) {
      log('Error deleting category: $e', name: 'SyncCategoryRepository');
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> setDefaultCategories() async {
    try {
      // Set default categories locally
      await localDataSource.setDefaultCategories();

      // Queue sync operations for each default category
      await _queueDefaultCategoriesSync();

      return const Success(null);
    } catch (e) {
      log('Error setting default categories: $e',
          name: 'SyncCategoryRepository');
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  /// Update a category (new method for sync-enabled repository)
  Future<Result<String>> updateCategory(CategoryEntity category) async {
    try {
      // Update local storage first
      final categoryModel = model.CategoryModel.fromEntity(category);
      final result = await localDataSource
          .addCategory(categoryModel); // addCategory handles updates too

      // Queue sync operation
      await _queueSyncOperation(
        SyncOperationType.update,
        category.id,
        categoryModel,
      );

      return Success(result);
    } catch (e) {
      log('Error updating category: $e', name: 'SyncCategoryRepository');
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  /// Queue a sync operation for create/update
  Future<void> _queueSyncOperation(
    SyncOperationType operationType,
    String categoryId,
    model.CategoryModel categoryModel,
  ) async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId();
      if (userId == null) {
        log('No user logged in, skipping sync operation',
            name: 'SyncCategoryRepository');
        return;
      }

      // Convert to Firestore model
      final firestoreModel =
          CategoryFirestoreModel.fromHiveModel(categoryModel, userId);

      // Create sync operation with Timestamp conversion
      final syncOperation = SyncOperationModel.createWithTimestampConversion(
        id: '${DateTime.now().microsecondsSinceEpoch}_${operationType.name}_$categoryId',
        operationType: operationType,
        dataType: SyncDataType.category,
        dataId: categoryId,
        data: firestoreModel.toFirestore(),
        createdAt: DateTime.now(),
        userId: userId,
      );

      await syncService.queueSyncOperation(syncOperation);
    } catch (e) {
      log('Error queuing sync operation: $e', name: 'SyncCategoryRepository');
      // Don't throw error here as local operation succeeded
    }
  }

  /// Queue a sync operation for delete
  Future<void> _queueDeleteSyncOperation(String categoryId) async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId();
      if (userId == null) {
        log('No user logged in, skipping sync operation',
            name: 'SyncCategoryRepository');
        return;
      }

      // Create sync operation
      final syncOperation = SyncOperationModel.delete(
        id: '${DateTime.now().microsecondsSinceEpoch}_delete_$categoryId',
        dataType: SyncDataType.category,
        dataId: categoryId,
        userId: userId,
      );

      await syncService.queueSyncOperation(syncOperation);
    } catch (e) {
      log('Error queuing delete sync operation: $e',
          name: 'SyncCategoryRepository');
      // Don't throw error here as local operation succeeded
    }
  }

  /// Queue sync operations for default categories
  Future<void> _queueDefaultCategoriesSync() async {
    try {
      final categories = await localDataSource.getAllCategories();
      for (final category in categories) {
        await _queueSyncOperation(
          SyncOperationType.create,
          category.id,
          category,
        );
      }
    } catch (e) {
      log('Error queuing default categories sync: $e',
          name: 'SyncCategoryRepository');
    }
  }

  /// Get current user ID from auth service
  /// TODO: This should be injected or obtained from a proper auth service
  Future<String?> _getCurrentUserId() async {
    // For now, return a placeholder
    // In a real implementation, this would come from the auth service
    return 'current_user_id'; // TODO: Replace with actual user ID
  }

  /// Batch add categories (useful for initial sync)
  Future<Result<void>> batchAddCategories(
      List<CategoryEntity> categories) async {
    try {
      for (final category in categories) {
        final categoryModel = model.CategoryModel.fromEntity(category);
        await localDataSource.addCategory(categoryModel);
      }
      return const Success(null);
    } catch (e) {
      log('Error batch adding categories: $e', name: 'SyncCategoryRepository');
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  /// Get categories by type
  Future<Result<List<CategoryEntity>>> getCategoriesByType(
      model.TransactionType type) async {
    try {
      final allCategories = await localDataSource.getAllCategories();
      final filteredCategories = allCategories
          .where((category) => category.type == type && !category.isDeleted)
          .map((model) => model.toEntity())
          .toList();

      return Success(filteredCategories);
    } catch (e) {
      log('Error getting categories by type: $e',
          name: 'SyncCategoryRepository');
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  /// Get active categories (not deleted)
  Future<Result<List<CategoryEntity>>> getActiveCategories() async {
    try {
      final allCategories = await localDataSource.getAllCategories();
      final activeCategories = allCategories
          .where((category) => !category.isDeleted)
          .map((model) => model.toEntity())
          .toList();

      return Success(activeCategories);
    } catch (e) {
      log('Error getting active categories: $e',
          name: 'SyncCategoryRepository');
      return Error(DatabaseFailure(message: e.toString()));
    }
  }

  /// Get sync status for categories
  Future<Map<String, dynamic>> getSyncStatus() async {
    return await syncService.getSyncStats();
  }

  /// Force sync categories
  Future<Result<void>> forceSync() async {
    try {
      final result = await syncService.forceSyncNow();
      if (result.success) {
        return const Success(null);
      } else {
        return Error(NetworkFailure(message: result.error ?? 'Sync failed'));
      }
    } catch (e) {
      log('Error forcing sync: $e', name: 'SyncCategoryRepository');
      return Error(NetworkFailure(message: e.toString()));
    }
  }
}
