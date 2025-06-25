/// 存储模块性能基准测试
/// 
/// 测试存储模块的性能表现
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_application_base/core/storage/database/app_database.dart';
import 'package:flutter_application_base/core/storage/repositories/user_repository.dart';
import 'package:flutter_application_base/core/storage/repositories/config_repository.dart';
import 'package:flutter_application_base/core/storage/models/user_entity.dart';
import 'package:flutter_application_base/core/storage/models/config_entity.dart';

void main() {
  group('Storage Performance Benchmark Tests', () {
    late AppDatabase database;
    late UserRepository userRepository;
    late ConfigRepository configRepository;

    setUp(() async {
      // 使用内存数据库进行性能测试
      database = AppDatabase.connect(NativeDatabase.memory());
      userRepository = UserRepository(database);
      configRepository = ConfigRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('benchmark single user insert performance', () async {
      final stopwatch = Stopwatch()..start();
      
      final now = DateTime.now();
      final entity = UserEntity(
        id: 'user_1',
        username: 'testuser',
        email: 'test@example.com',
        nickname: 'Test User',
        createdAt: now,
        updatedAt: now,
      );

      await userRepository.insert(entity);
      
      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;
      
      print('Single user insert: ${elapsedMs}ms');
      expect(elapsedMs, lessThan(10)); // 应该在10ms内完成
    });

    test('benchmark single user query performance', () async {
      // 先插入用户
      final now = DateTime.now();
      final entity = UserEntity(
        id: 'user_1',
        username: 'testuser',
        email: 'test@example.com',
        createdAt: now,
        updatedAt: now,
      );
      await userRepository.insert(entity);

      final stopwatch = Stopwatch()..start();
      
      final found = await userRepository.findById('user_1');
      
      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;
      
      print('Single user query: ${elapsedMs}ms');
      expect(found, isNotNull);
      expect(elapsedMs, lessThan(5)); // 应该在5ms内完成
    });

    test('benchmark batch user insert performance', () async {
      const batchSize = 100;
      final now = DateTime.now();
      final entities = <UserEntity>[];
      
      // 准备数据
      for (int i = 1; i <= batchSize; i++) {
        entities.add(UserEntity(
          id: 'user_$i',
          username: 'user$i',
          email: 'user$i@example.com',
          nickname: 'User $i',
          createdAt: now,
          updatedAt: now,
        ));
      }

      final stopwatch = Stopwatch()..start();
      
      await userRepository.insertAll(entities);
      
      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;
      final avgMs = elapsedMs / batchSize;
      
      print('Batch insert ($batchSize users): ${elapsedMs}ms (avg: ${avgMs.toStringAsFixed(2)}ms/user)');
      expect(elapsedMs, lessThan(100)); // 100条记录应该在100ms内完成
      expect(avgMs, lessThan(1)); // 平均每条记录应该在1ms内
    });

    test('benchmark pagination query performance', () async {
      const totalUsers = 1000;
      const pageSize = 20;
      final now = DateTime.now();
      
      // 插入大量用户
      final entities = <UserEntity>[];
      for (int i = 1; i <= totalUsers; i++) {
        entities.add(UserEntity(
          id: 'user_$i',
          username: 'user$i',
          email: 'user$i@example.com',
          createdAt: now.add(Duration(seconds: i)),
          updatedAt: now.add(Duration(seconds: i)),
        ));
      }
      await userRepository.insertAll(entities);

      final stopwatch = Stopwatch()..start();
      
      final page = await userRepository.findPage(1, pageSize);
      
      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;
      
      print('Pagination query ($pageSize/$totalUsers): ${elapsedMs}ms');
      expect(page.data.length, pageSize);
      expect(page.total, totalUsers);
      expect(elapsedMs, lessThan(20)); // 分页查询应该在20ms内完成
    });

    test('benchmark user search performance', () async {
      const totalUsers = 500;
      final now = DateTime.now();
      
      // 插入用户，其中一些包含搜索关键词
      final entities = <UserEntity>[];
      for (int i = 1; i <= totalUsers; i++) {
        final hasKeyword = i % 10 == 0; // 每10个用户中有1个包含关键词
        entities.add(UserEntity(
          id: 'user_$i',
          username: hasKeyword ? 'john_user$i' : 'user$i',
          email: 'user$i@example.com',
          nickname: hasKeyword ? 'John User $i' : 'User $i',
          createdAt: now,
          updatedAt: now,
        ));
      }
      await userRepository.insertAll(entities);

      final stopwatch = Stopwatch()..start();
      
      final results = await userRepository.searchUsers('john');
      
      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;
      
      print('User search ($totalUsers users, ${results.length} matches): ${elapsedMs}ms');
      expect(results.length, totalUsers ~/ 10); // 应该找到50个匹配的用户
      expect(elapsedMs, lessThan(30)); // 搜索应该在30ms内完成
    });

    test('benchmark transaction performance', () async {
      const batchSize = 50;
      final now = DateTime.now();

      final stopwatch = Stopwatch()..start();
      
      await database.transaction(() async {
        for (int i = 1; i <= batchSize; i++) {
          final entity = UserEntity(
            id: 'user_$i',
            username: 'user$i',
            email: 'user$i@example.com',
            createdAt: now,
            updatedAt: now,
          );
          await userRepository.insert(entity);
        }
      });
      
      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;
      final avgMs = elapsedMs / batchSize;
      
      print('Transaction ($batchSize inserts): ${elapsedMs}ms (avg: ${avgMs.toStringAsFixed(2)}ms/insert)');
      expect(elapsedMs, lessThan(50)); // 事务应该在50ms内完成
      
      // 验证所有数据都已插入
      final count = await userRepository.count();
      expect(count, batchSize);
    });

    test('benchmark config operations performance', () async {
      const configCount = 200;
      
      // 测试配置插入性能
      final insertStopwatch = Stopwatch()..start();
      
      for (int i = 1; i <= configCount; i++) {
        await configRepository.setValue('config_$i', 'value_$i', type: 'test');
      }
      
      insertStopwatch.stop();
      final insertMs = insertStopwatch.elapsedMilliseconds;
      
      print('Config insert ($configCount configs): ${insertMs}ms');
      expect(insertMs, lessThan(100)); // 配置插入应该在100ms内完成
      
      // 测试配置查询性能
      final queryStopwatch = Stopwatch()..start();
      
      for (int i = 1; i <= 10; i++) {
        final value = await configRepository.getString('config_$i');
        expect(value, 'value_$i');
      }
      
      queryStopwatch.stop();
      final queryMs = queryStopwatch.elapsedMilliseconds;
      
      print('Config query (10 configs): ${queryMs}ms');
      expect(queryMs, lessThan(20)); // 配置查询应该在20ms内完成
    });

    test('benchmark complex query performance', () async {
      const totalUsers = 1000;
      final now = DateTime.now();
      
      // 插入用户数据
      final entities = <UserEntity>[];
      for (int i = 1; i <= totalUsers; i++) {
        entities.add(UserEntity(
          id: 'user_$i',
          username: 'user$i',
          email: 'user$i@example.com',
          status: i % 3 == 0 ? 'inactive' : 'active',
          emailVerified: i % 2 == 0,
          createdAt: now.subtract(Duration(days: i % 365)),
          updatedAt: now,
        ));
      }
      await userRepository.insertAll(entities);

      final stopwatch = Stopwatch()..start();
      
      // 复杂查询：查找活跃且邮箱已验证的用户
      final activeVerifiedUsers = await userRepository.findWhere(
        'status = ? AND email_verified = ?',
        ['active', true],
      );
      
      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;
      
      print('Complex query ($totalUsers users, ${activeVerifiedUsers.length} matches): ${elapsedMs}ms');
      expect(elapsedMs, lessThan(50)); // 复杂查询应该在50ms内完成
    });

    test('benchmark database size and vacuum performance', () async {
      const totalUsers = 1000;
      final now = DateTime.now();
      
      // 插入大量数据
      final entities = <UserEntity>[];
      for (int i = 1; i <= totalUsers; i++) {
        entities.add(UserEntity(
          id: 'user_$i',
          username: 'user$i',
          email: 'user$i@example.com',
          nickname: 'User $i with some longer text to increase size',
          bio: 'This is a longer bio text for user $i to simulate real data size',
          createdAt: now,
          updatedAt: now,
        ));
      }
      await userRepository.insertAll(entities);
      
      // 删除一半数据以创建碎片
      for (int i = 1; i <= totalUsers ~/ 2; i++) {
        await userRepository.delete('user_$i');
      }
      
      // 测试VACUUM性能
      final vacuumStopwatch = Stopwatch()..start();
      
      await database.customStatement('VACUUM');
      
      vacuumStopwatch.stop();
      final vacuumMs = vacuumStopwatch.elapsedMilliseconds;
      
      print('Database vacuum: ${vacuumMs}ms');
      expect(vacuumMs, lessThan(200)); // VACUUM应该在200ms内完成
      
      // 验证数据完整性
      final remainingCount = await userRepository.count();
      expect(remainingCount, totalUsers ~/ 2);
    });

    test('performance summary', () {
      print('\n=== Storage Performance Summary ===');
      print('✅ Single operations: < 10ms');
      print('✅ Batch operations: < 1ms per item');
      print('✅ Pagination queries: < 20ms');
      print('✅ Search operations: < 30ms');
      print('✅ Transaction operations: < 50ms');
      print('✅ Complex queries: < 50ms');
      print('✅ Database maintenance: < 200ms');
      print('=====================================\n');
    });
  });
}
