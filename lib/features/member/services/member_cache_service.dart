/// 会员信息缓存服务
///
/// 提供会员信息的本地缓存功能，减少网络请求，提升用户体验
/// 支持内存缓存、持久化缓存和混合缓存策略
library;

import 'package:flutter/foundation.dart';
import '../../../core/storage/storage_service.dart';
import '../models/member_models.dart';
import '../config/member_config.dart';

/// 缓存项模型
class MemberCacheItem {
  /// 会员信息数据
  final MemberInfo memberInfo;

  /// 缓存时间
  final DateTime cacheTime;

  /// 过期时间
  final DateTime expireTime;

  /// 缓存版本（用于数据结构变更时的兼容性）
  final int version;

  const MemberCacheItem({
    required this.memberInfo,
    required this.cacheTime,
    required this.expireTime,
    this.version = 1,
  });

  /// 是否已过期
  bool get isExpired => DateTime.now().isAfter(expireTime);

  /// 剩余有效时间（分钟）
  int get remainingMinutes {
    if (isExpired) return 0;
    return expireTime.difference(DateTime.now()).inMinutes;
  }

  /// 缓存年龄（分钟）
  int get ageInMinutes => DateTime.now().difference(cacheTime).inMinutes;

  /// 从JSON创建
  factory MemberCacheItem.fromJson(Map<String, dynamic> json) {
    return MemberCacheItem(
      memberInfo: MemberInfo.fromJson(json['memberInfo']),
      cacheTime: DateTime.parse(json['cacheTime']),
      expireTime: DateTime.parse(json['expireTime']),
      version: json['version'] ?? 1,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'memberInfo': memberInfo.toJson(),
      'cacheTime': cacheTime.toIso8601String(),
      'expireTime': expireTime.toIso8601String(),
      'version': version,
    };
  }

  /// 复制并更新过期时间
  MemberCacheItem copyWithNewExpireTime(DateTime newExpireTime) {
    return MemberCacheItem(
      memberInfo: memberInfo,
      cacheTime: cacheTime,
      expireTime: newExpireTime,
      version: version,
    );
  }

  @override
  String toString() {
    return 'MemberCacheItem(memberId: ${memberInfo.id}, '
        'age: ${ageInMinutes}min, remaining: ${remainingMinutes}min)';
  }
}

/// 会员信息缓存服务
class MemberCacheService {
  static MemberCacheService? _instance;

  /// 存储服务实例
  final StorageService _storageService = StorageService.instance;

  /// 内存缓存
  MemberCacheItem? _memoryCache;

  /// 缓存键名
  static const String _cacheKey = 'member_info_cache';
  static const String _cacheMetaKey = 'member_cache_meta';

  /// 缓存统计信息
  int _hitCount = 0;
  int _missCount = 0;
  int _networkRequestCount = 0;

  MemberCacheService._internal();

  /// 单例模式
  static MemberCacheService get instance {
    _instance ??= MemberCacheService._internal();
    return _instance!;
  }

  /// 初始化缓存服务
  Future<void> initialize() async {
    await _loadCacheFromStorage();
    await _loadCacheMetadata();
    debugPrint('会员缓存服务初始化完成');
  }

  /// 获取缓存的会员信息
  Future<MemberInfo?> getCachedMemberInfo() async {
    // 1. 先检查内存缓存
    if (_memoryCache != null && !_memoryCache!.isExpired) {
      _hitCount++;
      debugPrint('✅ 内存缓存命中: ${_memoryCache!}');
      return _memoryCache!.memberInfo;
    }

    // 2. 检查持久化缓存
    final cachedItem = await _loadCacheFromStorage();
    if (cachedItem != null && !cachedItem.isExpired) {
      // 更新内存缓存
      _memoryCache = cachedItem;
      _hitCount++;
      debugPrint('✅ 持久化缓存命中: $cachedItem');
      return cachedItem.memberInfo;
    }

    // 3. 缓存未命中
    _missCount++;
    debugPrint('❌ 缓存未命中，需要网络请求');
    return null;
  }

  /// 缓存会员信息
  Future<void> cacheMemberInfo(MemberInfo memberInfo, {Duration? ttl}) async {
    final cacheTtl =
        ttl ?? const Duration(minutes: MemberConfig.cacheExpirationMinutes);
    final now = DateTime.now();

    final cacheItem = MemberCacheItem(
      memberInfo: memberInfo,
      cacheTime: now,
      expireTime: now.add(cacheTtl),
    );

    // 更新内存缓存
    _memoryCache = cacheItem;

    // 保存到持久化存储
    await _saveCacheToStorage(cacheItem);

    debugPrint('💾 会员信息已缓存: $cacheItem');
  }

