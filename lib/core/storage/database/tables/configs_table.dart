/// 配置表定义
/// 
/// 用于存储应用配置、权限配置等键值对数据
library;

import 'package:drift/drift.dart';

/// 配置表
class Configs extends Table {
  /// 配置键 - 主键
  TextColumn get key => text()();
  
  /// 配置值 - JSON字符串格式
  TextColumn get value => text()();
  
  /// 配置类型/分组 - 用于分类管理配置
  TextColumn get type => text().withDefault(const Constant('general'))();
  
  /// 配置描述
  TextColumn get description => text().nullable()();
  
  /// 是否为系统配置（系统配置不允许用户修改）
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  
  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  /// 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
  
  @override
  String get tableName => 'configs';
}

/// 缓存表 - 用于存储临时数据和缓存
class CacheEntries extends Table {
  /// 缓存键 - 主键
  TextColumn get key => text()();
  
  /// 缓存值 - JSON字符串格式
  TextColumn get value => text()();
  
  /// 缓存类型/分组
  TextColumn get type => text().withDefault(const Constant('general'))();
  
  /// 过期时间 - 可选，null表示永不过期
  DateTimeColumn get expiresAt => dateTime().nullable()();
  
  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  /// 最后访问时间
  DateTimeColumn get lastAccessedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
  
  @override
  String get tableName => 'cache_entries';
}
