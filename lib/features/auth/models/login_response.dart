/// 登录响应模型
/// 
/// 匹配后端LoginResponseDTO的简化响应格式
library;

import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

/// 登录响应模型（匹配后端LoginResponseDTO）
@JsonSerializable()
class LoginResponse {
  /// 访问令牌
  @JsonKey(name: 'token')
  final String token;

  const LoginResponse({
    required this.token,
  });

  /// 从JSON创建
  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  /// 获取Authorization头部值
  String get authorizationHeader => 'Bearer $token';

  /// 检查token是否为空
  bool get hasToken => token.isNotEmpty;

  /// 复制并更新字段
  LoginResponse copyWith({
    String? token,
  }) {
    return LoginResponse(
      token: token ?? this.token,
    );
  }

  @override
  String toString() {
    return 'LoginResponse(token: ${token.isNotEmpty ? '***' : 'empty'})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginResponse && other.token == token;
  }

  @override
  int get hashCode => token.hashCode;
}

/// 扩展的认证响应模型（包含用户信息）
@JsonSerializable()
class ExtendedAuthResponse {
  /// 访问令牌
  @JsonKey(name: 'token')
  final String token;
  
  /// 用户信息（可选，某些接口可能不返回）
  @JsonKey(name: 'user')
  final Map<String, dynamic>? user;
  
  /// 权限信息（可选）
  @JsonKey(name: 'permissions')
  final List<String>? permissions;
  
  /// 角色信息（可选）
  @JsonKey(name: 'roles')
  final List<String>? roles;

  const ExtendedAuthResponse({
    required this.token,
    this.user,
    this.permissions,
    this.roles,
  });

  /// 从JSON创建
  factory ExtendedAuthResponse.fromJson(Map<String, dynamic> json) =>
      _$ExtendedAuthResponseFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$ExtendedAuthResponseToJson(this);

  /// 转换为简单的LoginResponse
  LoginResponse toLoginResponse() {
    return LoginResponse(token: token);
  }

  /// 获取Authorization头部值
  String get authorizationHeader => 'Bearer $token';

  /// 检查是否有用户信息
  bool get hasUserInfo => user != null && user!.isNotEmpty;

  /// 检查是否有权限信息
  bool get hasPermissions => permissions != null && permissions!.isNotEmpty;

  /// 检查是否有角色信息
  bool get hasRoles => roles != null && roles!.isNotEmpty;

  @override
  String toString() {
    return 'ExtendedAuthResponse(token: ${token.isNotEmpty ? '***' : 'empty'}, hasUser: $hasUserInfo)';
  }
}
