/// 路由注册器基础接口
/// 
/// 定义了路由注册器的基本契约，支持分层路由管理
library;

import 'package:go_router/go_router.dart';

/// 路由层级枚举
enum RouteLayer {
  /// 核心路由层 - 错误页、加载页等系统级路由
  core(priority: 1000),
  
  /// 通用路由层 - 登录、注册、首页等通用业务路由
  common(priority: 800),
  
  /// 业务路由层 - 具体业务功能路由
  business(priority: 600),
  
  /// 自定义路由层 - 用户自定义扩展路由
  custom(priority: 400);

  const RouteLayer({required this.priority});
  
  /// 默认优先级
  final int priority;
}

/// 路由注册器抽象接口
abstract class RouteRegistrar {
  /// 路由命名空间，用于避免冲突
  String get namespace;
  
  /// 路由层级
  RouteLayer get layer;
  
  /// 注册优先级，数值越大优先级越高
  int get priority => layer.priority;
  
  /// 依赖的其他注册器命名空间
  List<String> get dependencies => const [];
  
  /// 获取路由定义列表
  List<RouteBase> getRoutes();
  
  /// 检查是否与其他注册器存在路由冲突
  bool hasConflictWith(RouteRegistrar other) {
    final myPaths = _extractRoutePaths(getRoutes());
    final otherPaths = _extractRoutePaths(other.getRoutes());
    
    return myPaths.any((path) => otherPaths.contains(path));
  }
  
  /// 验证路由定义的有效性
  bool validateRoutes() {
    try {
      final routes = getRoutes();
      return routes.isNotEmpty && _validateRoutePaths(routes);
    } catch (e) {
      return false;
    }
  }
  
  /// 提取路由路径
  List<String> _extractRoutePaths(List<RouteBase> routes) {
    final paths = <String>[];
    for (final route in routes) {
      if (route is GoRoute) {
        paths.add(route.path);
      } else if (route is ShellRoute) {
        paths.addAll(_extractRoutePaths(route.routes));
      }
    }
    return paths;
  }
  
  /// 验证路由路径格式
  bool _validateRoutePaths(List<RouteBase> routes) {
    final paths = _extractRoutePaths(routes);
    return paths.every((path) => path.startsWith('/'));
  }
}

/// 路由元数据
class RouteMetadata {
  final String name;
  final String description;
  final String version;
  final bool requiresAuth;
  final bool hasBottomNav;
  final Map<String, dynamic> extra;
  
  const RouteMetadata({
    required this.name,
    this.description = '',
    this.version = '1.0.0',
    this.requiresAuth = false,
    this.hasBottomNav = false,
    this.extra = const {},
  });
}

/// 带元数据的路由注册器
abstract class MetadataRouteRegistrar extends RouteRegistrar {
  /// 获取路由元数据
  RouteMetadata getMetadata();
}
