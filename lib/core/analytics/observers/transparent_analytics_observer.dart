library;

import 'package:flutter/material.dart';

class AnalyticsObserver extends NavigatorObserver {
  /// 页面进入时间记录，用于计算停留时长
  final Map<String, DateTime> _pageEnterTimes = {};

  /// 当前路由栈信息
  final List<String> _routeStack = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    final routeInfo = _extractRouteInfo(route);
    if (routeInfo != null) {
      _routeStack.add(routeInfo.path);
      _handlePageEnter(routeInfo, 'push', previousRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    final routeInfo = _extractRouteInfo(route);
    if (routeInfo != null) {
      _routeStack.remove(routeInfo.path);
      _handlePageExit(routeInfo, 'pop');
    }

    // 处理返回到的页面（重新激活）
    if (previousRoute != null) {
      final previousRouteInfo = _extractRouteInfo(previousRoute);
      if (previousRouteInfo != null) {
        _handlePageReenter(previousRouteInfo, 'pop_return');
      }
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    if (oldRoute != null) {
      final oldRouteInfo = _extractRouteInfo(oldRoute);
      if (oldRouteInfo != null) {
        _routeStack.remove(oldRouteInfo.path);
        _handlePageExit(oldRouteInfo, 'replace_out');
      }
    }

    if (newRoute != null) {
      final newRouteInfo = _extractRouteInfo(newRoute);
      if (newRouteInfo != null) {
        _routeStack.add(newRouteInfo.path);
        _handlePageEnter(newRouteInfo, 'replace_in', oldRoute);
      }
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);

    final routeInfo = _extractRouteInfo(route);
    if (routeInfo != null) {
      _routeStack.remove(routeInfo.path);
      _handlePageExit(routeInfo, 'remove');
    }
  }

  /// 处理页面进入事件
  void _handlePageEnter(
    RouteInfo routeInfo,
    String action,
    Route<dynamic>? previousRoute,
  ) {
    // 记录页面进入时间
    _pageEnterTimes[routeInfo.path] = DateTime.now();

    // 获取上一个页面信息
    String? previousPath;
    if (previousRoute != null) {
      final previousRouteInfo = _extractRouteInfo(previousRoute);
      previousPath = previousRouteInfo?.path;
    }

    // 触发埋点事件
    /* _analyticsManager.handlePageEnter(routeInfo.path, routeInfo.name, {
      ...routeInfo.parameters,
      'navigation_action': action,
      'route_stack_depth': _routeStack.length,
      'previous_page': previousPath,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }); */

    debugPrint('🔍 [透明埋点] 页面进入: ${routeInfo.path} (action: $action)');
  }

  /// 处理页面退出事件
  void _handlePageExit(RouteInfo routeInfo, String action) {
    // 计算页面停留时间
    final enterTime = _pageEnterTimes[routeInfo.path];
    int? duration;
    if (enterTime != null) {
      duration = DateTime.now().difference(enterTime).inMilliseconds;
      _pageEnterTimes.remove(routeInfo.path);
    }

    // 触发页面退出埋点
    /* _analyticsManager.handlePageExit(routeInfo.path);

    // 发送页面停留时长事件
    if (duration != null && duration > 100) {
      // 过滤掉过短的停留时间
      _analyticsManager.trackEvent('page_duration', {
        'page_path': routeInfo.path,
        'page_name': routeInfo.name,
        'duration_ms': duration,
        'duration_seconds': (duration / 1000).round(),
        'exit_action': action,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
 */
    debugPrint(
      '🔍 [透明埋点] 页面退出: ${routeInfo.path} (action: $action, duration: ${duration}ms)',
    );
  }

  /// 处理页面重新进入事件（从其他页面返回）
  void _handlePageReenter(RouteInfo routeInfo, String action) {
    // 重新记录进入时间
    _pageEnterTimes[routeInfo.path] = DateTime.now();

    // 发送页面重新激活事件
    /* _analyticsManager.trackEvent('page_reenter', {
      'page_path': routeInfo.path,
      'page_name': routeInfo.name,
      'reenter_action': action,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }); */

    debugPrint('🔍 [透明埋点] 页面重新进入: ${routeInfo.path} (action: $action)');
  }

  /// 提取路由信息
  RouteInfo? _extractRouteInfo(Route<dynamic> route) {
    final settings = route.settings;

    // 获取路由名称和路径
    String? routePath = settings.name;
    String routeName = routePath ?? 'unknown';
    Map<String, dynamic> parameters = {};

    // 尝试从arguments中提取参数
    final arguments = settings.arguments;
    if (arguments is Map<String, dynamic>) {
      parameters = Map<String, dynamic>.from(arguments);
    }

    // 如果没有路由名称，尝试生成一个
    if (routePath == null || routePath.isEmpty) {
      routePath = _generateRoutePathFromRoute(route);
      routeName = routePath;
    }

    // 过滤掉系统路由
    if (_isSystemRoute(routePath)) {
      return null;
    }

    return RouteInfo(path: routePath, name: routeName, parameters: parameters);
  }

  /// 从路由对象生成路径
  String _generateRoutePathFromRoute(Route<dynamic> route) {
    final routeType = route.runtimeType.toString();

    if (routeType.contains('MaterialPageRoute')) {
      return '/material_page_${route.hashCode}';
    } else if (routeType.contains('CupertinoPageRoute')) {
      return '/cupertino_page_${route.hashCode}';
    } else if (routeType.contains('PageRouteBuilder')) {
      return '/custom_page_${route.hashCode}';
    } else if (routeType.contains('DialogRoute')) {
      return '/dialog_${route.hashCode}';
    }

    return '/unknown_${route.hashCode}';
  }

  /// 判断是否为系统路由（需要过滤掉）
  bool _isSystemRoute(String routePath) {
    // 过滤掉对话框、弹窗等系统路由
    return routePath.contains('/dialog_') ||
        routePath.contains('_dialog') ||
        routePath.contains('/popup') ||
        routePath.contains('/overlay') ||
        routePath.contains('/modal');
  }

  /// 获取当前路由栈信息（用于调试）
  List<String> getCurrentRouteStack() {
    return List.unmodifiable(_routeStack);
  }

  /// 获取当前路由栈深度
  int getCurrentStackDepth() {
    return _routeStack.length;
  }

  /// 清理资源
  void dispose() {
    _pageEnterTimes.clear();
    _routeStack.clear();
  }
}

/// 路由信息数据类
class RouteInfo {
  final String path;
  final String name;
  final Map<String, dynamic> parameters;

  const RouteInfo({
    required this.path,
    required this.name,
    required this.parameters,
  });

  @override
  String toString() {
    return 'RouteInfo(path: $path, name: $name, parameters: $parameters)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteInfo && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}

/// 兼容性别名，保持向后兼容
typedef AnalyticsRouteObserver = AnalyticsObserver;
