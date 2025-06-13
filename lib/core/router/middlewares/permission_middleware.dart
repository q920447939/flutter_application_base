/// 权限中间件
///
/// 在路由层处理权限检查，实现权限与业务逻辑的完全分离
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../permissions/permission_service.dart';
import 'base_middleware.dart';

/// 权限拒绝处理策略枚举
enum PermissionDeniedStrategy {
  /// 返回上一页面
  goBack,

  /// 跳转到主页
  goHome,

  /// 退出应用
  exitApp,

  /// 跳转到指定路由
  redirectTo,

  /// 自定义处理
  custom,
}

/// 权限检查状态
enum PermissionCheckState {
  /// 初始状态
  initial,

  /// 检查中
  checking,

  /// 请求权限中
  requesting,

  /// 权限被拒绝
  denied,

  /// 权限已授权
  granted,

  /// 达到最大尝试次数
  maxAttemptsReached,
}

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

  /// 最大权限请求尝试次数（防止无限循环）
  final int maxAttempts;

  /// 权限拒绝处理策略
  final PermissionDeniedStrategy deniedStrategy;

  /// 自定义重定向路由（当策略为redirectTo时使用）
  final String? customRedirectRoute;

  /// 权限检查失败时的自定义处理
  final Future<bool> Function(List<AppPermission> deniedPermissions)?
  onPermissionDenied;

  /// 权限授权成功时的回调
  final void Function(List<AppPermission> grantedPermissions)?
  onPermissionGranted;

  /// 达到最大尝试次数时的回调
  final Future<void> Function(String route, int attempts)? onMaxAttemptsReached;

  const PermissionMiddlewareConfig({
    this.requiredPermissions = const [],
    this.optionalPermissions = const [],
    this.showGuide = true,
    this.allowSkipOptional = true,
    this.deniedRedirectRoute,
    this.maxAttempts = 3,
    this.deniedStrategy = PermissionDeniedStrategy.goBack,
    this.customRedirectRoute,
    this.onPermissionDenied,
    this.onPermissionGranted,
    this.onMaxAttemptsReached,
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
    int? maxAttempts,
    PermissionDeniedStrategy? deniedStrategy,
    String? customRedirectRoute,
    Future<bool> Function(List<AppPermission>)? onPermissionDenied,
    void Function(List<AppPermission>)? onPermissionGranted,
    Future<void> Function(String, int)? onMaxAttemptsReached,
  }) {
    return PermissionMiddlewareConfig(
      requiredPermissions: requiredPermissions ?? this.requiredPermissions,
      optionalPermissions: optionalPermissions ?? this.optionalPermissions,
      showGuide: showGuide ?? this.showGuide,
      allowSkipOptional: allowSkipOptional ?? this.allowSkipOptional,
      deniedRedirectRoute: deniedRedirectRoute ?? this.deniedRedirectRoute,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      deniedStrategy: deniedStrategy ?? this.deniedStrategy,
      customRedirectRoute: customRedirectRoute ?? this.customRedirectRoute,
      onPermissionDenied: onPermissionDenied ?? this.onPermissionDenied,
      onPermissionGranted: onPermissionGranted ?? this.onPermissionGranted,
      onMaxAttemptsReached: onMaxAttemptsReached ?? this.onMaxAttemptsReached,
    );
  }
}

/// 权限检查状态管理器
class PermissionCheckStateManager {
  static final PermissionCheckStateManager _instance =
      PermissionCheckStateManager._internal();
  factory PermissionCheckStateManager() => _instance;
  PermissionCheckStateManager._internal();

  /// 路由权限检查状态缓存 <路由路径, <权限检查状态, 尝试次数>>
  final Map<String, Map<String, dynamic>> _routePermissionStates = {};

  /// 获取路由的权限检查状态
  PermissionCheckState getRoutePermissionState(String route) {
    final stateData = _routePermissionStates[route];
    if (stateData == null) return PermissionCheckState.initial;
    return stateData['state'] ?? PermissionCheckState.initial;
  }

  /// 获取路由的权限检查尝试次数
  int getRouteAttemptCount(String route) {
    final stateData = _routePermissionStates[route];
    if (stateData == null) return 0;
    return stateData['attempts'] ?? 0;
  }

  /// 设置路由的权限检查状态
  void setRoutePermissionState(String route, PermissionCheckState state) {
    _routePermissionStates[route] ??= {};
    _routePermissionStates[route]!['state'] = state;
  }

