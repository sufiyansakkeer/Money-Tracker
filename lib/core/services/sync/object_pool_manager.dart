/// Memory optimization - object pooling for frequently created objects
class ObjectPoolManager {
  final List<Map<String, dynamic>> _mapPool = [];
  final List<List<dynamic>> _listPool = [];
  static const int _maxPoolSize = 10;

  /// Get a pooled map or create a new one
  Map<String, dynamic> getPooledMap() {
    if (_mapPool.isNotEmpty) {
      final map = _mapPool.removeLast();
      map.clear(); // Ensure it's clean
      return map;
    }
    return <String, dynamic>{};
  }

  /// Get a pooled list or create a new one
  List<T> getPooledList<T>() {
    if (_listPool.isNotEmpty) {
      final list = _listPool.removeLast() as List<T>;
      list.clear(); // Ensure it's clean
      return list;
    }
    return <T>[];
  }

  /// Return a map to the pool for reuse
  void returnMapToPool(Map<String, dynamic> map) {
    if (_mapPool.length < _maxPoolSize) {
      map.clear();
      _mapPool.add(map);
    }
  }

  /// Return a list to the pool for reuse
  void returnListToPool<T>(List<T> list) {
    if (_listPool.length < _maxPoolSize) {
      list.clear();
      _listPool.add(list);
    }
  }

  /// Clear all pools to free memory
  void clearPools() {
    _mapPool.clear();
    _listPool.clear();
  }

  /// Get pool statistics for monitoring
  Map<String, int> getPoolStats() {
    return {
      'mapPoolSize': _mapPool.length,
      'listPoolSize': _listPool.length,
      'maxPoolSize': _maxPoolSize,
    };
  }
}
