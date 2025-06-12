/// 权限管理服务
///
/// 提供统一的权限管理接口，包括：
/// - 权限状态检查
/// - 权限请求
/// - 权限引导
/// - 批量权限处理
library;

import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// 平台类型枚举
enum PlatformType {
  mobile, // 移动端 (iOS/Android)
  desktop, // 桌面端 (Windows/macOS/Linux)
  web, // Web端
}

/// 权限重要性级别
enum PermissionPriority {
  required, // 必要权限 - 没有此权限应用无法正常运行
  optional, // 可选权限 - 没有此权限应用可以降级运行
}

/// 权限触发场景
enum PermissionTrigger {
  appLaunch, // 应用启动时
  pageEnter, // 进入页面时
  actionTrigger, // 触发特定操作时
  background, // 后台运行时
}

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
  // Web特有权限
  webCamera,
  webMicrophone,
  webNotification,
  webLocation,
  // 桌面端特有权限
  desktopFileSystem,
  desktopSystemTray,
  desktopAutoStart,
}

/// 权限状态扩展
extension AppPermissionExtension on AppPermission {
  /// 转换为系统权限
  Permission get systemPermission {
    switch (this) {
      case AppPermission.camera:
      case AppPermission.webCamera:
        return Permission.camera;
      case AppPermission.microphone:
      case AppPermission.webMicrophone:
        return Permission.microphone;
      case AppPermission.photos:
        return Permission.photos;
      case AppPermission.location:
      case AppPermission.webLocation:
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
      case AppPermission.webNotification:
        return Permission.notification;
      case AppPermission.bluetooth:
        return Permission.bluetooth;
      case AppPermission.bluetoothScan:
        return Permission.bluetoothScan;
      case AppPermission.bluetoothAdvertise:
        return Permission.bluetoothAdvertise;
      case AppPermission.bluetoothConnect:
        return Permission.bluetoothConnect;
      // 桌面端权限暂时映射到存储权限，实际实现时需要平台特定处理
      case AppPermission.desktopFileSystem:
        return Permission.storage;
      case AppPermission.desktopSystemTray:
      case AppPermission.desktopAutoStart:
        return Permission.systemAlertWindow;
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
      // Web特有权限
      case AppPermission.webCamera:
        return 'Web相机';
      case AppPermission.webMicrophone:
        return 'Web麦克风';
      case AppPermission.webNotification:
        return 'Web通知';
      case AppPermission.webLocation:
        return 'Web位置';
      // 桌面端特有权限
      case AppPermission.desktopFileSystem:
        return '文件系统访问';
      case AppPermission.desktopSystemTray:
        return '系统托盘';
      case AppPermission.desktopAutoStart:
        return '开机自启动';
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
      // Web特有权限
      case AppPermission.webCamera:
        return '用于在浏览器中访问摄像头';
      case AppPermission.webMicrophone:
        return '用于在浏览器中访问麦克风';
      case AppPermission.webNotification:
        return '用于在浏览器中显示通知';
      case AppPermission.webLocation:
        return '用于在浏览器中获取位置信息';
      // 桌面端特有权限
      case AppPermission.desktopFileSystem:
        return '用于访问本地文件系统';
      case AppPermission.desktopSystemTray:
        return '用于在系统托盘显示图标';
      case AppPermission.desktopAutoStart:
        return '用于开机自动启动应用';
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

  factory PermissionResult.fromStatus(
    AppPermission permission,
    PermissionStatus status,
  ) {
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
  bool _isInitialized = false;

  /// 权限状态缓存
  final Map<AppPermission, PermissionResult> _permissionCache = {};

  /// 缓存过期时间（毫秒）
  static const int _cacheExpiryMs = 30000; // 30秒

  /// 缓存时间戳
  final Map<AppPermission, int> _cacheTimestamps = {};

  PermissionService._internal();

  /// 单例模式
  static PermissionService get instance {
    _instance ??= PermissionService._internal();
    return _instance!;
  }

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化权限服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 这里可以添加权限服务的初始化逻辑
      _isInitialized = true;
    } catch (e) {
      debugPrint('权限服务初始化失败: $e');
      rethrow;
    }
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
      // 更新缓存
      _updateCache(permission, result);
    }

    return results;
  }

  /// 同步检查单个权限状态（从缓存）
  PermissionResult? checkPermissionSync(AppPermission permission) {
    final cachedResult = _getCachedResult(permission);
    if (cachedResult != null) {
      return cachedResult;
    }

    // 如果没有缓存，返回默认的拒绝状态
    // 在实际应用中，这里可以从本地存储读取上次的权限状态
    return PermissionResult.fromStatus(permission, PermissionStatus.denied);
  }

  /// 同步检查多个权限状态（从缓存）
  Map<AppPermission, PermissionResult> checkPermissionsSync(
    List<AppPermission> permissions,
  ) {
    final results = <AppPermission, PermissionResult>{};

    for (final permission in permissions) {
      results[permission] =
          checkPermissionSync(permission) ??
          PermissionResult.fromStatus(permission, PermissionStatus.denied);
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
      final result = await requestPermission(
        permission,
        showRationale: showRationale,
      );
      results[permission] = result;
    }

    return results;
  }

  /// 批量请求权限（系统原生方式）
  Future<Map<AppPermission, PermissionResult>> requestPermissionsBatch(
    List<AppPermission> permissions,
  ) async {
    final systemPermissions =
        permissions.map((p) => p.systemPermission).toList();
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
          TextButton(onPressed: () => Get.back(), child: const Text('取消')),
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
    try {
      return await permission_handler.openAppSettings();
    } catch (e) {
      debugPrint('打开应用设置失败: $e');
      return false;
    }
  }

  /// 检查是否有权限被永久拒绝
  Future<bool> hasPermissionsPermanentlyDenied(
    List<AppPermission> permissions,
  ) async {
    for (final permission in permissions) {
      final result = await checkPermission(permission);
      if (result.isPermanentlyDenied) {
        return true;
      }
    }
    return false;
  }

  /// 获取被拒绝的权限列表
  Future<List<AppPermission>> getDeniedPermissions(
    List<AppPermission> permissions,
  ) async {
    final deniedPermissions = <AppPermission>[];

    for (final permission in permissions) {
      final result = await checkPermission(permission);
      if (result.isDenied || result.isPermanentlyDenied) {
        deniedPermissions.add(permission);
      }
    }

    return deniedPermissions;
  }

  /// 更新权限缓存
  void _updateCache(AppPermission permission, PermissionResult result) {
    _permissionCache[permission] = result;
    _cacheTimestamps[permission] = DateTime.now().millisecondsSinceEpoch;
  }

  /// 获取缓存的权限结果
  PermissionResult? _getCachedResult(AppPermission permission) {
    final timestamp = _cacheTimestamps[permission];
    if (timestamp == null) {
      return null;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - timestamp > _cacheExpiryMs) {
      // 缓存已过期，清除
      _permissionCache.remove(permission);
      _cacheTimestamps.remove(permission);
      return null;
    }

    return _permissionCache[permission];
  }

  /// 清除权限缓存
  void clearCache() {
    _permissionCache.clear();
    _cacheTimestamps.clear();
  }

  /// 预热权限缓存
  Future<void> warmupCache(List<AppPermission> permissions) async {
    await checkPermissions(permissions);
  }

  /// 获取已授权的权限列表
  Future<List<AppPermission>> getGrantedPermissions(
    List<AppPermission> permissions,
  ) async {
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