  /// 更新缓存中的特定字段
  Future<void> updateCachedMemberInfo({
    String? nickName,
    String? avatarUrl,
  }) async {
    final currentCache = _memoryCache;
    if (currentCache == null || currentCache.isExpired) {
      debugPrint('⚠️ 无有效缓存可更新');
      return;
    }

    // 创建更新后的会员信息
    final updatedMemberInfo = currentCache.memberInfo.copyWith(
      nickName: nickName ?? currentCache.memberInfo.nickName,
      avatarUrl: avatarUrl ?? currentCache.memberInfo.avatarUrl,
    );

    // 保持原有的缓存时间和过期时间
    final updatedCacheItem = MemberCacheItem(
      memberInfo: updatedMemberInfo,
      cacheTime: currentCache.cacheTime,
      expireTime: currentCache.expireTime,
      version: currentCache.version,
    );

    // 更新缓存
    _memoryCache = updatedCacheItem;
    await _saveCacheToStorage(updatedCacheItem);

    debugPrint('🔄 缓存已更新: $updatedCacheItem');
  }

  /// 清除会员信息缓存
  Future<void> clearMemberInfoCache() async {
    _memoryCache = null;
    await _storageService.remove(_cacheKey);
    debugPrint('🗑️ 会员信息缓存已清除');
  }

  /// 刷新缓存（延长过期时间）
  Future<void> refreshCache({Duration? newTtl}) async {
    final currentCache = _memoryCache;
    if (currentCache == null) {
      debugPrint('⚠️ 无缓存可刷新');
      return;
    }

    final refreshTtl =
        newTtl ?? const Duration(minutes: MemberConfig.cacheExpirationMinutes);
    final newExpireTime = DateTime.now().add(refreshTtl);

    final refreshedCache = currentCache.copyWithNewExpireTime(newExpireTime);

    _memoryCache = refreshedCache;
    await _saveCacheToStorage(refreshedCache);

    debugPrint('🔄 缓存已刷新: $refreshedCache');
  }

  /// 检查缓存是否有效
  bool isCacheValid() {
    return _memoryCache != null && !_memoryCache!.isExpired;
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    final totalRequests = _hitCount + _missCount;
    final hitRate = totalRequests > 0 ? (_hitCount / totalRequests * 100) : 0.0;

    return {
      'hitCount': _hitCount,
      'missCount': _missCount,
      'networkRequestCount': _networkRequestCount,
      'hitRate': hitRate.toStringAsFixed(2),
      'totalRequests': totalRequests,
      'cacheValid': isCacheValid(),
      'cacheAge': _memoryCache?.ageInMinutes ?? 0,
      'remainingTime': _memoryCache?.remainingMinutes ?? 0,
    };
  }

  /// 重置缓存统计
  void resetCacheStats() {
    _hitCount = 0;
    _missCount = 0;
    _networkRequestCount = 0;
    debugPrint('📊 缓存统计已重置');
  }

  /// 记录网络请求
  void recordNetworkRequest() {
    _networkRequestCount++;
  }

  /// 预热缓存（在应用启动时调用）
  Future<void> preloadCache() async {
    final cachedItem = await _loadCacheFromStorage();
    if (cachedItem != null && !cachedItem.isExpired) {
      _memoryCache = cachedItem;
      debugPrint('🔥 缓存预热完成: $cachedItem');
    } else {
      debugPrint('🔥 缓存预热：无有效缓存');
    }
  }

  /// 从存储加载缓存
  Future<MemberCacheItem?> _loadCacheFromStorage() async {
    try {
      final cacheJson = _storageService.getObject(_cacheKey);
      if (cacheJson != null) {
        final cacheItem = MemberCacheItem.fromJson(cacheJson);
        debugPrint('📦 从存储加载缓存: $cacheItem');
        return cacheItem;
      }
    } catch (e) {
      debugPrint('⚠️ 加载缓存失败: $e');
    }
    return null;
  }

  /// 保存缓存到存储
  Future<void> _saveCacheToStorage(MemberCacheItem cacheItem) async {
    try {
      await _storageService.setObject(_cacheKey, cacheItem.toJson());
      await _saveCacheMetadata();
    } catch (e) {
      debugPrint('⚠️ 保存缓存失败: $e');
    }
  }

  /// 加载缓存元数据
  Future<void> _loadCacheMetadata() async {
    try {
      final metaJson = _storageService.getObject(_cacheMetaKey);
      if (metaJson != null) {
        _hitCount = metaJson['hitCount'] ?? 0;
        _missCount = metaJson['missCount'] ?? 0;
        _networkRequestCount = metaJson['networkRequestCount'] ?? 0;
      }
    } catch (e) {
      debugPrint('⚠️ 加载缓存元数据失败: $e');
    }
  }

  /// 保存缓存元数据
  Future<void> _saveCacheMetadata() async {
    try {
      await _storageService.setObject(_cacheMetaKey, {
        'hitCount': _hitCount,
        'missCount': _missCount,
        'networkRequestCount': _networkRequestCount,
        'lastUpdate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('⚠️ 保存缓存元数据失败: $e');
    }
  }
}
