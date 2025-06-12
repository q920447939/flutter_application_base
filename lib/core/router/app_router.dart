/// 应用路由管理
///
/// 支持静态和动态路由配置，提供：
/// - 声明式路由配置
/// - 动态路由从后端获取
/// - 路由守卫
/// - 深度链接支持
/// - 路由动画
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/splash/splash_page.dart';
import '../../features/home/home_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/pages/edit_profile_page.dart';
import '../../features/settings/pages/settings_page.dart';
import 'dynamic_route_service.dart';
import 'dynamic_page_factory.dart';
import 'auth_middleware.dart';

/// 路由路径常量
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String settings = '/settings';
  static const String notFound = '/404';
}

/// 应用路由配置
class AppRouter {
  /// 静态路由页面列表
  static List<GetPage> get staticPages => [
    // 启动页
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),

    // 认证相关路由
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.register, page: () => const RegisterPage()),

    // 主应用路由
    GetPage(name: AppRoutes.home, page: () => const HomePage()),

    // 用户资料
    GetPage(name: AppRoutes.profile, page: () => const ProfilePage()),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfilePage()),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const _ChangePasswordPage(),
    ),

    // 设置页面
    GetPage(name: AppRoutes.settings, page: () => const SettingsPage()),

    // 404页面
    GetPage(name: AppRoutes.notFound, page: () => const _NotFoundPage()),
  ];

  /// 初始化动态路由
  static Future<void> initializeDynamicRoutes() async {
    await DynamicRouteService.instance.fetchRouteConfig();
  }

  /// 刷新动态路由
  static Future<void> refreshDynamicRoutes() async {
    await DynamicRouteService.instance.fetchRouteConfig(forceRefresh: true);
    // 通知GetX重新构建路由
    Get.reset();
  }

  /// 检查路由是否存在
  static bool routeExists(String path) {
    // 检查静态路由
    final staticRouteExists = staticPages.any((page) => page.name == path);
    if (staticRouteExists) return true;

    // 检查动态路由
    final dynamicRoute = DynamicRouteService.instance.getRouteByPath(path);
    return dynamicRoute != null && dynamicRoute.enabled;
  }

  /// 导航到路由
  static Future<T?> navigateTo<T>(
    String path, {
    Map<String, dynamic>? arguments,
    bool preventDuplicates = true,
  }) async {
    // 检查路由是否存在
    if (!routeExists(path)) {
      Get.toNamed(AppRoutes.notFound);
      return null;
    }

    // 检查是否需要认证
    final dynamicRoute = DynamicRouteService.instance.getRouteByPath(path);
    if (dynamicRoute?.requiresAuth == true) {
      // 这里可以添加认证检查逻辑
      // if (!AuthService.instance.isAuthenticated) {
      //   Get.toNamed(AppRoutes.login);
      //   return null;
      // }
    }

    return Get.toNamed<T>(
      path,
      arguments: arguments,
      preventDuplicates: preventDuplicates,
    );
  }

  /// 替换当前路由
  static Future<T?> replaceTo<T>(
    String path, {
    Map<String, dynamic>? arguments,
  }) async {
    if (!routeExists(path)) {
      Get.offNamed(AppRoutes.notFound);
      return null;
    }

    return Get.offNamed<T>(path, arguments: arguments);
  }

  /// 清空路由栈并导航
  static Future<T?> navigateAndClearStack<T>(
    String path, {
    Map<String, dynamic>? arguments,
  }) async {
    if (!routeExists(path)) {
      Get.offAllNamed(AppRoutes.notFound);
      return null;
    }

    return Get.offAllNamed<T>(path, arguments: arguments);
  }
}

// ==================== 页面组件 ====================
// 这些是临时的页面组件，实际项目中应该在对应的feature模块中

// 启动页面已在 features/splash/splash_page.dart 中实现

// 登录和注册页面已在 features/auth/pages/ 中实现

// 首页已在 features/home/home_page.dart 中实现

// 用户资料页面已在 features/profile/pages/ 中实现

/// 修改密码页面（临时）
class _ChangePasswordPage extends StatelessWidget {
  const _ChangePasswordPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('修改密码')),
      body: const Center(child: Text('修改密码页面开发中...')),
    );
  }
}

// 设置页面已在 features/settings/pages/settings_page.dart 中实现

/// 404页面
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面未找到')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              '404',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            Text('页面未找到'),
          ],
        ),
      ),
    );
  }
}
