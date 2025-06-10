/// Flutter 自建框架主应用入口
///
/// 集成了核心框架组件：
/// - 应用初始化
/// - 路由管理
/// - 状态管理
/// - 主题系统
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 核心框架导入
import 'core/app/app_initializer.dart';
import 'core/app/app_config.dart';
import 'core/router/app_router.dart';
import 'core/localization/translations.dart';
import 'core/localization/app_localizations.dart';
import 'core/network/network_service.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 设置应用配置（根据构建环境）
  AppConfig.setCurrent(AppConfig.development);

  // 初始化应用
  await AppInitializer.initialize();

  // 初始化网络服务
  NetworkService.instance;

  // 运行应用
  runApp(const MyApp());
}

/// 主应用组件
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // 应用基本信息
      title: AppConfig.current.appName,
      debugShowCheckedModeBanner: AppConfig.current.isDebugMode,

      // 路由配置
      initialRoute: '/splash',
      getPages: AppRouter.pages,

      // 主题配置
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,

      // 国际化配置
      locale: const Locale('zh', 'CN'),
      fallbackLocale: const Locale('en', 'US'),
      translations: AppTranslations(),

      // 全局配置
      builder: (context, child) {
        return MediaQuery(
          // 禁用系统字体缩放
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? const SizedBox.shrink(),
        );
      },
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
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
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
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
