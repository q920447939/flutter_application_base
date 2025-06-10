/// 应用初始化管理器
///
/// 负责应用启动时的各种初始化工作，包括：
/// - 依赖注入配置
/// - 数据库初始化
/// - 网络配置
/// - 主题配置
/// - 权限检查等
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../permissions/permission_service.dart';
import '../permissions/permission_initializer.dart';
import '../security/security_detector.dart';
import '../security/certificate_pinning_service.dart';
import '../localization/localization_service.dart';
import '../../features/auth/services/auth_service.dart';
import '../storage/storage_service.dart';
import '../router/dynamic_route_service.dart';
import '../network/network_initializer.dart';
import '../theme/theme_initializer.dart';
import '../../example/routes/example_routes.dart';

/// 应用初始化器
class AppInitializer {
  static bool _isInitialized = false;

  /// 初始化应用
  static Future<void> initialize() async {
    if (_isInitialized) return;

    WidgetsFlutterBinding.ensureInitialized();

    // 初始化Hive数据库
    await _initializeHive();

    // 初始化依赖注入
    await _initializeDependencies();

    // 初始化存储服务（必须在认证服务之前）
    await StorageService.instance.initialize();

    // 初始化网络配置
    await _initializeNetwork();

    // 初始化主题配置
    await _initializeTheme();

    // 初始化权限
    await _initializePermissions();

    // 初始化安全检测
    await _initializeSecurity();

    // 初始化国际化
    await _initializeLocalization();

    // 初始化认证服务
    await _initializeAuth();

    // 初始化动态路由服务
    await _initializeDynamicRoutes();

    // 初始化示例路由系统
    await _initializeExampleRoutes();

    _isInitialized = true;
  }

  /// 初始化Hive数据库
  static Future<void> _initializeHive() async {
    await Hive.initFlutter();
    // 注册适配器
    // Hive.registerAdapter(UserAdapter());
  }

  /// 初始化依赖注入
  static Future<void> _initializeDependencies() async {
    // 注册核心服务
    Get.put<DynamicRouteService>(DynamicRouteService());
    // Get.put<NetworkService>(NetworkService());
    // Get.put<StorageService>(StorageService());
    // Get.put<ThemeService>(ThemeService());
  }

  /// 初始化网络配置
  static Future<void> _initializeNetwork() async {
    // 使用网络初始化器进行完整的网络层初始化
    final result = await NetworkInitializer.instance.initialize();

    if (!result.success) {
      debugPrint('网络初始化失败: ${result.error}');
      // 注意：这里不抛出异常，因为应用可能需要在离线模式下运行
    } else {
      debugPrint('网络初始化成功，耗时: ${result.duration.inMilliseconds}ms');
    }
  }

  /// 初始化主题配置
  static Future<void> _initializeTheme() async {
    // 使用主题初始化器进行完整的主题系统初始化
    final result = await ThemeInitializer.instance.initialize();

    if (!result.success) {
      debugPrint('主题初始化失败: ${result.error}');
      // 注意：这里不抛出异常，因为已经有降级方案
    } else {
      debugPrint('主题初始化成功，耗时: ${result.duration.inMilliseconds}ms');
      if (result.appliedTheme != null) {
        debugPrint('已应用主题: ${result.appliedTheme!.name}');
      }
    }
  }

  /// 初始化权限
  static Future<void> _initializePermissions() async {
    // 初始化权限服务
    PermissionService.instance;

    // 初始化权限系统
    final result = await PermissionInitializer.instance.initialize(
      showGuideOnStartup: true,
      useCache: true,
    );

    if (!result.success) {
      debugPrint('权限初始化失败: ${result.errorMessage}');
      if (result.shouldExitApp) {
        debugPrint('应用将退出');
        // 这里可以添加退出应用的逻辑
      }
    } else {
      debugPrint('权限初始化成功');
      debugPrint(
        '已授权权限: ${result.grantedPermissions.map((p) => p.name).join(', ')}',
      );
      if (result.deniedPermissions.isNotEmpty) {
        debugPrint(
          '被拒绝权限: ${result.deniedPermissions.map((p) => p.name).join(', ')}',
        );
      }
    }
  }

  /// 初始化安全检测
  static Future<void> _initializeSecurity() async {
    // 初始化安全检测服务
    SecurityDetector.instance;

    // 初始化证书绑定
    CertificatePinningService.instance.initializeCommonConfigs();
  }

  /// 初始化国际化
  static Future<void> _initializeLocalization() async {
    // 初始化国际化服务
    await LocalizationService.instance.initialize();
  }

  /// 初始化认证服务
  static Future<void> _initializeAuth() async {
    // 初始化认证服务
    await AuthService.instance.initialize();
  }

  /// 初始化动态路由服务
  static Future<void> _initializeDynamicRoutes() async {
    // 初始化动态路由服务并获取配置
    await DynamicRouteService.instance.fetchRouteConfig();
  }

  /// 初始化示例路由系统
  static Future<void> _initializeExampleRoutes() async {
    try {
      debugPrint('开始初始化示例路由系统...');

      // 初始化示例路由
      await ExampleRoutes.initializeRoutes();

      debugPrint('示例路由系统初始化完成');
    } catch (e) {
      debugPrint('示例路由系统初始化失败: $e');
      // 不抛出异常，允许应用继续运行
    }
  }

  /// 检查是否已初始化
  static bool get isInitialized => _isInitialized;
}
