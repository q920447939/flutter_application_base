/// 应用路由管理器
/// 
/// 统一管理应用的所有路由配置和路由操作
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'route_config.dart';
import 'route_feature.dart';
import 'middlewares/base_middleware.dart';

/// 应用路由管理器
/// 
/// 负责管理应用的所有路由配置、路由组和路由操作
class AppRouteManager {
  static AppRouteManager? _instance;
  
  AppRouteManager._internal();
  
  /// 单例实例
  static AppRouteManager get instance {
    _instance ??= AppRouteManager._internal();
    return _instance!;
  }

  /// 路由配置映射
  final Map<String, RouteConfig> _routes = {};
  
  /// 路由组映射
  final Map<String, RouteGroup> _routeGroups = {};
  
  /// 是否已初始化
  bool _isInitialized = false;

  /// 获取是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化路由管理器
  Future<void> initialize({
    List<RouteConfig>? routes,
    List<RouteGroup>? routeGroups,
    bool validateRoutes = true,
  }) async {
    if (_isInitialized) {
      debugPrint('路由管理器已初始化，跳过重复初始化');
      return;
    }

    try {
      // 清空现有配置
      _routes.clear();
      _routeGroups.clear();

      // 注册路由组
      if (routeGroups != null) {
        for (final group in routeGroups) {
          await registerRouteGroup(group);
        }
      }

      // 注册单独的路由
      if (routes != null) {
        for (final route in routes) {
          await registerRoute(route);
        }
      }

      // 验证路由配置
      if (validateRoutes) {
        final validationResult = validateAllRoutes();
        if (!validationResult.isValid) {
          debugPrint('路由验证失败:');
          for (final error in validationResult.errors) {
            debugPrint('  - $error');
          }
          throw Exception('路由配置验证失败');
        }

        if (validationResult.hasWarnings) {
          debugPrint('路由验证警告:');
          for (final warning in validationResult.warnings) {
            debugPrint('  - $warning');
          }
        }
      }

      // 初始化路由功能特性
      await RouteFeatureManager.instance.initializeAllFeatures();

      _isInitialized = true;
      debugPrint('路由管理器初始化完成，共注册 ${_routes.length} 个路由');
    } catch (e) {
      debugPrint('路由管理器初始化失败: $e');
      rethrow;
    }
  }

  /// 注册路由配置
  Future<void> registerRoute(RouteConfig route) async {
    if (_routes.containsKey(route.path)) {
      debugPrint('警告: 路由 ${route.path} 已存在，将被覆盖');
    }

    // 验证路由配置
    final validationResult = RouteConfigValidator.validateRoute(route);
    if (!validationResult.isValid) {
      throw Exception('路由配置无效: ${validationResult.errors.join(', ')}');
    }

    // 注册路由功能特性
    for (final feature in route.features) {
      RouteFeatureManager.instance.registerFeature(feature);
    }

    _routes[route.path] = route;
    debugPrint('已注册路由: ${route.path}');
  }

  /// 批量注册路由配置
  Future<void> registerRoutes(List<RouteConfig> routes) async {
    for (final route in routes) {
      await registerRoute(route);
    }
  }

  /// 注册路由组
  Future<void> registerRouteGroup(RouteGroup group) async {
    if (_routeGroups.containsKey(group.name)) {
      debugPrint('警告: 路由组 ${group.name} 已存在，将被覆盖');
    }

    // 验证路由组配置
    final validationResult = RouteConfigValidator.validateRouteGroup(group);
    if (!validationResult.isValid) {
      throw Exception('路由组配置无效: ${validationResult.errors.join(', ')}');
    }

    // 注册路由组中的所有路由
    final fullRoutes = group.getFullRoutes();
    for (final route in fullRoutes) {
      await registerRoute(route);
    }

    _routeGroups[group.name] = group;
    debugPrint('已注册路由组: ${group.name}，包含 ${fullRoutes.length} 个路由');
  }

  /// 批量注册路由组
  Future<void> registerRouteGroups(List<RouteGroup> groups) async {
    for (final group in groups) {
      await registerRouteGroup(group);
    }
  }

  /// 获取路由配置
  RouteConfig? getRoute(String path) {
    return _routes[path];
  }

  /// 获取路由组
  RouteGroup? getRouteGroup(String name) {
    return _routeGroups[name];
  }

  /// 获取所有路由配置
  List<RouteConfig> getAllRoutes() {
    return _routes.values.toList();
  }

  /// 获取所有路由组
  List<RouteGroup> getAllRouteGroups() {
    return _routeGroups.values.toList();
  }

  /// 获取GetX路由页面列表
  List<GetPage> getGetPages() {
    return _routes.values.map((route) => route.toGetPage()).toList();
  }

