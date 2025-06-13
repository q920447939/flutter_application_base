/// 声明式权限配置路由演示
///
/// 展示如何在路由配置中使用声明式权限配置
library;

import 'package:flutter/material.dart';
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

      // 自定义权限配置演示
      ..._getCustomRoutes(),
    ];
  }

  /// 演示首页路由
  static RouteConfig _getHomePage() {
    return RouteBuilder()
        .path('/declarative')
        .page(() => const DeclarativePermissionHomePage())
        .title('声明式权限配置演示')
        .withAnalytics(pageName: 'declarative_permission_home')
        .build();
  }

  /// 预设权限配置路由
  static List<RouteConfig> _getPresetRoutes() {
    return [
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

  /// 自定义权限配置路由
  static List<RouteConfig> _getCustomRoutes() {
    return [
      // 7. 自定义权限配置演示 - 使用构建器模式
      RouteBuilder()
          .path('/declarative/custom')
          .page(() => const DeclarativeCustomPage())
          .title('自定义权限配置')
          .withDeclarativePermissions(
            PermissionConfigBuilder()
                .required([AppPermission.camera])
                .optional([AppPermission.storage, AppPermission.microphone])
                .description('这是一个自定义的权限配置演示')
                .showGuide(true)
                .allowSkipOptional(false)
                .deniedRedirectRoute('/permission_denied')
                .addCustomTitle(AppPermission.camera, '自定义相机权限')
                .addCustomDescription(AppPermission.camera, '用于演示自定义权限配置的相机功能')
                .addCustomTitle(AppPermission.storage, '自定义存储权限')
                .addCustomDescription(AppPermission.storage, '用于保存演示文件')
                .build(),
          )
          .withAnalytics(pageName: 'declarative_custom')
          .build(),

      // 8. 工厂方法演示 - 使用工厂方法创建
      RouteBuilder()
          .path('/declarative/factory')
          .page(() => const DeclarativeFactoryPage())
          .title('工厂方法演示')
          .withDeclarativePermissions(
            PermissionConfigFactory.multimedia(
              cameraRequired: true,
              micRequired: false,
            ),
          )
          .withAnalytics(pageName: 'declarative_factory')
          .build(),

      // 9. 复杂权限配置演示 - 组合多种配置方式
      RouteBuilder()
          .path('/declarative/complex')
          .page(() => const DeclarativeCustomPage())
          .title('复杂权限配置')
          .withDeclarativePermissions(
            PermissionConfigBuilder()
                .required([AppPermission.camera, AppPermission.microphone])
                .optional([
                  AppPermission.storage,
                  AppPermission.location,
                  AppPermission.contacts,
                ])
                .description('复杂的多权限配置演示，包含多个必需和可选权限')
                .showGuide(true)
                .allowSkipOptional(true)
                .customTitles({
                  AppPermission.camera: '高清相机',
                  AppPermission.microphone: '专业录音',
                  AppPermission.storage: '云端存储',
                  AppPermission.location: '精准定位',
                  AppPermission.contacts: '智能通讯录',
                })
                .customDescriptions({
                  AppPermission.camera: '提供4K高清视频录制功能',
                  AppPermission.microphone: '支持降噪和音效处理',
                  AppPermission.storage: '自动同步到云端存储',
                  AppPermission.location: '基于GPS的精准位置服务',
                  AppPermission.contacts: '智能联系人管理和推荐',
                })
                .build(),
          )
          .withAnalytics(
            pageName: 'declarative_complex',
            customParameters: {'complexity': 'high'},
          )
          .build(),

      // 10. Web权限演示 - Web平台特定权限
      RouteBuilder()
          .path('/declarative/web')
          .page(() => const DeclarativeCustomPage())
          .title('Web权限演示')
          .withDeclarativePermissions(PermissionPresets.webCamera)
          .withAnalytics(pageName: 'declarative_web')
          .build(),

      // 11. 桌面权限演示 - 桌面平台特定权限
      RouteBuilder()
          .path('/declarative/desktop')
          .page(() => const DeclarativeCustomPage())
          .title('桌面权限演示')
          .withDeclarativePermissions(PermissionPresets.desktopFileSystem)
          .withAnalytics(pageName: 'declarative_desktop')
          .build(),

      // 12. 条件权限配置演示 - 根据条件动态配置权限
      RouteBuilder()
          .path('/declarative/conditional')
          .page(() => const DeclarativeCustomPage())
          .title('条件权限配置')
          .withDeclarativePermissions(_getConditionalPermissionConfig())
          .withAnalytics(pageName: 'declarative_conditional')
          .build(),
    ];
  }

  /// 获取条件权限配置
  static RequiresPermissions _getConditionalPermissionConfig() {
    // 根据平台或其他条件动态配置权限
    final isWeb = identical(0, 0.0); // 简单的Web检测

    if (isWeb) {
      return PermissionConfigBuilder()
          .required([AppPermission.webCamera])
          .optional([AppPermission.webMicrophone, AppPermission.webLocation])
          .description('Web平台权限配置')
          .build();
    } else {
      return PermissionConfigBuilder()
          .required([AppPermission.camera])
          .optional([AppPermission.microphone, AppPermission.location])
          .description('移动平台权限配置')
          .build();
    }
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
      'custom_routes': _getCustomRoutes().length,
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
