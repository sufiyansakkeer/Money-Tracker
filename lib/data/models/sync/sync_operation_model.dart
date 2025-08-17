import 'package:hive_ce/hive.dart';
import 'package:money_track/data/adapters/timestamp_adapter.dart';

part 'sync_operation_model.g.dart';

/// Enum for sync operation types
@HiveType(typeId: 10)
enum SyncOperationType {
  @HiveField(0)
  create,
  @HiveField(1)
  update,
  @HiveField(2)
  delete,
}

/// Enum for data types that can be synced
@HiveType(typeId: 11)
enum SyncDataType {
  @HiveField(0)
  transaction,
  @HiveField(1)
  category,
}

/// Model for tracking pending sync operations
@HiveType(typeId: 12)
class SyncOperationModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final SyncOperationType operationType;

  @HiveField(2)
  final SyncDataType dataType;

  @HiveField(3)
  final String dataId;

  @HiveField(4)
  final Map<String, dynamic> data;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final int retryCount;

  @HiveField(7)
  final String? error;

  @HiveField(8)
  final String userId;

  const SyncOperationModel({
    required this.id,
    required this.operationType,
    required this.dataType,
    required this.dataId,
    required this.data,
    required this.createdAt,
    required this.userId,
    this.retryCount = 0,
    this.error,
  });

  /// Create a copy with updated fields
  SyncOperationModel copyWith({
    String? id,
    SyncOperationType? operationType,
    SyncDataType? dataType,
    String? dataId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? retryCount,
    String? error,
    String? userId,
  }) {
    return SyncOperationModel(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      dataType: dataType ?? this.dataType,
      dataId: dataId ?? this.dataId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      error: error ?? this.error,
      userId: userId ?? this.userId,
    );
  }

  /// Create a new operation for creating data
  factory SyncOperationModel.create({
    required String id,
    required SyncDataType dataType,
    required String dataId,
    required Map<String, dynamic> data,
    required String userId,
  }) {
    return SyncOperationModel(
      id: id,
      operationType: SyncOperationType.create,
      dataType: dataType,
      dataId: dataId,
      data: data,
      createdAt: DateTime.now(),
      userId: userId,
    );
  }

  /// Create a new operation for updating data
  factory SyncOperationModel.update({
    required String id,
    required SyncDataType dataType,
    required String dataId,
    required Map<String, dynamic> data,
    required String userId,
  }) {
    return SyncOperationModel(
      id: id,
      operationType: SyncOperationType.update,
      dataType: dataType,
      dataId: dataId,
      data: data,
      createdAt: DateTime.now(),
      userId: userId,
    );
  }

  /// Create a new operation for deleting data
  factory SyncOperationModel.delete({
    required String id,
    required SyncDataType dataType,
    required String dataId,
    required String userId,
  }) {
    return SyncOperationModel(
      id: id,
      operationType: SyncOperationType.delete,
      dataType: dataType,
      dataId: dataId,
      data: {},
      createdAt: DateTime.now(),
      userId: userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncOperationModel &&
        other.id == id &&
        other.operationType == operationType &&
        other.dataType == dataType &&
        other.dataId == dataId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      operationType,
      dataType,
      dataId,
      userId,
    );
  }

  /// Create a sync operation with Timestamp conversion for Hive storage
  factory SyncOperationModel.createWithTimestampConversion({
    required String id,
    required SyncOperationType operationType,
    required SyncDataType dataType,
    required String dataId,
    required Map<String, dynamic> data,
    required String userId,
    DateTime? createdAt,
    int retryCount = 0,
    String? error,
  }) {
    // Convert any Timestamp objects to DateTime for Hive storage
    final convertedData = TimestampConverter.containsTimestamps(data)
        ? TimestampConverter.convertTimestampsToDateTime(data)
        : data;

    return SyncOperationModel(
      id: id,
      operationType: operationType,
      dataType: dataType,
      dataId: dataId,
      data: convertedData,
      createdAt: createdAt ?? DateTime.now(),
      userId: userId,
      retryCount: retryCount,
      error: error,
    );
  }

  /// Get the data with Timestamps converted back for Firestore operations
  Map<String, dynamic> getDataForFirestore() {
    // Check if we need to convert DateTime objects back to Timestamps
    final hasDateTimes = data.values.any((value) =>
        value is DateTime ||
        (value is Map && value.values.any((v) => v is DateTime)));

    if (hasDateTimes) {
      return TimestampConverter.convertDateTimeToTimestamps(data);
    }

    return data;
  }

  @override
  String toString() {
    return 'SyncOperationModel(id: $id, operationType: $operationType, dataType: $dataType, dataId: $dataId, userId: $userId, retryCount: $retryCount)';
  }
}
