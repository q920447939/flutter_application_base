/// 权限引导页面
///
/// 提供友好的权限引导界面，包括：
/// - 权限说明展示
/// - 批量权限请求
/// - 权限状态管理
/// - 跳过和重试功能
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'permission_service.dart';

/// 权限引导页面
class PermissionGuidePage extends StatefulWidget {
  final List<AppPermission> requiredPermissions;
  final String title;
  final String description;
  final VoidCallback? onCompleted;
  final VoidCallback? onSkipped;
  final bool allowSkip;

  PermissionGuidePage({
    super.key,
    this.requiredPermissions = const [],
    this.title = '权限授权',
    this.description = '为了更好地为您提供服务，需要获取以下权限：',
    this.onCompleted,
    this.onSkipped,
    this.allowSkip = true,
  });

  // 添加一个工厂构造函数从路由参数创建
  static Widget fromRouteSettings(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    return PermissionGuidePage(
      requiredPermissions: args?['requiredPermissions'] ?? const [],
      title: '必要权限授权',
      description: '以下权限是应用正常运行所必需的，请授权：',
      allowSkip: false,
      onCompleted: () => Get.back(result: true),
    );
  }

  @override
  State<PermissionGuidePage> createState() => _PermissionGuidePageState();
}

class _PermissionGuidePageState extends State<PermissionGuidePage> {
  final Map<AppPermission, PermissionResult> _permissionResults = {};
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _checkInitialPermissions();
  }

  /// 检查初始权限状态
  Future<void> _checkInitialPermissions() async {
    final results = await PermissionService.instance.checkPermissions(
      widget.requiredPermissions,
    );
    setState(() {
      _permissionResults.addAll(results);
    });
  }

  /// 请求所有权限
  Future<void> _requestAllPermissions() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      final results = await PermissionService.instance.requestPermissions(
        widget.requiredPermissions,
        showRationale: false, // 页面本身就是说明
      );

      setState(() {
        _permissionResults.addAll(results);
      });

      // 检查是否所有权限都已授权
      final allGranted = results.values.every((result) => result.isGranted);
      if (allGranted) {
        widget.onCompleted?.call();
      }
    } finally {
      setState(() {
        _isRequesting = false;
      });
    }
  }

  /// 请求单个权限
  Future<void> _requestSinglePermission(AppPermission permission) async {
    final result = await PermissionService.instance.requestPermission(
      permission,
      showRationale: false,
    );

    setState(() {
      _permissionResults[permission] = result;
    });
  }

  /// 获取权限状态图标
  Widget _getPermissionIcon(AppPermission permission) {
    final result = _permissionResults[permission];
    if (result == null) {
      return const Icon(Icons.help_outline, color: Colors.grey);
    }

    if (result.isGranted) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (result.isPermanentlyDenied) {
      return const Icon(Icons.block, color: Colors.red);
    } else {
      return const Icon(Icons.warning, color: Colors.orange);
    }
  }

  /// 获取权限状态文本
  String _getPermissionStatusText(AppPermission permission) {
    final result = _permissionResults[permission];
    if (result == null) {
      return '检查中...';
    }

    if (result.isGranted) {
      return '已授权';
    } else if (result.isPermanentlyDenied) {
      return '已拒绝';
    } else {
      return '未授权';
    }
  }

  /// 获取权限对应的图标
  IconData _getPermissionTypeIcon(AppPermission permission) {
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
      // 桌面端特有权限
      case AppPermission.desktopFileSystem:
        return Icons.folder;
      case AppPermission.desktopSystemTray:
        return Icons.apps;
      case AppPermission.desktopAutoStart:
        return Icons.power_settings_new;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allGranted =
        _permissionResults.values.isNotEmpty &&
        _permissionResults.values.every((result) => result.isGranted);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 描述文本
            Text(
              widget.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // 权限列表
            Expanded(
              child: ListView.builder(
                itemCount: widget.requiredPermissions.length,
                itemBuilder: (context, index) {
                  final permission = widget.requiredPermissions[index];
                  final result = _permissionResults[permission];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          _getPermissionTypeIcon(permission),
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(permission.name),
                      subtitle: Text(permission.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _getPermissionIcon(permission),
                          const SizedBox(width: 8),
                          Text(
                            _getPermissionStatusText(permission),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (result != null && !result.isGranted) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed:
                                  () => _requestSinglePermission(permission),
                              icon: const Icon(Icons.refresh),
                              tooltip: '重新请求',
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 底部按钮
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.allowSkip && !allGranted)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onSkipped,
                      child: const Text('跳过'),
                    ),
                  ),
                if (widget.allowSkip && !allGranted) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        allGranted
                            ? widget.onCompleted
                            : _isRequesting
                            ? null
                            : _requestAllPermissions,
                    child:
                        _isRequesting
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(allGranted ? '完成' : '授权'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 权限引导控制器
class PermissionGuideController extends GetxController {
  final RxMap<AppPermission, PermissionResult> permissionResults =
      <AppPermission, PermissionResult>{}.obs;
  final RxBool isRequesting = false.obs;

  /// 显示权限引导页面
  static Future<bool> showPermissionGuide({
    required List<AppPermission> permissions,
    String title = '权限授权',
    String description = '为了更好地为您提供服务，需要获取以下权限：',
    bool allowSkip = true,
  }) async {
    final result = await Get.to<bool>(
      () => PermissionGuidePage(
        requiredPermissions: permissions,
        title: title,
        description: description,
        allowSkip: allowSkip,
        onCompleted: () => Get.back(result: true),
        onSkipped: () => Get.back(result: false),
      ),
    );
    return result ?? false;
  }

  /// 检查并请求必要权限
  static Future<bool> checkAndRequestPermissions(
    List<AppPermission> permissions,
  ) async {
    // 先检查当前权限状态
    final results = await PermissionService.instance.checkPermissions(
      permissions,
    );
    final deniedPermissions =
        results.entries
            .where((entry) => !entry.value.isGranted)
            .map((entry) => entry.key)
            .toList();

    // 如果所有权限都已授权，直接返回true
    if (deniedPermissions.isEmpty) {
      return true;
    }

    // 显示权限引导页面
    return await showPermissionGuide(permissions: deniedPermissions);
  }
}
