/// 用户数据库实体
/// 
/// 用于数据库层的用户数据模型
library;

import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../../../features/auth/models/user_model.dart';

/// 用户数据库实体
class UserEntity {
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
  final String? gender;
  
  /// 生日
  final DateTime? birthday;
  
  /// 地址
  final String? address;
  
  /// 个人简介
  final String? bio;
  
  /// 用户状态
  final String status;
  
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

  const UserEntity({
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
    this.status = 'active',
    this.emailVerified = false,
    this.phoneVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  /// 从Drift数据行创建实体
  factory UserEntity.fromRow(QueryRow row) {
    return UserEntity(
      id: row.read<String>('id'),
      username: row.readNullable<String>('username'),
      email: row.readNullable<String>('email'),
      phone: row.readNullable<String>('phone'),
      nickname: row.readNullable<String>('nickname'),
      avatar: row.readNullable<String>('avatar'),
      gender: row.readNullable<String>('gender'),
      birthday: row.readNullable<DateTime>('birthday'),
      address: row.readNullable<String>('address'),
      bio: row.readNullable<String>('bio'),
      status: row.read<String>('status'),
      emailVerified: row.read<bool>('email_verified'),
      phoneVerified: row.read<bool>('phone_verified'),
      createdAt: row.read<DateTime>('created_at'),
      updatedAt: row.read<DateTime>('updated_at'),
      lastLoginAt: row.readNullable<DateTime>('last_login_at'),
    );
  }

  /// 从业务模型创建实体
  factory UserEntity.fromUserModel(UserModel userModel) {
    return UserEntity(
      id: userModel.id,
      username: userModel.username,
      email: userModel.email,
      phone: userModel.phone,
      nickname: userModel.nickname,
      avatar: userModel.avatar,
      gender: userModel.gender?.name,
      birthday: userModel.birthday,
      address: userModel.address,
      bio: userModel.bio,
      status: userModel.status.name,
      emailVerified: userModel.emailVerified,
      phoneVerified: userModel.phoneVerified,
      createdAt: userModel.createdAt,
      updatedAt: userModel.updatedAt,
      lastLoginAt: userModel.lastLoginAt,
    );
  }

  /// 转换为业务模型
  UserModel toUserModel() {
    return UserModel(
      id: id,
      username: username,
      email: email,
      phone: phone,
      nickname: nickname,
      avatar: avatar,
      gender: gender != null ? Gender.values.firstWhere(
        (g) => g.name == gender,
        orElse: () => Gender.male,
      ) : null,
      birthday: birthday,
      address: address,
      bio: bio,
      status: UserStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => UserStatus.active,
      ),
      emailVerified: emailVerified,
      phoneVerified: phoneVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
    );
  }

  /// 转换为Drift Companion
  UsersCompanion toCompanion() {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      email: Value(email),
      phone: Value(phone),
      nickname: Value(nickname),
      avatar: Value(avatar),
      gender: Value(gender),
      birthday: Value(birthday),
      address: Value(address),
      bio: Value(bio),
      status: Value(status),
      emailVerified: Value(emailVerified),
      phoneVerified: Value(phoneVerified),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastLoginAt: Value(lastLoginAt),
    );
  }

  /// 复制并更新部分字段
  UserEntity copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? nickname,
    String? avatar,
    String? gender,
    DateTime? birthday,
    String? address,
    String? bio,
    String? status,
    bool? emailVerified,
    bool? phoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserEntity(
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

  @override
  String toString() {
    return 'UserEntity(id: $id, username: $username, email: $email, nickname: $nickname)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
