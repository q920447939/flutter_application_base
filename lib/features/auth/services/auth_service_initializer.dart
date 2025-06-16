/// 认证服务初始化器
/// 
/// 负责初始化认证相关的所有服务和依赖
library;

import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'auth_manager.dart';
import 'captcha_service.dart';
import 'device_info_service.dart';
import '../config/auth_config.dart';

/// 认证服务初始化器
class AuthServiceInitializer {
  static bool _initialized = false;
  
  /// 是否已初始化
  static bool get isInitialized => _initialized;

  /// 初始化认证服务
  static Future<void> initialize() async {
    if (_initialized) {
      debugPrint('认证服务已经初始化，跳过重复初始化');
      return;
    }

    try {
      debugPrint('开始初始化认证服务...');
      
      // 1. 注册配置管理器
      if (!Get.isRegistered<AuthConfigManager>()) {
        Get.put<AuthConfigManager>(AuthConfigManager(), permanent: true);
        debugPrint('✓ 认证配置管理器注册完成');
      }

      // 2. 注册设备信息服务
      if (!Get.isRegistered<DeviceInfoService>()) {
        Get.put<DeviceInfoService>(DeviceInfoService(), permanent: true);
        debugPrint('✓ 设备信息服务注册完成');
      }

      // 3. 注册验证码服务
      if (!Get.isRegistered<CaptchaService>()) {
        Get.put<CaptchaService>(CaptchaService(), permanent: true);
        debugPrint('✓ 验证码服务注册完成');
      }

      // 4. 注册认证管理器
      if (!Get.isRegistered<AuthManager>()) {
        Get.put<AuthManager>(AuthManager(), permanent: true);
        debugPrint('✓ 认证管理器注册完成');
      }

      // 5. 注册认证服务（保持单例模式兼容）
      if (!Get.isRegistered<AuthService>()) {
        Get.put<AuthService>(AuthService.instance, permanent: true);
        debugPrint('✓ 认证服务注册完成');
      }

      // 6. 初始化认证服务
      await AuthService.instance.initialize();
      debugPrint('✓ 认证服务初始化完成');

      _initialized = true;
      debugPrint('🎉 认证服务模块初始化成功');
      
    } catch (e) {
      debugPrint('❌ 认证服务初始化失败: $e');
      rethrow;
    }
  }

  /// 重新初始化认证服务
  static Future<void> reinitialize() async {
    debugPrint('重新初始化认证服务...');
    _initialized = false;
    await initialize();
  }

  /// 清理认证服务
  static Future<void> cleanup() async {
    try {
      debugPrint('开始清理认证服务...');

      // 清理认证服务
      if (Get.isRegistered<AuthService>()) {
        await AuthService.instance.logout();
        Get.delete<AuthService>();
        debugPrint('✓ 认证服务清理完成');
      }

      // 清理认证管理器
      if (Get.isRegistered<AuthManager>()) {
        Get.delete<AuthManager>();
        debugPrint('✓ 认证管理器清理完成');
      }

      // 清理验证码服务
      if (Get.isRegistered<CaptchaService>()) {
        CaptchaService.instance.clearAllCaptcha();
        Get.delete<CaptchaService>();
        debugPrint('✓ 验证码服务清理完成');
      }

      // 清理设备信息服务
      if (Get.isRegistered<DeviceInfoService>()) {
        DeviceInfoService.instance.clearCache();
        Get.delete<DeviceInfoService>();
        debugPrint('✓ 设备信息服务清理完成');
      }

      // 清理配置管理器
      if (Get.isRegistered<AuthConfigManager>()) {
        Get.delete<AuthConfigManager>();
        debugPrint('✓ 认证配置管理器清理完成');
      }

      _initialized = false;
      debugPrint('🧹 认证服务模块清理完成');
      
    } catch (e) {
      debugPrint('❌ 认证服务清理失败: $e');
    }
  }

  /// 检查服务状态
  static Map<String, bool> checkServiceStatus() {
    return {
      'initialized': _initialized,
      'auth_config_manager': Get.isRegistered<AuthConfigManager>(),
      'device_info_service': Get.isRegistered<DeviceInfoService>(),
      'captcha_service': Get.isRegistered<CaptchaService>(),
      'auth_manager': Get.isRegistered<AuthManager>(),
      'auth_service': Get.isRegistered<AuthService>(),
    };
  }

  /// 获取服务状态报告
  static String getStatusReport() {
    final status = checkServiceStatus();
    final buffer = StringBuffer();
    
    buffer.writeln('认证服务状态报告:');
    buffer.writeln('==================');
    
    status.forEach((service, isRegistered) {
      final icon = isRegistered ? '✓' : '✗';
      buffer.writeln('$icon $service: ${isRegistered ? '已注册' : '未注册'}');
    });
    
    buffer.writeln('==================');
    
    return buffer.toString();
  }

  /// 验证所有服务是否正常
  static bool validateServices() {
    final status = checkServiceStatus();
    return status.values.every((isRegistered) => isRegistered);
  }

  /// 获取服务实例（用于调试）
  static Map<String, dynamic> getServiceInstances() {
    final instances = <String, dynamic>{};
    
    if (Get.isRegistered<AuthConfigManager>()) {
      instances['auth_config_manager'] = AuthConfigManager.instance;
    }
    
    if (Get.isRegistered<DeviceInfoService>()) {
      instances['device_info_service'] = DeviceInfoService.instance;
    }
    
    if (Get.isRegistered<CaptchaService>()) {
      instances['captcha_service'] = CaptchaService.instance;
    }
    
    if (Get.isRegistered<AuthManager>()) {
      instances['auth_manager'] = AuthManager.instance;
    }
    
    if (Get.isRegistered<AuthService>()) {
      instances['auth_service'] = AuthService.instance;
    }
    
    return instances;
  }
}
