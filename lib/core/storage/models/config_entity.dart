/// 配置数据库实体
/// 
/// 用于数据库层的配置数据模型
library;

import 'package:drift/drift.dart';
import '../database/app_database.dart';

/// 配置数据库实体
class ConfigEntity {
  /// 配置键
  final String key;
  
  /// 配置值
  final String value;
  
  /// 配置类型/分组
  final String type;
  
  /// 配置描述
  final String? description;
  
  /// 是否为系统配置
  final bool isSystem;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;

  const ConfigEntity({
    required this.key,
    required this.value,
    this.type = 'general',
    this.description,
    this.isSystem = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从Drift数据行创建实体
  factory ConfigEntity.fromRow(QueryRow row) {
    return ConfigEntity(
      key: row.read<String>('key'),
      value: row.read<String>('value'),
      type: row.read<String>('type'),
      description: row.readNullable<String>('description'),
      isSystem: row.read<bool>('is_system'),
      createdAt: row.read<DateTime>('created_at'),
      updatedAt: row.read<DateTime>('updated_at'),
    );
  }

  /// 转换为Drift Companion
  ConfigsCompanion toCompanion() {
    return ConfigsCompanion(
      key: Value(key),
      value: Value(value),
      type: Value(type),
      description: Value(description),
      isSystem: Value(isSystem),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  /// 复制并更新部分字段
  ConfigEntity copyWith({
    String? key,
    String? value,
    String? type,
    String? description,
    bool? isSystem,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConfigEntity(
      key: key ?? this.key,
      value: value ?? this.value,
      type: type ?? this.type,
      description: description ?? this.description,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ConfigEntity(key: $key, value: $value, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConfigEntity && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}
