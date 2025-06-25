/// 配置仓储测试
/// 
/// 测试ConfigRepository的所有功能
library;

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_application_base/core/storage/database/app_database.dart';
import 'package:flutter_application_base/core/storage/repositories/config_repository.dart';
import 'package:flutter_application_base/core/storage/models/config_entity.dart';

void main() {
  group('ConfigRepository Tests', () {
    late AppDatabase database;
    late ConfigRepository configRepository;

    setUp(() async {
      // 为每个测试创建内存数据库
      database = AppDatabase.connect(NativeDatabase.memory(logStatements: true));
      configRepository = ConfigRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('should insert config entity', () async {
      final now = DateTime.now();
      final entity = ConfigEntity(
        key: 'test_key',
        value: 'test_value',
        type: 'test',
        description: 'Test configuration',
        createdAt: now,
        updatedAt: now,
      );

      final result = await configRepository.insert(entity);

      expect(result.key, entity.key);
      expect(result.value, entity.value);
      expect(result.type, entity.type);
      expect(result.description, entity.description);
    });

    test('should find config by key', () async {
      final now = DateTime.now();
      final entity = ConfigEntity(
        key: 'test_key',
        value: 'test_value',
        type: 'test',
        createdAt: now,
        updatedAt: now,
      );
      await configRepository.insert(entity);

      final found = await configRepository.findById('test_key');

      expect(found, isNotNull);
      expect(found!.key, 'test_key');
      expect(found.value, 'test_value');
      expect(found.type, 'test');
    });

    test('should return null when config not found', () async {
      final found = await configRepository.findById('non_existent');
      expect(found, isNull);
    });

    test('should find configs by type', () async {
      final now = DateTime.now();
      
      // 插入不同类型的配置
      final configs = [
        ConfigEntity(
          key: 'app_config_1',
          value: 'value1',
          type: 'app',
          createdAt: now,
          updatedAt: now,
        ),
        ConfigEntity(
          key: 'app_config_2',
          value: 'value2',
          type: 'app',
          createdAt: now,
          updatedAt: now,
        ),
        ConfigEntity(
          key: 'user_config_1',
          value: 'value3',
          type: 'user',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      for (final config in configs) {
        await configRepository.insert(config);
      }

      final appConfigs = await configRepository.findByType('app');
      expect(appConfigs.length, 2);
      expect(appConfigs.map((c) => c.key), containsAll(['app_config_1', 'app_config_2']));

      final userConfigs = await configRepository.findByType('user');
      expect(userConfigs.length, 1);
      expect(userConfigs.first.key, 'user_config_1');
    });

    test('should update config entity', () async {
      final now = DateTime.now();
      
      // 插入配置
      final entity = ConfigEntity(
        key: 'test_key',
        value: 'original_value',
        type: 'test',
        createdAt: now,
        updatedAt: now,
      );
      await configRepository.insert(entity);

      // 更新配置
      final updatedEntity = entity.copyWith(
        value: 'updated_value',
        updatedAt: now.add(const Duration(hours: 1)),
      );
      await configRepository.update(updatedEntity);

      // 验证更新
      final found = await configRepository.findById('test_key');
      expect(found!.value, 'updated_value');
    });

    test('should delete config', () async {
      final now = DateTime.now();
      
      // 插入配置
      final entity = ConfigEntity(
        key: 'test_key',
        value: 'test_value',
        type: 'test',
        createdAt: now,
        updatedAt: now,
      );
      await configRepository.insert(entity);

      // 删除配置
      await configRepository.delete('test_key');

      // 验证删除
      final found = await configRepository.findById('test_key');
      expect(found, isNull);
    });

    test('should get and set string values', () async {
      // 设置字符串值
      await configRepository.setValue('string_key', 'hello world');

      // 获取字符串值
      final value = await configRepository.getString('string_key');
      expect(value, 'hello world');

      // 获取不存在的键，返回默认值
      final defaultValue = await configRepository.getString('non_existent', 'default');
      expect(defaultValue, 'default');
    });

    test('should get and set integer values', () async {
      // 设置整数值
      await configRepository.setValue('int_key', 42);

      // 获取整数值
      final value = await configRepository.getInt('int_key');
      expect(value, 42);

      // 获取不存在的键，返回默认值
      final defaultValue = await configRepository.getInt('non_existent', 100);
      expect(defaultValue, 100);
    });

    test('should get and set boolean values', () async {
      // 设置布尔值
      await configRepository.setValue('bool_key', true);

      // 获取布尔值
      final value = await configRepository.getBool('bool_key');
      expect(value, true);

      // 获取不存在的键，返回默认值
      final defaultValue = await configRepository.getBool('non_existent', false);
      expect(defaultValue, false);
    });

    test('should get and set double values', () async {
      // 设置双精度值
      await configRepository.setValue('double_key', 3.14);

      // 获取双精度值
      final value = await configRepository.getDouble('double_key');
      expect(value, 3.14);

      // 获取不存在的键，返回默认值
      final defaultValue = await configRepository.getDouble('non_existent', 2.71);
      expect(defaultValue, 2.71);
    });

    test('should handle complex JSON values', () async {
      final complexData = {
        'name': 'John Doe',
        'age': 30,
        'active': true,
        'scores': [85, 92, 78],
        'metadata': {
          'created': '2024-01-01',
          'tags': ['user', 'premium']
        }
      };

      // 设置复杂JSON值
      await configRepository.setValue('complex_key', complexData);

      // 获取复杂JSON值
      final value = await configRepository.getValue<Map<String, dynamic>>('complex_key');
      expect(value, isNotNull);
      expect(value!['name'], 'John Doe');
      expect(value['age'], 30);
      expect(value['active'], true);
      expect(value['scores'], [85, 92, 78]);
      expect(value['metadata']['created'], '2024-01-01');
    });

    test('should update existing config when setting value', () async {
      // 首次设置
      await configRepository.setValue('update_key', 'original_value');
      
      final original = await configRepository.findById('update_key');
      expect(original!.value, 'original_value');
      
      // 更新值
      await configRepository.setValue('update_key', 'updated_value');
      
      final updated = await configRepository.findById('update_key');
      expect(updated!.value, 'updated_value');
      expect(updated.createdAt, original.createdAt); // 创建时间不变
      expect(updated.updatedAt.isAfter(original.updatedAt), true); // 更新时间改变
    });

    test('should support pagination', () async {
      final now = DateTime.now();
      
      // 插入多个配置
      for (int i = 1; i <= 10; i++) {
        final entity = ConfigEntity(
          key: 'config_$i',
          value: 'value_$i',
          type: 'test',
          createdAt: now,
          updatedAt: now,
        );
        await configRepository.insert(entity);
      }

      // 测试分页
      final page1 = await configRepository.findPage(1, 3);
      expect(page1.data.length, 3);
      expect(page1.total, 12); // 包括默认插入的2个配置
      expect(page1.page, 1);
      expect(page1.size, 3);
    });

    test('should count configs', () async {
      final now = DateTime.now();
      
      // 插入配置
      for (int i = 1; i <= 5; i++) {
        final entity = ConfigEntity(
          key: 'config_$i',
          value: 'value_$i',
          type: 'test',
          createdAt: now,
          updatedAt: now,
        );
        await configRepository.insert(entity);
      }

      final count = await configRepository.count();
      expect(count, 7); // 包括默认插入的2个配置
    });

    test('should check if config exists', () async {
      final now = DateTime.now();
      final entity = ConfigEntity(
        key: 'test_key',
        value: 'test_value',
        type: 'test',
        createdAt: now,
        updatedAt: now,
      );
      await configRepository.insert(entity);

      expect(await configRepository.exists('test_key'), true);
      expect(await configRepository.exists('non_existent'), false);
    });

    test('should clear all configs', () async {
      final now = DateTime.now();
      
      // 插入配置
      for (int i = 1; i <= 3; i++) {
        final entity = ConfigEntity(
          key: 'config_$i',
          value: 'value_$i',
          type: 'test',
          createdAt: now,
          updatedAt: now,
        );
        await configRepository.insert(entity);
      }

      await configRepository.clear();

      final count = await configRepository.count();
      expect(count, 0);
    });
  });
}
