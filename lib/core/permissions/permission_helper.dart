/// 权限检查工具类
///
/// 提供便捷的权限检查和请求方法，包括：
/// - 常用权限组合
/// - 权限检查装饰器
/// - 权限相关的工具方法
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'permission_service.dart';
import 'permission_guide_page.dart';

/// 权限助手类
class PermissionHelper {
  PermissionHelper._();

  /// 相机相关权限
  static const List<AppPermission> cameraPermissions = [
    AppPermission.camera,
    AppPermission.storage,
  ];

  /// 录音相关权限
  static const List<AppPermission> audioPermissions = [
    AppPermission.microphone,
    AppPermission.storage,
  ];

  /// 位置相关权限
  static const List<AppPermission> locationPermissions = [
    AppPermission.locationWhenInUse,
  ];

  /// 精确位置权限
  static const List<AppPermission> preciseLocationPermissions = [
    AppPermission.locationAlways,
  ];

  /// 存储相关权限
  static const List<AppPermission> storagePermissions = [
    AppPermission.storage,
    AppPermission.photos,
  ];

  /// 通讯相关权限
  static const List<AppPermission> communicationPermissions = [
    AppPermission.phone,
    AppPermission.sms,
    AppPermission.contacts,
  ];

  /// 蓝牙相关权限
  static const List<AppPermission> bluetoothPermissions = [
    AppPermission.bluetooth,
    AppPermission.bluetoothScan,
    AppPermission.bluetoothConnect,
  ];

  /// 检查并请求相机权限
  static Future<bool> requestCameraPermission() async {
    return await _requestPermissionsWithGuide(
      cameraPermissions,
      title: '相机权限',
      description: '需要相机和存储权限来拍照和保存图片',
    );
  }

  /// 检查并请求录音权限
  static Future<bool> requestAudioPermission() async {
    return await _requestPermissionsWithGuide(
      audioPermissions,
      title: '录音权限',
      description: '需要麦克风和存储权限来录制和保存音频',
    );
  }

  /// 检查并请求位置权限
  static Future<bool> requestLocationPermission() async {
    return await _requestPermissionsWithGuide(
      locationPermissions,
      title: '位置权限',
      description: '需要位置权限来提供基于位置的服务',
    );
  }

  /// 检查并请求精确位置权限
  static Future<bool> requestPreciseLocationPermission() async {
    return await _requestPermissionsWithGuide(
      preciseLocationPermissions,
      title: '精确位置权限',
      description: '需要精确位置权限来提供更准确的位置服务',
    );
  }

  /// 检查并请求存储权限
  static Future<bool> requestStoragePermission() async {
    return await _requestPermissionsWithGuide(
      storagePermissions,
      title: '存储权限',
      description: '需要存储权限来读取和保存文件',
    );
  }

  /// 检查并请求通讯权限
  static Future<bool> requestCommunicationPermission() async {
    return await _requestPermissionsWithGuide(
      communicationPermissions,
      title: '通讯权限',
      description: '需要通讯权限来访问联系人、拨打电话和发送短信',
    );
  }

  /// 检查并请求蓝牙权限
  static Future<bool> requestBluetoothPermission() async {
    return await _requestPermissionsWithGuide(
      bluetoothPermissions,
      title: '蓝牙权限',
      description: '需要蓝牙权限来连接和管理蓝牙设备',
    );
  }

  /// 检查并请求通知权限
  static Future<bool> requestNotificationPermission() async {
    return await _requestPermissionsWithGuide(
      [AppPermission.notification],
      title: '通知权限',
      description: '需要通知权限来向您发送重要消息',
    );
  }

  /// 通用权限请求方法（带引导页面）
  static Future<bool> _requestPermissionsWithGuide(
    List<AppPermission> permissions, {
    required String title,
    required String description,
  }) async {
    // 先检查权限状态
    final results = await PermissionService.instance.checkPermissions(
      permissions,
    );
    final deniedPermissions =
        results.entries
            .where((entry) => !entry.value.isGranted)
            .map((entry) => entry.key)
            .toList();

    // 如果所有权限都已授权
    if (deniedPermissions.isEmpty) {
      return true;
    }

    // 显示权限引导页面
    return await PermissionGuideController.showPermissionGuide(
      permissions: deniedPermissions,
      title: title,
      description: description,
    );
  }

