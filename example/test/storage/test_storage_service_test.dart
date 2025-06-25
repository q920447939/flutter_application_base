/// 测试专用存储服务测试
/// 
/// 使用内存数据库测试存储服务功能
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_base/core/storage/services/storage_service.dart';
import 'package:flutter_application_base/core/storage/repositories/user_repository.dart';
import 'package:flutter_application_base/core/storage/repositories/config_repository.dart';
import 'package:flutter_application_base/core/storage/repositories/base_repository.dart';
import 'package:flutter_application_base/core/storage/models/user_entity.dart';
import 'test_storage_service.dart';

void main() {
  group('Test Storage Service Tests', () {
    late TestStorageService storageService;

    setUp(() async {
      storageService = TestStorageService();
    });

    tearDown(() async {
      if (storageService.isInitialized) {
        await storageService.dispose();
      }
    });

    test('should initialize storage service', () async {
      expect(storageService.isInitialized, false);
      
      await storageService.initialize();
      
      expect(storageService.isInitialized, true);
      expect(storageService.databasePath, ':memory:');
      
      print('✅ 存储服务初始化成功');
    });

    test('should throw exception when getting repository before initialization', () async {
      expect(
        () => storageService.getRepository<UserRepository>(),
        throwsA(isA<StorageException>()),
      );
      
      print('✅ 未初始化时正确抛出异常');
    });

    test('should get repository after initialization', () async {
      await storageService.initialize();
      
      final userRepo = storageService.getRepository<UserRepository>();
      expect(userRepo, isA<UserRepository>());
      
      final configRepo = storageService.getRepository<ConfigRepository>();
      expect(configRepo, isA<ConfigRepository>());
      
      print('✅ 仓储获取成功');
    });

    test('should throw exception for unregistered repository', () async {
      await storageService.initialize();
      
      expect(
        () => storageService.getRepository<TestRepository>(),
        throwsA(isA<StorageException>()),
      );
      
      print('✅ 未注册仓储正确抛出异常');
    });

    test('should support transactions', () async {
      await storageService.initialize();
      
      final userRepo = storageService.getRepository<UserRepository>();
      final now = DateTime.now();
      
      // 在事务中插入多个用户
      final users = await storageService.transaction(() async {
        final insertedUsers = <UserEntity>[];
        
        for (int i = 1; i <= 3; i++) {
          final entity = UserEntity(
            id: 'user_$i',
            username: 'user$i',
            email: 'user$i@example.com',
            createdAt: now,
            updatedAt: now,
          );
          final inserted = await userRepo.insert(entity);
          insertedUsers.add(inserted);
        }
        
        return insertedUsers;
      });
      
      expect(users.length, 3);
      
      // 验证用户已插入
      final allUsers = await userRepo.findAll();
      expect(allUsers.length, 3);
      
      print('✅ 事务操作成功，插入${users.length}个用户');
    });

    test('should rollback transaction on error', () async {
      await storageService.initialize();
      
      final userRepo = storageService.getRepository<UserRepository>();
      final now = DateTime.now();
      
      try {
        await storageService.transaction(() async {
          // 插入一个用户
          final entity = UserEntity(
            id: 'user_1',
            username: 'user1',
            email: 'user1@example.com',
            createdAt: now,
            updatedAt: now,
          );
          await userRepo.insert(entity);
          
          // 故意抛出异常
          throw Exception('Test error');
        });
      } catch (e) {
        // 预期的异常
      }
      
      // 验证事务回滚，用户未插入
      final users = await userRepo.findAll();
      expect(users.length, 0);
      
      print('✅ 事务回滚成功');
    });

    test('should get database size', () async {
      await storageService.initialize();
      
      final size = await storageService.getDatabaseSize();
      expect(size, greaterThan(0));
      
      print('✅ 数据库大小获取成功: ${size}字节');
    });

    test('should get database statistics', () async {
      await storageService.initialize();
      
      final userRepo = storageService.getRepository<UserRepository>();
      
      // 插入一些测试数据
      final now = DateTime.now();
      await userRepo.insert(UserEntity(
        id: 'user_1',
        username: 'testuser',
        email: 'test@example.com',
        createdAt: now,
        updatedAt: now,
      ));
      
      final stats = await storageService.getDatabaseStats();
      
      expect(stats['userCount'], 1);
      expect(stats['configCount'], greaterThanOrEqualTo(2)); // 默认配置
      expect(stats['databaseSize'], greaterThan(0));
      expect(stats['databasePath'], ':memory:');
      expect(stats['isInitialized'], true);
      
      print('✅ 数据库统计信息获取成功');
      print('   用户数: ${stats['userCount']}');
      print('   配置数: ${stats['configCount']}');
      print('   数据库大小: ${stats['databaseSize']}字节');
    });

    test('should vacuum database', () async {
      await storageService.initialize();
      
      // 插入一些数据然后删除，创建碎片
      final userRepo = storageService.getRepository<UserRepository>();
      final now = DateTime.now();
      
      for (int i = 1; i <= 10; i++) {
        await userRepo.insert(UserEntity(
          id: 'user_$i',
          username: 'user$i',
          email: 'user$i@example.com',
          createdAt: now,
          updatedAt: now,
        ));
      }
      
      // 删除一些数据
      for (int i = 1; i <= 5; i++) {
        await userRepo.delete('user_$i');
      }
      
      // 压缩数据库
      await storageService.vacuum();
      
      // 验证剩余数据
      final remainingUsers = await userRepo.findAll();
      expect(remainingUsers.length, 5);
      
      print('✅ 数据库压缩成功，剩余${remainingUsers.length}个用户');
    });

    test('should handle backup and restore errors gracefully', () async {
      await storageService.initialize();
      
      // 内存数据库不支持备份
      expect(
        storageService.backup('/tmp/backup.db'),
        throwsA(isA<StorageException>()),
      );
      
      // 内存数据库不支持恢复
      expect(
        storageService.restore('/tmp/backup.db'),
        throwsA(isA<StorageException>()),
      );
      
      print('✅ 备份恢复异常处理正确');
    });

    test('should dispose properly', () async {
      await storageService.initialize();
      expect(storageService.isInitialized, true);
      
      await storageService.dispose();
      expect(storageService.isInitialized, false);
      
      // 再次调用dispose应该不会出错
      await storageService.dispose();
      
      print('✅ 存储服务销毁成功');
    });

    test('should throw exception when operating on disposed service', () async {
      await storageService.initialize();
      await storageService.dispose();
      
      expect(
        () => storageService.getRepository<UserRepository>(),
        throwsA(isA<StorageException>()),
      );
      
      expect(
        storageService.transaction(() async {}),
        throwsA(isA<StorageException>()),
      );
      
      expect(
        storageService.vacuum(),
        throwsA(isA<StorageException>()),
      );
      
      print('✅ 已销毁服务的异常处理正确');
    });

    test('performance test - batch operations', () async {
      await storageService.initialize();
      
      final userRepo = storageService.getRepository<UserRepository>();
      final stopwatch = Stopwatch()..start();
      
      // 批量插入100个用户
      await storageService.transaction(() async {
        for (int i = 0; i < 100; i++) {
          await userRepo.insert(UserEntity(
            id: 'perf_user_$i',
            username: 'perfuser$i',
            email: 'perfuser$i@example.com',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
        }
      });
      
      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;
      
      // 验证插入成功
      final users = await userRepo.findAll();
      expect(users.length, 100);
      
      print('✅ 性能测试: 100个用户插入耗时${elapsedMs}ms');
      expect(elapsedMs, lessThan(1000)); // 应该在1秒内完成
    });
  });
}

/// 测试用的未注册仓储类
abstract class TestRepository implements IBaseRepository<String, String> {
  // 这个类故意不实现任何方法，仅用于测试类型检查
}
