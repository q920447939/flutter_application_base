/// 示例路由配置
///
/// 展示如何使用新的路由架构配置应用路由
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_base/core/router/index.dart';
import 'package:flutter_application_base/core/permissions/permission_service.dart';
import 'declarative_permission_routes.dart';

/// 示例路由配置类
class ExampleRoutes {
  /// 获取所有路由配置
  static List<RouteConfig> getAllRoutes() {
    return [
      // 声明式权限配置演示路由
      ...DeclarativePermissionRoutes.getAllRoutes(),
    ];
  }

  /// 初始化路由系统
  static Future<void> initializeRoutes() async {
    try {
      debugPrint('开始初始化示例路由系统...');

      // 初始化路由管理器
      /*
      await AppRouteManager.instance.initialize(
        routes: getAllRoutes(),
        routeGroups: getAllRouteGroups(),
        validateRoutes: true,
      );
*/

      // 打印路由信息
      AppRouteManager.instance.printRouteInfo();

      debugPrint('示例路由系统初始化完成');
    } catch (e) {
      debugPrint('示例路由系统初始化失败: $e');
      rethrow;
    }
  }

  /// 获取GetX路由页面列表
  static List<GetPage> getGetPages() {
    return AppRouteManager.instance.getGetPages();
  }

  /// 获取路由统计信息
  static Map<String, dynamic> getRouteStatistics() {
    return AppRouteManager.instance.getStatistics();
  }

  /// 导出路由配置
  static Map<String, dynamic> exportRouteConfiguration() {
    return AppRouteManager.instance.exportConfiguration();
  }

  /// 查找路由示例
  static void demonstrateRouteFinding() {
    debugPrint('=== 路由查找演示 ===');

    // 查找包含 'demo' 的路由
    final demoRoutes = AppRouteManager.instance.findRoutes(pathPattern: 'demo');
    debugPrint('包含 "demo" 的路由: ${demoRoutes.map((r) => r.path).join(', ')}');

    // 查找需要权限的路由
    final permissionRoutes = AppRouteManager.instance.findRoutes(
      featureType: PermissionRouteFeature,
    );
    debugPrint('需要权限的路由: ${permissionRoutes.map((r) => r.path).join(', ')}');

    // 查找媒体相关路由
    final mediaRoutes = AppRouteManager.instance.findRoutes(titlePattern: '媒体');
    debugPrint('媒体相关路由: ${mediaRoutes.map((r) => r.path).join(', ')}');
  }
}
