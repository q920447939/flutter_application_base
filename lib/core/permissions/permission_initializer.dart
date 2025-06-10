/// 权限初始化管理器
///
/// 负责应用启动时的权限初始化，包括：
/// - 平台检测
/// - 权限配置加载
/// - 必要权限检查
/// - 权限策略执行
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'permission_service.dart';
import 'permission_config.dart';
import 'platform_detector.dart';
import 'permission_guide_page.dart';

/// 权限初始化结果
class PermissionInitResult {
  /// 是否初始化成功
  final bool success;

  /// 已授权的权限列表
  final List<AppPermission> grantedPermissions;

  /// 被拒绝的权限列表
  final List<AppPermission> deniedPermissions;

  /// 被永久拒绝的权限列表
  final List<AppPermission> permanentlyDeniedPermissions;

  /// 错误信息
  final String? errorMessage;

  /// 是否需要退出应用
  final bool shouldExitApp;

  const PermissionInitResult({
    required this.success,
    required this.grantedPermissions,
    required this.deniedPermissions,
    required this.permanentlyDeniedPermissions,
    this.errorMessage,
    this.shouldExitApp = false,
  });

  /// 创建成功结果
  factory PermissionInitResult.success({
    required List<AppPermission> grantedPermissions,
    List<AppPermission> deniedPermissions = const [],
    List<AppPermission> permanentlyDeniedPermissions = const [],
  }) {
    return PermissionInitResult(
      success: true,
      grantedPermissions: grantedPermissions,
      deniedPermissions: deniedPermissions,
      permanentlyDeniedPermissions: permanentlyDeniedPermissions,
    );
  }

  /// 创建失败结果
  factory PermissionInitResult.failure({
    required String errorMessage,
    bool shouldExitApp = false,
    List<AppPermission> grantedPermissions = const [],
    List<AppPermission> deniedPermissions = const [],
    List<AppPermission> permanentlyDeniedPermissions = const [],
  }) {
    return PermissionInitResult(
      success: false,
      grantedPermissions: grantedPermissions,
      deniedPermissions: deniedPermissions,
      permanentlyDeniedPermissions: permanentlyDeniedPermissions,
      errorMessage: errorMessage,
      shouldExitApp: shouldExitApp,
    );
  }

  /// 是否有权限被拒绝
  bool get hasRejectedPermissions =>
      deniedPermissions.isNotEmpty || permanentlyDeniedPermissions.isNotEmpty;

  /// 是否有必要权限被拒绝
  bool hasRejectedRequiredPermissions(List<PermissionConfig> configs) {
    final requiredPermissions =
        configs
            .where((config) => config.isRequired)
            .map((config) => config.permission)
            .toSet();

    final rejectedPermissions = {
      ...deniedPermissions,
      ...permanentlyDeniedPermissions,
    };

    return requiredPermissions.intersection(rejectedPermissions).isNotEmpty;
  }
}

/// 权限初始化管理器
class PermissionInitializer {
  static PermissionInitializer? _instance;

  PermissionInitializer._internal();

  /// 单例模式
  static PermissionInitializer get instance {
    _instance ??= PermissionInitializer._internal();
    return _instance!;
  }

  /// 是否已初始化
  bool _isInitialized = false;

  /// 获取初始化状态
  bool get isInitialized => _isInitialized;

  /// 初始化权限系统
  Future<PermissionInitResult> initialize({
    String? remoteConfigUrl,
    bool useCache = true,
    bool showGuideOnStartup = true,
  }) async {
    try {
      // 1. 初始化权限配置管理器
      await PermissionConfigManager.instance.initialize(
        remoteConfigUrl: remoteConfigUrl,
        useCache: useCache,
      );

      // 2. 检查应用启动时需要的权限
      final appLaunchConfigs =
          PermissionConfigManager.instance.getAppLaunchConfigs();

      if (appLaunchConfigs.isEmpty) {
        _isInitialized = true;
        return PermissionInitResult.success(grantedPermissions: []);
      }

      // 3. 分离必要权限和可选权限
      final requiredConfigs =
          appLaunchConfigs.where((config) => config.isRequired).toList();
      final optionalConfigs =
          appLaunchConfigs.where((config) => config.isOptional).toList();

      // 4. 处理必要权限
      final requiredResult = await _handleRequiredPermissions(
        requiredConfigs,
        showGuideOnStartup,
      );
      if (!requiredResult.success) {
        return requiredResult;
      }

      // 5. 处理可选权限
      final optionalResult = await _handleOptionalPermissions(
        optionalConfigs,
        showGuideOnStartup,
      );

      // 6. 合并结果
      final allGranted = [
        ...requiredResult.grantedPermissions,
        ...optionalResult.grantedPermissions,
      ];
      final allDenied = [
        ...requiredResult.deniedPermissions,
        ...optionalResult.deniedPermissions,
      ];
      final allPermanentlyDenied = [
        ...requiredResult.permanentlyDeniedPermissions,
        ...optionalResult.permanentlyDeniedPermissions,
      ];

      _isInitialized = true;

      return PermissionInitResult.success(
        grantedPermissions: allGranted,
        deniedPermissions: allDenied,
        permanentlyDeniedPermissions: allPermanentlyDenied,
      );
    } catch (e) {
      return PermissionInitResult.failure(errorMessage: '权限初始化失败: $e');
    }
  }

