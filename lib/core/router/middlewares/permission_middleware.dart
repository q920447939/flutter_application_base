/// 权限中间件
///
/// 在路由层处理权限检查，实现权限与业务逻辑的完全分离
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'base_middleware.dart';
import '../../permissions/permission_service.dart';

/// 权限中间件配置
class PermissionMiddlewareConfig {
  /// 必需的权限列表
  final List<AppPermission> requiredPermissions;

  /// 可选的权限列表
  final List<AppPermission> optionalPermissions;

  /// 是否显示权限引导
  final bool showGuide;

  /// 是否允许跳过可选权限
  final bool allowSkipOptional;

  /// 权限被拒绝时的重定向路由
  final String? deniedRedirectRoute;

  /// 权限检查失败时的自定义处理
  final Future<bool> Function(List<AppPermission> deniedPermissions)?
  onPermissionDenied;

  /// 权限授权成功时的回调
  final void Function(List<AppPermission> grantedPermissions)?
  onPermissionGranted;

  const PermissionMiddlewareConfig({
    this.requiredPermissions = const [],
    this.optionalPermissions = const [],
    this.showGuide = true,
    this.allowSkipOptional = true,
    this.deniedRedirectRoute,
    this.onPermissionDenied,
    this.onPermissionGranted,
  });

  /// 获取所有权限
  List<AppPermission> get allPermissions => [
    ...requiredPermissions,
    ...optionalPermissions,
  ];

  /// 是否有权限需要检查
  bool get hasPermissions => allPermissions.isNotEmpty;

  /// 复制并修改配置
  PermissionMiddlewareConfig copyWith({
    List<AppPermission>? requiredPermissions,
    List<AppPermission>? optionalPermissions,
    bool? showGuide,
    bool? allowSkipOptional,
    String? deniedRedirectRoute,
    Future<bool> Function(List<AppPermission>)? onPermissionDenied,
    void Function(List<AppPermission>)? onPermissionGranted,
  }) {
    return PermissionMiddlewareConfig(
      requiredPermissions: requiredPermissions ?? this.requiredPermissions,
      optionalPermissions: optionalPermissions ?? this.optionalPermissions,
      showGuide: showGuide ?? this.showGuide,
      allowSkipOptional: allowSkipOptional ?? this.allowSkipOptional,
      deniedRedirectRoute: deniedRedirectRoute ?? this.deniedRedirectRoute,
      onPermissionDenied: onPermissionDenied ?? this.onPermissionDenied,
      onPermissionGranted: onPermissionGranted ?? this.onPermissionGranted,
    );
  }
}

/// 权限中间件实现
class PermissionMiddleware extends BaseRouteMiddleware {
  final PermissionMiddlewareConfig config;

  PermissionMiddleware(this.config);

  @override
  String get middlewareName => 'PermissionMiddleware';

  @override
  String get description => '权限检查中间件，在路由跳转前验证所需权限';

  @override
  int? get priority => 10; // 权限检查优先级较高

  @override
  Map<String, dynamic> get configuration => {
    'required_permissions':
        config.requiredPermissions.map((p) => p.name).toList(),
    'optional_permissions':
        config.optionalPermissions.map((p) => p.name).toList(),
    'show_guide': config.showGuide,
    'allow_skip_optional': config.allowSkipOptional,
    'denied_redirect_route': config.deniedRedirectRoute,
  };

  @override
  Future<MiddlewareResult> preCheck(
    String? route,
    Map<String, String>? parameters,
  ) async {
    if (!config.hasPermissions) {
      logInfo('无需权限检查，允许访问路由: $route');
      return MiddlewareResult.proceed();
    }

    try {
      logInfo('开始权限检查，路由: $route');

      // 检查必需权限
      if (config.requiredPermissions.isNotEmpty) {
        final requiredResult = await _checkRequiredPermissions(route);
        if (!requiredResult.canProceed) {
          return requiredResult;
        }
      }

      // 检查可选权限
      if (config.optionalPermissions.isNotEmpty) {
        await _checkOptionalPermissions(route);
      }

      logInfo('权限检查通过，允许访问路由: $route');
      return MiddlewareResult.proceed();
    } catch (e) {
      logError('权限检查异常', e);
      return MiddlewareResult.redirect(
        config.deniedRedirectRoute ?? '/error',
        errorMessage: '权限检查失败: $e',
      );
    }
  }

  /// 检查必需权限
  Future<MiddlewareResult> _checkRequiredPermissions(String? route) async {
    final results = await PermissionService.instance.checkPermissions(
      config.requiredPermissions,
    );

    final deniedPermissions =
        results.entries
            .where((entry) => !entry.value.isGranted)
            .map((entry) => entry.key)
            .toList();

    if (deniedPermissions.isEmpty) {
      // 所有必需权限都已授权
      final grantedPermissions = config.requiredPermissions;
      config.onPermissionGranted?.call(grantedPermissions);
      logInfo('必需权限检查通过: ${grantedPermissions.map((p) => p.name).join(', ')}');
      return MiddlewareResult.proceed();
    }

    logWarning('必需权限被拒绝: ${deniedPermissions.map((p) => p.name).join(', ')}');

    // 尝试请求权限
    final granted = await _requestPermissions(
      deniedPermissions,
      isRequired: true,
    );

    if (!granted) {
      // 权限被拒绝，执行自定义处理或重定向
      if (config.onPermissionDenied != null) {
        final customResult = await config.onPermissionDenied!(
          deniedPermissions,
        );
        if (customResult) {
          return MiddlewareResult.proceed();
        }
      }

      return MiddlewareResult.redirect(
        config.deniedRedirectRoute ?? '/permission_denied',
        errorMessage:
            '必需权限被拒绝: ${deniedPermissions.map((p) => p.name).join(', ')}',
      );
    }

    config.onPermissionGranted?.call(config.requiredPermissions);
    return MiddlewareResult.proceed();
  }

