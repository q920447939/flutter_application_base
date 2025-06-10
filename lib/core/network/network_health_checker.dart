/// 网络健康检查器
///
/// 负责监控网络连接的健康状态，包括：
/// - 连接性检查
/// - 延迟测试
/// - 服务可用性检查
/// - 带宽测试
/// - DNS解析检查
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'network_config_manager.dart';

/// 健康检查项类型
enum HealthCheckType {
  /// 连接性检查
  connectivity,
  /// 延迟检查
  latency,
  /// 服务可用性检查
  serviceAvailability,
  /// DNS解析检查
  dnsResolution,
  /// 带宽检查
  bandwidth,
}

/// 健康检查结果
class HealthCheckResult {
  /// 检查类型
  final HealthCheckType type;
  /// 是否健康
  final bool isHealthy;
  /// 检查耗时
  final Duration duration;
  /// 详细信息
  final Map<String, dynamic> details;
  /// 错误信息
  final String? error;
  /// 检查时间
  final DateTime timestamp;

  const HealthCheckResult({
    required this.type,
    required this.isHealthy,
    required this.duration,
    this.details = const {},
    this.error,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'HealthCheckResult{type: $type, isHealthy: $isHealthy, duration: ${duration.inMilliseconds}ms, error: $error}';
  }
}

/// 综合健康检查结果
class ComprehensiveHealthResult {
  /// 是否整体健康
  final bool isHealthy;
  /// 各项检查结果
  final List<HealthCheckResult> results;
  /// 总检查耗时
  final Duration totalDuration;
  /// 问题列表
  final List<String> issues;
  /// 检查时间
  final DateTime timestamp;

  const ComprehensiveHealthResult({
    required this.isHealthy,
    required this.results,
    required this.totalDuration,
    required this.issues,
    required this.timestamp,
  });

  /// 获取特定类型的检查结果
  HealthCheckResult? getResult(HealthCheckType type) {
    try {
      return results.firstWhere((result) => result.type == type);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'ComprehensiveHealthResult{isHealthy: $isHealthy, issues: ${issues.length}, duration: ${totalDuration.inMilliseconds}ms}';
  }
}

/// 网络健康检查器
class NetworkHealthChecker extends GetxController {
  static NetworkHealthChecker? _instance;
  
  /// 单例实例
  static NetworkHealthChecker get instance {
    _instance ??= NetworkHealthChecker._internal();
    return _instance!;
  }

  NetworkHealthChecker._internal();

  /// Dio实例用于健康检查
  late final Dio _dio;
  
  /// 最后检查结果
  final Rx<ComprehensiveHealthResult?> _lastResult = Rx<ComprehensiveHealthResult?>(null);
  
  /// 是否正在检查
  final RxBool _isChecking = false.obs;
  
  /// 定时检查定时器
  Timer? _periodicCheckTimer;
  
  /// 检查间隔
  static const Duration _checkInterval = Duration(minutes: 5);
  
  /// 默认超时时间
  static const Duration _defaultTimeout = Duration(seconds: 10);

  /// 获取最后检查结果
  ComprehensiveHealthResult? get lastResult => _lastResult.value;
  
  /// 是否正在检查
  bool get isChecking => _isChecking.value;

  /// 初始化健康检查器
  Future<void> initialize() async {
    // 创建专用的Dio实例
    _dio = Dio(BaseOptions(
      connectTimeout: _defaultTimeout,
      receiveTimeout: _defaultTimeout,
      sendTimeout: _defaultTimeout,
    ));

    // 启动定期健康检查
    _startPeriodicCheck();
    
    debugPrint('网络健康检查器初始化完成');
  }