  /// 查找路由
  List<RouteConfig> findRoutes({
    String? pathPattern,
    String? titlePattern,
    Type? featureType,
  }) {
    return _routes.values.where((route) {
      // 路径匹配
      if (pathPattern != null && !route.path.contains(pathPattern)) {
        return false;
      }

      // 标题匹配
      if (titlePattern != null && 
          (route.title == null || !route.title!.contains(titlePattern))) {
        return false;
      }

      // 功能特性类型匹配
      if (featureType != null && !route.features.any((f) => f.runtimeType == featureType)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// 验证所有路由配置
  RouteValidationResult validateAllRoutes() {
    final errors = <String>[];
    final warnings = <String>[];

    // 验证单个路由
    for (final route in _routes.values) {
      final result = RouteConfigValidator.validateRoute(route);
      if (!result.isValid) {
        errors.addAll(result.errors.map((e) => '${route.path}: $e'));
      }
      warnings.addAll(result.warnings.map((w) => '${route.path}: $w'));
    }

    // 验证路由组
    for (final group in _routeGroups.values) {
      final result = RouteConfigValidator.validateRouteGroup(group);
      if (!result.isValid) {
        errors.addAll(result.errors.map((e) => '${group.name}: $e'));
      }
      warnings.addAll(result.warnings.map((w) => '${group.name}: $w'));
    }

    // 检查路径重复
    final paths = _routes.keys.toList();
    final uniquePaths = paths.toSet();
    if (paths.length != uniquePaths.length) {
      errors.add('存在重复的路由路径');
    }

    return RouteValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// 移除路由配置
  void removeRoute(String path) {
    if (_routes.containsKey(path)) {
      _routes.remove(path);
      debugPrint('已移除路由: $path');
    }
  }

  /// 移除路由组
  void removeRouteGroup(String name) {
    final group = _routeGroups[name];
    if (group != null) {
      // 移除路由组中的所有路由
      final fullRoutes = group.getFullRoutes();
      for (final route in fullRoutes) {
        removeRoute(route.path);
      }
      
      _routeGroups.remove(name);
      debugPrint('已移除路由组: $name');
    }
  }

  /// 清空所有路由配置
  void clear() {
    _routes.clear();
    _routeGroups.clear();
    RouteFeatureManager.instance.clear();
    MiddlewareManager.instance.clear();
    _isInitialized = false;
    debugPrint('已清空所有路由配置');
  }

  /// 重新加载路由配置
  Future<void> reload({
    List<RouteConfig>? routes,
    List<RouteGroup>? routeGroups,
    bool validateRoutes = true,
  }) async {
    clear();
    await initialize(
      routes: routes,
      routeGroups: routeGroups,
      validateRoutes: validateRoutes,
    );
  }

  /// 获取路由统计信息
  Map<String, dynamic> getStatistics() {
    final routeCount = _routes.length;
    final groupCount = _routeGroups.length;
    final featureCount = RouteFeatureManager.instance.getAllFeatures().length;
    final middlewareCount = MiddlewareManager.instance.getAllMiddlewares().length;

    // 统计功能特性使用情况
    final featureUsage = <String, int>{};
    for (final route in _routes.values) {
      for (final feature in route.features) {
        final featureName = feature.featureName;
        featureUsage[featureName] = (featureUsage[featureName] ?? 0) + 1;
      }
    }

    return {
      'route_count': routeCount,
      'group_count': groupCount,
      'feature_count': featureCount,
      'middleware_count': middlewareCount,
      'feature_usage': featureUsage,
      'is_initialized': _isInitialized,
    };
  }

  /// 导出路由配置
  Map<String, dynamic> exportConfiguration() {
    return {
      'routes': _routes.values.map((route) => {
        'path': route.path,
        'title': route.title,
        'features': route.features.map((f) => f.featureName).toList(),
        'metadata': route.metadata,
      }).toList(),
      'route_groups': _routeGroups.values.map((group) => {
        'name': group.name,
        'prefix': group.prefix,
        'description': group.description,
        'routes_count': group.routes.length,
      }).toList(),
      'statistics': getStatistics(),
    };
  }

  /// 打印路由信息
  void printRouteInfo() {
    final stats = getStatistics();
    debugPrint('=== 路由管理器信息 ===');
    debugPrint('路由总数: ${stats['route_count']}');
    debugPrint('路由组总数: ${stats['group_count']}');
    debugPrint('功能特性总数: ${stats['feature_count']}');
    debugPrint('中间件总数: ${stats['middleware_count']}');
    debugPrint('初始化状态: ${stats['is_initialized']}');
    
    debugPrint('\n=== 路由列表 ===');
    for (final route in _routes.values) {
      debugPrint('${route.path} - ${route.title ?? '无标题'} (${route.features.length} 个功能)');
    }
    
    debugPrint('\n=== 路由组列表 ===');
    for (final group in _routeGroups.values) {
      debugPrint('${group.name} - ${group.description ?? '无描述'} (${group.routes.length} 个路由)');
    }
  }

  @override
  String toString() {
    final stats = getStatistics();
    return 'AppRouteManager(routes: ${stats['route_count']}, groups: ${stats['group_count']}, initialized: ${stats['is_initialized']})';
  }
}
