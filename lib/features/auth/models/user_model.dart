/// 用户模型
/// 
/// 定义用户相关的数据模型
library;

import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// 用户性别枚举
enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('other')
  other,
}

/// 用户状态枚举
enum UserStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('suspended')
  suspended,
  @JsonValue('deleted')
  deleted,
}

/// 用户模型
@JsonSerializable()
class UserModel {
  /// 用户ID
  final String id;
  
  /// 用户名
  final String? username;
  
  /// 邮箱
  final String? email;
  
  /// 手机号
  final String? phone;
  
  /// 昵称
  final String? nickname;
  
  /// 头像URL
  final String? avatar;
  
  /// 性别
  final Gender? gender;
  
  /// 生日
  final DateTime? birthday;
  
  /// 地址
  final String? address;
  
  /// 个人简介
  final String? bio;
  
  /// 用户状态
  final UserStatus status;
  
  /// 是否已验证邮箱
  final bool emailVerified;
  
  /// 是否已验证手机号
  final bool phoneVerified;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;
  
  /// 最后登录时间
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    this.username,
    this.email,
    this.phone,
    this.nickname,
    this.avatar,
    this.gender,
    this.birthday,
    this.address,
    this.bio,
    this.status = UserStatus.active,
    this.emailVerified = false,
    this.phoneVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  /// 从JSON创建用户模型
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// 复制并更新部分字段
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? nickname,
    String? avatar,
    Gender? gender,
    DateTime? birthday,
    String? address,
    String? bio,
    UserStatus? status,
    bool? emailVerified,
    bool? phoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      status: status ?? this.status,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// 获取显示名称
  String get displayName {
    if (nickname != null && nickname!.isNotEmpty) {
      return nickname!;
    }
    if (username != null && username!.isNotEmpty) {
      return username!;
    }
    if (email != null && email!.isNotEmpty) {
      return email!.split('@').first;
    }
    if (phone != null && phone!.isNotEmpty) {
      return phone!;
    }
    return 'User';
  }

  /// 获取头像显示文本
  String get avatarText {
    final name = displayName;
    if (name.isNotEmpty) {
      // 如果是中文，取第一个字符
      if (name.contains(RegExp(r'[\u4e00-\u9fa5]'))) {
        return name.substring(0, 1);
      }
      // 如果是英文，取首字母
      return name.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  /// 是否为活跃用户
  bool get isActive => status == UserStatus.active;

  /// 是否已完成基本信息
  bool get hasBasicInfo {
    return nickname != null && 
           nickname!.isNotEmpty && 
           (email != null || phone != null);
  }

  /// 获取年龄
  int? get age {
    if (birthday == null) return null;
    final now = DateTime.now();
    int age = now.year - birthday!.year;
    if (now.month < birthday!.month || 
        (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return age;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, nickname: $nickname)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 登录请求模型
@JsonSerializable()
class LoginRequest {
  /// 登录标识（邮箱或手机号）
  final String identifier;
  
  /// 密码
  final String password;
  
  /// 记住登录状态
  final bool rememberMe;

  const LoginRequest({
    required this.identifier,
    required this.password,
    this.rememberMe = false,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

/// 注册请求模型
@JsonSerializable()
class RegisterRequest {
  /// 用户名
  final String? username;
  
  /// 邮箱
  final String? email;
  
  /// 手机号
  final String? phone;
  
  /// 密码
  final String password;
  
  /// 确认密码
  final String confirmPassword;
  
  /// 昵称
  final String? nickname;
  
  /// 验证码
  final String? verificationCode;

  const RegisterRequest({
    this.username,
    this.email,
    this.phone,
    required this.password,
    required this.confirmPassword,
    this.nickname,
    this.verificationCode,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

/// 认证响应模型
@JsonSerializable()
class AuthResponse {
  /// 访问令牌
  final String accessToken;
  
  /// 刷新令牌
  final String? refreshToken;
  
  /// 令牌类型
  final String tokenType;
  
  /// 过期时间（秒）
  final int expiresIn;
  
  /// 用户信息
  final UserModel user;

  const AuthResponse({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  /// 获取完整的Authorization头
  String get authorizationHeader => '$tokenType $accessToken';

  /// 检查令牌是否即将过期（30分钟内）
  bool get isTokenExpiringSoon {
    return expiresIn < 1800; // 30分钟 = 1800秒
  }
}
