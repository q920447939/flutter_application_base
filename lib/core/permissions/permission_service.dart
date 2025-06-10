/// 权限管理服务
/// 
/// 提供统一的权限管理接口，包括：
/// - 权限状态检查
/// - 权限请求
/// - 权限引导
/// - 批量权限处理
library;

import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// 权限类型枚举
enum AppPermission {
  camera,
  microphone,
  photos,
  location,
  locationAlways,
  locationWhenInUse,
  storage,
  contacts,
  phone,
  sms,
  notification,
  bluetooth,
  bluetoothScan,
  bluetoothAdvertise,
  bluetoothConnect,
}

/// 权限状态扩展
extension AppPermissionExtension on AppPermission {
  /// 转换为系统权限
  Permission get systemPermission {
    switch (this) {
      case AppPermission.camera:
        return Permission.camera;
      case AppPermission.microphone:
        return Permission.microphone;
      case AppPermission.photos:
        return Permission.photos;
      case AppPermission.location:
        return Permission.location;
      case AppPermission.locationAlways:
        return Permission.locationAlways;
      case AppPermission.locationWhenInUse:
        return Permission.locationWhenInUse;
      case AppPermission.storage:
        return Permission.storage;
      case AppPermission.contacts:
        return Permission.contacts;
      case AppPermission.phone:
        return Permission.phone;
      case AppPermission.sms:
        return Permission.sms;
      case AppPermission.notification:
        return Permission.notification;
      case AppPermission.bluetooth:
        return Permission.bluetooth;
      case AppPermission.bluetoothScan:
        return Permission.bluetoothScan;
      case AppPermission.bluetoothAdvertise:
        return Permission.bluetoothAdvertise;
      case AppPermission.bluetoothConnect:
        return Permission.bluetoothConnect;
    }
  }

  /// 权限名称
  String get name {
    switch (this) {
      case AppPermission.camera:
        return '相机';
      case AppPermission.microphone:
        return '麦克风';
      case AppPermission.photos:
        return '相册';
      case AppPermission.location:
        return '位置信息';
      case AppPermission.locationAlways:
        return '始终访问位置';
      case AppPermission.locationWhenInUse:
        return '使用时访问位置';
      case AppPermission.storage:
        return '存储空间';
      case AppPermission.contacts:
        return '通讯录';
      case AppPermission.phone:
        return '电话';
      case AppPermission.sms:
        return '短信';
      case AppPermission.notification:
        return '通知';
      case AppPermission.bluetooth:
        return '蓝牙';
      case AppPermission.bluetoothScan:
        return '蓝牙扫描';
      case AppPermission.bluetoothAdvertise:
        return '蓝牙广播';
      case AppPermission.bluetoothConnect:
        return '蓝牙连接';
    }
  }

  /// 权限描述
  String get description {
    switch (this) {
      case AppPermission.camera:
        return '用于拍照和录制视频';
      case AppPermission.microphone:
        return '用于录制音频和语音通话';
      case AppPermission.photos:
        return '用于访问和保存图片';
      case AppPermission.location:
        return '用于获取您的位置信息';
      case AppPermission.locationAlways:
        return '用于在后台获取位置信息';
      case AppPermission.locationWhenInUse:
        return '用于在使用应用时获取位置信息';
      case AppPermission.storage:
        return '用于读取和保存文件';
      case AppPermission.contacts:
        return '用于访问您的联系人信息';
      case AppPermission.phone:
        return '用于拨打电话';
      case AppPermission.sms:
        return '用于发送短信';
      case AppPermission.notification:
        return '用于向您发送通知消息';
      case AppPermission.bluetooth:
        return '用于连接蓝牙设备';
      case AppPermission.bluetoothScan:
        return '用于扫描蓝牙设备';
      case AppPermission.bluetoothAdvertise:
        return '用于蓝牙设备广播';
      case AppPermission.bluetoothConnect:
        return '用于连接蓝牙设备';
    }
  }
}

/// 权限请求结果
class PermissionResult {
  final AppPermission permission;
  final PermissionStatus status;
  final bool isGranted;
  final bool isDenied;
  final bool isPermanentlyDenied;

  const PermissionResult({
    required this.permission,
    required this.status,
    required this.isGranted,
    required this.isDenied,
    required this.isPermanentlyDenied,
  });

  factory PermissionResult.fromStatus(AppPermission permission, PermissionStatus status) {
    return PermissionResult(
      permission: permission,
      status: status,
      isGranted: status.isGranted,
      isDenied: status.isDenied,
      isPermanentlyDenied: status.isPermanentlyDenied,
    );
  }
}

