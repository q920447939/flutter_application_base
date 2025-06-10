/// 示例路由配置
///
/// 展示如何使用新的路由架构配置应用路由
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_base/core/router/index.dart';
import 'package:flutter_application_base/core/permissions/permission_service.dart';
import '../pages/simple_example_pages.dart';
import 'declarative_permission_routes.dart';

/// 示例路由配置类
class ExampleRoutes {
  /// 获取所有路由配置
  static List<RouteConfig> getAllRoutes() {
    return [
      // 基础路由
      ...getBasicRoutes(),

      // 权限相关路由
      ...getPermissionRoutes(),

      // 声明式权限配置演示路由
      ...DeclarativePermissionRoutes.getAllRoutes(),

      // 系统路由
      ...getSystemRoutes(),
    ];
  }

  /// 获取所有路由组
  static List<RouteGroup> getAllRouteGroups() {
    return [
      // 用户相关路由组
      getUserRouteGroup(),

      // 媒体相关路由组
      getMediaRouteGroup(),

      // 工具相关路由组
      getToolsRouteGroup(),
    ];
  }

  /// 基础路由配置
  static List<RouteConfig> getBasicRoutes() {
    return [
      // 首页
      RoutePresets.home(() => const SimpleHomePage()),

      // 关于页面
      RoutePresets.about(() => const SimpleAboutPage()),

      // 帮助页面
      RoutePresets.help(() => const SimpleHelpPage()),
    ];
  }

  /// 权限相关路由配置
  static List<RouteConfig> getPermissionRoutes() {
    return [
      // 相机页面（需要权限）
      RouteBuilder()
          .path('/camera_demo')
          .page(() => const SimpleCameraPage())
          .title('相机演示')
          .withPermissions(
            required: [AppPermission.camera],
            optional: [AppPermission.storage],
            onGranted: (permissions) {
              debugPrint('权限已授权: ${permissions.map((p) => p.name).join(', ')}');
            },
            onDenied: (permissions) async {
              debugPrint('权限被拒绝: ${permissions.map((p) => p.name).join(', ')}');
              return false; // 不允许进入页面
            },
          )
          .withAnalytics(
            pageName: 'camera_demo',
            customParameters: {'demo_type': 'permission'},
          )
          .build(),

      // 地图页面（需要位置权限和网络）
      RouteBuilder()
          .path('/map_demo')
          .page(() => const SimpleMapPage())
          .title('地图演示')
          .withPermissions(
            optional: [AppPermission.location],
            showGuide: true,
            allowSkipOptional: true,
          )
          .withLoading(
            enableNetworkCheck: true,
            minLoadingDuration: 1000,
            onPreloadData: () async {
              // 模拟地图数据加载
              await Future.delayed(const Duration(seconds: 2));
              debugPrint('地图数据加载完成');
              return true;
            },
            onNetworkStatusChanged: (isConnected) {
              debugPrint('网络状态变化: ${isConnected ? '已连接' : '已断开'}');
            },
          )
          .withAnalytics(
            pageName: 'map_demo',
            customParameters: {'demo_type': 'location_network'},
          )
          .build(),

      // 多媒体页面（需要多个权限）
      RouteBuilder()
          .path('/multimedia_demo')
          .page(() => const SimpleMultimediaPage())
          .title('多媒体演示')
          .withPermissions(
            required: [AppPermission.camera, AppPermission.microphone],
            optional: [AppPermission.storage],
            showGuide: true,
          )
          .withAnalytics(
            pageName: 'multimedia_demo',
            customParameters: {'demo_type': 'multimedia'},
          )
          .build(),

      // 文件管理页面（需要存储权限）
      RouteBuilder()
          .path('/file_demo')
          .page(() => const SimpleFilePage())
          .title('文件管理演示')
          .withPermissions(
            required: [AppPermission.storage],
            showGuide: true,
            allowSkipOptional: false,
          )
          .withAnalytics(pageName: 'file_demo')
          .build(),
    ];
  }

  /// 系统路由配置
  static List<RouteConfig> getSystemRoutes() {
    return [
      // 错误页面
      RoutePresets.error(() => const SimpleErrorPage()),

      // 权限被拒绝页面
      RoutePresets.permissionDenied(() => const SimplePermissionDeniedPage()),

      // 网络错误页面
      RoutePresets.networkError(() => const SimpleNetworkErrorPage()),

      // 加载错误页面
      RoutePresets.loadingError(() => const SimpleLoadingErrorPage()),
    ];
  }

  /// 用户相关路由组
  static RouteGroup getUserRouteGroup() {
    return RouteGroupBuilder()
        .name('user')
        .prefix('/user')
        .description('用户相关页面')
        .withGroupAnalytics(customParameters: {'group': 'user'})
        .routeBuilder(
          (builder) => builder
              .path('/profile')
              .page(() => const SimpleProfilePage())
              .title('个人资料')
              .withAnalytics(pageName: 'user_profile'),
        )
        .routeBuilder(
          (builder) => builder
              .path('/settings')
              .page(() => const SimpleSettingsPage())
              .title('设置')
              .withAnalytics(pageName: 'user_settings'),
        )
        .routeBuilder(
          (builder) => builder
              .path('/edit')
              .page(() => const SimpleEditProfilePage())
              .title('编辑资料')
              .withAnalytics(pageName: 'user_edit'),
        )
        .build();
  }

