/// 框架示例应用
///
/// 独立的示例应用，展示框架的各种功能
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_base/core/permissions/permission_guide_page.dart';
import 'package:flutter_application_base/core/permissions/permission_service.dart';
import 'package:flutter_application_base/core/router/middlewares/permission_middleware.dart';
import 'package:flutter_application_base/example/pages/declarative_permission_demo_pages.dart';
import 'package:get/get.dart';
import 'package:flutter_application_base/example/routes/example_routes.dart';

/// 示例应用主类
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter框架示例1',
      debugShowCheckedModeBanner: false,

      // 使用示例路由配置
      getPages: [
        ...ExampleRoutes.getGetPages(),
        GetPage(
          name: '/declarative/camera',
          page: () => const DeclarativeCameraPage(),
          middlewares: [
            // 只检查相机页面需要的权限
            PermissionMiddlewareBuilder()
                .requiredPermissions([
                  AppPermission.camera,
                  AppPermission.storage,
                ])
                .maxAttempts(3) // 最多尝试3次
                .deniedStrategy(PermissionDeniedStrategy.goBack) // 拒绝后返回上一页
                .showGuide(true)
                .onPermissionGranted((permissions) {
                  debugPrint(
                    '相机页面权限已授权: ${permissions.map((p) => p.name).join(', ')}',
                  );
                })
                .onMaxAttemptsReached((route, attempts) async {
                  debugPrint('相机页面权限检查达到最大尝试次数: $attempts');
                  // 可以在这里记录用户行为分析
                })
                .build(),
          ],
        ),
      ],
      initialRoute: '/declarative',

      // 主题配置
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,

      // 全局配置
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? const SizedBox.shrink(),
        );
      },

      // 错误处理
      unknownRoute: GetPage(
        name: '/unknown',
        page: () => const UnknownRoutePage(),
      ),
    );
  }

  /// 构建浅色主题
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  /// 构建深色主题
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

/// 未知路由页面
class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              '页面未找到',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('您访问的页面不存在', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.offAllNamed('/declarative'),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotPermission extends StatelessWidget {
  const NotPermission({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('您必须拥有权限才能访问'));
  }
}
