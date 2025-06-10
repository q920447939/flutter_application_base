/// 网络策略工厂
///
/// 负责创建和管理各种网络策略，包括：
/// - 重试策略
/// - 缓存策略
/// - 安全策略
/// - 限流策略
/// - 降级策略
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

/// 网络策略类型
enum NetworkStrategyType {
  /// 重试策略
  retry,

  /// 缓存策略
  cache,

  /// 安全策略
  security,

  /// 限流策略
  rateLimit,

  /// 降级策略
  fallback,
}

/// 抽象网络策略基类
abstract class NetworkStrategy {
  /// 策略类型
  NetworkStrategyType get type;

  /// 策略名称
  String get name;

  /// 是否启用
  bool get enabled;

  /// 应用策略
  Future<Response<T>> apply<T>(
    RequestOptions options,
    Future<Response<T>> Function() request,
  );
}

/// 重试策略
class RetryStrategy extends NetworkStrategy {
  @override
  NetworkStrategyType get type => NetworkStrategyType.retry;

  @override
  String get name => 'RetryStrategy';

  @override
  bool get enabled => _enabled;

  final bool _enabled;
  final int maxAttempts;
  final Duration delay;
  final List<DioExceptionType> retryableErrors;

  RetryStrategy({
    bool enabled = true,
    this.maxAttempts = 3,
    this.delay = const Duration(seconds: 1),
    this.retryableErrors = const [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.unknown,
    ],
  }) : _enabled = enabled;

  @override
  Future<Response<T>> apply<T>(
    RequestOptions options,
    Future<Response<T>> Function() request,
  ) async {
    if (!enabled) {
      return await request();
    }

    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        return await request();
      } catch (e) {
        attempts++;

        if (e is DioException &&
            retryableErrors.contains(e.type) &&
            attempts < maxAttempts) {
          debugPrint('请求失败，第 $attempts 次重试，延迟 ${delay.inSeconds} 秒...');
          await Future.delayed(delay);
          continue;
        }

        rethrow;
      }
    }

    throw Exception('重试次数已达上限');
  }
}

/// 缓存策略
class CacheStrategy extends NetworkStrategy {
  @override
  NetworkStrategyType get type => NetworkStrategyType.cache;

  @override
  String get name => 'CacheStrategy';

  @override
  bool get enabled => _enabled;

  final bool _enabled;
  final Duration maxAge;
  final Map<String, _CacheEntry> _cache = {};

  CacheStrategy({bool enabled = true, this.maxAge = const Duration(minutes: 5)})
    : _enabled = enabled;

  @override
  Future<Response<T>> apply<T>(
    RequestOptions options,
    Future<Response<T>> Function() request,
  ) async {
    if (!enabled || options.method.toUpperCase() != 'GET') {
      return await request();
    }

    final cacheKey = _generateCacheKey(options);
    final cachedEntry = _cache[cacheKey];

    // 检查缓存是否有效
    if (cachedEntry != null && !cachedEntry.isExpired) {
      debugPrint('使用缓存响应: $cacheKey');
      return cachedEntry.response as Response<T>;
    }

    // 执行请求并缓存结果
    final response = await request();
    _cache[cacheKey] = _CacheEntry(response, DateTime.now().add(maxAge));

    // 清理过期缓存
    _cleanupExpiredCache();

    return response;
  }

  String _generateCacheKey(RequestOptions options) {
    return '${options.method}_${options.uri}_${options.queryParameters}';
  }

  void _cleanupExpiredCache() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  /// 清空缓存
  void clearCache() {
    _cache.clear();
  }
}

/// 缓存条目
class _CacheEntry {
  final Response response;
  final DateTime expiresAt;

