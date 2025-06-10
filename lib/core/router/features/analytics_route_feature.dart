/// 分析路由功能特性
///
/// 实现页面访问分析的路由功能特性，与分析中间件配合工作
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../route_feature.dart';
import '../middlewares/analytics_middleware.dart';

/// 分析路由功能特性
class AnalyticsRouteFeature implements IRouteFeature {
  final AnalyticsMiddlewareConfig config;

  AnalyticsRouteFeature({
    String? pageName,
    bool enablePageView = true,
    bool enableDuration = true,
    Map<String, dynamic> customParameters = const {},
    void Function(String, Map<String, dynamic>)? onPageEnter,
    void Function(String, Duration)? onPageExit,
    void Function(String, Map<String, dynamic>)? onPageView,
  }) : config = AnalyticsMiddlewareConfig(
         pageName: pageName,
         enablePageView: enablePageView,
         enableDuration: enableDuration,
         customParameters: customParameters,
         onPageEnter: onPageEnter,
         onPageExit: onPageExit,
         onPageView: onPageView,
       );

  /// 使用配置构造
  const AnalyticsRouteFeature.withConfig(this.config);

  @override
  String get featureName => 'AnalyticsRouteFeature';

  @override
  String get description => '页面访问分析路由功能特性，统计页面访问和用户行为';

  @override
  int get priority => 50; // 分析统计优先级较低

  @override
  bool get isEnabled => config.enablePageView || config.enableDuration;

  @override
  GetMiddleware? createMiddleware() {
    return AnalyticsMiddleware(config);
  }

