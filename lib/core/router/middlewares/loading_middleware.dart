/// 加载中间件
/// 
/// 在路由层处理页面加载状态和网络检查
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'base_middleware.dart';

/// 加载中间件配置
class LoadingMiddlewareConfig {
  /// 是否启用全局加载状态
  final bool enableGlobalLoading;
  
  /// 是否启用网络状态检查
  final bool enableNetworkCheck;
  
  /// 最小加载时间（毫秒）
  final int minLoadingDuration;
  
  /// 加载超时时间（毫秒）
  final int loadingTimeout;
  
  /// 页面数据预加载回调
  final Future<bool> Function()? onPreloadData;
  
  /// 网络状态变化回调
  final void Function(bool isConnected)? onNetworkStatusChanged;
  
  /// 加载开始回调
  final void Function(String route)? onLoadingStart;
  
  /// 加载完成回调
  final void Function(String route, Duration duration)? onLoadingComplete;
  
  /// 加载失败回调
  final void Function(String route, String error)? onLoadingError;

  const LoadingMiddlewareConfig({
    this.enableGlobalLoading = true,
    this.enableNetworkCheck = true,
    this.minLoadingDuration = 500,
    this.loadingTimeout = 30000,
    this.onPreloadData,
    this.onNetworkStatusChanged,
    this.onLoadingStart,
    this.onLoadingComplete,
    this.onLoadingError,
  });

  /// 复制并修改配置
  LoadingMiddlewareConfig copyWith({
    bool? enableGlobalLoading,
    bool? enableNetworkCheck,
    int? minLoadingDuration,
    int? loadingTimeout,
    Future<bool> Function()? onPreloadData,
    void Function(bool)? onNetworkStatusChanged,
    void Function(String)? onLoadingStart,
    void Function(String, Duration)? onLoadingComplete,
    void Function(String, String)? onLoadingError,
  }) {
    return LoadingMiddlewareConfig(
      enableGlobalLoading: enableGlobalLoading ?? this.enableGlobalLoading,
      enableNetworkCheck: enableNetworkCheck ?? this.enableNetworkCheck,
      minLoadingDuration: minLoadingDuration ?? this.minLoadingDuration,
      loadingTimeout: loadingTimeout ?? this.loadingTimeout,
      onPreloadData: onPreloadData ?? this.onPreloadData,
      onNetworkStatusChanged: onNetworkStatusChanged ?? this.onNetworkStatusChanged,
      onLoadingStart: onLoadingStart ?? this.onLoadingStart,
      onLoadingComplete: onLoadingComplete ?? this.onLoadingComplete,
      onLoadingError: onLoadingError ?? this.onLoadingError,
    );
  }
}

/// 加载中间件实现
class LoadingMiddleware extends BaseRouteMiddleware {
  final LoadingMiddlewareConfig config;
  DateTime? _loadingStartTime;
  bool _isLoading = false;

  LoadingMiddleware(this.config);

  @override
  String get middlewareName => 'LoadingMiddleware';

  @override
  String get description => '加载状态管理中间件，处理页面加载和网络检查';

  @override
  int? get priority => 20; // 加载检查优先级中等

  @override
  Map<String, dynamic> get configuration => {
    'enable_global_loading': config.enableGlobalLoading,
    'enable_network_check': config.enableNetworkCheck,
    'min_loading_duration': config.minLoadingDuration,
    'loading_timeout': config.loadingTimeout,
  };

