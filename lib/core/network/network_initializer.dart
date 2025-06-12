/// 网络初始化器
///
/// 负责网络层的完整初始化流程，包括：
/// - 配置管理器初始化
/// - 网络策略配置
/// - 健康检查
/// - 连接性监控
/// - 错误恢复机制
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'network_config_manager.dart';
import 'network_service.dart';
import 'network_health_checker.dart';
import 'network_strategy_factory.dart';
import '../app/app_config.dart';

/// 网络初始化状态枚举
enum NetworkInitializationStatus {
  /// 未初始化
  notInitialized,

  /// 初始化中
  initializing,

  /// 初始化成功
  initialized,

  /// 初始化失败
  failed,

  /// 重新初始化中
  reinitializing,
}

/// 网络初始化结果
class NetworkInitializationResult {
  /// 是否成功
  final bool success;

  /// 错误信息
  final String? error;

  /// 初始化耗时
  final Duration duration;

  /// 详细信息
  final Map<String, dynamic> details;

  const NetworkInitializationResult({
    required this.success,
    this.error,
    required this.duration,
    this.details = const {},
  });

  @override
  String toString() {
    return 'NetworkInitializationResult{success: $success, error: $error, duration: ${duration.inMilliseconds}ms}';
  }
}

/// 网络初始化器
class NetworkInitializer extends GetxController {
  static NetworkInitializer? _instance;

  /// 单例实例
  static NetworkInitializer get instance {
    _instance ??= NetworkInitializer._internal();
    return _instance!;
  }

  NetworkInitializer._internal();

  /// 初始化状态
  final Rx<NetworkInitializationStatus> _status =
      NetworkInitializationStatus.notInitialized.obs;

  /// 连接状态监听
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// 初始化结果
  NetworkInitializationResult? _lastResult;

  /// 重试计数器
  int _retryCount = 0;

  /// 最大重试次数
  static const int _maxRetryAttempts = 3;

  /// 重试延迟
  static const Duration _retryDelay = Duration(seconds: 2);

  /// 获取当前状态
  NetworkInitializationStatus get status => _status.value;

  /// 获取最后初始化结果
  NetworkInitializationResult? get lastResult => _lastResult;

  /// 是否已初始化
  bool get isInitialized =>
      _status.value == NetworkInitializationStatus.initialized;

  /// 初始化网络层
  Future<NetworkInitializationResult> initialize({
    bool forceReinitialize = false,
  }) async {
    // 如果已经初始化且不强制重新初始化，直接返回成功
    if (isInitialized && !forceReinitialize) {
      return NetworkInitializationResult(
        success: true,
        duration: Duration.zero,
        details: {'message': '网络层已初始化'},
      );
    }

    final stopwatch = Stopwatch()..start();
    _status.value =
        forceReinitialize
            ? NetworkInitializationStatus.reinitializing
            : NetworkInitializationStatus.initializing;

    try {
      debugPrint('开始初始化网络层...');

      // 步骤1: 初始化配置管理器
      await _initializeConfigManager();

      // 步骤2: 初始化网络策略
      await _initializeNetworkStrategies();

      // 步骤3: 初始化网络服务
      await _initializeNetworkService();

      // 步骤4: 初始化健康检查器
      //await _initializeHealthChecker();

      // 步骤5: 启动连接性监控
      await _startConnectivityMonitoring();

      stopwatch.stop();
      _status.value = NetworkInitializationStatus.initialized;
      _retryCount = 0;

      _lastResult = NetworkInitializationResult(
        success: true,
        duration: stopwatch.elapsed,
        details: {
          'configVersion': NetworkConfigManager.instance.currentConfig?.version,
          'retryCount': _retryCount,
        },
      );

      debugPrint('网络层初始化成功，耗时: ${stopwatch.elapsedMilliseconds}ms');
      return _lastResult!;
    } catch (e) {
      stopwatch.stop();
      _status.value = NetworkInitializationStatus.failed;

      _lastResult = NetworkInitializationResult(
        success: false,
        error: e.toString(),
        duration: stopwatch.elapsed,
        details: {'retryCount': _retryCount, 'error': e.toString()},
      );

      debugPrint('网络层初始化失败: $e');

      // 如果初始化失败且重试次数未达上限，尝试重试
      if (_retryCount < _maxRetryAttempts) {
        _retryCount++;
        debugPrint('将在 ${_retryDelay.inSeconds} 秒后进行第 $_retryCount 次重试...');

        await Future.delayed(_retryDelay);
        return await initialize(forceReinitialize: true);
      }

      return _lastResult!;
    }
  }

