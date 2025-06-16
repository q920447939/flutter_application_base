/// 认证配置管理
///
/// 管理认证相关的配置信息，包括端点、超时时间、重试次数等
library;

import 'package:get/get.dart';
import '../models/auth_enums.dart';

/// 认证配置类
class AuthConfig {
  /// 认证基础路径
  static const String baseAuthPath = '/api/auth';

  /// 验证码过期时间
  static const Duration captchaExpiry = Duration(minutes: 5);

  /// 最大登录尝试次数
  static const int maxLoginAttempts = 5;

  /// 认证超时时间
  static const Duration authTimeout = Duration(seconds: 30);

  /// Token刷新提前时间（提前5分钟刷新）
  static const Duration tokenRefreshAdvance = Duration(minutes: 5);

  /// 密码最小长度
  static const int passwordMinLength = 6;

  /// 密码最大长度
  static const int passwordMaxLength = 50;

  /// 用户名最小长度
  static const int usernameMinLength = 6;

  /// 用户名最大长度
  static const int usernameMaxLength = 30;

  /// 验证码最小长度
  static const int captchaMinLength = 4;

  /// 验证码最大长度
  static const int captchaMaxLength = 6;

  /// 认证端点映射
  static const Map<AuthTypeEnum, String> endpoints = {
    AuthTypeEnum.usernamePassword: '$baseAuthPath/login/username',
    AuthTypeEnum.phonePassword: '$baseAuthPath/login/phone',
    AuthTypeEnum.emailPassword: '$baseAuthPath/login/email',
    AuthTypeEnum.phoneCode: '$baseAuthPath/login/phone-code',
    AuthTypeEnum.emailCode: '$baseAuthPath/login/email-code',
  };

  /// 验证码端点
  static const Map<String, String> captchaEndpoints = {
    'get': '$baseAuthPath/captcha',
    'refresh': '$baseAuthPath/captcha/refresh',
    'verify': '$baseAuthPath/captcha/verify',
    'sms': '$baseAuthPath/captcha/sms',
    'email': '$baseAuthPath/captcha/email',
  };

  /// 其他认证相关端点
  static const Map<String, String> authEndpoints = {
    'logout': '$baseAuthPath/logout',
    'refresh': '$baseAuthPath/refresh',
    'register': '$baseAuthPath/register',
    'forgot-password': '$baseAuthPath/forgot-password',
    'reset-password': '$baseAuthPath/reset-password',
    'change-password': '$baseAuthPath/change-password',
    'profile': '$baseAuthPath/profile',
  };

  /// 获取认证端点
  static String getAuthEndpoint(AuthTypeEnum authType) {
    return endpoints[authType] ?? '$baseAuthPath/login';
  }

  /// 获取验证码端点
  static String getCaptchaEndpoint(String type) {
    return captchaEndpoints[type] ?? '$baseAuthPath/captcha';
  }

  /// 获取其他端点
  static String getEndpoint(String type) {
    return authEndpoints[type] ?? baseAuthPath;
  }
}

/// 认证配置管理器
class AuthConfigManager extends GetxController {
  static AuthConfigManager get instance => Get.find<AuthConfigManager>();

  /// 动态配置存储
  final RxMap<String, dynamic> _dynamicConfig = <String, dynamic>{}.obs;

  /// 是否启用动态配置
  final RxBool _enableDynamicConfig = false.obs;

  /// 是否启用动态配置
  bool get enableDynamicConfig => _enableDynamicConfig.value;

  @override
  void onInit() {
    super.onInit();
    _loadDefaultConfig();
  }

  /// 获取认证端点
  String getAuthEndpoint(AuthTypeEnum authType) {
    if (_enableDynamicConfig.value) {
      final key = 'auth_endpoint_${authType.value}';
      return _dynamicConfig[key] ?? AuthConfig.getAuthEndpoint(authType);
    }
    return AuthConfig.getAuthEndpoint(authType);
  }

  /// 获取验证码端点
  String getCaptchaEndpoint(String type) {
    if (_enableDynamicConfig.value) {
      final key = 'captcha_endpoint_$type';
      return _dynamicConfig[key] ?? AuthConfig.getCaptchaEndpoint(type);
    }
    return AuthConfig.getCaptchaEndpoint(type);
  }

  /// 获取其他端点
  String getEndpoint(String type) {
    if (_enableDynamicConfig.value) {
      final key = 'endpoint_$type';
      return _dynamicConfig[key] ?? AuthConfig.getEndpoint(type);
    }
    return AuthConfig.getEndpoint(type);
  }

