/// 权限检查功能
/// 
/// 实现页面权限检查的功能组件
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../base_page.dart';
import '../../permissions/permission_service.dart';
import '../../permissions/permission_initializer.dart';
import '../../permissions/permission_config.dart';

/// 权限检查功能配置
class PermissionFeatureConfig {
  /// 必需的权限列表
  final List<AppPermission> requiredPermissions;
  
  /// 可选的权限列表
  final List<AppPermission> optionalPermissions;
  
  /// 是否显示权限引导
  final bool showGuide;
  
  /// 是否允许跳过可选权限
  final bool allowSkipOptional;
  
  /// 权限被拒绝时的自定义处理
  final Future<bool> Function(List<AppPermission> deniedPermissions)? onPermissionDenied;
  
  /// 权限授权成功时的回调
  final void Function(List<AppPermission> grantedPermissions)? onPermissionGranted;
  
  /// 自定义权限引导页面
  final Widget Function(BuildContext context, List<AppPermission> permissions)? customGuideBuilder;

  const PermissionFeatureConfig({
    this.requiredPermissions = const [],
    this.optionalPermissions = const [],
    this.showGuide = true,
    this.allowSkipOptional = true,
    this.onPermissionDenied,
    this.onPermissionGranted,
    this.customGuideBuilder,
  });

  /// 获取所有权限
  List<AppPermission> get allPermissions => [...requiredPermissions, ...optionalPermissions];

  /// 是否有权限需要检查
  bool get hasPermissions => allPermissions.isNotEmpty;
}

/// 权限检查功能实现
class PermissionFeature implements IPageFeature {
  final PermissionFeatureConfig config;

  const PermissionFeature(this.config);

  @override
  String get featureName => 'PermissionFeature';

  @override
  Future<bool> onPageEnter(BuildContext context, String route) async {
    if (!config.hasPermissions) {
      return true;
    }

    try {
      // 检查必需权限
      if (config.requiredPermissions.isNotEmpty) {
        final requiredResult = await _checkRequiredPermissions(context, route);
        if (!requiredResult) {
          return false;
        }
      }

      // 检查可选权限
      if (config.optionalPermissions.isNotEmpty) {
        await _checkOptionalPermissions(context, route);
      }

      return true;
    } catch (e) {
      debugPrint('权限检查失败: $e');
      return false;
    }
  }

  @override
  Widget onPageBuild(BuildContext context, Widget child) {
    // 权限功能不修改页面构建
    return child;
  }

  @override
  Future<bool> onPageExit(BuildContext context, String route) async {
    // 页面退出时不需要权限检查
    return true;
  }

  @override
  void onPageDispose() {
    // 权限功能不需要特殊的销毁处理
  }

  /// 检查必需权限
  Future<bool> _checkRequiredPermissions(BuildContext context, String route) async {
    final results = await PermissionService.instance.checkPermissions(config.requiredPermissions);
    
    final deniedPermissions = results.entries
        .where((entry) => !entry.value.isGranted)
        .map((entry) => entry.key)
        .toList();

    if (deniedPermissions.isEmpty) {
      // 所有必需权限都已授权
      config.onPermissionGranted?.call(config.requiredPermissions);
      return true;
    }

    // 有必需权限被拒绝，尝试请求
    final granted = await _requestPermissions(context, deniedPermissions, isRequired: true);
    
    if (!granted) {
      // 权限被拒绝，执行自定义处理
      if (config.onPermissionDenied != null) {
        return await config.onPermissionDenied!(deniedPermissions);
      }
      return false;
    }

    config.onPermissionGranted?.call(config.requiredPermissions);
    return true;
  }

  /// 检查可选权限
  Future<void> _checkOptionalPermissions(BuildContext context, String route) async {
    final results = await PermissionService.instance.checkPermissions(config.optionalPermissions);
    
    final deniedPermissions = results.entries
        .where((entry) => !entry.value.isGranted)
        .map((entry) => entry.key)
        .toList();

    final grantedPermissions = results.entries
        .where((entry) => entry.value.isGranted)
        .map((entry) => entry.key)
        .toList();

    if (deniedPermissions.isNotEmpty) {
      // 尝试请求可选权限
      await _requestPermissions(context, deniedPermissions, isRequired: false);
    }

    if (grantedPermissions.isNotEmpty) {
      config.onPermissionGranted?.call(grantedPermissions);
    }
  }

