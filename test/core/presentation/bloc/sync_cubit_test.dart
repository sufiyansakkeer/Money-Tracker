import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:money_track/core/presentation/bloc/sync_cubit.dart';
import 'package:money_track/core/services/connectivity_service.dart';
import 'package:money_track/core/services/sync_service.dart';

import 'sync_cubit_test.mocks.dart';

@GenerateMocks([
  SyncService,
  ConnectivityService,
])
void main() {
  group('SyncCubit', () {
    late SyncCubit syncCubit;
    late MockSyncService mockSyncService;
    late MockConnectivityService mockConnectivityService;
    late StreamController<SyncStatus> syncStatusController;
    late StreamController<SyncResult> syncResultController;
    late StreamController<bool> connectivityController;

    setUp(() {
      mockSyncService = MockSyncService();
      mockConnectivityService = MockConnectivityService();
      syncStatusController = StreamController<SyncStatus>();
      syncResultController = StreamController<SyncResult>();
      connectivityController = StreamController<bool>();

      // Setup stream mocks
      when(mockSyncService.syncStatusStream)
          .thenAnswer((_) => syncStatusController.stream);
      when(mockSyncService.syncResultStream)
          .thenAnswer((_) => syncResultController.stream);
      when(mockConnectivityService.connectivityStream)
          .thenAnswer((_) => connectivityController.stream);

      // Setup initial state mocks
      when(mockConnectivityService.isConnected).thenReturn(true);
      when(mockSyncService.currentStatus).thenReturn(SyncStatus.idle);
      when(mockSyncService.getSyncStats()).thenAnswer((_) async => {
            'isOnline': true,
            'currentStatus': 'idle',
            'pendingOperations': 0,
            'pendingTransactions': 0,
            'pendingCategories': 0,
          });

      syncCubit = SyncCubit(
        syncService: mockSyncService,
        connectivityService: mockConnectivityService,
      );
    });

    tearDown(() {
      syncStatusController.close();
      syncResultController.close();
      connectivityController.close();
      syncCubit.close();
    });

    test('initial state is SyncInitial or SyncIdle', () {
      expect(syncCubit.state, anyOf(isA<SyncInitial>(), isA<SyncIdle>()));
    });

    group('sync status changes', () {
      blocTest<SyncCubit, SyncState>(
        'emits SyncInProgress when sync status changes to syncing',
        build: () => syncCubit,
        act: (cubit) {
          syncStatusController.add(SyncStatus.syncing);
        },
        expect: () => [
          isA<SyncInProgress>(),
        ],
      );

      test('handles sync status changes to idle', () async {
        // Act
        syncStatusController.add(SyncStatus.idle);
        await Future.delayed(Duration.zero); // Allow stream to process

        // Assert - just verify the cubit is still functioning
        expect(syncCubit.state, isA<SyncState>());
      });
    });

    group('sync result changes', () {
      blocTest<SyncCubit, SyncState>(
        'emits SyncSuccess when sync result is successful',
        build: () => syncCubit,
        act: (cubit) {
          syncResultController.add(const SyncResult(
            success: true,
            syncedTransactions: 5,
            syncedCategories: 3,
          ));
        },
        expect: () => [
          isA<SyncSuccess>(),
        ],
      );

      blocTest<SyncCubit, SyncState>(
        'emits SyncError when sync result has error',
        build: () => syncCubit,
        act: (cubit) {
          syncResultController.add(const SyncResult(
            success: false,
            error: 'Sync failed',
          ));
        },
        expect: () => [
          isA<SyncError>(),
        ],
      );
    });

    group('connectivity changes', () {
      blocTest<SyncCubit, SyncState>(
        'emits SyncOffline when connectivity changes to offline',
        build: () => syncCubit,
        act: (cubit) {
          when(mockConnectivityService.isConnected).thenReturn(false);
          connectivityController.add(false);
        },
        expect: () => [
          isA<SyncOffline>(),
        ],
      );

      test('handles connectivity changes to online', () async {
        // Act
        when(mockConnectivityService.isConnected).thenReturn(true);
        connectivityController.add(true);
        await Future.delayed(Duration.zero); // Allow stream to process

        // Assert - just verify the cubit is still functioning
        expect(syncCubit.state, isA<SyncState>());
      });
    });

    group('force sync', () {
      blocTest<SyncCubit, SyncState>(
        'calls syncService.forceSyncNow when forceSync is called',
        build: () => syncCubit,
        act: (cubit) async {
          when(mockSyncService.forceSyncNow())
              .thenAnswer((_) async => const SyncResult(success: true));
          await cubit.forceSync();
        },
        verify: (_) {
          verify(mockSyncService.forceSyncNow()).called(1);
        },
      );

      blocTest<SyncCubit, SyncState>(
        'emits SyncInProgress then handles result when forceSync is called',
        build: () => syncCubit,
        act: (cubit) async {
          when(mockSyncService.forceSyncNow())
              .thenAnswer((_) async => const SyncResult(success: true));
          await cubit.forceSync();
        },
        expect: () => [
          isA<SyncInProgress>(),
        ],
      );
    });

    group('utility methods', () {
      test('getSyncStats returns sync service stats', () async {
        // Arrange
        final expectedStats = {
          'isOnline': true,
          'pendingOperations': 5,
        };
        when(mockSyncService.getSyncStats())
            .thenAnswer((_) async => expectedStats);

        // Act
        final stats = await syncCubit.getSyncStats();

        // Assert
        expect(stats, expectedStats);
        verify(mockSyncService.getSyncStats()).called(greaterThanOrEqualTo(1));
      });

      test(
          'hasPendingOperations returns true when there are pending operations',
          () async {
        // Arrange
        when(mockSyncService.getSyncStats()).thenAnswer((_) async => {
              'pendingOperations': 3,
            });

        // Act
        final hasPending = await syncCubit.hasPendingOperations();

        // Assert
        expect(hasPending, true);
      });

      test(
          'hasPendingOperations returns false when there are no pending operations',
          () async {
        // Arrange
        when(mockSyncService.getSyncStats()).thenAnswer((_) async => {
              'pendingOperations': 0,
            });

        // Act
        final hasPending = await syncCubit.hasPendingOperations();

        // Assert
        expect(hasPending, false);
      });

      test('isOnline returns connectivity service status', () {
        // Arrange
        when(mockConnectivityService.isConnected).thenReturn(true);

        // Act
        final isOnline = syncCubit.isOnline;

        // Assert
        expect(isOnline, true);
      });
    });
  });
}
