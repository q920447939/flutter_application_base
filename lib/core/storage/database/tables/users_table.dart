/// 用户表定义
/// 
/// 使用Drift定义用户数据表结构
library;

import 'package:drift/drift.dart';

/// 用户表
class Users extends Table {
  /// 用户ID - 主键，使用字符串类型以兼容现有API
  TextColumn get id => text()();
  
  /// 用户名 - 可选，唯一
  TextColumn get username => text().nullable().unique()();
  
  /// 邮箱 - 可选，唯一
  TextColumn get email => text().nullable().unique()();
  
  /// 手机号 - 可选，唯一
  TextColumn get phone => text().nullable().unique()();
  
  /// 昵称 - 可选
  TextColumn get nickname => text().nullable()();
  
  /// 头像URL - 可选
  TextColumn get avatar => text().nullable()();
  
  /// 性别 - 存储为字符串：'male', 'female', 'other'
  TextColumn get gender => text().nullable()();
  
  /// 生日 - 可选
  DateTimeColumn get birthday => dateTime().nullable()();
  
  /// 地址 - 可选
  TextColumn get address => text().nullable()();
  
  /// 个人简介 - 可选
  TextColumn get bio => text().nullable()();
  
  /// 用户状态 - 存储为字符串：'active', 'inactive', 'suspended', 'deleted'
  TextColumn get status => text().withDefault(const Constant('active'))();
  
  /// 是否已验证邮箱
  BoolColumn get emailVerified => boolean().withDefault(const Constant(false))();
  
  /// 是否已验证手机号
  BoolColumn get phoneVerified => boolean().withDefault(const Constant(false))();
  
  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  /// 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  /// 最后登录时间 - 可选
  DateTimeColumn get lastLoginAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
  
  @override
  String get tableName => 'users';
}