  /// 执行综合健康检查
  Future<ComprehensiveHealthResult> performHealthCheck({
    List<HealthCheckType>? checkTypes,
  }) async {
    if (_isChecking.value) {
      return _lastResult.value ?? _createFailedResult('检查正在进行中');
    }

    _isChecking.value = true;
    final stopwatch = Stopwatch()..start();
    final timestamp = DateTime.now();
    
    try {
      // 默认检查所有类型
      checkTypes ??= HealthCheckType.values;
      
      final results = <HealthCheckResult>[];
      final issues = <String>[];

      // 并发执行各项检查
      final futures = checkTypes.map((type) => _performSingleCheck(type));
      final checkResults = await Future.wait(futures);
      
      results.addAll(checkResults);
      
      // 收集问题
      for (final result in results) {
        if (!result.isHealthy) {
          issues.add('${result.type.name}: ${result.error ?? '检查失败'}');
        }
      }

      stopwatch.stop();
      
      final comprehensiveResult = ComprehensiveHealthResult(
        isHealthy: issues.isEmpty,
        results: results,
        totalDuration: stopwatch.elapsed,
        issues: issues,
        timestamp: timestamp,
      );

      _lastResult.value = comprehensiveResult;
      
      debugPrint('网络健康检查完成: ${comprehensiveResult.toString()}');
      return comprehensiveResult;

    } catch (e) {
      stopwatch.stop();
      final failedResult = ComprehensiveHealthResult(
        isHealthy: false,
        results: [],
        totalDuration: stopwatch.elapsed,
        issues: ['健康检查执行失败: $e'],
        timestamp: timestamp,
      );
      
      _lastResult.value = failedResult;
      debugPrint('网络健康检查失败: $e');
      return failedResult;
    } finally {
      _isChecking.value = false;
    }
  }

  /// 执行单项检查
  Future<HealthCheckResult> _performSingleCheck(HealthCheckType type) async {
    final stopwatch = Stopwatch()..start();
    final timestamp = DateTime.now();
    
    try {
      switch (type) {
        case HealthCheckType.connectivity:
          return await _checkConnectivity(stopwatch, timestamp);
        case HealthCheckType.latency:
          return await _checkLatency(stopwatch, timestamp);
        case HealthCheckType.serviceAvailability:
          return await _checkServiceAvailability(stopwatch, timestamp);
        case HealthCheckType.dnsResolution:
          return await _checkDnsResolution(stopwatch, timestamp);
        case HealthCheckType.bandwidth:
          return await _checkBandwidth(stopwatch, timestamp);
      }
    } catch (e) {
      stopwatch.stop();
      return HealthCheckResult(
        type: type,
        isHealthy: false,
        duration: stopwatch.elapsed,
        error: e.toString(),
        timestamp: timestamp,
      );
    }
  }

  /// 检查连接性
  Future<HealthCheckResult> _checkConnectivity(Stopwatch stopwatch, DateTime timestamp) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      stopwatch.stop();
      
      return HealthCheckResult(
        type: HealthCheckType.connectivity,
        isHealthy: result.isNotEmpty && result[0].rawAddress.isNotEmpty,
        duration: stopwatch.elapsed,
        details: {
          'addresses': result.map((addr) => addr.address).toList(),
        },
        timestamp: timestamp,
      );
    } catch (e) {
      stopwatch.stop();
      return HealthCheckResult(
        type: HealthCheckType.connectivity,
        isHealthy: false,
        duration: stopwatch.elapsed,
        error: e.toString(),
        timestamp: timestamp,
      );
    }
  }

  /// 检查延迟
  Future<HealthCheckResult> _checkLatency(Stopwatch stopwatch, DateTime timestamp) async {
    try {
      final response = await _dio.get('https://httpbin.org/get');
      stopwatch.stop();
      
      final latency = stopwatch.elapsedMilliseconds;
      final isHealthy = latency < 3000; // 3秒内认为健康
      
      return HealthCheckResult(
        type: HealthCheckType.latency,
        isHealthy: isHealthy,
        duration: stopwatch.elapsed,
        details: {
          'latency_ms': latency,
          'status_code': response.statusCode,
        },
        error: isHealthy ? null : '延迟过高: ${latency}ms',
        timestamp: timestamp,
      );
    } catch (e) {
      stopwatch.stop();
      return HealthCheckResult(
        type: HealthCheckType.latency,
        isHealthy: false,
        duration: stopwatch.elapsed,
        error: e.toString(),
        timestamp: timestamp,
      );
    }
  }

