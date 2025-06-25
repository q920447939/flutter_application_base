/// 认证令牌表定义
/// 
/// 用于存储用户的访问令牌和刷新令牌
library;

import 'package:drift/drift.dart';

/// 认证令牌表
class AuthTokens extends Table {
  /// 令牌ID - 主键，自增
  IntColumn get id => integer().autoIncrement()();
  
  /// 用户ID - 外键关联用户表
  TextColumn get userId => text()();
  
  /// 访问令牌
  TextColumn get accessToken => text()();
  
  /// 刷新令牌 - 可选
  TextColumn get refreshToken => text().nullable()();
  
  /// 令牌类型 - 默认为 'Bearer'
  TextColumn get tokenType => text().withDefault(const Constant('Bearer'))();
  
  /// 过期时间（秒）
  IntColumn get expiresIn => integer()();
  
  /// 令牌创建时间
  DateTimeColumn get issuedAt => dateTime().withDefault(currentDateAndTime)();
  
  /// 令牌过期时间
  DateTimeColumn get expiresAt => dateTime()();
  
  /// 是否为活跃令牌
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  /// 设备信息 - 可选，用于标识令牌来源设备
  TextColumn get deviceInfo => text().nullable()();
  
  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  /// 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  String get tableName => 'auth_tokens';
}
