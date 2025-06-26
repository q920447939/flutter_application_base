/// 路由配置数据模型
/// 
/// 支持从配置文件动态加载路由定义
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../base/route_registrar.dart';

/// 路由配置数据模型
class RouteConfigModel {
  final String path;
  final String name;
  final String pageClass;
  final bool requiresAuth;
  final bool hasBottomNav;
  final Map<String, dynamic> metadata;
  final List<RouteConfigModel> children;
  
  const RouteConfigModel({
    required this.path,
    required this.name,
    required this.pageClass,
    this.requiresAuth = false,
    this.hasBottomNav = false,
    this.metadata = const {},
    this.children = const [],
  });
  
  /// 从JSON创建路由配置
  factory RouteConfigModel.fromJson(Map<String, dynamic> json) {
    return RouteConfigModel(
      path: json['path'] as String,
      name: json['name'] as String,
      pageClass: json['pageClass'] as String,
      requiresAuth: json['requiresAuth'] as bool? ?? false,
      hasBottomNav: json['hasBottomNav'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      children: (json['children'] as List<dynamic>?)
          ?.map((child) => RouteConfigModel.fromJson(child as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'pageClass': pageClass,
      'requiresAuth': requiresAuth,
      'hasBottomNav': hasBottomNav,
      'metadata': metadata,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }
}

/// 页面工厂接口
abstract class PageFactory {
  /// 创建页面实例
  Widget createPage(String pageClass, GoRouterState state);
  
  /// 注册页面构造器
  void registerPageBuilder(String pageClass, Widget Function(GoRouterState) builder);
  
  /// 检查页面类是否已注册
  bool isPageRegistered(String pageClass);
}

/// 默认页面工厂实现
class DefaultPageFactory implements PageFactory {
  static final DefaultPageFactory _instance = DefaultPageFactory._internal();
  factory DefaultPageFactory() => _instance;
  DefaultPageFactory._internal();
  
  final Map<String, Widget Function(GoRouterState)> _builders = {};
  
  @override
  Widget createPage(String pageClass, GoRouterState state) {
    final builder = _builders[pageClass];
    if (builder == null) {
      throw Exception('未注册的页面类: $pageClass');
    }
    return builder(state);
  }
  
  @override
  void registerPageBuilder(String pageClass, Widget Function(GoRouterState) builder) {
    _builders[pageClass] = builder;
  }
  
  @override
  bool isPageRegistered(String pageClass) {
    return _builders.containsKey(pageClass);
  }
  
  /// 注册默认页面构造器
  void registerDefaultBuilders() {
    // 注册一些默认的页面构造器
    registerPageBuilder('ErrorPage', (state) {
      final error = state.extra as Exception?;
      return ErrorPage(error: error);
    });
    
    registerPageBuilder('LoadingPage', (state) => const LoadingPage());
    
    registerPageBuilder('NotFoundPage', (state) => const NotFoundPage());
  }
}

/// 配置化路由注册器
class ConfigurableRouteRegistrar extends MetadataRouteRegistrar {
  final List<RouteConfigModel> _routeConfigs;
  final PageFactory _pageFactory;
  final String _namespace;
  final RouteLayer _layer;
  final List<String> _dependencies;
  
  ConfigurableRouteRegistrar({
    required List<RouteConfigModel> routeConfigs,
    PageFactory? pageFactory,
    String namespace = 'configurable',
    RouteLayer layer = RouteLayer.business,
    List<String> dependencies = const [],
  }) : _routeConfigs = routeConfigs,
       _pageFactory = pageFactory ?? DefaultPageFactory(),
       _namespace = namespace,
       _layer = layer,
       _dependencies = dependencies;
  
  @override
  String get namespace => _namespace;
  
  @override
  RouteLayer get layer => _layer;
  
  @override
  List<String> get dependencies => _dependencies;
  
  @override
  RouteMetadata getMetadata() {
    return RouteMetadata(
      name: '配置化路由',
      description: '从配置文件加载的路由',
      version: '1.0.0',
      extra: {
        'routeCount': _routeConfigs.length,
        'configSource': 'file',
      },
    );
  }
  
  @override
  List<RouteBase> getRoutes() {
    return _routeConfigs.map((config) => _buildRouteFromConfig(config)).toList();
  }
  
  /// 从配置构建路由
  GoRoute _buildRouteFromConfig(RouteConfigModel config) {
    return GoRoute(
      path: config.path,
      name: config.name,
      builder: (context, state) {
        try {
          return _pageFactory.createPage(config.pageClass, state);
        } catch (e) {
          // 如果页面创建失败，返回错误页面
          return ErrorPage(error: Exception('页面创建失败: ${config.pageClass}, 错误: $e'));
        }
      },
      routes: config.children.map((child) => _buildRouteFromConfig(child)).toList(),
    );
  }
  
  @override
  bool validateRoutes() {
    // 验证所有页面类是否已注册
    for (final config in _routeConfigs) {
      if (!_validateRouteConfig(config)) {
        return false;
      }
    }
    return super.validateRoutes();
  }
  
  bool _validateRouteConfig(RouteConfigModel config) {
    // 检查页面类是否已注册
    if (!_pageFactory.isPageRegistered(config.pageClass)) {
      return false;
    }
    
    // 递归验证子路由
    for (final child in config.children) {
      if (!_validateRouteConfig(child)) {
        return false;
      }
    }
    
    return true;
  }
}

/// 示例错误页面
class ErrorPage extends StatelessWidget {
  final Exception? error;
  
  const ErrorPage({super.key, this.error});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('错误')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(error?.toString() ?? '未知错误'),
          ],
        ),
      ),
    );
  }
}

/// 示例加载页面
class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// 示例404页面
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面未找到')),
      body: const Center(
        child: Text('404 - 页面未找到'),
      ),
    );
  }
}
