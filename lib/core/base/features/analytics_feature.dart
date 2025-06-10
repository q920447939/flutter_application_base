/// 页面分析功能
/// 
/// 实现页面访问统计和用户行为分析
library;

import 'package:flutter/material.dart';
import '../base_page.dart';

/// 分析功能配置
class AnalyticsFeatureConfig {
  /// 页面名称（用于统计）
  final String? pageName;
  
  /// 是否启用页面访问统计
  final bool enablePageView;
  
  /// 是否启用停留时间统计
  final bool enableDuration;
  
  /// 自定义参数
  final Map<String, dynamic> customParameters;
  
  /// 页面进入事件回调
  final void Function(String route, Map<String, dynamic> parameters)? onPageEnter;
  
  /// 页面退出事件回调
  final void Function(String route, Duration duration)? onPageExit;

  const AnalyticsFeatureConfig({
    this.pageName,
    this.enablePageView = true,
    this.enableDuration = true,
    this.customParameters = const {},
    this.onPageEnter,
    this.onPageExit,
  });
}

/// 分析功能实现
class AnalyticsFeature implements IPageFeature {
  final AnalyticsFeatureConfig config;
  DateTime? _enterTime;

  AnalyticsFeature(this.config);

  @override
  String get featureName => 'AnalyticsFeature';

  @override
  Future<bool> onPageEnter(BuildContext context, String route) async {
    if (config.enableDuration) {
      _enterTime = DateTime.now();
    }

    if (config.enablePageView) {
      final pageName = config.pageName ?? route;
      final parameters = {
        'route': route,
        'timestamp': DateTime.now().toIso8601String(),
        ...config.customParameters,
      };

      // 记录页面访问
      _trackPageView(pageName, parameters);
      
      // 执行自定义回调
      config.onPageEnter?.call(route, parameters);
    }

    return true;
  }

  @override
  Widget onPageBuild(BuildContext context, Widget child) {
    // 分析功能不修改页面构建
    return child;
  }

  @override
  Future<bool> onPageExit(BuildContext context, String route) async {
    if (config.enableDuration && _enterTime != null) {
      final duration = DateTime.now().difference(_enterTime!);
      
      // 记录停留时间
      _trackDuration(route, duration);
      
      // 执行自定义回调
      config.onPageExit?.call(route, duration);
    }

    return true;
  }

  @override
  void onPageDispose() {
    // 清理资源
    _enterTime = null;
  }

  /// 记录页面访问
  void _trackPageView(String pageName, Map<String, dynamic> parameters) {
    // 这里可以集成具体的分析服务，如 Firebase Analytics, 友盟等
    debugPrint('📊 页面访问: $pageName, 参数: $parameters');
    
    // 示例：发送到分析服务
    // FirebaseAnalytics.instance.logScreenView(
    //   screenName: pageName,
    //   parameters: parameters,
    // );
  }

  /// 记录停留时间
  void _trackDuration(String route, Duration duration) {
    debugPrint('⏱️ 页面停留时间: $route, 时长: ${duration.inSeconds}秒');
    
    // 示例：发送到分析服务
    // FirebaseAnalytics.instance.logEvent(
    //   name: 'page_duration',
    //   parameters: {
    //     'route': route,
    //     'duration_seconds': duration.inSeconds,
    //   },
    // );
  }
}

/// 分析功能构建器
class AnalyticsFeatureBuilder {
  /// 创建基础分析功能
  static AnalyticsFeature basic({String? pageName}) {
    return AnalyticsFeature(AnalyticsFeatureConfig(
      pageName: pageName,
    ));
  }

  /// 创建详细分析功能
  static AnalyticsFeature detailed({
    String? pageName,
    Map<String, dynamic> customParameters = const {},
    void Function(String route, Map<String, dynamic> parameters)? onPageEnter,
    void Function(String route, Duration duration)? onPageExit,
  }) {
    return AnalyticsFeature(AnalyticsFeatureConfig(
      pageName: pageName,
      customParameters: customParameters,
      onPageEnter: onPageEnter,
      onPageExit: onPageExit,
    ));
  }

  /// 创建自定义分析功能
  static AnalyticsFeature custom(AnalyticsFeatureConfig config) {
    return AnalyticsFeature(config);
  }
}
