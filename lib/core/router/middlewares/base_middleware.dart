/// 中间件基类
/// 
/// 提供路由中间件的基础功能和统一接口
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 中间件执行结果
class MiddlewareResult {
  /// 是否允许继续执行
  final bool canProceed;
  
  /// 重定向路由（如果需要重定向）
  final String? redirectRoute;
  
  /// 错误信息
  final String? errorMessage;
  
  /// 附加数据
  final Map<String, dynamic> data;

  const MiddlewareResult({
    required this.canProceed,
    this.redirectRoute,
    this.errorMessage,
    this.data = const {},
  });

  /// 创建允许继续的结果
  factory MiddlewareResult.proceed({Map<String, dynamic> data = const {}}) {
    return MiddlewareResult(
      canProceed: true,
      data: data,
    );
  }

  /// 创建重定向结果
  factory MiddlewareResult.redirect(String route, {String? errorMessage}) {
    return MiddlewareResult(
      canProceed: false,
      redirectRoute: route,
      errorMessage: errorMessage,
    );
  }

  /// 创建阻止结果
  factory MiddlewareResult.block(String errorMessage) {
    return MiddlewareResult(
      canProceed: false,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    return 'MiddlewareResult(canProceed: $canProceed, redirectRoute: $redirectRoute, errorMessage: $errorMessage)';
  }
}

/// 路由中间件基类
/// 
/// 提供中间件的基础功能和生命周期管理
abstract class BaseRouteMiddleware extends GetMiddleware {
  /// 中间件名称
  String get middlewareName;

  /// 中间件描述
  String get description => '';

  /// 中间件优先级（数值越小优先级越高）
  @override
  int? get priority => 0;

  /// 是否启用中间件
  bool get isEnabled => true;

  /// 中间件配置
  Map<String, dynamic> get configuration => {};

  /// 执行前置检查
  /// 
  /// 在路由跳转前执行，返回检查结果
  Future<MiddlewareResult> preCheck(String? route, Map<String, String>? parameters) async {
    return MiddlewareResult.proceed();
  }

  /// 执行后置处理
  /// 
  /// 在路由跳转后执行，用于清理或记录
  Future<void> postProcess(String? route, Map<String, String>? parameters) async {}

  @override
  RouteSettings? redirect(String? route) {
    if (!isEnabled) {
      return null;
    }

    try {
      // 解析路由参数
      final uri = Uri.parse(route ?? '');
      final parameters = uri.queryParameters;

      // 执行前置检查
      final result = _executePreCheck(route, parameters);
      
      if (!result.canProceed) {
        if (result.redirectRoute != null) {
          debugPrint('[$middlewareName] 重定向到: ${result.redirectRoute}');
          return RouteSettings(name: result.redirectRoute);
        } else {
          debugPrint('[$middlewareName] 阻止访问: ${result.errorMessage}');
          return RouteSettings(name: '/error', arguments: result.errorMessage);
        }
      }

      return null;
    } catch (e) {
      debugPrint('[$middlewareName] 执行异常: $e');
      return RouteSettings(name: '/error', arguments: '中间件执行异常: $e');
    }
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    if (!isEnabled || page == null) {
      return page;
    }

    try {
      // 执行页面调用处理
      return onPageCalledInternal(page);
    } catch (e) {
      debugPrint('[$middlewareName] 页面调用处理异常: $e');
      return page;
    }
  }

  @override
  List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
    if (!isEnabled) {
      return bindings;
    }

    try {
      // 执行绑定开始处理
      return onBindingsStartInternal(bindings);
    } catch (e) {
      debugPrint('[$middlewareName] 绑定开始处理异常: $e');
      return bindings;
    }
  }

  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    if (!isEnabled) {
      return page;
    }