  /// 处理必要权限
  Future<PermissionInitResult> _handleRequiredPermissions(
    List<PermissionConfig> requiredConfigs,
    bool showGuide,
  ) async {
    if (requiredConfigs.isEmpty) {
      return PermissionInitResult.success(grantedPermissions: []);
    }

    final requiredPermissions =
        requiredConfigs.map((config) => config.permission).toList();

    // 检查当前权限状态
    final results = await PermissionService.instance.checkPermissions(
      requiredPermissions,
    );

    final grantedPermissions = <AppPermission>[];
    final deniedPermissions = <AppPermission>[];
    final permanentlyDeniedPermissions = <AppPermission>[];

    for (final entry in results.entries) {
      if (entry.value.isGranted) {
        grantedPermissions.add(entry.key);
      } else if (entry.value.isPermanentlyDenied) {
        permanentlyDeniedPermissions.add(entry.key);
      } else {
        deniedPermissions.add(entry.key);
      }
    }

    // 如果所有必要权限都已授权，直接返回成功
    if (deniedPermissions.isEmpty && permanentlyDeniedPermissions.isEmpty) {
      return PermissionInitResult.success(
        grantedPermissions: grantedPermissions,
      );
    }

    // 尝试请求未授权的权限
    final needRequestPermissions = [
      ...deniedPermissions,
      ...permanentlyDeniedPermissions,
    ];

    if (showGuide) {
      // 显示权限引导页面
      final granted = await PermissionGuideController.showPermissionGuide(
        permissions: needRequestPermissions,
        title: '必要权限授权',
        description: '以下权限是应用正常运行所必需的，请授权：',
        allowSkip: false,
      );

      if (!granted) {
        return PermissionInitResult.failure(
          errorMessage: '必要权限未授权，应用无法正常运行',
          shouldExitApp: true,
          grantedPermissions: grantedPermissions,
          deniedPermissions: deniedPermissions,
          permanentlyDeniedPermissions: permanentlyDeniedPermissions,
        );
      }
    } else {
      // 直接请求权限
      final requestResults = await PermissionService.instance
          .requestPermissions(needRequestPermissions);
      final stillDenied =
          requestResults.entries
              .where((entry) => !entry.value.isGranted)
              .map((entry) => entry.key)
              .toList();

      if (stillDenied.isNotEmpty) {
        return PermissionInitResult.failure(
          errorMessage: '必要权限未授权：${stillDenied.map((p) => p.name).join(', ')}',
          shouldExitApp: true,
          grantedPermissions: grantedPermissions,
          deniedPermissions: stillDenied,
        );
      }
    }

    // 重新检查权限状态
    final finalResults = await PermissionService.instance.checkPermissions(
      requiredPermissions,
    );
    final finalGranted =
        finalResults.entries
            .where((entry) => entry.value.isGranted)
            .map((entry) => entry.key)
            .toList();

    final finalDenied =
        finalResults.entries
            .where((entry) => !entry.value.isGranted)
            .map((entry) => entry.key)
            .toList();

    if (finalDenied.isNotEmpty) {
      return PermissionInitResult.failure(
        errorMessage: '必要权限仍未授权：${finalDenied.map((p) => p.name).join(', ')}',
        shouldExitApp: true,
        grantedPermissions: finalGranted,
        deniedPermissions: finalDenied,
      );
    }

    return PermissionInitResult.success(grantedPermissions: finalGranted);
  }

  /// 处理可选权限
  Future<PermissionInitResult> _handleOptionalPermissions(
    List<PermissionConfig> optionalConfigs,
    bool showGuide,
  ) async {
    if (optionalConfigs.isEmpty) {
      return PermissionInitResult.success(grantedPermissions: []);
    }

    final optionalPermissions =
        optionalConfigs.map((config) => config.permission).toList();

    // 检查当前权限状态
    final results = await PermissionService.instance.checkPermissions(
      optionalPermissions,
    );

    final grantedPermissions = <AppPermission>[];
    final deniedPermissions = <AppPermission>[];

    for (final entry in results.entries) {
      if (entry.value.isGranted) {
        grantedPermissions.add(entry.key);
      } else {
        deniedPermissions.add(entry.key);
      }
    }

    // 如果有未授权的可选权限，尝试请求
    if (deniedPermissions.isNotEmpty && showGuide) {
      final granted = await PermissionGuideController.showPermissionGuide(
        permissions: deniedPermissions,
        title: '可选权限授权',
        description: '以下权限可以提升您的使用体验：',
        allowSkip: true,
      );

      if (granted) {
        // 重新检查权限状态
        final finalResults = await PermissionService.instance.checkPermissions(
          deniedPermissions,
        );
        final newlyGranted =
            finalResults.entries
                .where((entry) => entry.value.isGranted)
                .map((entry) => entry.key)
                .toList();

        grantedPermissions.addAll(newlyGranted);
        deniedPermissions.removeWhere(
          (permission) => newlyGranted.contains(permission),
        );
      }
    }

    return PermissionInitResult.success(
      grantedPermissions: grantedPermissions,
      deniedPermissions: deniedPermissions,
    );
  }