  /// 获取验证码过期时间
  Duration getCaptchaExpiry() {
    if (_enableDynamicConfig.value) {
      final minutes = _dynamicConfig['captcha_expiry_minutes'] as int?;
      if (minutes != null) {
        return Duration(minutes: minutes);
      }
    }
    return AuthConfig.captchaExpiry;
  }

  /// 获取最大登录尝试次数
  int getMaxLoginAttempts() {
    if (_enableDynamicConfig.value) {
      return _dynamicConfig['max_login_attempts'] as int? ??
          AuthConfig.maxLoginAttempts;
    }
    return AuthConfig.maxLoginAttempts;
  }

  /// 获取认证超时时间
  Duration getAuthTimeout() {
    if (_enableDynamicConfig.value) {
      final seconds = _dynamicConfig['auth_timeout_seconds'] as int?;
      if (seconds != null) {
        return Duration(seconds: seconds);
      }
    }
    return AuthConfig.authTimeout;
  }

  /// 获取密码最小长度
  int getPasswordMinLength() {
    if (_enableDynamicConfig.value) {
      return _dynamicConfig['password_min_length'] as int? ??
          AuthConfig.passwordMinLength;
    }
    return AuthConfig.passwordMinLength;
  }

  /// 检查是否启用密码复杂度验证
  bool isPasswordComplexityEnabled() {
    if (_enableDynamicConfig.value) {
      return _dynamicConfig['enable_password_complexity'] as bool? ?? false;
    }
    return false; // 默认不启用复杂度验证
  }

  /// 获取密码最大长度
  int getPasswordMaxLength() {
    if (_enableDynamicConfig.value) {
      return _dynamicConfig['password_max_length'] as int? ??
          AuthConfig.passwordMaxLength;
    }
    return AuthConfig.passwordMaxLength;
  }

  /// 获取用户名最小长度
  int getUsernameMinLength() {
    if (_enableDynamicConfig.value) {
      return _dynamicConfig['username_min_length'] as int? ??
          AuthConfig.usernameMinLength;
    }
    return AuthConfig.usernameMinLength;
  }

  /// 获取用户名最大长度
  int getUsernameMaxLength() {
    if (_enableDynamicConfig.value) {
      return _dynamicConfig['username_max_length'] as int? ??
          AuthConfig.usernameMaxLength;
    }
    return AuthConfig.usernameMaxLength;
  }

  /// 更新动态配置
  void updateConfig(Map<String, dynamic> config) {
    _dynamicConfig.addAll(config);
  }

  /// 设置配置项
  void setConfigValue(String key, dynamic value) {
    _dynamicConfig[key] = value;
  }

  /// 获取配置项
  T? getConfigValue<T>(String key) {
    return _dynamicConfig[key] as T?;
  }

  /// 启用动态配置
  void setDynamicConfigEnabled(bool enabled) {
    _enableDynamicConfig.value = enabled;
  }

  /// 禁用动态配置
  void disableDynamicConfig() {
    _enableDynamicConfig.value = false;
  }

  /// 重置为默认配置
  void resetToDefault() {
    _dynamicConfig.clear();
    _enableDynamicConfig.value = false;
    _loadDefaultConfig();
  }

  /// 获取所有配置
  Map<String, dynamic> getAllConfig() {
    final config = <String, dynamic>{};

    // 添加静态配置
    config.addAll({
      'base_auth_path': AuthConfig.baseAuthPath,
      'captcha_expiry_minutes': AuthConfig.captchaExpiry.inMinutes,
      'max_login_attempts': AuthConfig.maxLoginAttempts,
      'auth_timeout_seconds': AuthConfig.authTimeout.inSeconds,
      'password_min_length': AuthConfig.passwordMinLength,
      'password_max_length': AuthConfig.passwordMaxLength,
      'username_min_length': AuthConfig.usernameMinLength,
      'username_max_length': AuthConfig.usernameMaxLength,
      'captcha_min_length': AuthConfig.captchaMinLength,
      'captcha_max_length': AuthConfig.captchaMaxLength,
    });

    // 添加端点配置
    AuthConfig.endpoints.forEach((authType, endpoint) {
      config['auth_endpoint_${authType.value}'] = endpoint;
    });

    AuthConfig.captchaEndpoints.forEach((type, endpoint) {
      config['captcha_endpoint_$type'] = endpoint;
    });

    AuthConfig.authEndpoints.forEach((type, endpoint) {
      config['endpoint_$type'] = endpoint;
    });

    // 添加动态配置（覆盖静态配置）
    if (_enableDynamicConfig.value) {
      config.addAll(_dynamicConfig);
    }

    return config;
  }

  /// 加载默认配置
  void _loadDefaultConfig() {
    // 这里可以从本地存储或远程配置中心加载配置
    // 暂时使用空实现
  }
}
