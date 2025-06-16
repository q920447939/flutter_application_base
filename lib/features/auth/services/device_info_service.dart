/// 设备信息服务
///
/// 提供设备信息收集、客户端IP获取等功能
library;

import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/widgets.dart';
import '../../../core/network/network_service.dart';
import '../models/common_result.dart';

/// 设备信息服务
class DeviceInfoService extends GetxService {
  static DeviceInfoService get instance => Get.find<DeviceInfoService>();

  /// 缓存的设备信息
  String? _cachedDeviceInfo;

  /// 缓存的客户端IP
  String? _cachedClientIp;

  /// IP缓存过期时间（5分钟）
  static const Duration _ipCacheExpiry = Duration(minutes: 5);
  DateTime? _ipCacheTime;

  @override
  void onInit() {
    super.onInit();
    debugPrint('设备信息服务初始化完成');
  }

  /// 获取设备信息
  Future<String> getDeviceInfo() async {
    if (_cachedDeviceInfo != null) {
      return _cachedDeviceInfo!;
    }

    try {
      final deviceInfo = await _collectDeviceInfo();
      _cachedDeviceInfo = deviceInfo;
      return deviceInfo;
    } catch (e) {
      debugPrint('获取设备信息失败: $e');
      return _getDefaultDeviceInfo();
    }
  }

  /// 获取客户端IP（通过服务器接口）
  Future<String?> getClientIp() async {
    // 检查缓存是否有效
    if (_cachedClientIp != null && _isIpCacheValid()) {
      return _cachedClientIp;
    }

    try {
      final response = await NetworkService.instance.get(
        '/api/common/client-ip',
      );

      if (response.statusCode == 200) {
        final result = CommonResult<String>.fromJson(
          response.data,
          (json) => json as String,
        );

        if (result.isSuccess && result.data != null) {
          _cachedClientIp = result.data;
          _ipCacheTime = DateTime.now();
          debugPrint('获取客户端IP成功: $_cachedClientIp');
          return _cachedClientIp;
        }
      }
    } catch (e) {
      debugPrint('获取客户端IP失败: $e');
    }

    return null;
  }

  /// 构建上下文信息
  Map<String, Object> buildContext({
    String? tenantId,
    String? domainId,
    String? organizationId,
    String? userId,
    Map<String, Object>? additional,
  }) {
    final context = <String, Object>{};

    // 添加基础上下文信息
    if (tenantId != null && tenantId.isNotEmpty) {
      context['tenantId'] = tenantId;
    }

    if (domainId != null && domainId.isNotEmpty) {
      context['domainId'] = domainId;
    }

    if (organizationId != null && organizationId.isNotEmpty) {
      context['organizationId'] = organizationId;
    }

    if (userId != null && userId.isNotEmpty) {
      context['userId'] = userId;
    }

    // 添加平台信息
    context['platform'] = _getPlatformName();
    context['timestamp'] = DateTime.now().millisecondsSinceEpoch;

    // 添加额外的上下文信息
    if (additional != null) {
      context.addAll(additional);
    }

    return context;
  }

  /// 获取平台名称
  String getPlatformName() {
    return _getPlatformName();
  }

  /// 获取应用版本信息
  Future<String> getAppVersion() async {
    try {
      // 这里可以通过package_info_plus获取应用版本
      // 暂时返回默认值
      return '1.0.0';
    } catch (e) {
      debugPrint('获取应用版本失败: $e');
      return '1.0.0';
    }
  }

  /// 获取操作系统版本
  String getOSVersion() {
    try {
      if (Platform.isAndroid) {
        return 'Android ${Platform.operatingSystemVersion}';
      } else if (Platform.isIOS) {
        return 'iOS ${Platform.operatingSystemVersion}';
      } else if (Platform.isWindows) {
        return 'Windows ${Platform.operatingSystemVersion}';
      } else if (Platform.isMacOS) {
        return 'macOS ${Platform.operatingSystemVersion}';
      } else if (Platform.isLinux) {
        return 'Linux ${Platform.operatingSystemVersion}';
      } else {
        return Platform.operatingSystem;
      }
    } catch (e) {
      debugPrint('获取操作系统版本失败: $e');
      return 'Unknown';
    }
  }

  /// 清除缓存
  void clearCache() {
    _cachedDeviceInfo = null;
    _cachedClientIp = null;
    _ipCacheTime = null;
    debugPrint('设备信息缓存已清除');
  }

  /// 收集设备信息
  Future<String> _collectDeviceInfo() async {
    final deviceInfoMap = <String, dynamic>{};

    try {
      // 平台信息
      deviceInfoMap['platform'] = _getPlatformName();
      deviceInfoMap['operatingSystem'] = getOSVersion();

      // 应用信息
      deviceInfoMap['appVersion'] = await getAppVersion();
      deviceInfoMap['flutterVersion'] = 'Flutter';

      // 设备特征信息（不包含敏感信息）
      if (Platform.isAndroid || Platform.isIOS) {
        deviceInfoMap['isMobile'] = true;
      } else {
        deviceInfoMap['isMobile'] = false;
      }

      // 屏幕信息（如果可用）
      if (!kIsWeb) {
        try {
          final view = WidgetsBinding.instance.platformDispatcher.views.first;
          deviceInfoMap['screenWidth'] = view.physicalSize.width;
          deviceInfoMap['screenHeight'] = view.physicalSize.height;
          deviceInfoMap['devicePixelRatio'] = view.devicePixelRatio;
        } catch (e) {
          debugPrint('获取屏幕信息失败: $e');
        }
      }

      // 时区信息
      deviceInfoMap['timeZone'] = DateTime.now().timeZoneName;
      deviceInfoMap['timeZoneOffset'] = DateTime.now().timeZoneOffset.inHours;
    } catch (e) {
      debugPrint('收集设备信息失败: $e');
    }

    // 转换为JSON字符串
    return deviceInfoMap.toString();
  }

  /// 获取平台名称
  String _getPlatformName() {
    if (kIsWeb) {
      return 'Web';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else {
      return 'Unknown';
    }
  }

  /// 获取默认设备信息
  String _getDefaultDeviceInfo() {
    return 'Flutter/${_getPlatformName()}/1.0.0';
  }

  /// 检查IP缓存是否有效
  bool _isIpCacheValid() {
    if (_ipCacheTime == null) return false;
    final now = DateTime.now();
    return now.difference(_ipCacheTime!).compareTo(_ipCacheExpiry) < 0;
  }
}