  /// 检查可选权限
  Future<void> _checkOptionalPermissions(String? route) async {
    final results = await PermissionService.instance.checkPermissions(
      config.optionalPermissions,
    );

    final deniedPermissions =
        results.entries
            .where((entry) => !entry.value.isGranted)
            .map((entry) => entry.key)
            .toList();

    final grantedPermissions =
        results.entries
            .where((entry) => entry.value.isGranted)
            .map((entry) => entry.key)
            .toList();

    if (deniedPermissions.isNotEmpty) {
      logInfo('可选权限被拒绝: ${deniedPermissions.map((p) => p.name).join(', ')}');

      // 尝试请求可选权限
      await _requestPermissions(deniedPermissions, isRequired: false);
    }

    if (grantedPermissions.isNotEmpty) {
      config.onPermissionGranted?.call(grantedPermissions);
      logInfo('可选权限已授权: ${grantedPermissions.map((p) => p.name).join(', ')}');
    }
  }

  /// 请求权限
  Future<bool> _requestPermissions(
    List<AppPermission> permissions, {
    required bool isRequired,
  }) async {
    if (config.showGuide) {
      // 显示权限引导
      return await _showPermissionGuide(permissions, isRequired);
    } else {
      // 直接请求权限
      final results = await PermissionService.instance.requestPermissions(
        permissions,
      );
      final allGranted = results.values.every((result) => result.isGranted);

      if (allGranted) {
        logInfo('权限请求成功: ${permissions.map((p) => p.name).join(', ')}');
      } else {
        logWarning('权限请求失败: ${permissions.map((p) => p.name).join(', ')}');
      }

      return allGranted;
    }
  }

  /// 显示权限引导
  Future<bool> _showPermissionGuide(
    List<AppPermission> permissions,
    bool isRequired,
  ) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text(isRequired ? '必需权限' : '可选权限'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isRequired ? '以下权限是页面正常运行所必需的：' : '以下权限可以提升您的使用体验：'),
              const SizedBox(height: 16),
              ...permissions.map(
                (permission) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(_getPermissionIcon(permission), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              permission.name,
                              style: Get.textTheme.titleSmall,
                            ),
                            Text(
                              permission.description,
                              style: Get.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                final results = await PermissionService.instance
                    .requestPermissions(permissions);
                final allGranted = results.values.every(
                  (result) => result.isGranted,
                );
                Get.back(result: allGranted);
              },
              child: const Text('授权'),
            ),
          ],
        ),
        barrierDismissible: !isRequired,
      );

      return result ?? false;
    } catch (e) {
      logError('显示权限引导失败', e);
      return false;
    }
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

/// 权限中间件构建器
class PermissionMiddlewareBuilder {
  PermissionMiddlewareConfig _config = const PermissionMiddlewareConfig();

  /// 设置必需权限
  PermissionMiddlewareBuilder requiredPermissions(
    List<AppPermission> permissions,
  ) {
    _config = _config.copyWith(requiredPermissions: permissions);
    return this;
  }

  /// 设置可选权限
  PermissionMiddlewareBuilder optionalPermissions(
    List<AppPermission> permissions,
  ) {
    _config = _config.copyWith(optionalPermissions: permissions);
    return this;
  }

  /// 设置是否显示引导
  PermissionMiddlewareBuilder showGuide(bool show) {
    _config = _config.copyWith(showGuide: show);
    return this;
  }

  /// 设置是否允许跳过可选权限
  PermissionMiddlewareBuilder allowSkipOptional(bool allow) {
    _config = _config.copyWith(allowSkipOptional: allow);
    return this;
  }

  /// 设置权限被拒绝时的重定向路由
  PermissionMiddlewareBuilder deniedRedirectRoute(String route) {
    _config = _config.copyWith(deniedRedirectRoute: route);
    return this;
  }

  /// 设置权限被拒绝时的自定义处理
  PermissionMiddlewareBuilder onPermissionDenied(
    Future<bool> Function(List<AppPermission>) callback,
  ) {
    _config = _config.copyWith(onPermissionDenied: callback);
    return this;
  }

  /// 设置权限授权成功时的回调
  PermissionMiddlewareBuilder onPermissionGranted(
    void Function(List<AppPermission>) callback,
  ) {
    _config = _config.copyWith(onPermissionGranted: callback);
    return this;
  }

  /// 构建权限中间件
  PermissionMiddleware build() {
    return PermissionMiddleware(_config);
  }
}
