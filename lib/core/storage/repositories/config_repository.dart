/// 配置仓储实现
/// 
/// 提供应用配置的CRUD操作
library;

import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/config_entity.dart';
import 'base_repository.dart';

/// Config表扩展方法
extension ConfigExtension on Config {
  /// 转换为实体
  ConfigEntity toEntity() {
    return ConfigEntity(
      key: key,
      value: value,
      type: type,
      description: description,
      isSystem: isSystem,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// 配置仓储实现
class ConfigRepository implements IBaseRepository<ConfigEntity, String> {
  final AppDatabase _database;
  
  ConfigRepository(this._database);

  @override
  Future<ConfigEntity> insert(ConfigEntity entity) async {
    await _database.into(_database.configs).insert(
      entity.toCompanion(),
    );
    return entity;
  }

  @override
  Future<List<ConfigEntity>> insertAll(List<ConfigEntity> entities) async {
    await _database.batch((batch) {
      for (final entity in entities) {
        batch.insert(_database.configs, entity.toCompanion());
      }
    });
    return entities;
  }

  @override
  Future<ConfigEntity?> findById(String key) async {
    final query = _database.select(_database.configs)
      ..where((c) => c.key.equals(key));
    
    final config = await query.getSingleOrNull();
    return config?.toEntity();
  }

  @override
  Future<List<ConfigEntity>> findAll() async {
    final configs = await _database.select(_database.configs).get();
    return configs.map((c) => c.toEntity()).toList();
  }

  @override
  Future<PageResult<ConfigEntity>> findPage(int page, int size) async {
    final offset = (page - 1) * size;
    
    // 查询总数
    final countQuery = _database.selectOnly(_database.configs)
      ..addColumns([_database.configs.key.count()]);
    final total = await countQuery.getSingle().then(
      (row) => row.read(_database.configs.key.count()) ?? 0,
    );
    
    // 分页查询
    final query = _database.select(_database.configs)
      ..limit(size, offset: offset)
      ..orderBy([(c) => OrderingTerm.asc(c.key)]);
    
    final configs = await query.get();
    final entities = configs.map((c) => c.toEntity()).toList();
    
    return PageResult(
      data: entities,
      total: total,
      page: page,
      size: size,
    );
  }

  @override
  Future<List<ConfigEntity>> findWhere(String condition, [List<dynamic>? args]) async {
    final query = _database.customSelect(
      'SELECT * FROM configs WHERE $condition',
      variables: args?.map((arg) => Variable(arg)).toList() ?? [],
      readsFrom: {_database.configs},
    );
    
    final results = await query.get();
    return results.map((row) => ConfigEntity.fromRow(row)).toList();
  }

  @override
  Future<ConfigEntity> update(ConfigEntity entity) async {
    await (_database.update(_database.configs)
      ..where((c) => c.key.equals(entity.key)))
      .write(entity.toCompanion());
    return entity;
  }

  @override
  Future<void> delete(String key) async {
    await (_database.delete(_database.configs)
      ..where((c) => c.key.equals(key)))
      .go();
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    await (_database.delete(_database.configs)
      ..where((c) => c.key.isIn(keys)))
      .go();
  }

  @override
  Future<int> count() async {
    final countQuery = _database.selectOnly(_database.configs)
      ..addColumns([_database.configs.key.count()]);
    final result = await countQuery.getSingle();
    return result.read(_database.configs.key.count()) ?? 0;
  }

  @override
  Future<int> countWhere(String condition, [List<dynamic>? args]) async {
    final query = _database.customSelect(
      'SELECT COUNT(*) as count FROM configs WHERE $condition',
      variables: args?.map((arg) => Variable(arg)).toList() ?? [],
      readsFrom: {_database.configs},
    );
    
    final result = await query.getSingle();
    return result.read<int>('count');
  }

  @override
  Future<bool> exists(String key) async {
    final count = await countWhere('key = ?', [key]);
    return count > 0;
  }

  @override
  Future<void> clear() async {
    await _database.delete(_database.configs).go();
  }

  /// 根据类型查询配置
  Future<List<ConfigEntity>> findByType(String type) async {
    final query = _database.select(_database.configs)
      ..where((c) => c.type.equals(type))
      ..orderBy([(c) => OrderingTerm.asc(c.key)]);
    
    final configs = await query.get();
    return configs.map((c) => c.toEntity()).toList();
  }

  /// 获取配置值（泛型）
  Future<T?> getValue<T>(String key) async {
    final config = await findById(key);
    if (config == null) return null;
    
    try {
      final value = jsonDecode(config.value);
      return value as T?;
    } catch (e) {
      // 如果不是JSON，直接返回字符串值
      return config.value as T?;
    }
  }

  /// 设置配置值
  Future<void> setValue<T>(String key, T value, {String type = 'general', String? description}) async {
    final jsonValue = value is String ? value : jsonEncode(value);
    
    final entity = ConfigEntity(
      key: key,
      value: jsonValue,
      type: type,
      description: description,
      isSystem: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final existing = await findById(key);
    if (existing != null) {
      await update(entity.copyWith(
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      ));
    } else {
      await insert(entity);
    }
  }

  /// 获取字符串配置
  Future<String?> getString(String key, [String? defaultValue]) async {
    final value = await getValue<String>(key);
    return value ?? defaultValue;
  }

  /// 获取整数配置
  Future<int?> getInt(String key, [int? defaultValue]) async {
    final value = await getValue<int>(key);
    return value ?? defaultValue;
  }

  /// 获取布尔配置
  Future<bool?> getBool(String key, [bool? defaultValue]) async {
    final value = await getValue<bool>(key);
    return value ?? defaultValue;
  }

  /// 获取双精度配置
  Future<double?> getDouble(String key, [double? defaultValue]) async {
    final value = await getValue<double>(key);
    return value ?? defaultValue;
  }
}
