/// 平台检测器
/// 
/// 负责检测当前运行平台并提供平台相关的权限映射
library;

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'permission_service.dart';

/// 平台检测器
class PlatformDetector {
  static PlatformDetector? _instance;
  
  PlatformDetector._internal();
  
  /// 单例模式
  static PlatformDetector get instance {
    _instance ??= PlatformDetector._internal();
    return _instance!;
  }
  
  /// 获取当前平台类型
  PlatformType get currentPlatform {
    if (kIsWeb) {
      return PlatformType.web;
    }
    
    if (Platform.isAndroid || Platform.isIOS) {
      return PlatformType.mobile;
    }
    
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return PlatformType.desktop;
    }
    
    // 默认返回移动端
    return PlatformType.mobile;
  }
  
  /// 检查权限是否在当前平台支持
  bool isPermissionSupportedOnCurrentPlatform(AppPermission permission) {
    return isPermissionSupportedOnPlatform(permission, currentPlatform);
  }
  
  /// 检查权限是否在指定平台支持
  bool isPermissionSupportedOnPlatform(AppPermission permission, PlatformType platform) {
    switch (platform) {
      case PlatformType.mobile:
        return _isMobilePermission(permission);
      case PlatformType.desktop:
        return _isDesktopPermission(permission);
      case PlatformType.web:
        return _isWebPermission(permission);
    }
  }
  
  /// 获取当前平台支持的权限列表
  List<AppPermission> getSupportedPermissions() {
    return getSupportedPermissionsForPlatform(currentPlatform);
  }
  
  /// 获取指定平台支持的权限列表
  List<AppPermission> getSupportedPermissionsForPlatform(PlatformType platform) {
    switch (platform) {
      case PlatformType.mobile:
        return _getMobilePermissions();
      case PlatformType.desktop:
        return _getDesktopPermissions();
      case PlatformType.web:
        return _getWebPermissions();
    }
  }
  
  /// 过滤出当前平台支持的权限
  List<AppPermission> filterSupportedPermissions(List<AppPermission> permissions) {
    return permissions.where((permission) => 
        isPermissionSupportedOnCurrentPlatform(permission)).toList();
  }
  
  /// 检查是否为移动端权限
  bool _isMobilePermission(AppPermission permission) {
    const mobilePermissions = [
      AppPermission.camera,
      AppPermission.microphone,
      AppPermission.photos,
      AppPermission.location,
      AppPermission.locationAlways,
      AppPermission.locationWhenInUse,
      AppPermission.storage,
      AppPermission.contacts,
      AppPermission.phone,
      AppPermission.sms,
      AppPermission.notification,
      AppPermission.bluetooth,
      AppPermission.bluetoothScan,
      AppPermission.bluetoothAdvertise,
      AppPermission.bluetoothConnect,
    ];
    return mobilePermissions.contains(permission);
  }
  
  /// 检查是否为桌面端权限
  bool _isDesktopPermission(AppPermission permission) {
    const desktopPermissions = [
      AppPermission.camera,
      AppPermission.microphone,
      AppPermission.location,
      AppPermission.storage,
      AppPermission.notification,
      AppPermission.desktopFileSystem,
      AppPermission.desktopSystemTray,
      AppPermission.desktopAutoStart,
    ];
    return desktopPermissions.contains(permission);
  }
  
  /// 检查是否为Web端权限
  bool _isWebPermission(AppPermission permission) {
    const webPermissions = [
      AppPermission.webCamera,
      AppPermission.webMicrophone,
      AppPermission.webNotification,
      AppPermission.webLocation,
    ];
    return webPermissions.contains(permission);
  }
  
  /// 获取移动端权限列表
  List<AppPermission> _getMobilePermissions() {
    return [
      AppPermission.camera,
      AppPermission.microphone,
      AppPermission.photos,
      AppPermission.location,
      AppPermission.locationAlways,
      AppPermission.locationWhenInUse,
      AppPermission.storage,
      AppPermission.contacts,
      AppPermission.phone,
      AppPermission.sms,
      AppPermission.notification,
      AppPermission.bluetooth,
      AppPermission.bluetoothScan,
      AppPermission.bluetoothAdvertise,
      AppPermission.bluetoothConnect,
    ];
  }
  
  /// 获取桌面端权限列表
  List<AppPermission> _getDesktopPermissions() {
    return [
      AppPermission.camera,
      AppPermission.microphone,
      AppPermission.location,
      AppPermission.storage,
      AppPermission.notification,
      AppPermission.desktopFileSystem,
      AppPermission.desktopSystemTray,
      AppPermission.desktopAutoStart,
    ];
  }
  
  /// 获取Web端权限列表
  List<AppPermission> _getWebPermissions() {
    return [
      AppPermission.webCamera,
      AppPermission.webMicrophone,
      AppPermission.webNotification,
      AppPermission.webLocation,
    ];
  }
  
  /// 获取平台名称
  String get platformName {
    switch (currentPlatform) {
      case PlatformType.mobile:
        if (Platform.isAndroid) return 'Android';
        if (Platform.isIOS) return 'iOS';
        return 'Mobile';
      case PlatformType.desktop:
        if (Platform.isWindows) return 'Windows';
        if (Platform.isMacOS) return 'macOS';
        if (Platform.isLinux) return 'Linux';
        return 'Desktop';
      case PlatformType.web:
        return 'Web';
    }
  }
  
  /// 是否为移动端
  bool get isMobile => currentPlatform == PlatformType.mobile;
  
  /// 是否为桌面端
  bool get isDesktop => currentPlatform == PlatformType.desktop;
  
  /// 是否为Web端
  bool get isWeb => currentPlatform == PlatformType.web;
}
