/// 验证码相关模型
///
/// 定义验证码获取、验证等相关的数据模型
library;

import 'package:json_annotation/json_annotation.dart';
import 'auth_enums.dart';

part 'captcha_model.g.dart';

/// 验证码信息
@JsonSerializable()
class CaptchaInfo {
  /// 会话ID
  @JsonKey(name: 'sessionId')
  final String sessionId;

  /// 验证码图片(Base64编码)
  @JsonKey(name: 'imageBase64')
  final String imageBase64;

  /// 过期秒数
  @JsonKey(name: 'expireSeconds')
  final int expireSeconds;

  /// 验证码长度
  @JsonKey(name: 'length')
  final int length;

  /// 验证码类型
  @JsonKey(name: 'type')
  final CaptchaTypeEnum type;

  /// 创建时间
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  CaptchaInfo({
    required this.sessionId,
    required this.imageBase64,
    required this.expireSeconds,
    this.length = 4,
    this.type = CaptchaTypeEnum.image,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 过期时间（计算得出）
  DateTime get expiresAt => createdAt.add(Duration(seconds: expireSeconds));

  /// 从JSON创建
  factory CaptchaInfo.fromJson(Map<String, dynamic> json) =>
      _$CaptchaInfoFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$CaptchaInfoToJson(this);

  /// 是否已过期
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// 是否即将过期（30秒内）
  bool get isExpiringSoon {
    final now = DateTime.now();
    final thirtySecondsLater = now.add(const Duration(seconds: 30));
    return expiresAt.isBefore(thirtySecondsLater);
  }

  /// 剩余有效时间（秒）
  int get remainingSeconds {
    final now = DateTime.now();
    if (isExpired) return 0;
    return expiresAt.difference(now).inSeconds;
  }

  /// 获取图片数据URL（用于显示）
  String get imageDataUrl => imageBase64;

  /// 复制并更新部分字段
  CaptchaInfo copyWith({
    String? sessionId,
    String? imageBase64,
    int? expireSeconds,
    int? length,
    CaptchaTypeEnum? type,
    DateTime? createdAt,
  }) {
    return CaptchaInfo(
      sessionId: sessionId ?? this.sessionId,
      imageBase64: imageBase64 ?? this.imageBase64,
      expireSeconds: expireSeconds ?? this.expireSeconds,
      length: length ?? this.length,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'CaptchaInfo(sessionId: $sessionId, type: $type, length: $length, isExpired: $isExpired)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CaptchaInfo && other.sessionId == sessionId;
  }

  @override
  int get hashCode => sessionId.hashCode;
}

/// 验证码获取请求
@JsonSerializable()
class CaptchaRequest {
  /// 验证码类型
  @JsonKey(name: 'type')
  final CaptchaTypeEnum type;

  /// 验证码长度
  @JsonKey(name: 'length')
  final int length;

  /// 宽度（图形验证码）
  @JsonKey(name: 'width')
  final int? width;

  /// 高度（图形验证码）
  @JsonKey(name: 'height')
  final int? height;

  /// 手机号（短信验证码）
  @JsonKey(name: 'phone')
  final String? phone;

  /// 邮箱（邮箱验证码）
  @JsonKey(name: 'email')
  final String? email;

  const CaptchaRequest({
    this.type = CaptchaTypeEnum.image,
    this.length = 4,
    this.width,
    this.height,
    this.phone,
    this.email,
  });

  /// 从JSON创建
  factory CaptchaRequest.fromJson(Map<String, dynamic> json) =>
      _$CaptchaRequestFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$CaptchaRequestToJson(this);

  /// 创建图形验证码请求
  factory CaptchaRequest.image({
    int length = 4,
    int width = 120,
    int height = 40,
  }) {
    return CaptchaRequest(
      type: CaptchaTypeEnum.image,
      length: length,
      width: width,
      height: height,
    );
  }

  /// 创建短信验证码请求
  factory CaptchaRequest.sms({required String phone, int length = 6}) {
    return CaptchaRequest(
      type: CaptchaTypeEnum.sms,
      length: length,
      phone: phone,
    );
  }

  /// 创建邮箱验证码请求
  factory CaptchaRequest.email({required String email, int length = 6}) {
    return CaptchaRequest(
      type: CaptchaTypeEnum.email,
      length: length,
      email: email,
    );
  }

  /// 验证请求参数
  bool validate() {
    switch (type) {
      case CaptchaTypeEnum.image:
        return length > 0 && (width ?? 0) > 0 && (height ?? 0) > 0;
      case CaptchaTypeEnum.sms:
        return phone != null && phone!.isNotEmpty && length > 0;
      case CaptchaTypeEnum.email:
        return email != null && email!.isNotEmpty && length > 0;
      case CaptchaTypeEnum.voice:
        return phone != null && phone!.isNotEmpty && length > 0;
    }
  }

  @override
  String toString() {
    return 'CaptchaRequest(type: $type, length: $length)';
  }
}

/// 验证码验证请求
@JsonSerializable()
class CaptchaVerifyRequest {
  /// 会话ID
  @JsonKey(name: 'sessionId')
  final String sessionId;

  /// 验证码
  @JsonKey(name: 'code')
  final String code;

  /// 验证码类型
  @JsonKey(name: 'type')
  final CaptchaTypeEnum type;

  const CaptchaVerifyRequest({
    required this.sessionId,
    required this.code,
    this.type = CaptchaTypeEnum.image,
  });

  /// 从JSON创建
  factory CaptchaVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$CaptchaVerifyRequestFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$CaptchaVerifyRequestToJson(this);

  /// 验证请求参数
  bool validate() {
    return sessionId.isNotEmpty && code.isNotEmpty;
  }

  @override
  String toString() {
    return 'CaptchaVerifyRequest(sessionId: $sessionId, type: $type)';
  }
}