  /// 权限检查装饰器
  static Future<T?> withPermission<T>(
    List<AppPermission> permissions,
    Future<T> Function() action, {
    String? title,
    String? description,
    bool showGuide = true,
  }) async {
    bool hasPermission;

    if (showGuide) {
      hasPermission = await _requestPermissionsWithGuide(
        permissions,
        title: title ?? '权限请求',
        description: description ?? '需要以下权限来执行此操作',
      );
    } else {
      final results = await PermissionService.instance.requestPermissions(
        permissions,
      );
      hasPermission = results.values.every((result) => result.isGranted);
    }

    if (hasPermission) {
      return await action();
    }
    return null;
  }

  /// 检查单个权限是否已授权
  static Future<bool> hasPermission(AppPermission permission) async {
    final result = await PermissionService.instance.checkPermission(permission);
    return result.isGranted;
  }

  /// 检查多个权限是否都已授权
  static Future<bool> hasPermissions(List<AppPermission> permissions) async {
    final results = await PermissionService.instance.checkPermissions(
      permissions,
    );
    return results.values.every((result) => result.isGranted);
  }

  /// 检查是否有权限被永久拒绝
  static Future<bool> hasPermissionsPermanentlyDenied(
    List<AppPermission> permissions,
  ) async {
    return await PermissionService.instance.hasPermissionsPermanentlyDenied(
      permissions,
    );
  }

  /// 获取权限状态摘要
  static Future<PermissionSummary> getPermissionSummary(
    List<AppPermission> permissions,
  ) async {
    final results = await PermissionService.instance.checkPermissions(
      permissions,
    );

    final granted = <AppPermission>[];
    final denied = <AppPermission>[];
    final permanentlyDenied = <AppPermission>[];

    for (final entry in results.entries) {
      if (entry.value.isGranted) {
        granted.add(entry.key);
      } else if (entry.value.isPermanentlyDenied) {
        permanentlyDenied.add(entry.key);
      } else {
        denied.add(entry.key);
      }
    }

    return PermissionSummary(
      granted: granted,
      denied: denied,
      permanentlyDenied: permanentlyDenied,
    );
  }

  /// 显示权限设置引导
  static Future<void> showPermissionSettingsGuide(
    List<AppPermission> permissions,
  ) async {
    final permissionNames = permissions.map((p) => p.name).join('、');

    await showDialog(
      context: Get.context!,
      builder:
          (context) => AlertDialog(
            title: const Text('权限设置'),
            content: Text('请在设置中手动开启以下权限：\n\n$permissionNames'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  PermissionService.instance.openAppSettings();
                },
                child: const Text('去设置'),
              ),
            ],
          ),
    );
  }
}

/// 权限状态摘要
class PermissionSummary {
  final List<AppPermission> granted;
  final List<AppPermission> denied;
  final List<AppPermission> permanentlyDenied;

  const PermissionSummary({
    required this.granted,
    required this.denied,
    required this.permanentlyDenied,
  });

  /// 是否所有权限都已授权
  bool get allGranted => denied.isEmpty && permanentlyDenied.isEmpty;

  /// 是否有权限被拒绝
  bool get hasDenied => denied.isNotEmpty || permanentlyDenied.isNotEmpty;

  /// 是否有权限被永久拒绝
  bool get hasPermanentlyDenied => permanentlyDenied.isNotEmpty;

  /// 总权限数量
  int get totalCount =>
      granted.length + denied.length + permanentlyDenied.length;

  /// 已授权权限数量
  int get grantedCount => granted.length;

  /// 权限授权率
  double get grantedRate => totalCount > 0 ? grantedCount / totalCount : 0.0;

  @override
  String toString() {
    return 'PermissionSummary(granted: ${granted.length}, denied: ${denied.length}, permanentlyDenied: ${permanentlyDenied.length})';
  }
}
