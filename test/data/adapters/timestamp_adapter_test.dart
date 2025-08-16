import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:money_track/data/adapters/timestamp_adapter.dart';

void main() {
  group('TimestampAdapter', () {
    late TimestampAdapter adapter;
    late MockBinaryReader reader;
    late MockBinaryWriter writer;

    setUp(() {
      adapter = TimestampAdapter();
      reader = MockBinaryReader();
      writer = MockBinaryWriter();
    });

    test('should have correct typeId', () {
      expect(adapter.typeId, 20);
    });

    test('should write Timestamp correctly', () {
      // Arrange
      final timestamp = Timestamp.fromMillisecondsSinceEpoch(1640995200000); // 2022-01-01
      
      // Act
      adapter.write(writer, timestamp);
      
      // Assert
      expect(writer.writtenInt, 1640995200000);
    });

    test('should read Timestamp correctly', () {
      // Arrange
      reader.intToReturn = 1640995200000; // 2022-01-01
      
      // Act
      final result = adapter.read(reader);
      
      // Assert
      expect(result.millisecondsSinceEpoch, 1640995200000);
    });

    test('should handle round-trip conversion', () {
      // Arrange
      final originalTimestamp = Timestamp.fromMillisecondsSinceEpoch(1640995200000);
      
      // Act - Write then read
      adapter.write(writer, originalTimestamp);
      reader.intToReturn = writer.writtenInt!;
      final roundTripTimestamp = adapter.read(reader);
      
      // Assert
      expect(roundTripTimestamp.millisecondsSinceEpoch, 
             originalTimestamp.millisecondsSinceEpoch);
    });
  });

  group('TimestampConverter', () {
    test('should convert Timestamps to DateTime in Map', () {
      // Arrange
      final timestamp = Timestamp.fromMillisecondsSinceEpoch(1640995200000);
      final data = {
        'createdAt': timestamp,
        'updatedAt': timestamp,
        'name': 'test',
        'count': 42,
      };

      // Act
      final result = TimestampConverter.convertTimestampsToDateTime(data);

      // Assert
      expect(result['createdAt'], isA<DateTime>());
      expect(result['updatedAt'], isA<DateTime>());
      expect(result['name'], 'test');
      expect(result['count'], 42);
      
      final convertedDate = result['createdAt'] as DateTime;
      expect(convertedDate.millisecondsSinceEpoch, 1640995200000);
    });

    test('should convert DateTime back to Timestamps in Map', () {
      // Arrange
      final dateTime = DateTime.fromMillisecondsSinceEpoch(1640995200000);
      final data = {
        'createdAt': dateTime,
        'updatedAt': dateTime,
        'name': 'test',
        'count': 42,
      };

      // Act
      final result = TimestampConverter.convertDateTimeToTimestamps(data);

      // Assert
      expect(result['createdAt'], isA<Timestamp>());
      expect(result['updatedAt'], isA<Timestamp>());
      expect(result['name'], 'test');
      expect(result['count'], 42);
      
      final convertedTimestamp = result['createdAt'] as Timestamp;
      expect(convertedTimestamp.millisecondsSinceEpoch, 1640995200000);
    });

    test('should handle nested Maps with Timestamps', () {
      // Arrange
      final timestamp = Timestamp.fromMillisecondsSinceEpoch(1640995200000);
      final data = {
        'user': {
          'createdAt': timestamp,
          'profile': {
            'lastLogin': timestamp,
          }
        },
        'metadata': {
          'updatedAt': timestamp,
        }
      };

      // Act
      final result = TimestampConverter.convertTimestampsToDateTime(data);

      // Assert
      expect((result['user'] as Map)['createdAt'], isA<DateTime>());
      expect(((result['user'] as Map)['profile'] as Map)['lastLogin'], isA<DateTime>());
      expect((result['metadata'] as Map)['updatedAt'], isA<DateTime>());
    });

    test('should handle Lists with Timestamps', () {
      // Arrange
      final timestamp = Timestamp.fromMillisecondsSinceEpoch(1640995200000);
      final data = {
        'timestamps': [timestamp, timestamp],
        'mixed': [timestamp, 'string', 42],
      };

      // Act
      final result = TimestampConverter.convertTimestampsToDateTime(data);

      // Assert
      final timestampsList = result['timestamps'] as List;
      expect(timestampsList[0], isA<DateTime>());
      expect(timestampsList[1], isA<DateTime>());
      
      final mixedList = result['mixed'] as List;
      expect(mixedList[0], isA<DateTime>());
      expect(mixedList[1], 'string');
      expect(mixedList[2], 42);
    });

    test('should detect Timestamps in Map', () {
      // Arrange
      final timestamp = Timestamp.fromMillisecondsSinceEpoch(1640995200000);
      final dataWithTimestamp = {'createdAt': timestamp, 'name': 'test'};
      final dataWithoutTimestamp = {'name': 'test', 'count': 42};

      // Act & Assert
      expect(TimestampConverter.containsTimestamps(dataWithTimestamp), true);
      expect(TimestampConverter.containsTimestamps(dataWithoutTimestamp), false);
    });

    test('should handle empty Map', () {
      // Arrange
      final data = <String, dynamic>{};

      // Act
      final result = TimestampConverter.convertTimestampsToDateTime(data);

      // Assert
      expect(result, isEmpty);
    });
  });
}

/// Mock BinaryReader for testing
class MockBinaryReader extends BinaryReader {
  int? intToReturn;

  @override
  int readInt() => intToReturn ?? 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock BinaryWriter for testing
class MockBinaryWriter extends BinaryWriter {
  int? writtenInt;

  @override
  void writeInt(int value) {
    writtenInt = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
