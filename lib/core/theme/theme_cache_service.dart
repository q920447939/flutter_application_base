/// 主题缓存服务
///
/// 负责主题配置的缓存管理，包括：
/// - 主题配置缓存
/// - 缓存过期管理
/// - 缓存清理
/// - 性能优化
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/storage_service.dart';
import 'models/theme_config.dart';

/// 缓存项
class ThemeCacheItem {
  final ThemeConfig config;
  final DateTime cachedAt;
  final Duration ttl;

  const ThemeCacheItem({
    required this.config,
    required this.cachedAt,
    required this.ttl,
  });

  /// 是否已过期
  bool get isExpired {
    return DateTime.now().difference(cachedAt) > ttl;
  }

  /// 剩余有效时间
  Duration get remainingTtl {
    final elapsed = DateTime.now().difference(cachedAt);
    return ttl - elapsed;
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'config': config.toJson(),
      'cachedAt': cachedAt.toIso8601String(),
      'ttl': ttl.inMilliseconds,
    };
  }

  /// 从JSON创建
  factory ThemeCacheItem.fromJson(Map<String, dynamic> json) {
    return ThemeCacheItem(
      config: ThemeConfig.fromJson(json['config'] as Map<String, dynamic>),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      ttl: Duration(milliseconds: json['ttl'] as int),
    );
  }
}

/// 主题缓存服务
class ThemeCacheService extends GetxController {
  static ThemeCacheService? _instance;
  static ThemeCacheService get instance => _instance ??= ThemeCacheService._();

  ThemeCacheService._();

  /// 缓存存储键
  static const String _cacheKey = 'theme_cache';
  static const String _currentThemeKey = 'current_theme_cache';

  /// 默认缓存时间（24小时）
  static const Duration _defaultTtl = Duration(hours: 24);

  /// 内存缓存
  final Map<String, ThemeCacheItem> _memoryCache = {};

  /// 当前主题缓存
  ThemeCacheItem? _currentThemeCache;

  /// 是否已初始化
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// 初始化缓存服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 从持久化存储加载缓存
    await _loadCacheFromStorage();

    // 清理过期缓存
    await _cleanExpiredCache();

