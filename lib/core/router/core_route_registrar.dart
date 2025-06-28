/// 核心路由注册器
///
/// 提供系统级核心路由，如错误页、加载页等
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_base/core/router/page/network_error_page.dart';
import 'package:flutter_application_base/core/router/page/not_found_404_page.dart';
import 'package:go_router/go_router.dart';

import 'page/error_screen.dart';

/// 核心路由注册器
class CoreRouteRegistrar {
  List<RouteBase> getRoutes() {
    return [
      // 错误页路由
      GoRoute(
        path: '/core/error',
        name: 'core-error',
        builder: (context, state) {
          final error = state.extra as Exception?;
          return ErrorScreenPage(error: error ?? Exception('未知错误'));
        },
      ),

      // 网络错误页
      GoRoute(
        path: '/core/network-error',
        name: 'core-network-error',
        builder: (context, state) => const NoConnectionScreen(),
      ),

      // 404页面
      GoRoute(
        path: '/core/not-found',
        name: 'core-not-found',
        builder: (context, state) => const Error404Screen(),
      ),
    ];
  }
}
