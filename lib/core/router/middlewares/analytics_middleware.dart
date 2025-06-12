/// 分析中间件
///
/// 在路由层处理页面访问统计和用户行为分析
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'base_middleware.dart';

/// 分析中间件配置
class AnalyticsMiddlewareConfig {
  /// 页面名称（用于统计）
  final String? pageName;

  /// 是否启用页面访问统计
  final bool enablePageView;

  /// 是否启用停留时间统计
  final bool enableDuration;

  /// 自定义参数
  final Map<String, dynamic> customParameters;

  /// 页面进入事件回调
  final void Function(String route, Map<String, dynamic> parameters)?
  onPageEnter;

  /// 页面退出事件回调
  final void Function(String route, Duration duration)? onPageExit;

  /// 页面访问事件回调
  final void Function(String pageName, Map<String, dynamic> parameters)?
  onPageView;

  const AnalyticsMiddlewareConfig({
    this.pageName,
    this.enablePageView = true,
    this.enableDuration = true,
    this.customParameters = const {},
    this.onPageEnter,
    this.onPageExit,
    this.onPageView,
  });

  /// 复制并修改配置
  AnalyticsMiddlewareConfig copyWith({
    String? pageName,
    bool? enablePageView,
    bool? enableDuration,
    Map<String, dynamic>? customParameters,
    void Function(String, Map<String, dynamic>)? onPageEnter,
    void Function(String, Duration)? onPageExit,
    void Function(String, Map<String, dynamic>)? onPageView,
  }) {
    return AnalyticsMiddlewareConfig(
      pageName: pageName ?? this.pageName,
      enablePageView: enablePageView ?? this.enablePageView,
      enableDuration: enableDuration ?? this.enableDuration,
      customParameters: customParameters ?? this.customParameters,
      onPageEnter: onPageEnter ?? this.onPageEnter,
      onPageExit: onPageExit ?? this.onPageExit,
      onPageView: onPageView ?? this.onPageView,
    );
  }
}

/// 分析中间件实现
class AnalyticsMiddleware extends BaseRouteMiddleware {
  final AnalyticsMiddlewareConfig config;
  DateTime? _enterTime;
  String? _currentRoute;

  AnalyticsMiddleware(this.config);

  @override
  String get middlewareName => 'AnalyticsMiddleware';

  @override
  String get description => '页面访问分析中间件，统计页面访问和用户行为';

  @override
  int? get priority => 50; // 分析统计优先级较低

  @override
  Map<String, dynamic> get configuration => {
    'page_name': config.pageName,
    'enable_page_view': config.enablePageView,
    'enable_duration': config.enableDuration,
    'custom_parameters': config.customParameters,
  };

  @override
  Future<MiddlewareResult> preCheck(
    String? route,
    Map<String, String>? parameters,
  ) async {
    _currentRoute = route;

    if (config.enableDuration) {
      _enterTime = DateTime.now();
      logInfo('记录页面进入时间: $route');
    }

    if (config.enablePageView) {
      await _trackPageView(route, parameters);
    }

    // 执行自定义页面进入回调
    if (config.onPageEnter != null && route != null) {
      try {
        final allParameters = <String, dynamic>{
          'route': route,
          'timestamp': DateTime.now().toIso8601String(),
          ...config.customParameters,
          if (parameters != null) ...parameters,
        };

        config.onPageEnter!(route, allParameters);
        logInfo('执行页面进入回调: $route');
      } catch (e) {
        logError('页面进入回调执行失败', e);
      }
    }

    return MiddlewareResult.proceed();
  }

  @override
  MiddlewareResult preCheckSync(
    String? route,
    Map<String, String>? parameters,
  ) {
    return MiddlewareResult.proceed();
  }

  @override
  Future<void> postProcess(
    String? route,
    Map<String, String>? parameters,
  ) async {
    if (config.enableDuration && _enterTime != null && route != null) {
      final duration = DateTime.now().difference(_enterTime!);

      // 记录停留时间
      await _trackDuration(route, duration);

      // 执行自定义页面退出回调
      if (config.onPageExit != null) {
        try {
          config.onPageExit!(route, duration);
          logInfo('执行页面退出回调: $route, 停留时间: ${duration.inSeconds}秒');
        } catch (e) {
          logError('页面退出回调执行失败', e);
        }
      }
    }
  }

  @override
  void onPageDisposeInternal() {
    super.onPageDisposeInternal();

    // 清理状态
    if (_currentRoute != null && _enterTime != null) {
      final duration = DateTime.now().difference(_enterTime!);
      logInfo('页面销毁，总停留时间: ${duration.inSeconds}秒');
    }

    _enterTime = null;
    _currentRoute = null;
  }

  /// 记录页面访问
  Future<void> _trackPageView(
    String? route,
    Map<String, String>? parameters,
  ) async {
    if (route == null) return;

    try {
      final pageName = config.pageName ?? _extractPageNameFromRoute(route);
      final allParameters = <String, dynamic>{
        'route': route,
        'timestamp': DateTime.now().toIso8601String(),
        'page_name': pageName,
        ...config.customParameters,
        if (parameters != null) ...parameters,
      };

      // 记录页面访问
      await _sendPageViewEvent(pageName, allParameters);

      // 执行自定义页面访问回调
      if (config.onPageView != null) {
        config.onPageView!(pageName, allParameters);
      }

      logInfo('记录页面访问: $pageName');
    } catch (e) {
      logError('记录页面访问失败', e);
    }
  }

