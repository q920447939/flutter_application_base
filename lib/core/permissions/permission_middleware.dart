/// 权限中间件
///
/// 用于路由守卫，在页面跳转时检查权限
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_base/core/permissions/permission_service.dart';
import 'package:get/get.dart';
import 'permission_initializer.dart';
import 'permission_config.dart';

/// 权限中间件
class PermissionMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (route == null) return null;

    // 检查权限初始化状态
    if (!PermissionInitializer.instance.isInitialized) {
      // 如果权限系统未初始化，跳转到初始化页面
      return const RouteSettings(name: '/permission_init');
    }

    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    return page;
  }

  @override
  List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
    return bindings;
  }

  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    return page;
  }

  @override
  Widget onPageBuilt(Widget page) {
    return page;
  }

  @override
  void onPageDispose() {
    // 页面销毁时的清理工作
  }
}

/// 权限检查装饰器
class PermissionChecker {
  /// 检查页面权限的装饰器
  static Widget withPagePermissions({
    required Widget child,
    required String route,
    Widget? loadingWidget,
    Widget? deniedWidget,
  }) {
    return FutureBuilder<bool>(
      future: PermissionInitializer.instance.checkPagePermissions(route),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data != true) {
          return deniedWidget ?? _buildDefaultDeniedWidget(route);
        }

        return child;
      },
    );
  }

  /// 检查操作权限的装饰器
  static Widget withActionPermissions({
    required Widget child,
    required List<AppPermission> permissions,
    VoidCallback? onPermissionDenied,
    bool checkOnTap = true,
  }) {
    if (!checkOnTap) {
      return FutureBuilder<bool>(
        future: PermissionInitializer.instance.checkActionPermissions(
          permissions,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }

          if (snapshot.hasError || snapshot.data != true) {
            onPermissionDenied?.call();
            return const SizedBox.shrink();
          }

          return child;
        },
      );
    }

    // 在点击时检查权限
    return GestureDetector(
      onTap: () async {
        final hasPermission = await PermissionInitializer.instance
            .checkActionPermissions(permissions);
        if (hasPermission) {
          // 如果原组件有onTap，执行它
          if (child is GestureDetector && child.onTap != null) {
            child.onTap!();
          } else if (child is InkWell && child.onTap != null) {
            child.onTap!();
          } else if (child is ElevatedButton && child.onPressed != null) {
            child.onPressed!();
          }
        } else {
          onPermissionDenied?.call();
        }
      },
      child: child,
    );
  }

  /// 构建默认的权限被拒绝页面
  static Widget _buildDefaultDeniedWidget(String route) {
    return Scaffold(
      appBar: AppBar(title: const Text('权限不足')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('访问此页面需要相应权限', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('请授权后重试', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

/// 权限注解
class RequiresPermission {
  final List<AppPermission> permissions;
  final bool required;

  const RequiresPermission(this.permissions, {this.required = true});
}

/// 权限混入
mixin PermissionMixin {
  /// 检查权限
  Future<bool> checkPermissions(List<AppPermission> permissions) async {
    return await PermissionInitializer.instance.checkActionPermissions(
      permissions,
    );
  }

  /// 请求权限
  Future<bool> requestPermissions(List<AppPermission> permissions) async {
    return await PermissionInitializer.instance.checkActionPermissions(
      permissions,
    );
  }

  /// 检查单个权限
  Future<bool> checkPermission(AppPermission permission) async {
    return await checkPermissions([permission]);
  }

  /// 请求单个权限
  Future<bool> requestPermission(AppPermission permission) async {
    return await requestPermissions([permission]);
  }

  /// 权限装饰器方法
  Future<T?> withPermission<T>(
    List<AppPermission> permissions,
    Future<T> Function() action,
  ) async {
    final hasPermission = await checkPermissions(permissions);
    if (hasPermission) {
      return await action();
    }
    return null;
  }
}

/// 权限控制器基类
abstract class PermissionController extends GetxController
    with PermissionMixin {
  /// 页面权限列表
  List<AppPermission> get requiredPermissions => [];

  /// 可选权限列表
  List<AppPermission> get optionalPermissions => [];

  @override
  void onInit() {
    super.onInit();
    _checkPagePermissions();
  }

  /// 检查页面权限
  Future<void> _checkPagePermissions() async {
    final allPermissions = [...requiredPermissions, ...optionalPermissions];
    if (allPermissions.isNotEmpty) {
      await checkPermissions(allPermissions);
    }
  }

  /// 权限检查失败时的处理
  void onPermissionDenied(List<AppPermission> deniedPermissions) {
    // 子类可以重写此方法来处理权限被拒绝的情况
  }

  /// 权限检查成功时的处理
  void onPermissionGranted(List<AppPermission> grantedPermissions) {
    // 子类可以重写此方法来处理权限授权成功的情况
  }
}

/// 权限工具类
class PermissionUtils {
  /// 批量检查权限
  static Future<Map<AppPermission, bool>> batchCheckPermissions(
    List<AppPermission> permissions,
  ) async {
    final results = <AppPermission, bool>{};
    for (final permission in permissions) {
      final hasPermission = await PermissionInitializer.instance
          .checkActionPermissions([permission]);
      results[permission] = hasPermission;
    }
    return results;
  }

  /// 获取权限状态摘要
  static Future<String> getPermissionSummary(
    List<AppPermission> permissions,
  ) async {
    final results = await batchCheckPermissions(permissions);
    final granted =
        results.entries.where((e) => e.value).map((e) => e.key.name).toList();
    final denied =
        results.entries.where((e) => !e.value).map((e) => e.key.name).toList();

    final summary = StringBuffer();
    if (granted.isNotEmpty) {
      summary.writeln('已授权权限: ${granted.join(', ')}');
    }
    if (denied.isNotEmpty) {
      summary.writeln('未授权权限: ${denied.join(', ')}');
    }

    return summary.toString();
  }

  /// 检查是否为敏感权限
  static bool isSensitivePermission(AppPermission permission) {
    const sensitivePermissions = [
      AppPermission.camera,
      AppPermission.microphone,
      AppPermission.location,
      AppPermission.locationAlways,
      AppPermission.contacts,
      AppPermission.phone,
      AppPermission.sms,
    ];
    return sensitivePermissions.contains(permission);
  }

  /// 获取权限分组
  static Map<String, List<AppPermission>> groupPermissions(
    List<AppPermission> permissions,
  ) {
    final groups = <String, List<AppPermission>>{
      '媒体权限': [],
      '位置权限': [],
      '通讯权限': [],
      '存储权限': [],
      '系统权限': [],
      '其他权限': [],
    };

    for (final permission in permissions) {
      switch (permission) {
        case AppPermission.camera:
        case AppPermission.microphone:
        case AppPermission.photos:
        case AppPermission.webCamera:
        case AppPermission.webMicrophone:
          groups['媒体权限']!.add(permission);
          break;
        case AppPermission.location:
        case AppPermission.locationAlways:
        case AppPermission.locationWhenInUse:
        case AppPermission.webLocation:
          groups['位置权限']!.add(permission);
          break;
        case AppPermission.contacts:
        case AppPermission.phone:
        case AppPermission.sms:
          groups['通讯权限']!.add(permission);
          break;
        case AppPermission.storage:
        case AppPermission.desktopFileSystem:
          groups['存储权限']!.add(permission);
          break;
        case AppPermission.notification:
        case AppPermission.webNotification:
        case AppPermission.desktopSystemTray:
        case AppPermission.desktopAutoStart:
          groups['系统权限']!.add(permission);
          break;
        default:
          groups['其他权限']!.add(permission);
          break;
      }
    }

    // 移除空分组
    groups.removeWhere((key, value) => value.isEmpty);
    return groups;
  }
}