  /// 请求权限
  Future<bool> _requestPermissions(
    BuildContext context, 
    List<AppPermission> permissions, {
    required bool isRequired,
  }) async {
    if (config.showGuide) {
      // 显示权限引导
      if (config.customGuideBuilder != null) {
        // 使用自定义引导页面
        final result = await Get.dialog<bool>(
          config.customGuideBuilder!(context, permissions),
        );
        return result ?? false;
      } else {
        // 使用默认引导页面
        return await _showDefaultPermissionGuide(permissions, isRequired);
      }
    } else {
      // 直接请求权限
      final results = await PermissionService.instance.requestPermissions(permissions);
      return results.values.every((result) => result.isGranted);
    }
  }

  /// 显示默认权限引导
  Future<bool> _showDefaultPermissionGuide(List<AppPermission> permissions, bool isRequired) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text(isRequired ? '必需权限' : '可选权限'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isRequired 
                ? '以下权限是页面正常运行所必需的：' 
                : '以下权限可以提升您的使用体验：'),
            const SizedBox(height: 16),
            ...permissions.map((permission) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(_getPermissionIcon(permission), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(permission.name, style: Get.textTheme.titleSmall),
                        Text(permission.description, style: Get.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
        actions: [
          if (!isRequired && config.allowSkipOptional)
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('跳过'),
            ),
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final results = await PermissionService.instance.requestPermissions(permissions);
              final allGranted = results.values.every((result) => result.isGranted);
              Get.back(result: allGranted);
            },
            child: const Text('授权'),
          ),
        ],
      ),
      barrierDismissible: !isRequired,
    ) ?? false;
  }

  /// 获取权限图标
  IconData _getPermissionIcon(AppPermission permission) {
    switch (permission) {
      case AppPermission.camera:
      case AppPermission.webCamera:
        return Icons.camera_alt;
      case AppPermission.microphone:
      case AppPermission.webMicrophone:
        return Icons.mic;
      case AppPermission.photos:
        return Icons.photo_library;
      case AppPermission.location:
      case AppPermission.locationAlways:
      case AppPermission.locationWhenInUse:
      case AppPermission.webLocation:
        return Icons.location_on;
      case AppPermission.storage:
        return Icons.storage;
      case AppPermission.contacts:
        return Icons.contacts;
      case AppPermission.phone:
        return Icons.phone;
      case AppPermission.sms:
        return Icons.sms;
      case AppPermission.notification:
      case AppPermission.webNotification:
        return Icons.notifications;
      case AppPermission.bluetooth:
      case AppPermission.bluetoothScan:
      case AppPermission.bluetoothAdvertise:
      case AppPermission.bluetoothConnect:
        return Icons.bluetooth;
      case AppPermission.desktopFileSystem:
        return Icons.folder;
      case AppPermission.desktopSystemTray:
        return Icons.apps;
      case AppPermission.desktopAutoStart:
        return Icons.power_settings_new;
    }
  }
}

/// 权限功能构建器
class PermissionFeatureBuilder {
  /// 创建基础权限功能
  static PermissionFeature basic({
    List<AppPermission> requiredPermissions = const [],
    List<AppPermission> optionalPermissions = const [],
  }) {
    return PermissionFeature(PermissionFeatureConfig(
      requiredPermissions: requiredPermissions,
      optionalPermissions: optionalPermissions,
    ));
  }

  /// 创建相机权限功能
  static PermissionFeature camera({bool required = false}) {
    return PermissionFeature(PermissionFeatureConfig(
      requiredPermissions: required ? [AppPermission.camera] : [],
      optionalPermissions: required ? [] : [AppPermission.camera],
    ));
  }

  /// 创建位置权限功能
  static PermissionFeature location({bool required = false}) {
    return PermissionFeature(PermissionFeatureConfig(
      requiredPermissions: required ? [AppPermission.location] : [],
      optionalPermissions: required ? [] : [AppPermission.location],
    ));
  }

  /// 创建存储权限功能
  static PermissionFeature storage({bool required = true}) {
    return PermissionFeature(PermissionFeatureConfig(
      requiredPermissions: required ? [AppPermission.storage] : [],
      optionalPermissions: required ? [] : [AppPermission.storage],
    ));
  }

  /// 创建多媒体权限功能（相机+麦克风+存储）
  static PermissionFeature multimedia({bool required = false}) {
    final permissions = [
      AppPermission.camera,
      AppPermission.microphone,
      AppPermission.storage,
    ];
    
    return PermissionFeature(PermissionFeatureConfig(
      requiredPermissions: required ? permissions : [],
      optionalPermissions: required ? [] : permissions,
    ));
  }

  /// 创建自定义权限功能
  static PermissionFeature custom(PermissionFeatureConfig config) {
    return PermissionFeature(config);
  }
}
