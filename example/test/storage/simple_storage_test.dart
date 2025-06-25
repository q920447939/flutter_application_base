/// 简化的存储模块测试
///
/// 测试存储模块的基本功能
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_base/core/storage/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';

void main() {
  group('Simple Storage Tests', () {
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

    test('should create database successfully', () async {
      // 验证数据库可以正常创建
      expect(database, isNotNull);

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

      print('✅ Database created successfully with tables: $tableNames');
    });

    test('should insert and query user data', () async {
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

      print('✅ User data inserted and queried successfully');
    });

    test('should insert and query config data', () async {
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

      print('✅ Config data inserted and queried successfully');
    });

    test('should support basic transactions', () async {
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

      print('✅ Transaction completed successfully with ${users.length} users');
    });

    test('should handle default configurations', () async {
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

      print('✅ Default configurations verified successfully');
    });

    test('should perform basic CRUD operations', () async {
      final now = DateTime.now();
      final userId = 'crud_test_user';

      // Create
      await database
          .into(database.users)
          .insert(
            UsersCompanion.insert(
              id: userId,
              username: const Value('cruduser'),
              email: const Value('crud@example.com'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      // Read
      var user =
          await (database.select(database.users)
            ..where((u) => u.id.equals(userId))).getSingle();
      expect(user.username, 'cruduser');

      // Update
      await (database.update(database.users)..where(
        (u) => u.id.equals(userId),
      )).write(const UsersCompanion(username: Value('updateduser')));

      user =
          await (database.select(database.users)
            ..where((u) => u.id.equals(userId))).getSingle();
      expect(user.username, 'updateduser');

      // Delete
      await (database.delete(database.users)
        ..where((u) => u.id.equals(userId))).go();

      final remainingUsers =
          await (database.select(database.users)
            ..where((u) => u.id.equals(userId))).get();
      expect(remainingUsers.length, 0);

      print('✅ CRUD operations completed successfully');
    });

    test('performance test - batch operations', () async {
      final stopwatch = Stopwatch()..start();

      // 批量插入100个用户
      await database.transaction(() async {
        for (int i = 0; i < 100; i++) {
          await database
              .into(database.users)
              .insert(
                UsersCompanion.insert(
                  id: 'perf_user_$i',
                  username: Value('perfuser$i'),
                  email: Value('perfuser$i@example.com'),
                  createdAt: Value(DateTime.now()),
                  updatedAt: Value(DateTime.now()),
                ),
              );
        }
      });

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      // 验证插入成功
      final users = await database.select(database.users).get();
      expect(users.length, 100);

      print('✅ Performance test: 100 users inserted in ${elapsedMs}ms');
      expect(elapsedMs, lessThan(1000)); // 应该在1秒内完成
    });
  });
}