  /// 增加路由的权限检查尝试次数
  void incrementRouteAttemptCount(String route) {
    _routePermissionStates[route] ??= {};
    final currentAttempts = _routePermissionStates[route]!['attempts'] ?? 0;
    _routePermissionStates[route]!['attempts'] = currentAttempts + 1;
  }

  /// 重置路由的权限检查状态
  void resetRoutePermissionState(String route) {
    _routePermissionStates.remove(route);
  }

  /// 清理所有状态
  void clearAllStates() {
    _routePermissionStates.clear();
  }

  /// 检查是否达到最大尝试次数
  bool hasReachedMaxAttempts(String route, int maxAttempts) {
    return getRouteAttemptCount(route) >= maxAttempts;
  }
}

/// 权限中间件实现
class PermissionMiddleware extends BaseRouteMiddleware {
  final PermissionMiddlewareConfig config;
  final PermissionCheckStateManager _stateManager =
      PermissionCheckStateManager();

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
  GetPage? onPageCalled(GetPage? page) {
    if (!isEnabled || page == null) {
      return page;
    }

    try {
      // 修改页面构建器，加入异步权限检查
      final originalBuilder = page.page;

      // 创建新的GetPage实例，而不是使用copyWith
      return GetPage(
        name: page.name,
        page: () {
          return FutureBuilder<bool>(
            future: preCheck(page.name, {}),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                bool isGrand = snapshot.data!;
                // 处理权限检查失败
                if (isGrand) {
                  // 权限检查通过，构建原始页面
                  return originalBuilder();
                } else {
                  // Show snackbar after the frame is built
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Get.snackbar('提示', '权限被拒绝,暂时无法使用该功能');
                    Get.offAllNamed("/");
                  });
                  return const SizedBox();
                }
              }
              // 权限检查通过，构建原始页面
              return originalBuilder();
            },
          );
        },
        title: page.title,
        transition: page.transition,
        binding: page.binding,
        bindings: page.bindings,
        children: page.children,
        middlewares: page.middlewares,
        fullscreenDialog: page.fullscreenDialog,
        opaque: page.opaque,
        preventDuplicates: page.preventDuplicates,
        popGesture: page.popGesture,
        transitionDuration: page.transitionDuration,
        curve: page.curve,
        participatesInRootNavigator: page.participatesInRootNavigator,
        gestureWidth: page.gestureWidth,
      );
    } catch (e) {
      debugPrint('[$middlewareName] 页面调用处理异常: $e');
      return page;
    }
  }

  Future<bool> preCheck(String? route, Map<String, String>? parameters) async {
    if (!config.hasPermissions) {
      logInfo('无需权限检查，允许访问路由: $route');
      return true;
    }
    try {
      logInfo('开始异步权限检查，路由: $route');

      // 检查必需权限
      if (config.requiredPermissions.isNotEmpty) {
        var anyIsNotGranted = await _checkRequiredPermissions(route);
        anyIsNotGranted = true;
        if (anyIsNotGranted) {
          var result = await _showPermissionGuide(
            config.requiredPermissions,
            true,
          );
          return result;
        }
      }

      logInfo('异步权限检查通过，允许访问路由: $route');
      return true;
    } catch (e) {
      logError('异步权限检查异常', e);
      return false;
    }
  }

  Future<bool> _checkRequiredPermissions(String? route) async {
    final results = await PermissionService.instance.checkPermissions(
      config.requiredPermissions,
    );

    return results.entries.any((entry) => !entry.value.isGranted);
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
                onPressed: () {
                  Get.back(result: false);
                },
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

  /// 设置最大尝试次数
  PermissionMiddlewareBuilder maxAttempts(int attempts) {
    _config = _config.copyWith(maxAttempts: attempts);
    return this;
  }

  /// 设置权限拒绝处理策略
  PermissionMiddlewareBuilder deniedStrategy(
    PermissionDeniedStrategy strategy,
  ) {
    _config = _config.copyWith(deniedStrategy: strategy);
    return this;
  }

  /// 设置自定义重定向路由
  PermissionMiddlewareBuilder customRedirectRoute(String route) {
    _config = _config.copyWith(customRedirectRoute: route);
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

  /// 设置达到最大尝试次数时的回调
  PermissionMiddlewareBuilder onMaxAttemptsReached(
    Future<void> Function(String route, int attempts) callback,
  ) {
    _config = _config.copyWith(onMaxAttemptsReached: callback);
    return this;
  }

  /// 构建权限中间件
  PermissionMiddleware build() {
    return PermissionMiddleware(_config);
  }
}
