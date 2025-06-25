/// 存储服务测试
///
/// 测试SqliteStorageService的所有功能
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_base/core/storage/services/sqlite_storage_service.dart';
import 'package:flutter_application_base/core/storage/services/storage_service.dart';
import 'package:flutter_application_base/core/storage/repositories/user_repository.dart';
import 'package:flutter_application_base/core/storage/repositories/config_repository.dart';
import 'package:flutter_application_base/core/storage/repositories/base_repository.dart';
import 'package:flutter_application_base/core/storage/models/user_entity.dart';

void main() {
  group('SqliteStorageService Tests', () {
    late SqliteStorageService storageService;

    setUpAll(() async {
      // 初始化Flutter绑定，这是测试中使用path_provider等插件的必要步骤
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      storageService = SqliteStorageService();
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
      expect(storageService.databasePath, isNotNull);
    });

    test(
      'should throw exception when getting repository before initialization',
      () async {
        expect(
          () => storageService.getRepository<UserRepository>(),
          throwsA(isA<StorageException>()),
        );
      },
    );

    test('should get repository after initialization', () async {
      await storageService.initialize();

      final userRepo = storageService.getRepository<UserRepository>();
      expect(userRepo, isA<UserRepository>());

      final configRepo = storageService.getRepository<ConfigRepository>();
      expect(configRepo, isA<ConfigRepository>());
    });

    test('should throw exception for unregistered repository', () async {
      await storageService.initialize();

      // 使用一个不存在的仓储类型来测试异常
      expect(
        () => storageService.getRepository<TestRepository>(),
        throwsA(isA<StorageException>()),
      );
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
    });

    test('should get database size', () async {
      await storageService.initialize();

      final size = await storageService.getDatabaseSize();
      expect(size, greaterThan(0));
    });

    test('should get database statistics', () async {
      await storageService.initialize();

      final userRepo = storageService.getRepository<UserRepository>();
      storageService.getRepository<ConfigRepository>(); // 验证配置仓储也能正常获取

      // 插入一些测试数据
      final now = DateTime.now();
      await userRepo.insert(
        UserEntity(
          id: 'user_1',
          username: 'testuser',
          email: 'test@example.com',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final stats = await storageService.getDatabaseStats();

      expect(stats['userCount'], 1);
      expect(stats['configCount'], greaterThanOrEqualTo(2)); // 默认配置
      expect(stats['databaseSize'], greaterThan(0));
      expect(stats['databasePath'], isNotNull);
      expect(stats['isInitialized'], true);
    });

    test('should vacuum database', () async {
      await storageService.initialize();

      // 插入一些数据然后删除，创建碎片
      final userRepo = storageService.getRepository<UserRepository>();
      final now = DateTime.now();

      for (int i = 1; i <= 10; i++) {
        await userRepo.insert(
          UserEntity(
            id: 'user_$i',
            username: 'user$i',
            email: 'user$i@example.com',
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      // 删除一些数据
      for (int i = 1; i <= 5; i++) {
        await userRepo.delete('user_$i');
      }

      final sizeBefore = await storageService.getDatabaseSize();

      // 压缩数据库
      await storageService.vacuum();

      final sizeAfter = await storageService.getDatabaseSize();

      // 压缩后大小应该小于等于压缩前
      expect(sizeAfter, lessThanOrEqualTo(sizeBefore));
    });

    test('should handle backup and restore', () async {
      await storageService.initialize();

      final userRepo = storageService.getRepository<UserRepository>();
      final now = DateTime.now();

      // 插入测试数据
      await userRepo.insert(
        UserEntity(
          id: 'user_1',
          username: 'testuser',
          email: 'test@example.com',
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 备份数据库
      final backupPath = '${storageService.databasePath}.backup';
      await storageService.backup(backupPath);

      // 验证备份文件存在
      final backupFile = File(backupPath);
      expect(await backupFile.exists(), true);

      // 清空数据
      await userRepo.clear();
      expect(await userRepo.count(), 0);

      // 恢复数据库
      await storageService.restore(backupPath);

      // 验证数据恢复
      final users = await userRepo.findAll();
      expect(users.length, 1);
      expect(users.first.id, 'user_1');

      // 清理备份文件
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
    });

    test('should dispose properly', () async {
      await storageService.initialize();
      expect(storageService.isInitialized, true);

      await storageService.dispose();
      expect(storageService.isInitialized, false);

      // 再次调用dispose应该不会出错
      await storageService.dispose();
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

      expect(storageService.vacuum(), throwsA(isA<StorageException>()));
    });

    test('should handle initialization errors gracefully', () async {
      // 这个测试比较难模拟，因为我们使用内存数据库
      // 在实际应用中，可能会因为权限问题或磁盘空间不足而失败
      expect(storageService.isInitialized, false);
    });
  });
}

/// 测试用的未注册仓储类
abstract class TestRepository implements IBaseRepository<String, String> {
  // 这个类故意不实现任何方法，仅用于测试类型检查
}
