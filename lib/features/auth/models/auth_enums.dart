/// 认证相关枚举定义
/// 
/// 定义认证模块中使用的各种枚举类型
library;

import 'package:json_annotation/json_annotation.dart';

/// 认证类型枚举
enum AuthTypeEnum {
  @JsonValue('USERNAME_PASSWORD')
  usernamePassword('USERNAME_PASSWORD', '用户名密码认证'),
  
  @JsonValue('PHONE_PASSWORD')
  phonePassword('PHONE_PASSWORD', '手机号密码认证'),
  
  @JsonValue('EMAIL_PASSWORD')
  emailPassword('EMAIL_PASSWORD', '邮箱密码认证'),
  
  @JsonValue('PHONE_CODE')
  phoneCode('PHONE_CODE', '手机验证码认证'),
  
  @JsonValue('EMAIL_CODE')
  emailCode('EMAIL_CODE', '邮箱验证码认证');

  const AuthTypeEnum(this.value, this.description);
  
  /// 枚举值
  final String value;
  
  /// 描述信息
  final String description;
  
  /// 从字符串值获取枚举
  static AuthTypeEnum? fromValue(String value) {
    for (final type in AuthTypeEnum.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

/// 认证结果状态枚举
enum AuthResultStatus {
  @JsonValue('SUCCESS')
  success('SUCCESS', '认证成功'),
  
  @JsonValue('FAILED')
  failed('FAILED', '认证失败'),
  
  @JsonValue('CAPTCHA_ERROR')
  captchaError('CAPTCHA_ERROR', '验证码错误'),
  
  @JsonValue('USER_NOT_FOUND')
  userNotFound('USER_NOT_FOUND', '用户不存在'),
  
  @JsonValue('PASSWORD_ERROR')
  passwordError('PASSWORD_ERROR', '密码错误'),
  
  @JsonValue('ACCOUNT_LOCKED')
  accountLocked('ACCOUNT_LOCKED', '账户被锁定'),
  
  @JsonValue('ACCOUNT_DISABLED')
  accountDisabled('ACCOUNT_DISABLED', '账户被禁用'),
  
  @JsonValue('TOKEN_EXPIRED')
  tokenExpired('TOKEN_EXPIRED', 'Token已过期'),
  
  @JsonValue('NETWORK_ERROR')
  networkError('NETWORK_ERROR', '网络错误'),
  
  @JsonValue('UNKNOWN_ERROR')
  unknownError('UNKNOWN_ERROR', '未知错误');

  const AuthResultStatus(this.value, this.description);
  
  /// 枚举值
  final String value;
  
  /// 描述信息
  final String description;
  
  /// 从字符串值获取枚举
  static AuthResultStatus? fromValue(String value) {
    for (final status in AuthResultStatus.values) {
      if (status.value == value) return status;
    }
    return null;
  }
}

/// 验证码类型枚举
enum CaptchaTypeEnum {
  @JsonValue('IMAGE')
  image('IMAGE', '图形验证码'),
  
  @JsonValue('SMS')
  sms('SMS', '短信验证码'),
  
  @JsonValue('EMAIL')
  email('EMAIL', '邮箱验证码'),
  
  @JsonValue('VOICE')
  voice('VOICE', '语音验证码');

  const CaptchaTypeEnum(this.value, this.description);
  
  /// 枚举值
  final String value;
  
  /// 描述信息
  final String description;
  
  /// 从字符串值获取枚举
  static CaptchaTypeEnum? fromValue(String value) {
    for (final type in CaptchaTypeEnum.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}