  /// 记录停留时间
  Future<void> _trackDuration(String route, Duration duration) async {
    try {
      final pageName = config.pageName ?? _extractPageNameFromRoute(route);
      final parameters = <String, dynamic>{
        'route': route,
        'page_name': pageName,
        'duration_seconds': duration.inSeconds,
        'duration_milliseconds': duration.inMilliseconds,
        'timestamp': DateTime.now().toIso8601String(),
        ...config.customParameters,
      };

      // 记录停留时间
      await _sendDurationEvent(pageName, parameters);

      logInfo('记录页面停留时间: $pageName, ${duration.inSeconds}秒');
    } catch (e) {
      logError('记录页面停留时间失败', e);
    }
  }

  /// 发送页面访问事件
  Future<void> _sendPageViewEvent(
    String pageName,
    Map<String, dynamic> parameters,
  ) async {
    // 这里可以集成具体的分析服务，如 Firebase Analytics, 友盟等
    debugPrint('📊 页面访问事件: $pageName');
    debugPrint('📊 参数: $parameters');

    // 示例：发送到分析服务
    // await FirebaseAnalytics.instance.logScreenView(
    //   screenName: pageName,
    //   parameters: parameters,
    // );

    // 示例：发送到自定义分析服务
    // await AnalyticsService.instance.trackPageView(pageName, parameters);
  }

  /// 发送停留时间事件
  Future<void> _sendDurationEvent(
    String pageName,
    Map<String, dynamic> parameters,
  ) async {
    // 这里可以集成具体的分析服务
    debugPrint('⏱️ 页面停留时间事件: $pageName');
    debugPrint('⏱️ 参数: $parameters');

    // 示例：发送到分析服务
    // await FirebaseAnalytics.instance.logEvent(
    //   name: 'page_duration',
    //   parameters: parameters,
    // );

    // 示例：发送到自定义分析服务
    // await AnalyticsService.instance.trackPageDuration(pageName, parameters);
  }

  /// 从路由提取页面名称
  String _extractPageNameFromRoute(String route) {
    // 移除查询参数
    final uri = Uri.parse(route);
    String path = uri.path;

    // 移除前导斜杠
    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    // 如果路径为空，返回默认名称
    if (path.isEmpty) {
      return 'home';
    }

    // 将路径转换为页面名称（替换斜杠为下划线）
    return path.replaceAll('/', '_');
  }
}

/// 分析中间件构建器
class AnalyticsMiddlewareBuilder {
  AnalyticsMiddlewareConfig _config = const AnalyticsMiddlewareConfig();

  /// 设置页面名称
  AnalyticsMiddlewareBuilder pageName(String name) {
    _config = _config.copyWith(pageName: name);
    return this;
  }

  /// 设置是否启用页面访问统计
  AnalyticsMiddlewareBuilder enablePageView(bool enable) {
    _config = _config.copyWith(enablePageView: enable);
    return this;
  }

  /// 设置是否启用停留时间统计
  AnalyticsMiddlewareBuilder enableDuration(bool enable) {
    _config = _config.copyWith(enableDuration: enable);
    return this;
  }

  /// 设置自定义参数
  AnalyticsMiddlewareBuilder customParameters(Map<String, dynamic> parameters) {
    _config = _config.copyWith(customParameters: parameters);
    return this;
  }

  /// 添加自定义参数
  AnalyticsMiddlewareBuilder addParameter(String key, dynamic value) {
    final newParameters = Map<String, dynamic>.from(_config.customParameters);
    newParameters[key] = value;
    _config = _config.copyWith(customParameters: newParameters);
    return this;
  }

  /// 设置页面进入回调
  AnalyticsMiddlewareBuilder onPageEnter(
    void Function(String, Map<String, dynamic>) callback,
  ) {
    _config = _config.copyWith(onPageEnter: callback);
    return this;
  }

  /// 设置页面退出回调
  AnalyticsMiddlewareBuilder onPageExit(
    void Function(String, Duration) callback,
  ) {
    _config = _config.copyWith(onPageExit: callback);
    return this;
  }

  /// 设置页面访问回调
  AnalyticsMiddlewareBuilder onPageView(
    void Function(String, Map<String, dynamic>) callback,
  ) {
    _config = _config.copyWith(onPageView: callback);
    return this;
  }

  /// 构建分析中间件
  AnalyticsMiddleware build() {
    return AnalyticsMiddleware(_config);
  }
}

/// 分析中间件工厂
class AnalyticsMiddlewareFactory {
  /// 创建基础分析中间件
  static AnalyticsMiddleware basic({String? pageName}) {
    return AnalyticsMiddlewareBuilder().pageName(pageName ?? '').build();
  }

  /// 创建详细分析中间件
  static AnalyticsMiddleware detailed({
    String? pageName,
    Map<String, dynamic> customParameters = const {},
    void Function(String, Map<String, dynamic>)? onPageEnter,
    void Function(String, Duration)? onPageExit,
  }) {
    return AnalyticsMiddlewareBuilder()
        .pageName(pageName ?? '')
        .customParameters(customParameters)
        .onPageEnter(onPageEnter ?? (route, params) {})
        .onPageExit(onPageExit ?? (route, duration) {})
        .build();
  }

  /// 创建仅页面访问统计的中间件
  static AnalyticsMiddleware pageViewOnly({String? pageName}) {
    return AnalyticsMiddlewareBuilder()
        .pageName(pageName ?? '')
        .enableDuration(false)
        .build();
  }

  /// 创建仅停留时间统计的中间件
  static AnalyticsMiddleware durationOnly({String? pageName}) {
    return AnalyticsMiddlewareBuilder()
        .pageName(pageName ?? '')
        .enablePageView(false)
        .build();
  }
}
