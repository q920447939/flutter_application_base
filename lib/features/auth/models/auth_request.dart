/// 认证请求模型
///
/// 定义各种认证请求的数据模型，匹配后端接口格式
library;

import 'package:json_annotation/json_annotation.dart';
import 'auth_enums.dart';

part 'auth_request.g.dart';

/// 认证请求基类
abstract class BaseAuthRequest {
  /// 认证类型
  @JsonKey(name: 'authType')
  final AuthTypeEnum authType;

  /// 设备信息
  @JsonKey(name: 'deviceInfo')
  final String? deviceInfo;

  /// 客户端IP
  @JsonKey(name: 'clientIp')
  final String? clientIp;

  /// 上下文信息（用于传递租户ID、域ID等信息）
  @JsonKey(name: 'context')
  final Map<String, Object>? context;

  const BaseAuthRequest({
    required this.authType,
    this.deviceInfo,
    this.clientIp,
    this.context,
  });

  /// 转换为JSON（子类需要实现）
  Map<String, dynamic> toJson();

  /// 验证请求参数（子类可以重写）
  bool validate() {
    return true;
  }
}

/// 用户名密码认证请求
@JsonSerializable()
class UsernamePasswordAuthRequest extends BaseAuthRequest {
  /// 用户名 (6-30位)
  @JsonKey(name: 'username')
  final String username;

  /// 密码
  @JsonKey(name: 'password')
  final String password;

  /// 图形验证码 (4-6位)
  @JsonKey(name: 'captcha')
  final String captcha;

  /// 验证码会话ID
  @JsonKey(name: 'captchaSessionId')
  final String captchaSessionId;

  const UsernamePasswordAuthRequest({
    required this.username,
    required this.password,
    required this.captcha,
    required this.captchaSessionId,
    String? deviceInfo,
    String? clientIp,
    Map<String, Object>? context,
  }) : super(
         authType: AuthTypeEnum.usernamePassword,
         deviceInfo: deviceInfo,
         clientIp: clientIp,
         context: context,
       );

  /// 从JSON创建
  factory UsernamePasswordAuthRequest.fromJson(Map<String, dynamic> json) =>
      _$UsernamePasswordAuthRequestFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$UsernamePasswordAuthRequestToJson(this);

  /// 验证请求参数
  @override
  bool validate() {
    return username.isNotEmpty &&
        username.length >= 6 &&
        username.length <= 30 &&
        password.isNotEmpty &&
        captcha.isNotEmpty &&
        captcha.length >= 4 &&
        captcha.length <= 6 &&
        captchaSessionId.isNotEmpty;
  }

  /// 复制并更新部分字段
  UsernamePasswordAuthRequest copyWith({
    String? username,
    String? password,
    String? captcha,
    String? captchaSessionId,
    String? deviceInfo,
    String? clientIp,
    Map<String, Object>? context,
  }) {
    return UsernamePasswordAuthRequest(
      username: username ?? this.username,
      password: password ?? this.password,
      captcha: captcha ?? this.captcha,
      captchaSessionId: captchaSessionId ?? this.captchaSessionId,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      clientIp: clientIp ?? this.clientIp,
      context: context ?? this.context,
    );
  }

  @override
  String toString() {
    return 'UsernamePasswordAuthRequest(username: $username, captchaSessionId: $captchaSessionId)';
  }
}

/// 手机号密码认证请求
@JsonSerializable()
class PhonePasswordAuthRequest extends BaseAuthRequest {
  /// 手机号
  @JsonKey(name: 'phone')
  final String phone;

  /// 密码
  @JsonKey(name: 'password')
  final String password;

  /// 图形验证码
  @JsonKey(name: 'captcha')
  final String captcha;

  /// 验证码会话ID
  @JsonKey(name: 'captchaSessionId')
  final String captchaSessionId;

  const PhonePasswordAuthRequest({
    required this.phone,
    required this.password,
    required this.captcha,
    required this.captchaSessionId,
    String? deviceInfo,
    String? clientIp,
    Map<String, Object>? context,
  }) : super(
         authType: AuthTypeEnum.phonePassword,
         deviceInfo: deviceInfo,
         clientIp: clientIp,
         context: context,
       );

  /// 从JSON创建
  factory PhonePasswordAuthRequest.fromJson(Map<String, dynamic> json) =>
      _$PhonePasswordAuthRequestFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$PhonePasswordAuthRequestToJson(this);

  /// 验证请求参数
  @override
  bool validate() {
    // 简单的手机号验证（11位数字）
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    return phoneRegex.hasMatch(phone) &&
        password.isNotEmpty &&
        captcha.isNotEmpty &&
        captcha.length >= 4 &&
        captcha.length <= 6 &&
        captchaSessionId.isNotEmpty;
  }

  @override
  String toString() {
    return 'PhonePasswordAuthRequest(phone: $phone, captchaSessionId: $captchaSessionId)';
  }
}

/// 邮箱密码认证请求
@JsonSerializable()
class EmailPasswordAuthRequest extends BaseAuthRequest {
  /// 邮箱
  @JsonKey(name: 'email')
  final String email;

  /// 密码
  @JsonKey(name: 'password')
  final String password;

  /// 图形验证码
  @JsonKey(name: 'captcha')
  final String captcha;

  /// 验证码会话ID
  @JsonKey(name: 'captchaSessionId')
  final String captchaSessionId;

  const EmailPasswordAuthRequest({
    required this.email,
    required this.password,
    required this.captcha,
    required this.captchaSessionId,
    String? deviceInfo,
    String? clientIp,
    Map<String, Object>? context,
  }) : super(
         authType: AuthTypeEnum.emailPassword,
         deviceInfo: deviceInfo,
         clientIp: clientIp,
         context: context,
       );

  /// 从JSON创建
  factory EmailPasswordAuthRequest.fromJson(Map<String, dynamic> json) =>
      _$EmailPasswordAuthRequestFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$EmailPasswordAuthRequestToJson(this);

  /// 验证请求参数
  @override
  bool validate() {
    // 简单的邮箱验证
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email) &&
        password.isNotEmpty &&
        captcha.isNotEmpty &&
        captcha.length >= 4 &&
        captcha.length <= 6 &&
        captchaSessionId.isNotEmpty;
  }

  @override
  String toString() {
    return 'EmailPasswordAuthRequest(email: $email, captchaSessionId: $captchaSessionId)';
  }
}
