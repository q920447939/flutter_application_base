/// 路由配置系统
/// 
/// 定义路由配置的数据结构和管理方式，实现配置驱动的路由管理
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'route_feature.dart';

/// 路由配置类
/// 
/// 统一管理单个路由的所有配置信息，包括路径、页面、标题、功能特性等
class RouteConfig {
  /// 路由路径
  final String path;
  
  /// 页面构建器
  final Widget Function() pageBuilder;
  
  /// 页面标题
  final String? title;
  
  /// 路由功能特性列表
  final List<IRouteFeature> features;
  
  /// 路由参数验证器
  final bool Function(Map<String, String> parameters)? parameterValidator;
  
  /// 路由转场动画
  final Transition? transition;
  
  /// 转场动画持续时间
  final Duration? transitionDuration;
  
  /// 是否全屏对话框
  final bool fullscreenDialog;
  
  /// 是否保持状态
  final bool maintainState;
  
  /// 路由元数据
  final Map<String, dynamic> metadata;

  const RouteConfig({
    required this.path,
    required this.pageBuilder,
    this.title,
    this.features = const [],
    this.parameterValidator,
    this.transition,
    this.transitionDuration,
    this.fullscreenDialog = false,
    this.maintainState = true,
    this.metadata = const {},
  });

  /// 获取路由名称（从路径提取）
  String get name => path;

  /// 检查是否有指定类型的功能特性
  bool hasFeature<T extends IRouteFeature>() {
    return features.any((feature) => feature is T);
  }

  /// 获取指定类型的功能特性
  T? getFeature<T extends IRouteFeature>() {
    try {
      return features.firstWhere((feature) => feature is T) as T;
    } catch (e) {
      return null;
    }
  }

  /// 获取所有指定类型的功能特性
  List<T> getFeatures<T extends IRouteFeature>() {
    return features.whereType<T>().toList();
  }

  /// 转换为GetX的GetPage
  GetPage toGetPage() {
    return GetPage(
      name: path,
      page: pageBuilder,
      title: title,
      transition: transition,
      transitionDuration: transitionDuration,
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
      middlewares: _buildMiddlewares(),
    );
  }

  /// 构建中间件列表
  List<GetMiddleware> _buildMiddlewares() {
    final middlewares = <GetMiddleware>[];
    
    // 将路由功能特性转换为中间件
    for (final feature in features) {
      final middleware = feature.createMiddleware();
      if (middleware != null) {
        middlewares.add(middleware);
      }
    }
    
    return middlewares;
  }

  /// 复制并修改配置
  RouteConfig copyWith({
    String? path,
    Widget Function()? pageBuilder,
    String? title,
    List<IRouteFeature>? features,
    bool Function(Map<String, String> parameters)? parameterValidator,
    Transition? transition,
    Duration? transitionDuration,
    bool? fullscreenDialog,
    bool? maintainState,
    Map<String, dynamic>? metadata,
  }) {
    return RouteConfig(
      path: path ?? this.path,
      pageBuilder: pageBuilder ?? this.pageBuilder,
      title: title ?? this.title,
      features: features ?? this.features,
      parameterValidator: parameterValidator ?? this.parameterValidator,
      transition: transition ?? this.transition,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      fullscreenDialog: fullscreenDialog ?? this.fullscreenDialog,
      maintainState: maintainState ?? this.maintainState,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'RouteConfig(path: $path, title: $title, features: ${features.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteConfig && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}

/// 路由组配置
/// 
/// 用于管理一组相关的路由配置
class RouteGroup {
  /// 组名称
  final String name;
  
  /// 路由前缀
  final String prefix;
  
  /// 组内路由列表
  final List<RouteConfig> routes;
  
  /// 组级别的功能特性
  final List<IRouteFeature> groupFeatures;
  
  /// 组描述
  final String? description;

  const RouteGroup({
    required this.name,
    required this.prefix,
    required this.routes,
    this.groupFeatures = const [],
    this.description,
  });

  /// 获取完整的路由配置列表（应用前缀和组功能）
  List<RouteConfig> getFullRoutes() {
    return routes.map((route) {
      final fullPath = prefix.isEmpty ? route.path : '$prefix${route.path}';
      final combinedFeatures = [...groupFeatures, ...route.features];
      
      return route.copyWith(
        path: fullPath,
        features: combinedFeatures,
      );
    }).toList();
  }

  /// 查找路由配置
  RouteConfig? findRoute(String path) {
    final fullRoutes = getFullRoutes();
    try {
      return fullRoutes.firstWhere((route) => route.path == path);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'RouteGroup(name: $name, prefix: $prefix, routes: ${routes.length})';
  }
}

/// 路由配置验证器
/// 
/// 用于验证路由配置的正确性
class RouteConfigValidator {
  /// 验证单个路由配置
  static RouteValidationResult validateRoute(RouteConfig config) {
    final errors = <String>[];
    final warnings = <String>[];

    // 验证路径格式
    if (!config.path.startsWith('/')) {
      errors.add('路由路径必须以 "/" 开头: ${config.path}');
    }

    // 验证路径中是否有非法字符
    if (config.path.contains(' ')) {
      errors.add('路由路径不能包含空格: ${config.path}');
    }

    // 验证功能特性
    for (final feature in config.features) {
      final featureResult = feature.validate();
      if (!featureResult.isValid) {
        errors.addAll(featureResult.errors.map((e) => '功能特性错误: $e'));
      }
    }

    // 检查是否有重复的功能特性类型
    final featureTypes = config.features.map((f) => f.runtimeType).toList();
    final uniqueTypes = featureTypes.toSet();
    if (featureTypes.length != uniqueTypes.length) {
      warnings.add('存在重复的功能特性类型');
    }

    return RouteValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// 验证路由组配置
  static RouteValidationResult validateRouteGroup(RouteGroup group) {
    final errors = <String>[];
    final warnings = <String>[];

    // 验证组内路由
    for (final route in group.routes) {
      final routeResult = validateRoute(route);
      if (!routeResult.isValid) {
        errors.addAll(routeResult.errors);
      }
      warnings.addAll(routeResult.warnings);
    }

    // 检查路径重复
    final paths = group.getFullRoutes().map((r) => r.path).toList();
    final uniquePaths = paths.toSet();
    if (paths.length != uniquePaths.length) {
      errors.add('组内存在重复的路由路径');
    }

    return RouteValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// 验证多个路由组
  static RouteValidationResult validateRouteGroups(List<RouteGroup> groups) {
    final errors = <String>[];
    final warnings = <String>[];

    // 验证每个组
    for (final group in groups) {
      final groupResult = validateRouteGroup(group);
      if (!groupResult.isValid) {
        errors.addAll(groupResult.errors.map((e) => '${group.name}: $e'));
      }
      warnings.addAll(groupResult.warnings.map((w) => '${group.name}: $w'));
    }

    // 检查跨组路径重复
    final allPaths = groups
        .expand((g) => g.getFullRoutes())
        .map((r) => r.path)
        .toList();
    final uniquePaths = allPaths.toSet();
    if (allPaths.length != uniquePaths.length) {
      errors.add('存在跨组的重复路由路径');
    }

    return RouteValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

/// 路由验证结果
class RouteValidationResult {
  /// 是否验证通过
  final bool isValid;
  
  /// 错误信息列表
  final List<String> errors;
  
  /// 警告信息列表
  final List<String> warnings;

  const RouteValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  /// 是否有警告
  bool get hasWarnings => warnings.isNotEmpty;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('RouteValidationResult(isValid: $isValid)');
    
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