  /// 初始化配置管理器
  Future<void> _initializeConfigManager() async {
    debugPrint('正在初始化网络配置管理器...');
    await NetworkConfigManager.instance.initialize();

    // 验证配置完整性
    final config = NetworkConfigManager.instance.currentConfig;
    if (!NetworkConfigManager.instance.validateConfig(config)) {
      throw Exception('网络配置验证失败');
    }

    debugPrint('网络配置管理器初始化完成');
  }

  /// 初始化网络策略
  Future<void> _initializeNetworkStrategies() async {
    debugPrint('正在初始化网络策略...');

    // 获取配置
    final configManager = NetworkConfigManager.instance;
    final enableCache = configManager.getConfigValue<bool>(
      'enable_cache',
      defaultValue: true,
    );
    final maxRetryAttempts = configManager.getConfigValue<int>(
      'max_retry_attempts',
      defaultValue: 3,
    );

    // 初始化策略工厂
    NetworkStrategyFactory.instance.initialize(
      enableCache: enableCache!,
      maxRetryAttempts: maxRetryAttempts!,
    );

    debugPrint('网络策略初始化完成');
  }

  /// 初始化网络服务
  Future<void> _initializeNetworkService() async {
    debugPrint('正在初始化网络服务...');

    // 网络服务会自动使用配置管理器的配置
    // 这里可以进行额外的配置
    final networkService = NetworkService.instance;

    // 可以在这里添加额外的拦截器或配置

    debugPrint('网络服务初始化完成');
  }

  /// 初始化健康检查器
  Future<void> _initializeHealthChecker() async {
    debugPrint('正在初始化网络健康检查器...');
    await NetworkHealthChecker.instance.initialize();
    debugPrint('网络健康检查器初始化完成');
  }

  /// 启动连接性监控
  Future<void> _startConnectivityMonitoring() async {
    debugPrint('正在启动连接性监控...');

    // 取消之前的订阅
    await _connectivitySubscription?.cancel();

    // 开始监听连接状态变化
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (error) {
        debugPrint('连接性监控错误: $error');
      },
    );

    debugPrint('连接性监控启动完成');
  }

  /// 执行初始健康检查
  Future<void> _performInitialHealthCheck() async {
    debugPrint('正在执行初始网络健康检查...');

    final healthResult =
        await NetworkHealthChecker.instance.performHealthCheck();
    if (!healthResult.isHealthy) {
      debugPrint('网络健康检查警告: ${healthResult.issues.join(', ')}');
      // 注意：这里不抛出异常，因为网络问题可能是暂时的
    }

    debugPrint('初始网络健康检查完成');
  }

  /// 连接状态变化处理
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );

    debugPrint('网络连接状态变化: $results');

    if (hasConnection) {
      _onNetworkConnected();
    } else {
      _onNetworkDisconnected();
    }
  }

  /// 网络连接恢复处理
  void _onNetworkConnected() {
    debugPrint('网络连接已恢复');

    // 可以在这里执行网络恢复后的操作
    // 例如：重新同步数据、重试失败的请求等

    // 执行健康检查
    NetworkHealthChecker.instance.performHealthCheck().then((result) {
      if (result.isHealthy) {
        debugPrint('网络恢复后健康检查通过');
      } else {
        debugPrint('网络恢复后健康检查失败: ${result.issues.join(', ')}');
      }
    });
  }

  /// 网络断开处理
  void _onNetworkDisconnected() {
    debugPrint('网络连接已断开');

    // 可以在这里执行网络断开后的操作
    // 例如：启用离线模式、暂停非关键请求等
  }

  /// 重新初始化
  Future<NetworkInitializationResult> reinitialize() async {
    debugPrint('开始重新初始化网络层...');
    return await initialize(forceReinitialize: true);
  }

  /// 获取初始化状态信息
  Map<String, dynamic> getStatusInfo() {
    return {
      'status': _status.value.toString(),
      'isInitialized': isInitialized,
      'lastResult': _lastResult?.toString(),
      'retryCount': _retryCount,
      'configVersion': NetworkConfigManager.instance.currentConfig?.version,
    };
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
