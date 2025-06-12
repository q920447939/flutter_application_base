/// 声明式权限配置路由演示
///
/// 展示如何在路由配置中使用声明式权限配置
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_base/core/router/index.dart';
import 'package:flutter_application_base/core/permissions/permission_service.dart';
import '../pages/declarative_permission_demo_pages.dart';

/// 声明式权限配置路由类
class DeclarativePermissionRoutes {
  /// 获取所有声明式权限演示路由
  static List<RouteConfig> getAllRoutes() {
    return [
      // 演示首页
      _getHomePage(),

      // 预设权限配置演示
      ..._getPresetRoutes(),
    ];
  }

  /// 获取GetX路由页面列表
  static List<GetPage> getGetPages() {
    return [
      // 演示首页
      GetPage(
        name: '/declarative',
        page: () => const DeclarativePermissionHomePage(),
      ),

      // 预设权限配置演示
      GetPage(
        name: '/declarative/camera',
        page: () => const DeclarativeCameraPage(),
      ),
      GetPage(
        name: '/declarative/location',
        page: () => const DeclarativeLocationPage(),
      ),
      GetPage(
        name: '/declarative/multimedia',
        page: () => const DeclarativeMultimediaPage(),
      ),
      GetPage(
        name: '/declarative/communication',
        page: () => const DeclarativeCommunicationPage(),
      ),
      GetPage(
        name: '/declarative/storage',
        page: () => const DeclarativeStoragePage(),
      ),
      GetPage(
        name: '/declarative/bluetooth',
        page: () => const DeclarativeBluetoothPage(),
      ),

      // 自定义权限配置演示
      GetPage(
        name: '/declarative/custom',
        page: () => const DeclarativeCustomPage(),
      ),
      GetPage(
        name: '/declarative/factory',
        page: () => const DeclarativeFactoryPage(),
      ),
    ];
  }

  /// 演示首页路由
  static RouteConfig _getHomePage() {
    return RouteBuilder()
        .path('/declarative')
        .page(() => const DeclarativePermissionHomePage())
        .title('声明式权限配置演示1')
        .withAnalytics(pageName: 'declarative_permission_home')
        .build();
  }

  /// 预设权限配置路由
  static List<RouteConfig> _getPresetRoutes() {
    return [
      // 1. 相机演示 - 使用预设权限配置
      RoutePresets.withDeclarativePermissions(
        '/declarative/camera',
        () => const DeclarativeCameraPage(),
        PermissionPresets.camera,
        title: '相机演示',
        analyticsPageName: 'declarative_camera',
      ),

      // 2. 位置演示 - 可选权限配置
      RoutePresets.withDeclarativePermissions(
        '/declarative/location',
        () => const DeclarativeLocationPage(),
        PermissionPresets.location,
        title: '位置演示',
        analyticsPageName: 'declarative_location',
      ),

      // 3. 多媒体演示 - 多权限组合
      RoutePresets.withDeclarativePermissions(
        '/declarative/multimedia',
        () => const DeclarativeMultimediaPage(),
        PermissionPresets.multimedia,
        title: '多媒体演示',
        analyticsPageName: 'declarative_multimedia',
      ),

      // 4. 通讯演示 - 通讯录权限
      RoutePresets.withDeclarativePermissions(
        '/declarative/communication',
        () => const DeclarativeCommunicationPage(),
        PermissionPresets.communication,
        title: '通讯演示',
        analyticsPageName: 'declarative_communication',
      ),

      // 5. 存储演示 - 文件系统权限
      RoutePresets.withDeclarativePermissions(
        '/declarative/storage',
        () => const DeclarativeStoragePage(),
        PermissionPresets.storage,
        title: '存储演示',
        analyticsPageName: 'declarative_storage',
      ),

      // 6. 蓝牙演示 - 蓝牙设备权限
      RoutePresets.withDeclarativePermissions(
        '/declarative/bluetooth',
        () => const DeclarativeBluetoothPage(),
        PermissionPresets.bluetooth,
        title: '蓝牙演示',
        analyticsPageName: 'declarative_bluetooth',
      ),
    ];
  }

  /// 获取路由统计信息
  static Map<String, dynamic> getRouteStatistics() {
    final routes = getAllRoutes();
    final permissionRoutes =
        routes
            .where((route) => route.hasFeature<PermissionRouteFeature>())
            .toList();

    return {
      'total_routes': routes.length,
      'permission_routes': permissionRoutes.length,
      'preset_routes': _getPresetRoutes().length,
    };
  }

  /// 打印路由配置信息
  static void printRouteInfo() {
    final routes = getAllRoutes();
    debugPrint('=== 声明式权限配置路由信息 ===');

    for (final route in routes) {
      final permissionFeature = route.getFeature<PermissionRouteFeature>();
      if (permissionFeature != null) {
        final config = permissionFeature.config;
        debugPrint('路由: ${route.path}');
        debugPrint('  标题: ${route.title}');
        debugPrint(
          '  必需权限: ${config.requiredPermissions.map((p) => p.name).join(', ')}',
        );
        debugPrint(
          '  可选权限: ${config.optionalPermissions.map((p) => p.name).join(', ')}',
        );
        debugPrint('  显示引导: ${config.showGuide}');
        debugPrint('  允许跳过: ${config.allowSkipOptional}');
        debugPrint('---');
      }
    }

    final stats = getRouteStatistics();
    debugPrint('统计信息: $stats');
  }

  /// 验证所有路由配置
  static bool validateAllRoutes() {
    try {
      final routes = getAllRoutes();
      for (final route in routes) {
        final validationResult = RouteConfigValidator.validateRoute(route);
        if (!validationResult.isValid) {
          debugPrint('路由验证失败: ${route.path}');
          for (final error in validationResult.errors) {
            debugPrint('  错误: $error');
          }
          return false;
        }
      }
      debugPrint('所有声明式权限路由验证通过');
      return true;
    } catch (e) {
      debugPrint('路由验证异常: $e');
      return false;
    }
  }
}
