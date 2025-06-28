import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../permissions/platform_detector.dart';

class AppInitInfo {
  final ScreenRatio screenRatio;
  final Widget child;
  final bool openDevicePreview;
  final AppRouterConfig appRouterConfig;

  AppInitInfo({
    required this.child,
    required this.appRouterConfig,
    ScreenRatio? screenRatio,
    this.openDevicePreview = false,
  }) : screenRatio = screenRatio ?? ScreenRatio() {
    if (appRouterConfig.bottomNavRoutes.isEmpty &&
        appRouterConfig.defaultRoutes.isEmpty) {
      throw Exception('路由配置不能为空');
    }
  }
}

class ScreenRatio {
  final double aspectRatio;

  ScreenRatio({double? aspectRatio})
    : aspectRatio = aspectRatio ?? _getDefaultAspectRatio();

  /// 根据平台获取默认宽高比
  static double _getDefaultAspectRatio() {
    final platformDetector = PlatformDetector.instance;

    if (platformDetector.isMobile) {
      // 手机默认 16:9
      return 16.0 / 9.0;
    } else {
      //  默认不设置 (-1)
      return -1.0;
    }
  }
}

class AppRouterConfig {
  final List<RouteBase> bottomNavRoutes;
  final List<RouteBase> defaultRoutes;

  AppRouterConfig({
    this.bottomNavRoutes = const [],
    required this.defaultRoutes,
  });
}
