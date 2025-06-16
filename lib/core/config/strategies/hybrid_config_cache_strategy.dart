/// 混合配置缓存策略
///
/// 结合内存缓存和持久化缓存的优势
/// - 内存缓存：快速访问，应用重启后失效
/// - 持久化缓存：跨应用会话保持，但访问相对较慢
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../config_manager_interface.dart';
import '../../storage/storage_service.dart';

/// 混合配置缓存策略
class HybridConfigCacheStrategy implements IConfigCacheStrategy {
  /// 存储服务实例
  late final StorageService _storageService;
  
  /// 内存缓存
  final Map<String, dynamic> _memoryCache = {};
  
  /// 缓存时间戳
  DateTime? _cacheTimestamp;
  
  /// 缓存过期时间（分钟）
  final int cacheExpireMinutes;
  
  /// 持久化缓存键前缀
  static const String _cacheKeyPrefix = 'remote_config_';
  
  /// 时间戳缓存键
  static const String _timestampKey = '${_cacheKeyPrefix}timestamp';
  
  /// 数据缓存键
  static const String _dataKey = '${_cacheKeyPrefix}data';

  HybridConfigCacheStrategy({
    this.cacheExpireMinutes = 60,
  });

  @override
  String get name => 'hybrid';

  @override
  Future<void> saveToCache(Map<String, dynamic> configs) async {
    try {
      _storageService = Get.find<StorageService>();
      
      final timestamp = DateTime.now();
      
      // 保存到内存缓存
      _memoryCache.clear();
      _memoryCache.addAll(configs);
      _cacheTimestamp = timestamp;
      
      // 保存到持久化缓存
      await _storageService.setString(_dataKey, json.encode(configs));
      await _storageService.setString(_timestampKey, timestamp.toIso8601String());
      
      debugPrint('配置已保存到混合缓存，配置项数量: ${configs.length}');
    } catch (e) {
      debugPrint('保存配置到缓存失败: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> loadFromCache() async {
    try {
      // 优先从内存缓存加载
      if (_memoryCache.isNotEmpty && _cacheTimestamp != null) {
        if (!await isCacheExpired()) {
          debugPrint('从内存缓存加载配置，配置项数量: ${_memoryCache.length}');
          return Map<String, dynamic>.from(_memoryCache);
        } else {
          debugPrint('内存缓存已过期，清除内存缓存');
          _memoryCache.clear();
          _cacheTimestamp = null;
        }
      }

      // 从持久化缓存加载
      _storageService = Get.find<StorageService>();
      
      final dataJson = await _storageService.getString(_dataKey);
      final timestampStr = await _storageService.getString(_timestampKey);
      
      if (dataJson == null || timestampStr == null) {
        debugPrint('持久化缓存中没有找到配置数据');
        return null;
      }

      _cacheTimestamp = DateTime.parse(timestampStr);
      
      if (await isCacheExpired()) {
        debugPrint('持久化缓存已过期，清除缓存');
        await clearCache();
        return null;
      }

      final configs = json.decode(dataJson) as Map<String, dynamic>;
      
      // 同步到内存缓存
      _memoryCache.clear();
      _memoryCache.addAll(configs);
      
      debugPrint('从持久化缓存加载配置，配置项数量: ${configs.length}');
      return configs;
    } catch (e) {
      debugPrint('从缓存加载配置失败: $e');
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      // 清除内存缓存
      _memoryCache.clear();
      _cacheTimestamp = null;
      
      // 清除持久化缓存
      _storageService = Get.find<StorageService>();
      await _storageService.remove(_dataKey);
      await _storageService.remove(_timestampKey);
      
      debugPrint('混合缓存已清除');
    } catch (e) {
      debugPrint('清除缓存失败: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isCacheExpired() async {
    if (_cacheTimestamp == null) {
      return true;
    }

    final now = DateTime.now();
    final expireTime = _cacheTimestamp!.add(Duration(minutes: cacheExpireMinutes));
    
    final isExpired = now.isAfter(expireTime);
    
    if (isExpired) {
      debugPrint('缓存已过期，缓存时间: $_cacheTimestamp, 过期时间: $expireTime, 当前时间: $now');
    }
    
    return isExpired;
  }

  @override
  Future<DateTime?> getCacheTimestamp() async {
    if (_cacheTimestamp != null) {
      return _cacheTimestamp;
    }

    try {
      _storageService = Get.find<StorageService>();
      final timestampStr = await _storageService.getString(_timestampKey);
      
      if (timestampStr != null) {
        _cacheTimestamp = DateTime.parse(timestampStr);
        return _cacheTimestamp;
      }
    } catch (e) {
      debugPrint('获取缓存时间戳失败: $e');
    }

    return null;
  }

  /// 获取内存缓存大小
  int get memoryCacheSize => _memoryCache.length;

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStatistics() {
    return {
      'memory_cache_size': _memoryCache.length,
      'cache_timestamp': _cacheTimestamp?.toIso8601String(),
      'cache_expire_minutes': cacheExpireMinutes,
      'is_memory_cache_available': _memoryCache.isNotEmpty,
    };
  }

  /// 预热内存缓存
  Future<void> warmupMemoryCache() async {
    if (_memoryCache.isEmpty) {
      final configs = await loadFromCache();
      if (configs != null) {
        debugPrint('内存缓存预热完成，配置项数量: ${configs.length}');
      }
    }
  }
}