  @override
  Future<MiddlewareResult> preCheck(String? route, Map<String, String>? parameters) async {
    if (route == null) {
      return MiddlewareResult.proceed();
    }

    try {
      logInfo('开始加载检查，路由: $route');
      _loadingStartTime = DateTime.now();
      _isLoading = true;

      // 执行加载开始回调
      config.onLoadingStart?.call(route);

      // 检查网络状态
      if (config.enableNetworkCheck) {
        final networkResult = await _checkNetworkStatus(route);
        if (!networkResult.canProceed) {
          return networkResult;
        }
      }

      // 执行数据预加载
      if (config.onPreloadData != null) {
        final preloadResult = await _executePreloadData(route);
        if (!preloadResult.canProceed) {
          return preloadResult;
        }
      }

      // 确保最小加载时间
      await _ensureMinLoadingDuration();

      final duration = DateTime.now().difference(_loadingStartTime!);
      config.onLoadingComplete?.call(route, duration);
      
      _isLoading = false;
      logInfo('加载检查完成，路由: $route, 耗时: ${duration.inMilliseconds}ms');
      
      return MiddlewareResult.proceed();
    } catch (e) {
      _isLoading = false;
      final errorMessage = '加载检查失败: $e';
      logError(errorMessage, e);
      
      config.onLoadingError?.call(route, errorMessage);
      
      return MiddlewareResult.redirect(
        '/error',
        errorMessage: errorMessage,
      );
    }
  }

  @override
  Widget onPageBuiltInternal(Widget page) {
    // 如果正在加载且启用了全局加载状态，显示加载页面
    if (_isLoading && config.enableGlobalLoading) {
      return _buildLoadingPage();
    }
    
    return page;
  }

  @override
  void onPageDisposeInternal() {
    super.onPageDisposeInternal();
    
    // 清理加载状态
    if (_isLoading) {
      _isLoading = false;
      logInfo('页面销毁，清理加载状态');
    }
  }

  /// 检查网络状态
  Future<MiddlewareResult> _checkNetworkStatus(String route) async {
    try {
      logInfo('检查网络状态');
      
      // 这里可以集成具体的网络检查库，如 connectivity_plus
      final isConnected = await _performNetworkCheck();
      
      if (!isConnected) {
        logWarning('网络连接失败');
        config.onNetworkStatusChanged?.call(false);
        
        return MiddlewareResult.redirect(
          '/network_error',
          errorMessage: '网络连接失败，请检查网络设置',
        );
      }
      
      config.onNetworkStatusChanged?.call(true);
      logInfo('网络连接正常');
      
      return MiddlewareResult.proceed();
    } catch (e) {
      logError('网络状态检查异常', e);
      return MiddlewareResult.redirect(
        '/network_error',
        errorMessage: '网络状态检查失败: $e',
      );
    }
  }

  /// 执行数据预加载
  Future<MiddlewareResult> _executePreloadData(String route) async {
    try {
      logInfo('开始数据预加载');
      
      // 设置超时
      final preloadFuture = config.onPreloadData!();
      final timeoutFuture = Future.delayed(
        Duration(milliseconds: config.loadingTimeout),
        () => false,
      );
      
      final result = await Future.any([preloadFuture, timeoutFuture]);
      
      if (!result) {
        logWarning('数据预加载失败或超时');
        return MiddlewareResult.redirect(
          '/loading_error',
          errorMessage: '数据加载失败，请重试',
        );
      }
      
      logInfo('数据预加载完成');
      return MiddlewareResult.proceed();
    } catch (e) {
      logError('数据预加载异常', e);
      return MiddlewareResult.redirect(
        '/loading_error',
        errorMessage: '数据预加载失败: $e',
      );
    }
  }

  /// 确保最小加载时间
  Future<void> _ensureMinLoadingDuration() async {
    if (_loadingStartTime == null) return;
    
    final elapsed = DateTime.now().difference(_loadingStartTime!);
    final minDuration = Duration(milliseconds: config.minLoadingDuration);
    
    if (elapsed < minDuration) {
      final remainingTime = minDuration - elapsed;
      logInfo('等待最小加载时间: ${remainingTime.inMilliseconds}ms');
      await Future.delayed(remainingTime);
    }
  }

  /// 执行网络检查
  Future<bool> _performNetworkCheck() async {
    try {
      // 这里可以集成具体的网络检查库
      // 示例：使用 connectivity_plus
      // final connectivityResult = await Connectivity().checkConnectivity();
      // return connectivityResult != ConnectivityResult.none;
      
      // 简单的网络检查示例（实际项目中应该使用更可靠的方法）
      await Future.delayed(const Duration(milliseconds: 100));
      return true; // 暂时返回 true
    } catch (e) {
      logError('网络检查失败', e);
      return false;
    }
  }

