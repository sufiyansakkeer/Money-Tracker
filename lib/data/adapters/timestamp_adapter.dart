import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

/// Hive TypeAdapter for Firestore Timestamp objects
/// This adapter handles serialization/deserialization of Timestamp objects to/from Hive storage
class TimestampAdapter extends TypeAdapter<Timestamp> {
  @override
  final int typeId = 20; // Use a unique typeId that doesn't conflict with existing adapters

  @override
  Timestamp read(BinaryReader reader) {
    // Read the stored milliseconds since epoch
    final millisecondsSinceEpoch = reader.readInt();
    
    // Convert back to Timestamp
    return Timestamp.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
  }

  @override
  void write(BinaryWriter writer, Timestamp obj) {
    // Store the timestamp as milliseconds since epoch
    writer.writeInt(obj.millisecondsSinceEpoch);
  }
}

/// Extension methods for easier Timestamp handling in sync operations
extension TimestampSyncExtensions on Timestamp {
  /// Convert Timestamp to a Hive-serializable format (DateTime)
  DateTime toDateTime() => toDate();
  
  /// Create Timestamp from DateTime
  static Timestamp fromDateTime(DateTime dateTime) => Timestamp.fromDate(dateTime);
}

/// Utility class for handling Timestamp conversion in sync operations
class TimestampConverter {
  /// Convert a Map containing Timestamp objects to DateTime objects for Hive storage
  static Map<String, dynamic> convertTimestampsToDateTime(Map<String, dynamic> data) {
    final convertedData = <String, dynamic>{};
    
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is Timestamp) {
        // Convert Timestamp to DateTime
        convertedData[key] = value.toDate();
      } else if (value is Map<String, dynamic>) {
        // Recursively convert nested maps
        convertedData[key] = convertTimestampsToDateTime(value);
      } else if (value is List) {
        // Handle lists that might contain Timestamps or Maps
        convertedData[key] = _convertListTimestamps(value);
      } else {
        // Keep other values as-is
        convertedData[key] = value;
      }
    }
    
    return convertedData;
  }
  
  /// Convert a Map containing DateTime objects back to Timestamp objects for Firestore
  static Map<String, dynamic> convertDateTimeToTimestamps(Map<String, dynamic> data) {
    final convertedData = <String, dynamic>{};
    
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is DateTime) {
        // Convert DateTime back to Timestamp
        convertedData[key] = Timestamp.fromDate(value);
      } else if (value is Map<String, dynamic>) {
        // Recursively convert nested maps
        convertedData[key] = convertDateTimeToTimestamps(value);
      } else if (value is List) {
        // Handle lists that might contain DateTimes or Maps
        convertedData[key] = _convertListDateTimes(value);
      } else {
        // Keep other values as-is
        convertedData[key] = value;
      }
    }
    
    return convertedData;
  }
  
  /// Helper method to convert Timestamps in lists
  static List<dynamic> _convertListTimestamps(List<dynamic> list) {
    return list.map((item) {
      if (item is Timestamp) {
        return item.toDate();
      } else if (item is Map<String, dynamic>) {
        return convertTimestampsToDateTime(item);
      } else if (item is List) {
        return _convertListTimestamps(item);
      } else {
        return item;
      }
    }).toList();
  }
  
  /// Helper method to convert DateTimes back to Timestamps in lists
  static List<dynamic> _convertListDateTimes(List<dynamic> list) {
    return list.map((item) {
      if (item is DateTime) {
        return Timestamp.fromDate(item);
      } else if (item is Map<String, dynamic>) {
        return convertDateTimeToTimestamps(item);
      } else if (item is List) {
        return _convertListDateTimes(item);
      } else {
        return item;
      }
    }).toList();
  }
  
  /// Check if a Map contains any Timestamp objects
  static bool containsTimestamps(Map<String, dynamic> data) {
    for (final value in data.values) {
      if (value is Timestamp) {
        return true;
      } else if (value is Map<String, dynamic>) {
        if (containsTimestamps(value)) {
          return true;
        }
      } else if (value is List) {
        if (_listContainsTimestamps(value)) {
          return true;
        }
      }
    }
    return false;
  }
  
  /// Helper method to check if a list contains Timestamps
  static bool _listContainsTimestamps(List<dynamic> list) {
    for (final item in list) {
      if (item is Timestamp) {
        return true;
      } else if (item is Map<String, dynamic>) {
        if (containsTimestamps(item)) {
          return true;
        }
      } else if (item is List) {
        if (_listContainsTimestamps(item)) {
          return true;
        }
      }
    }
    return false;
  }
}