/// 权限服务类
class PermissionService {
  static PermissionService? _instance;

  PermissionService._internal();

  /// 单例模式
  static PermissionService get instance {
    _instance ??= PermissionService._internal();
    return _instance!;
  }

  /// 检查单个权限状态
  Future<PermissionResult> checkPermission(AppPermission permission) async {
    final status = await permission.systemPermission.status;
    return PermissionResult.fromStatus(permission, status);
  }

  /// 检查多个权限状态
  Future<Map<AppPermission, PermissionResult>> checkPermissions(
    List<AppPermission> permissions,
  ) async {
    final results = <AppPermission, PermissionResult>{};
    
    for (final permission in permissions) {
      final result = await checkPermission(permission);
      results[permission] = result;
    }
    
    return results;
  }

  /// 请求单个权限
  Future<PermissionResult> requestPermission(
    AppPermission permission, {
    bool showRationale = true,
  }) async {
    // 先检查当前状态
    final currentResult = await checkPermission(permission);
    
    // 如果已经授权，直接返回
    if (currentResult.isGranted) {
      return currentResult;
    }
    
    // 如果被永久拒绝，引导用户到设置页面
    if (currentResult.isPermanentlyDenied) {
      if (showRationale) {
        await _showPermissionDeniedDialog(permission);
      }
      return currentResult;
    }
    
    // 如果需要显示权限说明
    if (showRationale && currentResult.isDenied) {
      final shouldRequest = await _showPermissionRationaleDialog(permission);
      if (!shouldRequest) {
        return currentResult;
      }
    }
    
    // 请求权限
    final status = await permission.systemPermission.request();
    return PermissionResult.fromStatus(permission, status);
  }

  /// 请求多个权限
  Future<Map<AppPermission, PermissionResult>> requestPermissions(
    List<AppPermission> permissions, {
    bool showRationale = true,
  }) async {
    final results = <AppPermission, PermissionResult>{};
    
    for (final permission in permissions) {
      final result = await requestPermission(permission, showRationale: showRationale);
      results[permission] = result;
    }
    
    return results;
  }

  /// 批量请求权限（系统原生方式）
  Future<Map<AppPermission, PermissionResult>> requestPermissionsBatch(
    List<AppPermission> permissions,
  ) async {
    final systemPermissions = permissions.map((p) => p.systemPermission).toList();
    final statusMap = await systemPermissions.request();
    
    final results = <AppPermission, PermissionResult>{};
    for (int i = 0; i < permissions.length; i++) {
      final permission = permissions[i];
      final status = statusMap[systemPermissions[i]] ?? PermissionStatus.denied;
      results[permission] = PermissionResult.fromStatus(permission, status);
    }
    
    return results;
  }

  /// 显示权限说明对话框
  Future<bool> _showPermissionRationaleDialog(AppPermission permission) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('需要${permission.name}权限'),
        content: Text('${permission.description}\n\n是否授权？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('拒绝'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('授权'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 显示权限被拒绝对话框
  Future<void> _showPermissionDeniedDialog(AppPermission permission) async {
    await Get.dialog(
      AlertDialog(
        title: Text('${permission.name}权限被拒绝'),
        content: Text('${permission.description}\n\n请在设置中手动开启权限。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  /// 打开应用设置页面
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// 检查是否有权限被永久拒绝
  Future<bool> hasPermissionsPermanentlyDenied(List<AppPermission> permissions) async {
    for (final permission in permissions) {
      final result = await checkPermission(permission);
      if (result.isPermanentlyDenied) {
        return true;
      }
    }
    return false;
  }

  /// 获取被拒绝的权限列表
  Future<List<AppPermission>> getDeniedPermissions(List<AppPermission> permissions) async {
    final deniedPermissions = <AppPermission>[];
    
    for (final permission in permissions) {
      final result = await checkPermission(permission);
      if (result.isDenied || result.isPermanentlyDenied) {
        deniedPermissions.add(permission);
      }
    }
    
    return deniedPermissions;
  }

  /// 获取已授权的权限列表
  Future<List<AppPermission>> getGrantedPermissions(List<AppPermission> permissions) async {
    final grantedPermissions = <AppPermission>[];
    
    for (final permission in permissions) {
      final result = await checkPermission(permission);
      if (result.isGranted) {
        grantedPermissions.add(permission);
      }
    }
    
    return grantedPermissions;
  }
}
