/// 存储模块集成测试
/// 
/// 测试存储模块与业务层的集成
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter_application_base/core/storage/services/storage_service.dart';
import 'package:flutter_application_base/core/storage/services/sqlite_storage_service.dart';
import 'package:flutter_application_base/core/storage/repositories/user_repository.dart';
import 'package:flutter_application_base/core/storage/repositories/config_repository.dart';
import 'package:flutter_application_base/core/storage/models/user_entity.dart';
import 'package:flutter_application_base/core/storage/examples/storage_usage_example.dart';
import 'package:flutter_application_base/features/auth/models/user_model.dart';

void main() {
  group('Storage Integration Tests', () {
    late IStorageService storageService;

    setUp(() async {
      // 清理Get容器
      Get.reset();
      
      // 初始化存储服务
      storageService = SqliteStorageService();
      await storageService.initialize();
      
      // 注册到Get容器
      Get.put<IStorageService>(storageService);
    });

    tearDown(() async {
      await storageService.dispose();
      Get.reset();
    });

    test('should integrate with business layer services', () async {
      final userService = UserService();
      final configService = ConfigService();
      
      // 测试用户服务
      final user = await userService.createUser(
        id: 'user_1',
        username: 'testuser',
        email: 'test@example.com',
        nickname: 'Test User',
      );
      
      expect(user.id, 'user_1');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.nickname, 'Test User');
      
      // 测试获取用户
      final foundUser = await userService.getUser('user_1');
      expect(foundUser, isNotNull);
      expect(foundUser!.id, 'user_1');
      
      // 测试配置服务
      await configService.setAppConfig('theme', 'dark');
      final theme = await configService.getAppConfig('theme');
      expect(theme, 'dark');
    });

    test('should handle user CRUD operations through service layer', () async {
      final userService = UserService();
      
      // 创建用户
      final user = await userService.createUser(
        id: 'user_1',
        username: 'testuser',
        email: 'test@example.com',
        nickname: 'Test User',
      );
      
      // 更新用户
      final updatedUser = await userService.updateUser(
        user.copyWith(nickname: 'Updated User'),
      );
      expect(updatedUser.nickname, 'Updated User');
      
      // 获取用户列表
      final users = await userService.getUserList();
      expect(users.length, 1);
      expect(users.first.nickname, 'Updated User');
      
      // 搜索用户
      final searchResults = await userService.searchUsers('test');
      expect(searchResults.length, 1);
      expect(searchResults.first.id, 'user_1');
      
      // 删除用户
      await userService.deleteUser('user_1');
      
      final deletedUser = await userService.getUser('user_1');
      expect(deletedUser, isNull);
    });

    test('should handle batch operations with transactions', () async {
      final userService = UserService();
      
      final userDataList = [
        {
          'id': 'user_1',
          'username': 'user1',
          'email': 'user1@example.com',
          'nickname': 'User 1',
        },
        {
          'id': 'user_2',
          'username': 'user2',
          'email': 'user2@example.com',
          'nickname': 'User 2',
        },
        {
          'id': 'user_3',
          'username': 'user3',
          'email': 'user3@example.com',
          'nickname': 'User 3',
        },
      ];
      
      final users = await userService.batchCreateUsers(userDataList);
      expect(users.length, 3);
      
      // 验证所有用户都已创建
      final allUsers = await userService.getUserList();
      expect(allUsers.length, 3);
    });

    test('should handle user preferences through config service', () async {
      final configService = ConfigService();
      const userId = 'user_123';
      
      // 设置用户偏好
      await configService.setUserPreference(userId, 'theme', 'dark');
      await configService.setUserPreference(userId, 'language', 'zh-CN');
      await configService.setUserPreference(userId, 'notifications', true);
      
      // 获取用户偏好
      final preferences = await configService.getUserPreferences(userId);
      
      expect(preferences['theme'], 'dark');
      expect(preferences['language'], 'zh-CN');
      expect(preferences['notifications'], 'true'); // 注意：存储为字符串
    });

    test('should handle system configurations', () async {
      final configService = ConfigService();
      
      // 获取系统配置（包括默认配置）
      final systemConfigs = await configService.getSystemConfigs();
      
      expect(systemConfigs, isNotEmpty);
      expect(systemConfigs.containsKey('app_version'), true);
      expect(systemConfigs.containsKey('database_version'), true);
    });

    test('should provide storage statistics', () async {
      final statsService = StorageStatsService();
      final userService = UserService();
      
      // 插入一些测试数据
      await userService.createUser(
        id: 'user_1',
        username: 'testuser',
        email: 'test@example.com',
      );
      
      final stats = await statsService.getStorageStats();
      
      expect(stats['userCount'], 1);
      expect(stats['configCount'], greaterThanOrEqualTo(2));
      expect(stats['databaseSize'], greaterThan(0));
      expect(stats['isInitialized'], true);
    });

    test('should handle database maintenance operations', () async {
      final statsService = StorageStatsService();
      final userService = UserService();
      
      // 插入一些数据
      for (int i = 1; i <= 5; i++) {
        await userService.createUser(
          id: 'user_$i',
          username: 'user$i',
          email: 'user$i@example.com',
        );
      }
      
      // 删除一些数据
      for (int i = 1; i <= 3; i++) {
        await userService.deleteUser('user_$i');
      }
      
      final sizeBefore = (await statsService.getStorageStats())['databaseSize'];
      
      // 压缩数据库
      await statsService.compressDatabase();
      
      final sizeAfter = (await statsService.getStorageStats())['databaseSize'];
      
      // 压缩后大小应该小于等于压缩前
      expect(sizeAfter, lessThanOrEqualTo(sizeBefore));
    });

    test('should handle data model conversions correctly', () async {
      final userService = UserService();
      
      // 创建用户
      final user = await userService.createUser(
        id: 'user_1',
        username: 'testuser',
        email: 'test@example.com',
        nickname: 'Test User',
      );
      
      // 验证UserModel属性
      expect(user, isA<UserModel>());
      expect(user.id, 'user_1');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.nickname, 'Test User');
      expect(user.status, UserStatus.active);
      expect(user.emailVerified, false);
      expect(user.phoneVerified, false);
      
      // 验证业务逻辑方法
      expect(user.displayName, 'Test User');
      expect(user.isActive, true);
      expect(user.hasBasicInfo, true);
    });

    test('should handle complex search scenarios', () async {
      final userService = UserService();
      
      // 创建多个用户
      final users = [
        await userService.createUser(
          id: 'user_1',
          username: 'john_doe',
          email: 'john@example.com',
          nickname: 'John Doe',
        ),
        await userService.createUser(
          id: 'user_2',
          username: 'jane_smith',
          email: 'jane@example.com',
          nickname: 'Jane Smith',
        ),
        await userService.createUser(
          id: 'user_3',
          username: 'bob_johnson',
          email: 'bob@test.com',
          nickname: 'Bob Johnson',
        ),
      ];
      
      // 搜索包含 "john" 的用户
      final johnResults = await userService.searchUsers('john');
      expect(johnResults.length, 2);
      expect(johnResults.map((u) => u.id), containsAll(['user_1', 'user_3']));
      
      // 搜索邮箱包含 "example" 的用户
      final exampleResults = await userService.searchUsers('example');
      expect(exampleResults.length, 2);
      expect(exampleResults.map((u) => u.id), containsAll(['user_1', 'user_2']));
      
      // 根据邮箱查找用户
      final userByEmail = await userService.findUserByEmail('john@example.com');
      expect(userByEmail, isNotNull);
      expect(userByEmail!.id, 'user_1');
    });

    test('should handle error scenarios gracefully', () async {
      final userService = UserService();
      
      // 尝试获取不存在的用户
      final nonExistentUser = await userService.getUser('non_existent');
      expect(nonExistentUser, isNull);
      
      // 尝试删除不存在的用户（应该不抛出异常）
      await userService.deleteUser('non_existent');
      
      // 搜索不存在的关键词
      final emptyResults = await userService.searchUsers('nonexistent');
      expect(emptyResults, isEmpty);
    });
  });
}
