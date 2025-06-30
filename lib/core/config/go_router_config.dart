// Create a GoRouter with all your app routes
import 'package:flutter/material.dart';
import 'package:flutter_application_base/core/analytics/observers/transparent_analytics_observer.dart';
import 'package:flutter_application_base/core/app/app_init_info.dart';
import 'package:flutter_application_base/ui/components/bottom_bar/scaffold_with_navbar.dart';
import 'package:flutter_application_base/utils/member_helper.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

import '../router/error_router.dart';
import '../router/core_route_registrar.dart';

// 使用新的增强配置
var goRouterBaseConfig = GoRouterConfig();

class GoRouterConfig {
  /// 初始化时注册所有路由提供者
  GoRouterConfig() {
    _initializeRoutes();
  }

  /// 初始化路由
  void _initializeRoutes() {}

  GoRouter getRouter(AppRouterConfig appRouterConfig) {
    var defaultRoutes = CoreRouteRegistrar().getRoutes();
    if (appRouterConfig.defaultRoutes.isNotEmpty) {
      defaultRoutes.addAll(appRouterConfig.defaultRoutes);
    }
    return GoRouter(
      navigatorKey: GlobalKey<NavigatorState>(),
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return child;
          },
          routes: defaultRoutes,
        ),
        if (appRouterConfig.bottomNavRoutes.isNotEmpty)
          ShellRoute(
            navigatorKey: GlobalKey<NavigatorState>(),
            builder: (context, state, child) {
              return ScaffoldWithNavBar(state: state, child: child);
            },
            routes: appRouterConfig.bottomNavRoutes,
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
  }
}
