/// 动态路由管理器
/// 
/// 负责统一管理所有路由注册器，支持依赖解析和冲突检测
library;

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../base/route_registrar.dart';

/// 路由管理器异常
class RouteManagerException implements Exception {
  final String message;
  const RouteManagerException(this.message);
  
  @override
  String toString() => 'RouteManagerException: $message';
}

/// 动态路由管理器
class DynamicRouteManager {
  static final DynamicRouteManager _instance = DynamicRouteManager._internal();
  factory DynamicRouteManager() => _instance;
  DynamicRouteManager._internal();
  
  /// 已注册的路由注册器
  final Map<String, RouteRegistrar> _registrars = {};
  
  /// 按层级分组的注册器
  final Map<RouteLayer, List<RouteRegistrar>> _layeredRegistrars = {};
  
  /// 是否已构建路由
  bool _isBuilt = false;
  
  /// 缓存的路由列表
  List<RouteBase>? _cachedRoutes;
  
  /// 注册路由提供者
  void registerRouteProvider(RouteRegistrar registrar) {
    if (_isBuilt) {
      throw const RouteManagerException('路由已构建，无法再注册新的路由提供者');
    }
    
    // 验证注册器
    _validateRegistrar(registrar);
    
    // 检查命名空间冲突
    if (_registrars.containsKey(registrar.namespace)) {
      throw RouteManagerException('命名空间冲突: ${registrar.namespace}');
    }
    
    // 注册
    _registrars[registrar.namespace] = registrar;
    _layeredRegistrars.putIfAbsent(registrar.layer, () => []).add(registrar);
    
    debugPrint('已注册路由提供者: ${registrar.namespace} (${registrar.layer.name})');
  }
  
  /// 批量注册路由提供者
  void registerRouteProviders(List<RouteRegistrar> registrars) {
    for (final registrar in registrars) {
      registerRouteProvider(registrar);
    }
  }
  
  /// 构建最终路由列表
  List<RouteBase> buildRoutes() {
    if (_cachedRoutes != null) {
      return _cachedRoutes!;
    }
    
    // 验证依赖关系
    _validateDependencies();
    
    // 按优先级和依赖关系排序
    final sortedRegistrars = _sortByPriorityAndDependency();
    
    // 构建路由列表
    final routes = <RouteBase>[];
    for (final registrar in sortedRegistrars) {
      try {
        final registrarRoutes = registrar.getRoutes();
        routes.addAll(registrarRoutes);
        debugPrint('已加载路由: ${registrar.namespace} (${registrarRoutes.length}个路由)');
      } catch (e) {
        debugPrint('加载路由失败: ${registrar.namespace}, 错误: $e');
        rethrow;
      }
    }
    
    _cachedRoutes = routes;
    _isBuilt = true;
    
    debugPrint('路由构建完成，总计: ${routes.length}个路由');
    return routes;
  }
  
  /// 获取指定层级的路由
  List<RouteBase> getRoutesByLayer(RouteLayer layer) {
    final registrars = _layeredRegistrars[layer] ?? [];
    final routes = <RouteBase>[];
    
    for (final registrar in registrars) {
      routes.addAll(registrar.getRoutes());
    }
    
    return routes;
  }
  
  /// 获取有底部导航的路由
  List<RouteBase> getBottomNavRoutes() {
    return buildRoutes().where((route) => _isBottomNavRoute(route)).toList();
  }
  
  /// 获取无底部导航的路由
  List<RouteBase> getNonBottomNavRoutes() {
    return buildRoutes().where((route) => !_isBottomNavRoute(route)).toList();
  }
  
  /// 重置管理器状态
  void reset() {
    _registrars.clear();
    _layeredRegistrars.clear();
    _cachedRoutes = null;
    _isBuilt = false;
  }
  
  /// 验证注册器
  void _validateRegistrar(RouteRegistrar registrar) {
    if (registrar.namespace.isEmpty) {
      throw const RouteManagerException('路由注册器命名空间不能为空');
    }
    
    if (!registrar.validateRoutes()) {
      throw RouteManagerException('路由注册器验证失败: ${registrar.namespace}');
    }
    
    // 检查与已有注册器的冲突
    for (final existing in _registrars.values) {
      if (registrar.hasConflictWith(existing)) {
        throw RouteManagerException(
          '路由冲突: ${registrar.namespace} 与 ${existing.namespace}',
        );
      }
    }
  }
  
  /// 验证依赖关系
  void _validateDependencies() {
    for (final registrar in _registrars.values) {
      for (final dependency in registrar.dependencies) {
        if (!_registrars.containsKey(dependency)) {
          throw RouteManagerException(
            '依赖缺失: ${registrar.namespace} 依赖 $dependency',
          );
        }
      }
    }
  }
  
  /// 按优先级和依赖关系排序
  List<RouteRegistrar> _sortByPriorityAndDependency() {
    final registrars = _registrars.values.toList();
    
    // 拓扑排序处理依赖关系
    final sorted = <RouteRegistrar>[];
    final visited = <String>{};
    final visiting = <String>{};
    
    void visit(RouteRegistrar registrar) {
      if (visiting.contains(registrar.namespace)) {
        throw RouteManagerException('检测到循环依赖: ${registrar.namespace}');
      }
      
      if (visited.contains(registrar.namespace)) {
        return;
      }
      
      visiting.add(registrar.namespace);
      
      // 先处理依赖
      for (final dependency in registrar.dependencies) {
        final depRegistrar = _registrars[dependency];
        if (depRegistrar != null) {
          visit(depRegistrar);
        }
      }
      
      visiting.remove(registrar.namespace);
      visited.add(registrar.namespace);
      sorted.add(registrar);
    }
    
    // 按优先级排序后进行拓扑排序
    registrars.sort((a, b) => b.priority.compareTo(a.priority));
    
    for (final registrar in registrars) {
      visit(registrar);
    }
    
    return sorted;
  }
  
  /// 判断是否为底部导航路由
  bool _isBottomNavRoute(RouteBase route) {
    // 这里可以根据路由的元数据或路径规则判断
    // 暂时使用简单的路径判断
    if (route is GoRoute) {
      return route.path == '/' || 
             route.path.startsWith('/home') ||
             route.path.startsWith('/my');
    }
    return false;
  }
}