  _CacheEntry(this.response, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// 安全策略
class SecurityStrategy extends NetworkStrategy {
  @override
  NetworkStrategyType get type => NetworkStrategyType.security;

  @override
  String get name => 'SecurityStrategy';

  @override
  bool get enabled => _enabled;

  final bool _enabled;
  final bool validateCertificate;
  final List<String> allowedHosts;

  SecurityStrategy({
    bool enabled = true,
    this.validateCertificate = true,
    this.allowedHosts = const [],
  }) : _enabled = enabled;

  @override
  Future<Response<T>> apply<T>(
    RequestOptions options,
    Future<Response<T>> Function() request,
  ) async {
    if (!enabled) {
      return await request();
    }

    // 检查主机白名单
    if (allowedHosts.isNotEmpty) {
      final host = options.uri.host;
      if (!allowedHosts.contains(host)) {
        throw DioException(
          requestOptions: options,
          error: '主机不在允许列表中: $host',
          type: DioExceptionType.unknown,
        );
      }
    }

    // 添加安全头
    options.headers.addAll({
      'X-Requested-With': 'XMLHttpRequest',
      'X-Client-Version': '1.0.0',
    });

    return await request();
  }
}

/// 限流策略
class RateLimitStrategy extends NetworkStrategy {
  @override
  NetworkStrategyType get type => NetworkStrategyType.rateLimit;

  @override
  String get name => 'RateLimitStrategy';

  @override
  bool get enabled => _enabled;

  final bool _enabled;
  final int maxRequestsPerMinute;
  final List<DateTime> _requestTimes = [];

  RateLimitStrategy({bool enabled = true, this.maxRequestsPerMinute = 60})
    : _enabled = enabled;

  @override
  Future<Response<T>> apply<T>(
    RequestOptions options,
    Future<Response<T>> Function() request,
  ) async {
    if (!enabled) {
      return await request();
    }

    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

    // 清理过期的请求记录
    _requestTimes.removeWhere((time) => time.isBefore(oneMinuteAgo));

    // 检查是否超过限制
    if (_requestTimes.length >= maxRequestsPerMinute) {
      throw DioException(
        requestOptions: options,
        error: '请求频率过高，请稍后再试',
        type: DioExceptionType.unknown,
      );
    }

    // 记录请求时间
    _requestTimes.add(now);

    return await request();
  }
}

/// 降级策略
class FallbackStrategy extends NetworkStrategy {
  @override
  NetworkStrategyType get type => NetworkStrategyType.fallback;

  @override
  String get name => 'FallbackStrategy';

  @override
  bool get enabled => _enabled;

  final bool _enabled;
  final List<String> fallbackUrls;

  FallbackStrategy({bool enabled = true, this.fallbackUrls = const []})
    : _enabled = enabled;

  @override
  Future<Response<T>> apply<T>(
    RequestOptions options,
    Future<Response<T>> Function() request,
  ) async {
    if (!enabled || fallbackUrls.isEmpty) {
      return await request();
    }

    try {
      return await request();
    } catch (e) {
      // 尝试降级URL
      for (final fallbackUrl in fallbackUrls) {
        try {
          final fallbackOptions = options.copyWith(baseUrl: fallbackUrl);
          debugPrint('尝试降级URL: $fallbackUrl');

          // 这里需要重新创建请求
          final dio = Dio();
          final response = await dio.request<T>(
            fallbackOptions.path,
            options: Options(
              method: fallbackOptions.method,
              headers: fallbackOptions.headers,
            ),
            data: fallbackOptions.data,
            queryParameters: fallbackOptions.queryParameters,
          );

          debugPrint('降级URL请求成功: $fallbackUrl');
          return response;
        } catch (fallbackError) {
          debugPrint('降级URL请求失败: $fallbackUrl, 错误: $fallbackError');
          continue;
        }
      }

      // 所有降级URL都失败，抛出原始错误
      rethrow;
    }
  }
}

/// 网络策略工厂
class NetworkStrategyFactory extends GetxController {
  static NetworkStrategyFactory? _instance;

  /// 单例实例
  static NetworkStrategyFactory get instance {
    _instance ??= NetworkStrategyFactory._internal();
    return _instance!;
  }

  NetworkStrategyFactory._internal();

  /// 策略列表
  final List<NetworkStrategy> _strategies = [];

  /// 是否已初始化
  bool _isInitialized = false;

  /// 获取所有策略
  List<NetworkStrategy> get strategies => List.unmodifiable(_strategies);

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化策略工厂
  void initialize({
    bool enableCache = true,
    int maxRetryAttempts = 3,
    Duration retryDelay = const Duration(seconds: 1),
    Duration cacheMaxAge = const Duration(minutes: 5),
    bool enableSecurity = true,
    int maxRequestsPerMinute = 60,
    List<String> fallbackUrls = const [],
  }) {
    if (_isInitialized) return;

    _strategies.clear();

    // 添加重试策略
    _strategies.add(
      RetryStrategy(
        enabled: true,
        maxAttempts: maxRetryAttempts,
        delay: retryDelay,
      ),
    );

    // 添加缓存策略
    _strategies.add(CacheStrategy(enabled: enableCache, maxAge: cacheMaxAge));

    // 添加安全策略
    _strategies.add(SecurityStrategy(enabled: enableSecurity));

    // 添加限流策略
    _strategies.add(
      RateLimitStrategy(
        enabled: true,
        maxRequestsPerMinute: maxRequestsPerMinute,
      ),
    );

    // 添加降级策略
    if (fallbackUrls.isNotEmpty) {
      _strategies.add(
        FallbackStrategy(enabled: true, fallbackUrls: fallbackUrls),
      );
    }

    _isInitialized = true;
    debugPrint('网络策略工厂初始化完成，共加载 ${_strategies.length} 个策略');
  }

  /// 获取特定类型的策略
  T? getStrategy<T extends NetworkStrategy>() {
    try {
      return _strategies.whereType<T>().first;
    } catch (e) {
      return null;
    }
  }

  /// 应用所有策略
  ///
  /// 将所有启用的策略按顺序应用到网络请求上
  /// [options] 请求选项
  /// [request] 原始请求函数
  /// 返回应用策略后的响应结果
  Future<Response<T>> applyStrategies<T>(
    RequestOptions options,
    Future<Response<T>> Function() request,
  ) async {
    // 初始化包装请求函数为原始请求
    Future<Response<T>> Function() wrappedRequest = request;

    // 按顺序应用每个启用的策略
    // 每个策略都会包装前一个请求函数，形成策略链
    for (final strategy in _strategies.where((s) => s.enabled)) {
      // 保存当前的请求函数引用
      final currentRequest = wrappedRequest;

      // 创建新的包装函数，将当前策略应用到之前的请求函数上
      wrappedRequest = () => strategy.apply(options, currentRequest);
    }

    // 执行最终的包装请求函数（包含所有策略）
    return await wrappedRequest();
  }

  /// 添加自定义策略
  void addStrategy(NetworkStrategy strategy) {
    _strategies.add(strategy);
    debugPrint('添加自定义策略: ${strategy.name}');
  }

  /// 移除策略
  void removeStrategy(NetworkStrategyType type) {
    _strategies.removeWhere((strategy) => strategy.type == type);
    debugPrint('移除策略: $type');
  }

  /// 清空缓存
  void clearCache() {
    final cacheStrategy = getStrategy<CacheStrategy>();
    cacheStrategy?.clearCache();
  }

  @override
  void onClose() {
    _strategies.clear();
    _isInitialized = false;
    super.onClose();
  }
}
