import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_track/data/adapters/timestamp_adapter.dart';
import 'package:money_track/data/models/sync/sync_operation_model.dart';

void main() {
  group('Timestamp Sync Integration Tests', () {
    setUpAll(() async {
      // Initialize Hive for testing
      Hive.init('./test/hive_test');

      // Register the Timestamp adapter
      if (!Hive.isAdapterRegistered(20)) {
        Hive.registerAdapter(TimestampAdapter());
      }

      // Register enum adapters
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(SyncOperationTypeAdapter());
      }

      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(SyncDataTypeAdapter());
      }

      // Register SyncOperationModel adapter
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(SyncOperationModelAdapter());
      }
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
    });

    test('should queue sync operation with Firestore Timestamps without error',
        () async {
      // Arrange
      final box =
          await Hive.openBox<SyncOperationModel>('test-sync-operations');

      // Create a transaction with Firestore Timestamps
      final now = Timestamp.now();
      final transactionData = {
        'id': 'test-transaction-1',
        'amount': 100.0,
        'description': 'Test transaction',
        'createdAt': now,
        'updatedAt': now,
        'userId': 'test-user-123',
        'version': 1,
      };

      // Act - Create sync operation using the new Timestamp-safe method
      final syncOperation = SyncOperationModel.createWithTimestampConversion(
        id: 'test-sync-op-1',
        operationType: SyncOperationType.create,
        dataType: SyncDataType.transaction,
        dataId: 'test-transaction-1',
        data: transactionData,
        userId: 'test-user-123',
      );

      // This should not throw a HiveError about unknown Timestamp type
      await box.put(syncOperation.id, syncOperation);

      // Assert
      final retrievedOperation = box.get(syncOperation.id);
      expect(retrievedOperation, isNotNull);
      expect(retrievedOperation!.id, 'test-sync-op-1');
      expect(retrievedOperation.dataId, 'test-transaction-1');
      expect(retrievedOperation.userId, 'test-user-123');

      // Verify that Timestamps were converted to DateTime for storage
      expect(retrievedOperation.data['createdAt'], isA<DateTime>());
      expect(retrievedOperation.data['updatedAt'], isA<DateTime>());

      // Verify that other data is preserved
      expect(retrievedOperation.data['amount'], 100.0);
      expect(retrievedOperation.data['description'], 'Test transaction');

      await box.close();
    });

    test('should convert DateTime back to Timestamps for Firestore operations',
        () async {
      // Arrange
      final box =
          await Hive.openBox<SyncOperationModel>('test-sync-operations-2');

      final now = Timestamp.now();
      final transactionData = {
        'id': 'test-transaction-2',
        'amount': 200.0,
        'description': 'Test transaction 2',
        'createdAt': now,
        'updatedAt': now,
        'userId': 'test-user-123',
        'version': 1,
      };

      // Create and store sync operation
      final syncOperation = SyncOperationModel.createWithTimestampConversion(
        id: 'test-sync-op-2',
        operationType: SyncOperationType.create,
        dataType: SyncDataType.transaction,
        dataId: 'test-transaction-2',
        data: transactionData,
        userId: 'test-user-123',
      );

      await box.put(syncOperation.id, syncOperation);

      // Act - Retrieve and convert back for Firestore
      final retrievedOperation = box.get(syncOperation.id)!;
      final firestoreData = retrievedOperation.getDataForFirestore();

      // Assert
      expect(firestoreData['createdAt'], isA<Timestamp>());
      expect(firestoreData['updatedAt'], isA<Timestamp>());

      // Verify that the Timestamp values are correct
      final createdAtTimestamp = firestoreData['createdAt'] as Timestamp;
      expect(createdAtTimestamp.millisecondsSinceEpoch,
          now.millisecondsSinceEpoch);

      // Verify that other data is preserved
      expect(firestoreData['amount'], 200.0);
      expect(firestoreData['description'], 'Test transaction 2');

      await box.close();
    });

    test('should handle nested Timestamps in complex data structures',
        () async {
      // Arrange
      final box =
          await Hive.openBox<SyncOperationModel>('test-sync-operations-3');

      final now = Timestamp.now();
      final complexData = {
        'transaction': {
          'id': 'test-transaction-3',
          'amount': 300.0,
          'timestamps': {
            'createdAt': now,
            'updatedAt': now,
          },
          'history': [
            {'action': 'created', 'timestamp': now},
            {'action': 'updated', 'timestamp': now},
          ]
        },
        'metadata': {
          'lastSync': now,
          'version': 1,
        }
      };

      // Act
      final syncOperation = SyncOperationModel.createWithTimestampConversion(
        id: 'test-sync-op-3',
        operationType: SyncOperationType.create,
        dataType: SyncDataType.transaction,
        dataId: 'test-transaction-3',
        data: complexData,
        userId: 'test-user-123',
      );

      await box.put(syncOperation.id, syncOperation);

      // Assert - Verify storage conversion
      final retrievedOperation = box.get(syncOperation.id)!;
      final transactionData = retrievedOperation.data['transaction'] as Map;
      final timestampsData = transactionData['timestamps'] as Map;
      final historyData = transactionData['history'] as List;
      final metadataData = retrievedOperation.data['metadata'] as Map;

      expect(timestampsData['createdAt'], isA<DateTime>());
      expect(timestampsData['updatedAt'], isA<DateTime>());
      expect((historyData[0] as Map)['timestamp'], isA<DateTime>());
      expect((historyData[1] as Map)['timestamp'], isA<DateTime>());
      expect(metadataData['lastSync'], isA<DateTime>());

      // Assert - Verify Firestore conversion
      final firestoreData = retrievedOperation.getDataForFirestore();
      final firestoreTransaction = firestoreData['transaction'] as Map;
      final firestoreTimestamps = firestoreTransaction['timestamps'] as Map;
      final firestoreHistory = firestoreTransaction['history'] as List;
      final firestoreMetadata = firestoreData['metadata'] as Map;

      expect(firestoreTimestamps['createdAt'], isA<Timestamp>());
      expect(firestoreTimestamps['updatedAt'], isA<Timestamp>());
      expect((firestoreHistory[0] as Map)['timestamp'], isA<Timestamp>());
      expect((firestoreHistory[1] as Map)['timestamp'], isA<Timestamp>());
      expect(firestoreMetadata['lastSync'], isA<Timestamp>());

      await box.close();
    });

    test('should handle data without Timestamps correctly', () async {
      // Arrange
      final box =
          await Hive.openBox<SyncOperationModel>('test-sync-operations-4');

      final dataWithoutTimestamps = {
        'id': 'test-transaction-4',
        'amount': 400.0,
        'description': 'Test transaction without timestamps',
        'userId': 'test-user-123',
        'version': 1,
        'tags': ['food', 'restaurant'],
        'metadata': {
          'source': 'mobile_app',
          'category': 'dining',
        }
      };

      // Act
      final syncOperation = SyncOperationModel.createWithTimestampConversion(
        id: 'test-sync-op-4',
        operationType: SyncOperationType.create,
        dataType: SyncDataType.transaction,
        dataId: 'test-transaction-4',
        data: dataWithoutTimestamps,
        userId: 'test-user-123',
      );

      await box.put(syncOperation.id, syncOperation);

      // Assert
      final retrievedOperation = box.get(syncOperation.id)!;

      // Data should be identical since no Timestamps to convert
      expect(retrievedOperation.data, equals(dataWithoutTimestamps));

      // getDataForFirestore should return the same data
      final firestoreData = retrievedOperation.getDataForFirestore();
      expect(firestoreData, equals(dataWithoutTimestamps));

      await box.close();
    });
  });
}
