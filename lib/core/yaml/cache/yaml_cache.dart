/// YAML 缓存管理
///
/// 提供高效的内存缓存机制，支持 TTL 过期和 LRU 淘汰策略
library;

import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/yaml_models.dart';
import '../exceptions/yaml_exceptions.dart';

/// YAML 缓存接口
abstract class IYamlCache {
  /// 获取缓存值
  Future<T?> get<T>(String key);

  /// 设置缓存值
  Future<void> set<T>(String key, T value, {Duration? ttl});

  /// 删除缓存
  Future<void> remove(String key);

  /// 清除所有缓存
  Future<void> clear();

  /// 清除匹配模式的缓存
  Future<void> clearPattern(String pattern);

  /// 检查缓存是否存在
  Future<bool> exists(String key);
}

/// YAML 缓存实现
class YamlCache implements IYamlCache {
  /// 内存缓存存储
  final Map<String, CacheEntry> _cache = LinkedHashMap<String, CacheEntry>();

  /// 默认 TTL
  final Duration _defaultTtl;

  /// 最大缓存条目数
  final int _maxEntries;

  /// 定时清理任务
  Timer? _cleanupTimer;

  YamlCache({
    Duration defaultTtl = const Duration(hours: 1),
    int maxEntries = 1000,
    Duration cleanupInterval = const Duration(minutes: 5),
  }) : _defaultTtl = defaultTtl,
       _maxEntries = maxEntries {
    // 启动定时清理任务
    _startCleanupTimer(cleanupInterval);
  }

  @override
  Future<T?> get<T>(String key) async {
    try {
      final entry = _cache[key];

      if (entry == null) {
        return null;
      }

      // 检查是否过期
      if (entry.isExpired) {
        _cache.remove(key);
        return null;
      }

      // 更新访问记录
      _cache[key] = entry.withAccess();

      return entry.value as T;
    } catch (e) {
      throw YamlCacheException(
        message: '获取缓存失败',
        cacheKey: key,
        innerException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<void> set<T>(String key, T value, {Duration? ttl}) async {
    try {
      final effectiveTtl = ttl ?? _defaultTtl;
      final now = DateTime.now();

      final entry = CacheEntry<T>(
        value: value,
        expireTime: now.add(effectiveTtl),
        createTime: now,
        lastAccessTime: now,
      );

      _cache[key] = entry;

      // 检查是否超过最大条目数，执行 LRU 淘汰
      if (_cache.length > _maxEntries) {
        _evictLeastRecentlyUsed();
      }
    } catch (e) {
      throw YamlCacheException(
        message: '设置缓存失败',
        cacheKey: key,
        innerException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<void> remove(String key) async {
    _cache.remove(key);
  }

  @override
  Future<void> clear() async {
    _cache.clear();
  }

  @override
  Future<void> clearPattern(String pattern) async {
    try {
      final regex = RegExp(pattern);
      final keysToRemove = _cache.keys.where(regex.hasMatch).toList();

      for (final key in keysToRemove) {
        _cache.remove(key);
      }
    } catch (e) {
      throw YamlCacheException(
        message: '清除匹配模式的缓存失败: $pattern',
        innerException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<bool> exists(String key) async {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  /// 启动定时清理任务
  void _startCleanupTimer(Duration interval) {
    _cleanupTimer = Timer.periodic(interval, (_) => _cleanupExpiredEntries());
  }

  /// 清理过期条目
  void _cleanupExpiredEntries() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    if (expiredKeys.isNotEmpty && kDebugMode) {
      debugPrint('YAML 缓存清理: 移除了 ${expiredKeys.length} 个过期条目');
    }
  }

  /// LRU 淘汰最少使用的条目
  void _evictLeastRecentlyUsed() {
    if (_cache.isEmpty) return;

    // 找到最少使用的条目
    String? lruKey;
    DateTime? oldestAccessTime;

    for (final entry in _cache.entries) {
      final accessTime = entry.value.lastAccessTime;
      if (oldestAccessTime == null || accessTime.isBefore(oldestAccessTime)) {
        oldestAccessTime = accessTime;
        lruKey = entry.key;
      }
    }

    if (lruKey != null) {
      _cache.remove(lruKey);

      if (kDebugMode) {
        debugPrint('YAML 缓存 LRU 淘汰: 移除键 $lruKey');
      }
    }
  }

  /// 销毁缓存
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _cache.clear();
  }
}
