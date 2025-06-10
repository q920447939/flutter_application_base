/// 路由功能特性接口
/// 
/// 定义路由级别的功能特性接口，实现功能的模块化和可组合性
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 路由功能特性接口
/// 
/// 所有路由功能特性都必须实现此接口，提供统一的功能管理方式
abstract class IRouteFeature {
  /// 功能特性名称
  String get featureName;

  /// 功能特性描述
  String get description => '';

  /// 功能特性优先级（数值越小优先级越高）
  int get priority => 100;

  /// 创建对应的中间件
  /// 
  /// 返回null表示该功能特性不需要中间件处理
  GetMiddleware? createMiddleware();

  /// 验证功能特性配置
  FeatureValidationResult validate() {
    return const FeatureValidationResult(isValid: true);
  }

  /// 功能特性初始化
  /// 
  /// 在路由系统启动时调用，用于初始化功能特性
  Future<void> initialize() async {}

  /// 功能特性销毁
  /// 
  /// 在路由系统关闭时调用，用于清理资源
  void dispose() {}

  /// 获取功能特性的配置信息
  Map<String, dynamic> getConfiguration() => {};

  /// 功能特性是否启用
  bool get isEnabled => true;

  @override
  String toString() => 'RouteFeature($featureName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IRouteFeature && other.featureName == featureName;
  }

  @override
  int get hashCode => featureName.hashCode;
}

/// 功能特性验证结果
class FeatureValidationResult {
  /// 是否验证通过
  final bool isValid;
  
  /// 错误信息列表
  final List<String> errors;
  
  /// 警告信息列表
  final List<String> warnings;

  const FeatureValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  /// 创建成功的验证结果
  factory FeatureValidationResult.success({List<String> warnings = const []}) {
    return FeatureValidationResult(
      isValid: true,
      warnings: warnings,
    );
  }

  /// 创建失败的验证结果
  factory FeatureValidationResult.failure(List<String> errors, {List<String> warnings = const []}) {
    return FeatureValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
    );
  }

  /// 是否有警告
  bool get hasWarnings => warnings.isNotEmpty;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('FeatureValidationResult(isValid: $isValid)');
    
    if (errors.isNotEmpty) {
      buffer.writeln('错误:');
      for (final error in errors) {
        buffer.writeln('  - $error');
      }
    }
    
    if (warnings.isNotEmpty) {
      buffer.writeln('警告:');
      for (final warning in warnings) {
        buffer.writeln('  - $warning');
      }
    }
    
    return buffer.toString();
  }
}

/// 路由功能特性管理器
/// 
/// 负责管理所有路由功能特性的生命周期
class RouteFeatureManager {
  static RouteFeatureManager? _instance;
  
  RouteFeatureManager._internal();
  
  /// 单例实例
  static RouteFeatureManager get instance {
    _instance ??= RouteFeatureManager._internal();
    return _instance!;
  }

  /// 已注册的功能特性
  final Map<String, IRouteFeature> _features = {};

  /// 功能特性初始化状态
  final Map<String, bool> _initializationStatus = {};

  /// 注册功能特性
  void registerFeature(IRouteFeature feature) {
    if (_features.containsKey(feature.featureName)) {
      debugPrint('警告: 功能特性 ${feature.featureName} 已存在，将被覆盖');
    }
    
    _features[feature.featureName] = feature;
    _initializationStatus[feature.featureName] = false;
    
    debugPrint('已注册路由功能特性: ${feature.featureName}');
  }

  /// 批量注册功能特性
  void registerFeatures(List<IRouteFeature> features) {
    for (final feature in features) {
      registerFeature(feature);
    }
  }

  /// 获取功能特性
  T? getFeature<T extends IRouteFeature>(String featureName) {
    final feature = _features[featureName];
    return feature is T ? feature : null;
  }

  /// 获取所有功能特性
  List<IRouteFeature> getAllFeatures() {
    return _features.values.toList();
  }

  /// 获取已启用的功能特性
  List<IRouteFeature> getEnabledFeatures() {
    return _features.values.where((feature) => feature.isEnabled).toList();
  }

  /// 初始化所有功能特性
  Future<void> initializeAllFeatures() async {
    final features = getEnabledFeatures();
    
    // 按优先级排序
    features.sort((a, b) => a.priority.compareTo(b.priority));
    
    for (final feature in features) {
      try {
        await feature.initialize();
        _initializationStatus[feature.featureName] = true;
        debugPrint('功能特性初始化成功: ${feature.featureName}');
      } catch (e) {
        debugPrint('功能特性初始化失败: ${feature.featureName}, 错误: $e');
        _initializationStatus[feature.featureName] = false;
      }
    }
  }

