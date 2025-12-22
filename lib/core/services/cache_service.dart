import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Cache entry với TTL (Time To Live)
class _CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;

  _CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

/// LRU Cache với TTL h hỗ trợ multiple types
class CacheService {
  static const Duration defaultTTL = Duration(minutes: 30);
  static const int defaultMaxSize = 100;

  final Map<String, _CacheEntry<dynamic>> _cache = {};
  final LinkedHashMap<String, dynamic> _lruKeys = LinkedHashMap();
  final int _maxSize;
  final Duration _defaultTTL;

  CacheService({
    int maxSize = defaultMaxSize,
    Duration defaultTTL = defaultTTL,
  })  : _maxSize = maxSize,
        _defaultTTL = defaultTTL;

  /// Lấy dữ liệu từ cache
  T? get<T>(String key) {
    final entry = _cache[key] as _CacheEntry<T>?;
    if (entry == null) return null;

    if (entry.isExpired) {
      _remove(key);
      return null;
    }

    // Update LRU
    _updateLRU(key);
    return entry.data;
  }

  /// Lưu dữ liệu vào cache
  void set<T>(
    String key,
    T value, {
    Duration? ttl,
  }) {
    final entry = _CacheEntry<T>(
      data: value,
      timestamp: DateTime.now(),
      ttl: ttl ?? _defaultTTL,
    );

    _cache[key] = entry;
    _updateLRU(key);

    // Evict nếu vượt quá size
    if (_cache.length > _maxSize) {
      _evictLRU();
    }
  }

  /// Kiểm tra key có t tồn tại và chưa hết hạn
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.isExpired) {
      _remove(key);
      return false;
    }

    return true;
  }

  /// Xóa key khỏi cache
  void remove(String key) {
    _remove(key);
  }

  /// Xóa toàn bộ cache
  void clear() {
    _cache.clear();
    _lruKeys.clear();
  }

  /// Lấy thống kê cache
  Map<String, dynamic> get stats {
    final now = DateTime.now();
    int expiredCount = 0;
    int validCount = 0;
    int totalSize = 0;

    _cache.forEach((key, entry) {
      totalSize += _estimateSize(entry.data);
      if (entry.isExpired) {
        expiredCount++;
      } else {
        validCount++;
      }
    });

    return {
      'total_entries': _cache.length,
      'valid_entries': validCount,
      'expired_entries': expiredCount,
      'cache_size_bytes': totalSize,
      'max_size': _maxSize,
      'default_ttl_seconds': _defaultTTL.inSeconds,
      'lru_keys': _lruKeys.keys.toList(),
    };
  }

  /// Xóa các entry đã hết hạn
  int cleanupExpired() {
    final expiredKeys = <String>[];
    _cache.forEach((key, entry) {
      if (entry.isExpired) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _remove(key);
    }

    return expiredKeys.length;
  }

  /// Preload cache từ Map
  void preload(Map<String, dynamic> data, {Duration? ttl}) {
    data.forEach((key, value) {
      set(key, value, ttl: ttl);
    });
  }

  // Private methods

  void _remove(String key) {
    _cache.remove(key);
    _lruKeys.remove(key);
  }

  void _updateLRU(String key) {
    _lruKeys.remove(key);
    _lruKeys[key] = null;
  }

  void _evictLRU() {
    if (_lruKeys.isNotEmpty) {
      final lruKey = _lruKeys.keys.first;
      _remove(lruKey);
    }
  }

  int _estimateSize(dynamic data) {
    // Rough estimation
    if (data is String) {
      return data.length * 2;
    } else if (data is Map || data is List) {
      return 100; // approximate
    } else {
      return 50;
    }
  }

  /// Singleton instance
  static final CacheService instance = CacheService();

  /// Shortcut methods
  static T? getValue<T>(String key) => instance.get<T>(key);
  static void setValue<T>(String key, T value, {Duration? ttl}) =>
      instance.set(key, value, ttl: ttl);
  static bool hasKey(String key) => instance.has(key);
  static void removeKey(String key) => instance.remove(key);
  static void clearAll() => instance.clear();
}