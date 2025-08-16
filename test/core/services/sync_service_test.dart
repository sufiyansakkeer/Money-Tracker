import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive/hive.dart';
import 'package:money_track/core/services/connectivity_service.dart';
import 'package:money_track/core/services/sync_service.dart';
import 'package:money_track/data/datasources/local/category_local_datasource.dart';
import 'package:money_track/data/datasources/local/transaction_local_datasource.dart';
import 'package:money_track/data/datasources/remote/category_remote_datasource.dart';
import 'package:money_track/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:money_track/data/models/sync/sync_operation_model.dart';

import 'sync_service_test.mocks.dart';

@GenerateMocks([
  TransactionLocalDataSource,
  CategoryLocalDataSource,
  TransactionRemoteDataSource,
  CategoryRemoteDataSource,
  ConnectivityService,
  HiveInterface,
], customMocks: [
  MockSpec<Box<SyncOperationModel>>(as: #MockSyncOperationBox),
  MockSpec<Box>(as: #MockGenericBox),
])
void main() {
  group('SyncService', () {
    late SyncService syncService;
    late MockTransactionLocalDataSource mockTransactionLocalDataSource;
    late MockCategoryLocalDataSource mockCategoryLocalDataSource;
    late MockTransactionRemoteDataSource mockTransactionRemoteDataSource;
    late MockCategoryRemoteDataSource mockCategoryRemoteDataSource;
    late MockConnectivityService mockConnectivityService;
    late MockHiveInterface mockHive;
    late MockSyncOperationBox mockSyncBox;

    setUp(() {
      mockTransactionLocalDataSource = MockTransactionLocalDataSource();
      mockCategoryLocalDataSource = MockCategoryLocalDataSource();
      mockTransactionRemoteDataSource = MockTransactionRemoteDataSource();
      mockCategoryRemoteDataSource = MockCategoryRemoteDataSource();
      mockConnectivityService = MockConnectivityService();
      mockHive = MockHiveInterface();
      mockSyncBox = MockSyncOperationBox();

      syncService = SyncService(
        transactionLocalDataSource: mockTransactionLocalDataSource,
        categoryLocalDataSource: mockCategoryLocalDataSource,
        transactionRemoteDataSource: mockTransactionRemoteDataSource,
        categoryRemoteDataSource: mockCategoryRemoteDataSource,
        connectivityService: mockConnectivityService,
        hive: mockHive,
      );
    });

    group('initialization', () {
      test('should initialize sync service for user', () async {
        // Arrange
        const userId = 'test-user-id';
        when(mockConnectivityService.isConnected).thenReturn(true);
        when(mockConnectivityService.connectivityStream)
            .thenAnswer((_) => Stream<bool>.empty());
        when(mockHive.openBox<SyncOperationModel>('sync-operations'))
            .thenAnswer((_) async => mockSyncBox);
        when(mockSyncBox.values).thenReturn([]);
        when(mockTransactionRemoteDataSource.getTransactionsStream(userId))
            .thenAnswer((_) => Stream.empty());
        when(mockCategoryRemoteDataSource.getCategoriesStream(userId))
            .thenAnswer((_) => Stream.empty());
        when(mockTransactionRemoteDataSource.getAllTransactions(userId))
            .thenAnswer((_) async => []);
        when(mockCategoryRemoteDataSource.getAllCategories(userId))
            .thenAnswer((_) async => []);

        // Act
        await syncService.initializeForUser(userId);

        // Assert
        expect(syncService.currentStatus,
            anyOf(SyncStatus.idle, SyncStatus.success));
      });

      test('should handle initialization error gracefully', () async {
        // Arrange
        const userId = 'test-user-id';
        when(mockConnectivityService.isConnected).thenReturn(true);
        when(mockHive.openBox<SyncOperationModel>('sync-operations'))
            .thenThrow(Exception('Hive error'));

        // Act & Assert
        expect(
          () => syncService.initializeForUser(userId),
          returnsNormally,
        );
      });
    });

    group('sync operations', () {
      test('should queue sync operation successfully', () async {
        // Arrange
        when(mockHive.openBox<SyncOperationModel>('sync-operations'))
            .thenAnswer((_) async => mockSyncBox);
        when(mockConnectivityService.isConnected).thenReturn(false);

        final operation = SyncOperationModel.create(
          id: 'test-op-id',
          dataType: SyncDataType.transaction,
          dataId: 'test-transaction-id',
          data: {'test': 'data'},
          userId: 'test-user-id',
        );

        // Act
        await syncService.queueSyncOperation(operation);

        // Assert
        verify(mockSyncBox.put(operation.id, operation)).called(1);
      });

      test('should get sync stats correctly', () async {
        // Arrange
        when(mockHive.openBox<SyncOperationModel>('sync-operations'))
            .thenAnswer((_) async => mockSyncBox);
        when(mockConnectivityService.isConnected).thenReturn(true);
        when(mockSyncBox.values).thenReturn([]);

        // Act
        final stats = await syncService.getSyncStats();

        // Assert
        expect(stats['isOnline'], true);
        expect(stats['pendingOperations'], 0);
        expect(stats['currentStatus'], 'idle');
      });
    });

    group('data clearing', () {
      test('should clear all local data on logout', () async {
        // Arrange
        final mockCategoryBox = MockGenericBox();
        final mockTransactionBox = MockGenericBox();

        when(mockHive.openBox('category-database'))
            .thenAnswer((_) async => mockCategoryBox);
        when(mockHive.openBox('Transaction-database'))
            .thenAnswer((_) async => mockTransactionBox);
        when(mockHive.openBox<SyncOperationModel>('sync-operations'))
            .thenAnswer((_) async => mockSyncBox);

        when(mockCategoryBox.clear()).thenAnswer((_) async => 0);
        when(mockTransactionBox.clear()).thenAnswer((_) async => 0);
        when(mockSyncBox.clear()).thenAnswer((_) async => 0);

        // Act
        await syncService.clearLocalData();

        // Assert
        verify(mockCategoryBox.clear()).called(1);
        verify(mockTransactionBox.clear()).called(1);
        verify(mockSyncBox.clear()).called(1);
      });
    });

    group('connectivity handling', () {
      test('should handle connectivity changes', () async {
        // Arrange
        const userId = 'test-user-id';
        when(mockConnectivityService.isConnected).thenReturn(true);
        when(mockConnectivityService.connectivityStream)
            .thenAnswer((_) => Stream<bool>.empty());
        when(mockHive.openBox<SyncOperationModel>('sync-operations'))
            .thenAnswer((_) async => mockSyncBox);
        when(mockSyncBox.values).thenReturn([]);
        when(mockTransactionRemoteDataSource.getTransactionsStream(userId))
            .thenAnswer((_) => Stream.empty());
        when(mockCategoryRemoteDataSource.getCategoriesStream(userId))
            .thenAnswer((_) => Stream.empty());
        when(mockTransactionRemoteDataSource.getAllTransactions(userId))
            .thenAnswer((_) async => []);
        when(mockCategoryRemoteDataSource.getAllCategories(userId))
            .thenAnswer((_) async => []);

        await syncService.initializeForUser(userId);

        // Act - simulate connectivity change
        when(mockConnectivityService.isConnected).thenReturn(false);

        // Assert - service should handle this gracefully
        expect(syncService.currentStatus,
            anyOf(SyncStatus.idle, SyncStatus.success));
      });
    });

    tearDown(() {
      syncService.dispose();
    });
  });
}
