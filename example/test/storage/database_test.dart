/// 数据库核心功能测试
///
/// 测试AppDatabase的基础功能
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_application_base/core/storage/database/app_database.dart';

void main() {
  group('AppDatabase Tests', () {
    late AppDatabase database;

    setUp(() async {
      // 为每个测试创建内存数据库
      database = AppDatabase.connect(
        NativeDatabase.memory(logStatements: true),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('should create database and tables', () async {
      // 验证数据库可以正常创建
      //expect(database, isNotNull);

      // 验证表是否存在
      final tables =
          await database
              .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
              .get();

      final tableNames = tables.map((row) => row.read<String>('name')).toList();

      expect(tableNames, contains('users'));
      expect(tableNames, contains('configs'));
      expect(tableNames, contains('cache_entries'));
      expect(tableNames, contains('auth_tokens'));
    });

    test('should insert default data on creation', () async {
      // 验证默认配置是否插入
      final configs = await database.select(database.configs).get();

      expect(configs.length, greaterThanOrEqualTo(2));

      final appVersionConfig = configs.firstWhere(
        (config) => config.key == 'app_version',
      );
      expect(appVersionConfig.value, '1.0.0');
      expect(appVersionConfig.isSystem, true);

      final dbVersionConfig = configs.firstWhere(
        (config) => config.key == 'database_version',
      );
      expect(dbVersionConfig.value, '1');
      expect(dbVersionConfig.isSystem, true);
    });

    test('should support CRUD operations on users table', () async {
      final now = DateTime.now();

      // 插入用户
      final userId = 'test_user_1';
      await database
          .into(database.users)
          .insert(
            UsersCompanion.insert(
              id: userId,
              username: const Value('testuser'),
              email: const Value('test@example.com'),
              nickname: const Value('Test User'),
              status: const Value('active'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      // 查询用户
      final users = await database.select(database.users).get();
      expect(users.length, 1);

      final user = users.first;
      expect(user.id, userId);
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.nickname, 'Test User');
      expect(user.status, 'active');

      // 更新用户
      await (database.update(database.users)
        ..where((u) => u.id.equals(userId))).write(
        const UsersCompanion(
          nickname: Value('Updated User'),
          updatedAt: Value.absent(),
        ),
      );

      final updatedUser =
          await (database.select(database.users)
            ..where((u) => u.id.equals(userId))).getSingle();
      expect(updatedUser.nickname, 'Updated User');

      // 删除用户
      await (database.delete(database.users)
        ..where((u) => u.id.equals(userId))).go();

      final remainingUsers = await database.select(database.users).get();
      expect(remainingUsers.length, 0);
    });

    test('should support CRUD operations on configs table', () async {
      final now = DateTime.now();

      // 插入配置
      const configKey = 'test_config';
      await database
          .into(database.configs)
          .insert(
            ConfigsCompanion.insert(
              key: configKey,
              value: 'test_value',
              type: const Value('test'),
              description: const Value('Test configuration'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      // 查询配置
      final config =
          await (database.select(database.configs)
            ..where((c) => c.key.equals(configKey))).getSingle();

      expect(config.key, configKey);
      expect(config.value, 'test_value');
      expect(config.type, 'test');
      expect(config.description, 'Test configuration');
      expect(config.isSystem, false);

      // 更新配置
      await (database.update(database.configs)..where(
        (c) => c.key.equals(configKey),
      )).write(const ConfigsCompanion(value: Value('updated_value')));

      final updatedConfig =
          await (database.select(database.configs)
            ..where((c) => c.key.equals(configKey))).getSingle();
      expect(updatedConfig.value, 'updated_value');

      // 删除配置
      await (database.delete(database.configs)
        ..where((c) => c.key.equals(configKey))).go();

      final remainingConfigs =
          await (database.select(database.configs)
            ..where((c) => c.key.equals(configKey))).get();
      expect(remainingConfigs.length, 0);
    });

    test('should support transactions', () async {
      await database.transaction(() async {
        // 在事务中插入多个用户
        for (int i = 0; i < 3; i++) {
          await database
              .into(database.users)
              .insert(
                UsersCompanion.insert(
                  id: 'user_$i',
                  username: Value('user$i'),
                  createdAt: Value(DateTime.now()),
                  updatedAt: Value(DateTime.now()),
                ),
              );
        }
      });

      final users = await database.select(database.users).get();
      expect(users.length, 3);
    });

    test('should handle transaction rollback on error', () async {
      try {
        await database.transaction(() async {
          // 插入一个用户
          await database
              .into(database.users)
              .insert(
                UsersCompanion.insert(
                  id: 'user_1',
                  username: const Value('user1'),
                  createdAt: Value(DateTime.now()),
                  updatedAt: Value(DateTime.now()),
                ),
              );

          // 故意抛出异常
          throw Exception('Test error');
        });
      } catch (e) {
        // 预期的异常
      }

      // 验证事务回滚，用户未插入
      final users = await database.select(database.users).get();
      expect(users.length, 0);
    });
  });
}