  /// 媒体相关路由组
  static RouteGroup getMediaRouteGroup() {
    return RouteGroupBuilder()
        .name('media')
        .prefix('/media')
        .description('媒体相关页面')
        .withGroupPermissions(
          optional: [
            AppPermission.camera,
            AppPermission.microphone,
            AppPermission.storage,
          ],
          showGuide: true,
        )
        .withGroupAnalytics(customParameters: {'group': 'media'})
        .routeBuilder(
          (builder) => builder
              .path('/camera')
              .page(() => const SimpleMediaCameraPage())
              .title('相机')
              .withAnalytics(pageName: 'media_camera'),
        )
        .routeBuilder(
          (builder) => builder
              .path('/gallery')
              .page(() => const SimpleMediaGalleryPage())
              .title('相册')
              .withAnalytics(pageName: 'media_gallery'),
        )
        .routeBuilder(
          (builder) => builder
              .path('/video')
              .page(() => const SimpleMediaVideoPage())
              .title('视频')
              .withAnalytics(pageName: 'media_video'),
        )
        .build();
  }

  /// 工具相关路由组
  static RouteGroup getToolsRouteGroup() {
    return RouteGroupBuilder()
        .name('tools')
        .prefix('/tools')
        .description('工具相关页面')
        .withGroupAnalytics(customParameters: {'group': 'tools'})
        .routeBuilder(
          (builder) => builder
              .path('/qr_scan')
              .page(() => const SimpleQRScanPage())
              .title('二维码扫描')
              .withPermissions(required: [AppPermission.camera])
              .withAnalytics(pageName: 'tools_qr_scan'),
        )
        .routeBuilder(
          (builder) => builder
              .path('/bluetooth')
              .page(() => const SimpleBluetoothPage())
              .title('蓝牙')
              .withPermissions(
                required: [AppPermission.bluetooth],
                optional: [
                  AppPermission.bluetoothScan,
                  AppPermission.bluetoothConnect,
                ],
              )
              .withAnalytics(pageName: 'tools_bluetooth'),
        )
        .routeBuilder(
          (builder) => builder
              .path('/calculator')
              .page(() => const SimpleCalculatorPage())
              .title('计算器')
              .withAnalytics(pageName: 'tools_calculator'),
        )
        .build();
  }

  /// 初始化路由系统
  static Future<void> initializeRoutes() async {
    try {
      debugPrint('开始初始化示例路由系统...');

      // 初始化路由管理器
      await AppRouteManager.instance.initialize(
        routes: getAllRoutes(),
        routeGroups: getAllRouteGroups(),
        validateRoutes: true,
      );

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
    // 如果 AppRouteManager 已初始化，使用它的配置
    if (AppRouteManager.instance.isInitialized) {
      return AppRouteManager.instance.getGetPages();
    }

    // 否则返回简化的路由配置
    return [
      // 首页
      GetPage(name: '/', page: () => const SimpleHomePage()),

      // 基础演示页面
      GetPage(name: '/camera_demo', page: () => const SimpleCameraPage()),
      GetPage(name: '/map_demo', page: () => const SimpleMapPage()),
      GetPage(
        name: '/multimedia_demo',
        page: () => const SimpleMultimediaPage(),
      ),
      GetPage(name: '/file_demo', page: () => const SimpleFilePage()),

      // 用户相关页面
      GetPage(name: '/user/profile', page: () => const SimpleProfilePage()),
      GetPage(name: '/user/settings', page: () => const SimpleSettingsPage()),
      GetPage(name: '/user/edit', page: () => const SimpleEditProfilePage()),

      // 媒体相关页面
      GetPage(name: '/media/camera', page: () => const SimpleMediaCameraPage()),
      GetPage(
        name: '/media/gallery',
        page: () => const SimpleMediaGalleryPage(),
      ),
      GetPage(name: '/media/video', page: () => const SimpleMediaVideoPage()),

      // 工具相关页面
      GetPage(name: '/tools/qr_scan', page: () => const SimpleQRScanPage()),
      GetPage(
        name: '/tools/bluetooth',
        page: () => const SimpleBluetoothPage(),
      ),
      GetPage(
        name: '/tools/calculator',
        page: () => const SimpleCalculatorPage(),
      ),

      // 声明式权限配置演示
      ...DeclarativePermissionRoutes.getGetPages(),

      // 系统页面
      GetPage(name: '/error', page: () => const SimpleErrorPage()),
      GetPage(
        name: '/permission_denied',
        page: () => const SimplePermissionDeniedPage(),
      ),
      GetPage(
        name: '/network_error',
        page: () => const SimpleNetworkErrorPage(),
      ),
      GetPage(
        name: '/loading_error',
        page: () => const SimpleLoadingErrorPage(),
      ),

      // 关于和帮助页面
      GetPage(name: '/about', page: () => const SimpleAboutPage()),
      GetPage(name: '/help', page: () => const SimpleHelpPage()),
    ];
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