    _isInitialized = true;
    debugPrint('✅ 主题缓存服务初始化完成');
  }

  /// 从存储加载缓存
  Future<void> _loadCacheFromStorage() async {
    try {
      // 加载主题缓存
      final cacheJson = StorageService.instance
          .getAppSetting<Map<String, dynamic>>(_cacheKey);
      if (cacheJson != null) {
        for (final entry in cacheJson.entries) {
          final cacheItem = ThemeCacheItem.fromJson(
            entry.value as Map<String, dynamic>,
          );
          if (!cacheItem.isExpired) {
            _memoryCache[entry.key] = cacheItem;
          }
        }
      }

      // 加载当前主题缓存
      final currentThemeJson = StorageService.instance
          .getAppSetting<Map<String, dynamic>>(_currentThemeKey);
      if (currentThemeJson != null) {
        final cacheItem = ThemeCacheItem.fromJson(currentThemeJson);
        if (!cacheItem.isExpired) {
          _currentThemeCache = cacheItem;
        }
      }

      debugPrint('📦 已从存储加载 ${_memoryCache.length} 个主题缓存');
    } catch (e) {
      debugPrint('⚠️ 从存储加载主题缓存失败: $e');
    }
  }

  /// 保存缓存到存储
  Future<void> _saveCacheToStorage() async {
    try {
      // 保存主题缓存
      final cacheJson = <String, dynamic>{};
      for (final entry in _memoryCache.entries) {
        if (!entry.value.isExpired) {
          cacheJson[entry.key] = entry.value.toJson();
        }
      }
      await StorageService.instance.setAppSetting(_cacheKey, cacheJson);

      // 保存当前主题缓存
      if (_currentThemeCache != null && !_currentThemeCache!.isExpired) {
        await StorageService.instance.setAppSetting(
          _currentThemeKey,
          _currentThemeCache!.toJson(),
        );
      }
    } catch (e) {
      debugPrint('⚠️ 保存主题缓存到存储失败: $e');
    }
  }

  /// 缓存主题配置
  Future<void> cacheTheme(
    ThemeConfig config, {
    Duration? ttl,
    bool isCurrentTheme = false,
  }) async {
    final cacheItem = ThemeCacheItem(
      config: config,
      cachedAt: DateTime.now(),
      ttl: ttl ?? _defaultTtl,
    );

    // 添加到内存缓存
    _memoryCache[config.id] = cacheItem;

    // 如果是当前主题，单独缓存
    if (isCurrentTheme) {
      _currentThemeCache = cacheItem;
    }

    // 保存到持久化存储
    await _saveCacheToStorage();

    debugPrint('💾 已缓存主题: ${config.name} (TTL: ${ttl ?? _defaultTtl})');
  }

  /// 获取缓存的主题配置
  ThemeConfig? getCachedTheme(String themeId) {
    final cacheItem = _memoryCache[themeId];
    if (cacheItem != null && !cacheItem.isExpired) {
      return cacheItem.config;
    }
    return null;
  }

  /// 获取当前主题缓存
  ThemeConfig? getCachedCurrentTheme() {
    if (_currentThemeCache != null && !_currentThemeCache!.isExpired) {
      return _currentThemeCache!.config;
    }
    return null;
  }

  /// 获取缓存的主题配置（异步版本，用于初始化）
  Future<ThemeConfig?> getCachedThemeAsync() async {
    return getCachedCurrentTheme();
  }

  /// 检查主题是否已缓存
  bool isThemeCached(String themeId) {
    final cacheItem = _memoryCache[themeId];
    return cacheItem != null && !cacheItem.isExpired;
  }

  /// 获取缓存项信息
  ThemeCacheItem? getCacheItem(String themeId) {
    return _memoryCache[themeId];
  }

  /// 清理过期缓存
  Future<void> _cleanExpiredCache() async {
    final expiredKeys = <String>[];

    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }

    // 检查当前主题缓存是否过期
    if (_currentThemeCache?.isExpired == true) {
      _currentThemeCache = null;
    }

    if (expiredKeys.isNotEmpty) {
      await _saveCacheToStorage();
      debugPrint('🧹 已清理 ${expiredKeys.length} 个过期主题缓存');
    }
  }

  /// 手动清理过期缓存
  Future<void> cleanExpiredCache() async {
    await _cleanExpiredCache();
  }

  /// 清理指定主题缓存
  Future<void> removeCachedTheme(String themeId) async {
    _memoryCache.remove(themeId);

    // 如果删除的是当前主题缓存
    if (_currentThemeCache?.config.id == themeId) {
      _currentThemeCache = null;
    }

    await _saveCacheToStorage();
    debugPrint('🗑️ 已删除主题缓存: $themeId');
  }

  /// 清空所有缓存
  Future<void> clearAllCache() async {
    _memoryCache.clear();
    _currentThemeCache = null;

    await StorageService.instance.setAppSetting(_cacheKey, null);
    await StorageService.instance.setAppSetting(_currentThemeKey, null);

    debugPrint('🧹 已清空所有主题缓存');
  }

  /// 预热缓存（预加载常用主题）
  Future<void> preloadThemes(List<ThemeConfig> themes) async {
    for (final theme in themes) {
      await cacheTheme(theme, ttl: const Duration(hours: 48));
    }
    debugPrint('🔥 已预热 ${themes.length} 个主题缓存');
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    int expiredCount = 0;
    int validCount = 0;
    Duration totalSize = Duration.zero;

    for (final cacheItem in _memoryCache.values) {
      if (cacheItem.isExpired) {
        expiredCount++;
      } else {
        validCount++;
        totalSize += now.difference(cacheItem.cachedAt);
      }
    }

    return {
      'totalItems': _memoryCache.length,
      'validItems': validCount,
      'expiredItems': expiredCount,
      'currentThemeCached': _currentThemeCache != null,
      'currentThemeExpired': _currentThemeCache?.isExpired ?? false,
      'averageAge': validCount > 0 ? totalSize.inMinutes / validCount : 0,
    };
  }

  /// 获取所有缓存的主题ID
  List<String> getCachedThemeIds() {
    return _memoryCache.entries
        .where((entry) => !entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();
  }

  /// 获取缓存大小估算（字节）
  int getEstimatedCacheSize() {
    int size = 0;
    for (final cacheItem in _memoryCache.values) {
      // 粗略估算每个配置的大小
      size += cacheItem.config.toJson().toString().length * 2; // UTF-16编码
    }
    return size;
  }

  /// 设置缓存清理定时器
  void startCacheCleanupTimer() {
    // 每小时清理一次过期缓存
    Timer.periodic(const Duration(hours: 1), (timer) {
      _cleanExpiredCache();
    });
  }

  /// 停止缓存清理定时器
  void stopCacheCleanupTimer() {
    // 实现定时器停止逻辑
  }
}