    try {
      // 执行页面构建开始处理
      return onPageBuildStartInternal(page);
    } catch (e) {
      debugPrint('[$middlewareName] 页面构建开始处理异常: $e');
      return page;
    }
  }

  @override
  Widget onPageBuilt(Widget page) {
    if (!isEnabled) {
      return page;
    }

    try {
      // 执行页面构建完成处理
      return onPageBuiltInternal(page);
    } catch (e) {
      debugPrint('[$middlewareName] 页面构建完成处理异常: $e');
      return page;
    }
  }

  @override
  void onPageDispose() {
    if (!isEnabled) {
      return;
    }

    try {
      // 执行页面销毁处理
      onPageDisposeInternal();
      
      // 执行后置处理
      final route = Get.currentRoute;
      final uri = Uri.parse(route);
      _executePostProcess(route, uri.queryParameters);
    } catch (e) {
      debugPrint('[$middlewareName] 页面销毁处理异常: $e');
    }
  }

  /// 内部页面调用处理（子类可重写）
  GetPage? onPageCalledInternal(GetPage page) {
    return page;
  }

  /// 内部绑定开始处理（子类可重写）
  List<Bindings>? onBindingsStartInternal(List<Bindings>? bindings) {
    return bindings;
  }

  /// 内部页面构建开始处理（子类可重写）
  GetPageBuilder? onPageBuildStartInternal(GetPageBuilder? page) {
    return page;
  }

  /// 内部页面构建完成处理（子类可重写）
  Widget onPageBuiltInternal(Widget page) {
    return page;
  }

  /// 内部页面销毁处理（子类可重写）
  void onPageDisposeInternal() {}

  /// 执行前置检查（同步版本）
  MiddlewareResult _executePreCheck(String? route, Map<String, String> parameters) {
    try {
      // 这里使用同步方式，如果需要异步可以在子类中重写
      return preCheck(route, parameters) as MiddlewareResult;
    } catch (e) {
      if (e is! TypeError) {
        rethrow;
      }
      // 如果是异步方法，返回默认结果
      return MiddlewareResult.proceed();
    }
  }

  /// 执行后置处理（异步版本）
  void _executePostProcess(String? route, Map<String, String> parameters) {
    // 异步执行后置处理，不阻塞主流程
    Future.microtask(() async {
      try {
        await postProcess(route, parameters);
      } catch (e) {
        debugPrint('[$middlewareName] 后置处理异常: $e');
      }
    });
  }

  /// 记录中间件日志
  void logInfo(String message) {
    debugPrint('[$middlewareName] $message');
  }

  /// 记录中间件警告
  void logWarning(String message) {
    debugPrint('[$middlewareName] 警告: $message');
  }

  /// 记录中间件错误
  void logError(String message, [Object? error]) {
    debugPrint('[$middlewareName] 错误: $message${error != null ? ', 详情: $error' : ''}');
  }

  /// 获取中间件状态信息
  Map<String, dynamic> getStatus() {
    return {
      'name': middlewareName,
      'enabled': isEnabled,
      'priority': priority,
      'description': description,
      'configuration': configuration,
    };
  }

  @override
  String toString() {
    return '$middlewareName(enabled: $isEnabled, priority: $priority)';
  }
}

/// 中间件管理器
/// 
/// 负责管理所有中间件的注册和生命周期
class MiddlewareManager {
  static MiddlewareManager? _instance;
  
  MiddlewareManager._internal();
  
  /// 单例实例
  static MiddlewareManager get instance {
    _instance ??= MiddlewareManager._internal();
    return _instance!;
  }

  /// 已注册的中间件
  final Map<String, BaseRouteMiddleware> _middlewares = {};

  /// 注册中间件
  void registerMiddleware(BaseRouteMiddleware middleware) {
    if (_middlewares.containsKey(middleware.middlewareName)) {
      debugPrint('警告: 中间件 ${middleware.middlewareName} 已存在，将被覆盖');
    }
    
    _middlewares[middleware.middlewareName] = middleware;
    debugPrint('已注册中间件: ${middleware.middlewareName}');
  }

  /// 批量注册中间件
  void registerMiddlewares(List<BaseRouteMiddleware> middlewares) {
    for (final middleware in middlewares) {
      registerMiddleware(middleware);
    }
  }

  /// 获取中间件
  T? getMiddleware<T extends BaseRouteMiddleware>(String name) {
    final middleware = _middlewares[name];
    return middleware is T ? middleware : null;
  }

  /// 获取所有中间件
  List<BaseRouteMiddleware> getAllMiddlewares() {
    return _middlewares.values.toList();
  }

  /// 获取已启用的中间件
  List<BaseRouteMiddleware> getEnabledMiddlewares() {
    return _middlewares.values.where((middleware) => middleware.isEnabled).toList();
  }

  /// 获取中间件统计信息
  Map<String, dynamic> getStatistics() {
    final total = _middlewares.length;
    final enabled = getEnabledMiddlewares().length;
    
    return {
      'total': total,
      'enabled': enabled,
      'disabled': total - enabled,
    };
  }

  /// 获取所有中间件状态
  Map<String, Map<String, dynamic>> getAllStatus() {
    final status = <String, Map<String, dynamic>>{};
    
    for (final middleware in _middlewares.values) {
      status[middleware.middlewareName] = middleware.getStatus();
    }
    
    return status;
  }

  /// 清除所有中间件
  void clear() {
    _middlewares.clear();
  }

  @override
  String toString() {
    final stats = getStatistics();
    return 'MiddlewareManager(总计: ${stats['total']}, 已启用: ${stats['enabled']})';
  }
}