  /// 检查页面权限
  Future<bool> checkPagePermissions(String route) async {
    final pageConfigs = PermissionConfigManager.instance.getConfigsByRoute(
      route,
    );

    if (pageConfigs.isEmpty) {
      return true;
    }

    final permissions = pageConfigs.map((config) => config.permission).toList();
    final results = await PermissionService.instance.checkPermissions(
      permissions,
    );

    // 检查必要权限
    final requiredConfigs =
        pageConfigs.where((config) => config.isRequired).toList();
    for (final config in requiredConfigs) {
      final result = results[config.permission];
      if (result == null || !result.isGranted) {
        // 必要权限未授权，尝试请求
        final granted = await _requestPermissionWithStrategy(config);
        if (!granted) {
          return false;
        }
      }
    }

    // 检查可选权限（静默处理）
    final optionalConfigs =
        pageConfigs.where((config) => config.isOptional).toList();
    for (final config in optionalConfigs) {
      final result = results[config.permission];
      if (result == null || !result.isGranted) {
        // 可选权限未授权，根据策略处理
        await _handleOptionalPermissionDenied(config);
      }
    }

    return true;
  }

  /// 检查操作权限
  Future<bool> checkActionPermissions(List<AppPermission> permissions) async {
    final results = await PermissionService.instance.checkPermissions(
      permissions,
    );

    for (final permission in permissions) {
      final result = results[permission];
      if (result == null || !result.isGranted) {
        final config = PermissionConfigManager.instance.getConfigByPermission(
          permission,
        );
        if (config != null) {
          final granted = await _requestPermissionWithStrategy(config);
          if (!granted && config.isRequired) {
            return false;
          }
        } else {
          // 没有配置的权限，直接请求
          final requestResult = await PermissionService.instance
              .requestPermission(permission);
          if (!requestResult.isGranted) {
            return false;
          }
        }
      }
    }

    return true;
  }

  /// 根据策略请求权限
  Future<bool> _requestPermissionWithStrategy(PermissionConfig config) async {
    final result = await PermissionService.instance.requestPermission(
      config.permission,
      showRationale: true,
    );

    if (!result.isGranted) {
      await _handlePermissionDenied(config, result);
      return false;
    }

    return true;
  }

  /// 处理权限被拒绝
  Future<void> _handlePermissionDenied(
    PermissionConfig config,
    PermissionResult result,
  ) async {
    switch (config.deniedStrategy) {
      case PermissionDeniedStrategy.showDialog:
        await _showPermissionDeniedDialog(config, result);
        break;
      case PermissionDeniedStrategy.showSnackbar:
        _showPermissionDeniedSnackbar(config);
        break;
      case PermissionDeniedStrategy.exitApp:
        if (config.isRequired) {
          await _exitApp('必要权限 ${config.title} 未授权');
        }
        break;
      case PermissionDeniedStrategy.disableFeature:
        // 功能降级处理，由具体业务实现
        break;
      case PermissionDeniedStrategy.silent:
        // 静默处理，不做任何操作
        break;
    }
  }

  /// 处理可选权限被拒绝
  Future<void> _handleOptionalPermissionDenied(PermissionConfig config) async {
    switch (config.deniedStrategy) {
      case PermissionDeniedStrategy.showSnackbar:
        _showPermissionDeniedSnackbar(config);
        break;
      case PermissionDeniedStrategy.disableFeature:
        // 功能降级处理
        break;
      default:
        // 其他策略对可选权限不适用
        break;
    }
  }

  /// 显示权限被拒绝对话框
  Future<void> _showPermissionDeniedDialog(
    PermissionConfig config,
    PermissionResult result,
  ) async {
    await Get.dialog(
      AlertDialog(
        title: Text('${config.title}权限被拒绝'),
        content: Text(
          '${config.description}\n\n${result.isPermanentlyDenied ? '请在设置中手动开启权限。' : '请授权以正常使用功能。'}',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
          if (result.isPermanentlyDenied)
            TextButton(
              onPressed: () {
                Get.back();
                PermissionService.instance.openAppSettings();
              },
              child: const Text('去设置'),
            )
          else
            TextButton(
              onPressed: () async {
                Get.back();
                await PermissionService.instance.requestPermission(
                  config.permission,
                );
              },
              child: const Text('重新授权'),
            ),
        ],
      ),
    );
  }

  /// 显示权限被拒绝提示条
  void _showPermissionDeniedSnackbar(PermissionConfig config) {
    Get.snackbar(
      '权限提示',
      '${config.title}权限被拒绝，部分功能可能无法正常使用',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  /// 退出应用
  Future<void> _exitApp(String reason) async {
    await Get.dialog(
      AlertDialog(
        title: const Text('应用无法继续运行'),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
            },
            child: const Text('退出'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// 重置初始化状态
  void reset() {
    _isInitialized = false;
  }
}
