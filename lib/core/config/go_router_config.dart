// Create a GoRouter with all your app routes
import 'package:flutter/material.dart';
import 'package:flutter_application_base/core/analytics/observers/transparent_analytics_observer.dart';
import 'package:flutter_application_base/ui/components/bottom_bar/scaffold_with_navbar.dart';
import 'package:flutter_application_base/utils/member_helper.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

import '../router/error_router.dart';
import '../router/has_bottom_navigator/shell_default_router.dart'
    as shell_default_router;

// 新增导入
import '../router/manager/dynamic_route_manager.dart';
import '../router/registrars/core_route_registrar.dart';
import '../router/registrars/common_route_registrar.dart';
import '../router/business/business_route_provider.dart';
import '../router/config/route_config_model.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

// 使用新的增强配置
var goRouterBaseConfig = EnhancedGoRouterConfig();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(state: state, child: child);
      },
      routes: goRouterBaseConfig.hasBottomNavigatorRoutes,
    ),
    ShellRoute(
      builder: (context, state, child) {
        return child;
      },
      routes: goRouterBaseConfig.notBottomNavigatorRoutes,
    ),
  ],
  redirect: (context, state) {
    /*    const isAuthenticated =
        true; // Add your logic to check whether a user is authenticated or not*/
    if (state.fullPath == null) {
      return null;
    }
    var fullPath = state.fullPath;
    if (fullPath == "/signup" || fullPath == "/signin") {
      return fullPath;
    }
    if (isFirstUse()) {
      return "/welcome";
    }
    var loginFlag = isLogin();
    if (!loginFlag) {
      return "/signin";
    }

    return fullPath;
  },
  observers: [FlutterSmartDialog.observer, AnalyticsObserver()],
  errorBuilder: (c, s) => ErrorRoute(error: s.error!).build(c, s),
);

/// 增强的GoRouter配置类
///
/// 支持动态路由注册和模块化管理
class EnhancedGoRouterConfig {
  final DynamicRouteManager _routeManager = DynamicRouteManager();

  /// 初始化时注册所有路由提供者
  EnhancedGoRouterConfig() {
    _initializeRoutes();
  }

  /// 初始化路由
  void _initializeRoutes() {
    // 注册核心路由
    _registerCoreRoutes();

    // 注册通用路由
    _registerCommonRoutes();

    // 注册业务路由（可选）
    _registerBusinessRoutes();

    // 注册配置化路由（可选）
    _registerConfigurableRoutes();
  }

  /// 注册核心路由
  void _registerCoreRoutes() {
    _routeManager.registerRouteProvider(CoreRouteRegistrar());
  }

  /// 注册通用路由
  void _registerCommonRoutes() {
    _routeManager.registerRouteProvider(CommonRouteRegistrar());
  }

  /// 注册业务路由
  void _registerBusinessRoutes() {
    // 示例：注册电商业务路由
    final ecommerceProvider = ECommerceRouteProvider();
    _routeManager.registerRouteProvider(
      BusinessRouteRegistrar(
        provider: ecommerceProvider,
        namespace: 'ecommerce',
        dependencies: ['common'],
      ),
    );
  }

  /// 注册配置化路由
  void _registerConfigurableRoutes() {
    // 这里可以从配置文件或远程配置加载路由
    // 示例配置
    final configs = [
      const RouteConfigModel(
        path: '/demo',
        name: 'demo',
        pageClass: 'DemoPage',
      ),
    ];

    // 注册页面构造器
    final pageFactory = DefaultPageFactory();
    pageFactory.registerDefaultBuilders();
    pageFactory.registerPageBuilder('DemoPage', (state) => const DemoPage());

    _routeManager.registerRouteProvider(
      ConfigurableRouteRegistrar(
        routeConfigs: configs,
        pageFactory: pageFactory,
        namespace: 'demo',
        dependencies: ['common'],
      ),
    );
  }

  /// 获取有底部导航的路由
  List<RouteBase> get hasBottomNavigatorRoutes {
    return _routeManager.getBottomNavRoutes();
  }

  /// 获取无底部导航的路由
  List<RouteBase> get notBottomNavigatorRoutes {
    return _routeManager.getNonBottomNavRoutes();
  }

  /// 动态注册业务路由提供者
  void registerBusinessProvider(
    BusinessRouteProvider provider, {
    String? namespace,
    List<String> dependencies = const [],
  }) {
    _routeManager.registerRouteProvider(
      BusinessRouteRegistrar(
        provider: provider,
        namespace: namespace,
        dependencies: dependencies,
      ),
    );
  }

  /// 获取路由管理器（用于高级操作）
  DynamicRouteManager get routeManager => _routeManager;
}

/// 示例演示页面
class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('演示页面')),
      body: const Center(child: Text('这是一个配置化路由的演示页面')),
    );
  }
}

/// 保留原有的配置类以兼容现有代码
@Deprecated('使用 EnhancedGoRouterConfig 替代')
class GoRouterBaseConfig {
  List<RouteBase> _hasBottomNavigatorRouterBaseList = [];
  List<RouteBase> _notBottomNavigatorRouterBaseList = [];

  get hasBottomNavigatorRouterBaseList => _hasBottomNavigatorRouterBaseList;

  get notBottomNavigatorRouterBaseList => _notBottomNavigatorRouterBaseList;

  GoRouterBaseConfig() {
    _hasBottomNavigatorRouterBaseList = [];
    _hasBottomNavigatorRouterBaseList.addAll(shell_default_router.$appRoutes);

    _notBottomNavigatorRouterBaseList = [];
    /* _notBottomNavigatorRouterBaseList.addAll(
      no_shell_default_router.$appRoutes,
    ); */
  }
}