  /// 检查服务可用性
  Future<HealthCheckResult> _checkServiceAvailability(Stopwatch stopwatch, DateTime timestamp) async {
    try {
      final baseUrl = NetworkConfigManager.instance.getConfigValue<String>('base_url');
      if (baseUrl == null) {
        throw Exception('未配置基础URL');
      }

      // 尝试访问健康检查端点
      final response = await _dio.get('$baseUrl/health');
      stopwatch.stop();
      
      final isHealthy = response.statusCode == 200;
      
      return HealthCheckResult(
        type: HealthCheckType.serviceAvailability,
        isHealthy: isHealthy,
        duration: stopwatch.elapsed,
        details: {
          'status_code': response.statusCode,
          'base_url': baseUrl,
        },
        error: isHealthy ? null : '服务不可用: ${response.statusCode}',
        timestamp: timestamp,
      );
    } catch (e) {
      stopwatch.stop();
      return HealthCheckResult(
        type: HealthCheckType.serviceAvailability,
        isHealthy: false,
        duration: stopwatch.elapsed,
        error: e.toString(),
        timestamp: timestamp,
      );
    }
  }

  /// 检查DNS解析
  Future<HealthCheckResult> _checkDnsResolution(Stopwatch stopwatch, DateTime timestamp) async {
    try {
      final baseUrl = NetworkConfigManager.instance.getConfigValue<String>('base_url');
      if (baseUrl == null) {
        throw Exception('未配置基础URL');
      }

      final uri = Uri.parse(baseUrl);
      final result = await InternetAddress.lookup(uri.host);
      stopwatch.stop();
      
      return HealthCheckResult(
        type: HealthCheckType.dnsResolution,
        isHealthy: result.isNotEmpty,
        duration: stopwatch.elapsed,
        details: {
          'host': uri.host,
          'addresses': result.map((addr) => addr.address).toList(),
        },
        timestamp: timestamp,
      );
    } catch (e) {
      stopwatch.stop();
      return HealthCheckResult(
        type: HealthCheckType.dnsResolution,
        isHealthy: false,
        duration: stopwatch.elapsed,
        error: e.toString(),
        timestamp: timestamp,
      );
    }
  }

  /// 检查带宽（简单测试）
  Future<HealthCheckResult> _checkBandwidth(Stopwatch stopwatch, DateTime timestamp) async {
    try {
      // 下载一个小文件来测试带宽
      final response = await _dio.get(
        'https://httpbin.org/bytes/1024', // 1KB测试文件
        options: Options(responseType: ResponseType.bytes),
      );
      stopwatch.stop();
      
      final bytes = (response.data as List<int>).length;
      final seconds = stopwatch.elapsed.inMilliseconds / 1000.0;
      final kbps = (bytes / 1024) / seconds;
      
      final isHealthy = kbps > 1; // 1KB/s以上认为健康
      
      return HealthCheckResult(
        type: HealthCheckType.bandwidth,
        isHealthy: isHealthy,
        duration: stopwatch.elapsed,
        details: {
          'bytes': bytes,
          'kbps': kbps.toStringAsFixed(2),
        },
        error: isHealthy ? null : '带宽过低: ${kbps.toStringAsFixed(2)} KB/s',
        timestamp: timestamp,
      );
    } catch (e) {
      stopwatch.stop();
      return HealthCheckResult(
        type: HealthCheckType.bandwidth,
        isHealthy: false,
        duration: stopwatch.elapsed,
        error: e.toString(),
        timestamp: timestamp,
      );
    }
  }

  /// 启动定期检查
  void _startPeriodicCheck() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = Timer.periodic(_checkInterval, (timer) {
      if (!_isChecking.value) {
        performHealthCheck();
      }
    });
  }

  /// 停止定期检查
  void stopPeriodicCheck() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = null;
  }

  /// 创建失败结果
  ComprehensiveHealthResult _createFailedResult(String error) {
    return ComprehensiveHealthResult(
      isHealthy: false,
      results: [],
      totalDuration: Duration.zero,
      issues: [error],
      timestamp: DateTime.now(),
    );
  }

  @override
  void onClose() {
    _periodicCheckTimer?.cancel();
    _dio.close();
    super.onClose();
  }
}