  /// 销毁所有功能特性
  void disposeAllFeatures() {
    for (final feature in _features.values) {
      try {
        feature.dispose();
        debugPrint('功能特性销毁成功: ${feature.featureName}');
      } catch (e) {
        debugPrint('功能特性销毁失败: ${feature.featureName}, 错误: $e');
      }
    }
    
    _initializationStatus.clear();
  }

  /// 验证所有功能特性
  Map<String, FeatureValidationResult> validateAllFeatures() {
    final results = <String, FeatureValidationResult>{};
    
    for (final feature in _features.values) {
      results[feature.featureName] = feature.validate();
    }
    
    return results;
  }

  /// 获取功能特性初始化状态
  bool isFeatureInitialized(String featureName) {
    return _initializationStatus[featureName] ?? false;
  }

  /// 获取所有功能特性的配置信息
  Map<String, Map<String, dynamic>> getAllConfigurations() {
    final configurations = <String, Map<String, dynamic>>{};
    
    for (final feature in _features.values) {
      configurations[feature.featureName] = feature.getConfiguration();
    }
    
    return configurations;
  }

  /// 清除所有功能特性
  void clear() {
    disposeAllFeatures();
    _features.clear();
  }

  /// 获取功能特性统计信息
  Map<String, dynamic> getStatistics() {
    final total = _features.length;
    final enabled = getEnabledFeatures().length;
    final initialized = _initializationStatus.values.where((status) => status).length;
    
    return {
      'total': total,
      'enabled': enabled,
      'initialized': initialized,
      'disabled': total - enabled,
      'failed_initialization': enabled - initialized,
    };
  }

  @override
  String toString() {
    final stats = getStatistics();
    return 'RouteFeatureManager(总计: ${stats['total']}, 已启用: ${stats['enabled']}, 已初始化: ${stats['initialized']})';
  }
}

/// 路由功能特性工厂
/// 
/// 提供常用功能特性的创建方法
abstract class RouteFeatureFactory {
  /// 创建权限功能特性
  static IRouteFeature createPermissionFeature(List<dynamic> permissions) {
    // 这里返回一个占位符，实际实现在具体的功能特性文件中
    throw UnimplementedError('权限功能特性将在 permission_route_feature.dart 中实现');
  }

  /// 创建分析功能特性
  static IRouteFeature createAnalyticsFeature(String pageName, {Map<String, dynamic> parameters = const {}}) {
    // 这里返回一个占位符，实际实现在具体的功能特性文件中
    throw UnimplementedError('分析功能特性将在 analytics_route_feature.dart 中实现');
  }

  /// 创建加载功能特性
  static IRouteFeature createLoadingFeature({
    bool enableNetworkCheck = true,
    Future<bool> Function()? preloadData,
  }) {
    // 这里返回一个占位符，实际实现在具体的功能特性文件中
    throw UnimplementedError('加载功能特性将在 loading_route_feature.dart 中实现');
  }
}

/// 功能特性组合器
/// 
/// 用于组合多个功能特性
class FeatureComposer {
  final List<IRouteFeature> _features = [];

  /// 添加功能特性
  FeatureComposer add(IRouteFeature feature) {
    _features.add(feature);
    return this;
  }

  /// 批量添加功能特性
  FeatureComposer addAll(List<IRouteFeature> features) {
    _features.addAll(features);
    return this;
  }

  /// 添加权限功能特性
  FeatureComposer withPermissions(List<dynamic> permissions) {
    return add(RouteFeatureFactory.createPermissionFeature(permissions));
  }

  /// 添加分析功能特性
  FeatureComposer withAnalytics(String pageName, {Map<String, dynamic> parameters = const {}}) {
    return add(RouteFeatureFactory.createAnalyticsFeature(pageName, parameters: parameters));
  }

  /// 添加加载功能特性
  FeatureComposer withLoading({
    bool enableNetworkCheck = true,
    Future<bool> Function()? preloadData,
  }) {
    return add(RouteFeatureFactory.createLoadingFeature(
      enableNetworkCheck: enableNetworkCheck,
      preloadData: preloadData,
    ));
  }

  /// 构建功能特性列表
  List<IRouteFeature> build() {
    // 按优先级排序
    _features.sort((a, b) => a.priority.compareTo(b.priority));
    return List.unmodifiable(_features);
  }

  /// 清空功能特性
  void clear() {
    _features.clear();
  }

  /// 获取功能特性数量
  int get length => _features.length;

  /// 是否为空
  bool get isEmpty => _features.isEmpty;

  /// 是否不为空
  bool get isNotEmpty => _features.isNotEmpty;
}