  /// 构建加载页面
  Widget _buildLoadingPage() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '页面加载中...',
              style: Get.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '请稍候',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 加载中间件构建器
class LoadingMiddlewareBuilder {
  LoadingMiddlewareConfig _config = const LoadingMiddlewareConfig();

  /// 设置是否启用全局加载状态
  LoadingMiddlewareBuilder enableGlobalLoading(bool enable) {
    _config = _config.copyWith(enableGlobalLoading: enable);
    return this;
  }

  /// 设置是否启用网络检查
  LoadingMiddlewareBuilder enableNetworkCheck(bool enable) {
    _config = _config.copyWith(enableNetworkCheck: enable);
    return this;
  }

  /// 设置最小加载时间
  LoadingMiddlewareBuilder minLoadingDuration(int milliseconds) {
    _config = _config.copyWith(minLoadingDuration: milliseconds);
    return this;
  }

  /// 设置加载超时时间
  LoadingMiddlewareBuilder loadingTimeout(int milliseconds) {
    _config = _config.copyWith(loadingTimeout: milliseconds);
    return this;
  }

  /// 设置数据预加载回调
  LoadingMiddlewareBuilder onPreloadData(Future<bool> Function() callback) {
    _config = _config.copyWith(onPreloadData: callback);
    return this;
  }

  /// 设置网络状态变化回调
  LoadingMiddlewareBuilder onNetworkStatusChanged(void Function(bool) callback) {
    _config = _config.copyWith(onNetworkStatusChanged: callback);
    return this;
  }

  /// 设置加载开始回调
  LoadingMiddlewareBuilder onLoadingStart(void Function(String) callback) {
    _config = _config.copyWith(onLoadingStart: callback);
    return this;
  }

  /// 设置加载完成回调
  LoadingMiddlewareBuilder onLoadingComplete(void Function(String, Duration) callback) {
    _config = _config.copyWith(onLoadingComplete: callback);
    return this;
  }

  /// 设置加载失败回调
  LoadingMiddlewareBuilder onLoadingError(void Function(String, String) callback) {
    _config = _config.copyWith(onLoadingError: callback);
    return this;
  }

  /// 构建加载中间件
  LoadingMiddleware build() {
    return LoadingMiddleware(_config);
  }
}

/// 加载中间件工厂
class LoadingMiddlewareFactory {
  /// 创建基础加载中间件
  static LoadingMiddleware basic() {
    return LoadingMiddlewareBuilder().build();
  }

  /// 创建带网络检查的中间件
  static LoadingMiddleware withNetworkCheck({
    void Function(bool)? onNetworkStatusChanged,
  }) {
    return LoadingMiddlewareBuilder()
        .enableNetworkCheck(true)
        .onNetworkStatusChanged(onNetworkStatusChanged ?? (isConnected) {})
        .build();
  }

  /// 创建带数据预加载的中间件
  static LoadingMiddleware withPreload(Future<bool> Function() preloadData) {
    return LoadingMiddlewareBuilder()
        .onPreloadData(preloadData)
        .build();
  }

  /// 创建完整功能的中间件
  static LoadingMiddleware full({
    bool enableNetworkCheck = true,
    int minLoadingDuration = 500,
    int loadingTimeout = 30000,
    Future<bool> Function()? preloadData,
    void Function(bool)? onNetworkStatusChanged,
  }) {
    final builder = LoadingMiddlewareBuilder()
        .enableNetworkCheck(enableNetworkCheck)
        .minLoadingDuration(minLoadingDuration)
        .loadingTimeout(loadingTimeout);

    if (preloadData != null) {
      builder.onPreloadData(preloadData);
    }

    if (onNetworkStatusChanged != null) {
      builder.onNetworkStatusChanged(onNetworkStatusChanged);
    }

    return builder.build();
  }
}