  @override
  FeatureValidationResult validate() {
    final errors = <String>[];
    final warnings = <String>[];

    // 验证页面名称
    if (config.pageName != null && config.pageName!.isEmpty) {
      warnings.add('页面名称为空，将使用路由路径作为页面名称');
    }

    // 验证自定义参数
    if (config.customParameters.isNotEmpty) {
      for (final entry in config.customParameters.entries) {
        if (entry.key.isEmpty) {
          errors.add('自定义参数的键不能为空');
        }

        // 检查参数值类型
        final value = entry.value;
        if (value != null &&
            value is! String &&
            value is! num &&
            value is! bool &&
            value is! List &&
            value is! Map) {
          warnings.add('自定义参数 ${entry.key} 的值类型可能不被分析服务支持');
        }
      }
    }

    // 验证功能启用状态
    if (!config.enablePageView && !config.enableDuration) {
      warnings.add('页面访问统计和停留时间统计都已禁用，该功能特性可能不必要');
    }

    return FeatureValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  @override
  Map<String, dynamic> getConfiguration() {
    return {
      'page_name': config.pageName,
      'enable_page_view': config.enablePageView,
      'enable_duration': config.enableDuration,
      'custom_parameters': config.customParameters,
      'has_page_enter_callback': config.onPageEnter != null,
      'has_page_exit_callback': config.onPageExit != null,
      'has_page_view_callback': config.onPageView != null,
    };
  }

  @override
  Future<void> initialize() async {
    // 分析功能特性的初始化
    // 可以在这里初始化分析服务或验证配置
  }

  @override
  void dispose() {
    // 分析功能特性的清理
    // 通常分析功能特性不需要特殊的清理操作
  }

  /// 手动记录页面访问事件
  void trackPageView(
    String route, {
    Map<String, dynamic>? additionalParameters,
  }) {
    final pageName = config.pageName ?? _extractPageNameFromRoute(route);
    final parameters = <String, dynamic>{
      'route': route,
      'timestamp': DateTime.now().toIso8601String(),
      'page_name': pageName,
      ...config.customParameters,
      if (additionalParameters != null) ...additionalParameters,
    };

    // 执行页面访问回调
    config.onPageView?.call(pageName, parameters);
  }

  /// 手动记录自定义事件
  void trackCustomEvent(String eventName, Map<String, dynamic> parameters) {
    final allParameters = <String, dynamic>{
      'event_name': eventName,
      'timestamp': DateTime.now().toIso8601String(),
      ...config.customParameters,
      ...parameters,
    };

    // 这里可以扩展为支持自定义事件的回调
    // config.onCustomEvent?.call(eventName, allParameters);
    debugPrint(
      'Analytics: Custom event $eventName with parameters: $allParameters',
    );
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

  /// 复制并修改功能特性
  AnalyticsRouteFeature copyWith({
    String? pageName,
    bool? enablePageView,
    bool? enableDuration,
    Map<String, dynamic>? customParameters,
    void Function(String, Map<String, dynamic>)? onPageEnter,
    void Function(String, Duration)? onPageExit,
    void Function(String, Map<String, dynamic>)? onPageView,
  }) {
    return AnalyticsRouteFeature.withConfig(
      config.copyWith(
        pageName: pageName,
        enablePageView: enablePageView,
        enableDuration: enableDuration,
        customParameters: customParameters,
        onPageEnter: onPageEnter,
        onPageExit: onPageExit,
        onPageView: onPageView,
      ),
    );
  }

  @override
  String toString() {
    return 'AnalyticsRouteFeature(pageName: ${config.pageName}, pageView: ${config.enablePageView}, duration: ${config.enableDuration})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsRouteFeature &&
        other.config.pageName == config.pageName &&
        other.config.enablePageView == config.enablePageView &&
        other.config.enableDuration == config.enableDuration;
  }

  @override
  int get hashCode => Object.hash(
    config.pageName,
    config.enablePageView,
    config.enableDuration,
  );
}

/// 分析路由功能特性构建器
class AnalyticsRouteFeatureBuilder {
  AnalyticsMiddlewareConfig _config = const AnalyticsMiddlewareConfig();

  /// 设置页面名称
  AnalyticsRouteFeatureBuilder pageName(String name) {
    _config = _config.copyWith(pageName: name);
    return this;
  }

  /// 设置是否启用页面访问统计
  AnalyticsRouteFeatureBuilder enablePageView(bool enable) {
    _config = _config.copyWith(enablePageView: enable);
    return this;
  }

  /// 设置是否启用停留时间统计
  AnalyticsRouteFeatureBuilder enableDuration(bool enable) {
    _config = _config.copyWith(enableDuration: enable);
    return this;
  }

  /// 设置自定义参数
  AnalyticsRouteFeatureBuilder customParameters(
    Map<String, dynamic> parameters,
  ) {
    _config = _config.copyWith(customParameters: parameters);
    return this;
  }

  /// 添加自定义参数
  AnalyticsRouteFeatureBuilder addParameter(String key, dynamic value) {
    final newParameters = Map<String, dynamic>.from(_config.customParameters);
    newParameters[key] = value;
    _config = _config.copyWith(customParameters: newParameters);
    return this;
  }

  /// 批量添加自定义参数
  AnalyticsRouteFeatureBuilder addParameters(Map<String, dynamic> parameters) {
    final newParameters = Map<String, dynamic>.from(_config.customParameters);
    newParameters.addAll(parameters);
    _config = _config.copyWith(customParameters: newParameters);
    return this;
  }

  /// 设置页面进入回调
  AnalyticsRouteFeatureBuilder onPageEnter(
    void Function(String, Map<String, dynamic>) callback,
  ) {
    _config = _config.copyWith(onPageEnter: callback);
    return this;
  }

  /// 设置页面退出回调
  AnalyticsRouteFeatureBuilder onPageExit(
    void Function(String, Duration) callback,
  ) {
    _config = _config.copyWith(onPageExit: callback);
    return this;
  }

  /// 设置页面访问回调
  AnalyticsRouteFeatureBuilder onPageView(
    void Function(String, Map<String, dynamic>) callback,
  ) {
    _config = _config.copyWith(onPageView: callback);
    return this;
  }

  /// 构建分析路由功能特性
  AnalyticsRouteFeature build() {
    return AnalyticsRouteFeature.withConfig(_config);
  }
}

/// 分析路由功能特性工厂
class AnalyticsRouteFeatureFactory {
  /// 创建基础分析功能特性
  static AnalyticsRouteFeature basic({String? pageName}) {
    return AnalyticsRouteFeature(pageName: pageName);
  }

  /// 创建详细分析功能特性
  static AnalyticsRouteFeature detailed({
    String? pageName,
    Map<String, dynamic> customParameters = const {},
    void Function(String, Map<String, dynamic>)? onPageEnter,
    void Function(String, Duration)? onPageExit,
  }) {
    return AnalyticsRouteFeature(
      pageName: pageName,
      customParameters: customParameters,
      onPageEnter: onPageEnter,
      onPageExit: onPageExit,
    );
  }

  /// 创建仅页面访问统计的功能特性
  static AnalyticsRouteFeature pageViewOnly({String? pageName}) {
    return AnalyticsRouteFeature(pageName: pageName, enableDuration: false);
  }

  /// 创建仅停留时间统计的功能特性
  static AnalyticsRouteFeature durationOnly({String? pageName}) {
    return AnalyticsRouteFeature(pageName: pageName, enablePageView: false);
  }

  /// 创建电商分析功能特性
  static AnalyticsRouteFeature ecommerce({
    String? pageName,
    String? category,
    String? productId,
    double? price,
  }) {
    final parameters = <String, dynamic>{
      'category': 'ecommerce',
      if (category != null) 'product_category': category,
      if (productId != null) 'product_id': productId,
      if (price != null) 'price': price,
    };

    return AnalyticsRouteFeature(
      pageName: pageName,
      customParameters: parameters,
    );
  }

  /// 创建用户行为分析功能特性
  static AnalyticsRouteFeature userBehavior({
    String? pageName,
    String? userType,
    String? source,
  }) {
    final parameters = <String, dynamic>{
      'category': 'user_behavior',
      if (userType != null) 'user_type': userType,
      if (source != null) 'source': source,
    };

    return AnalyticsRouteFeature(
      pageName: pageName,
      customParameters: parameters,
    );
  }

  /// 创建自定义分析功能特性
  static AnalyticsRouteFeature custom(AnalyticsMiddlewareConfig config) {
    return AnalyticsRouteFeature.withConfig(config);
  }
}

/// 更新路由功能特性工厂以支持分析功能特性
extension RouteFeatureFactoryAnalyticsExtension on RouteFeatureFactory {
  /// 创建分析功能特性
  static IRouteFeature createAnalyticsFeature(
    String pageName, {
    Map<String, dynamic> parameters = const {},
  }) {
    return AnalyticsRouteFeatureFactory.detailed(
      pageName: pageName,
      customParameters: parameters,
    );
  }
}
