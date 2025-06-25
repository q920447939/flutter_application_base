/// 用户仓储测试
/// 
/// 测试UserRepository的所有功能
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_application_base/core/storage/database/app_database.dart';
import 'package:flutter_application_base/core/storage/repositories/user_repository.dart';
import 'package:flutter_application_base/core/storage/models/user_entity.dart';

void main() {
  group('UserRepository Tests', () {
    late AppDatabase database;
    late UserRepository userRepository;

    setUp(() async {
      // 为每个测试创建内存数据库
      database = AppDatabase.connect(NativeDatabase.memory(logStatements: true));
      userRepository = UserRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('should insert user entity', () async {
      final now = DateTime.now();
      final entity = UserEntity(
        id: 'user_1',
        username: 'testuser',
        email: 'test@example.com',
        nickname: 'Test User',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      final result = await userRepository.insert(entity);

      expect(result.id, entity.id);
      expect(result.username, entity.username);
      expect(result.email, entity.email);
      expect(result.nickname, entity.nickname);
    });

    test('should find user by id', () async {
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

      // 查找用户
      final found = await userRepository.findById('user_1');

      expect(found, isNotNull);
      expect(found!.id, 'user_1');
      expect(found.username, 'testuser');
      expect(found.email, 'test@example.com');
    });

    test('should return null when user not found', () async {
      final found = await userRepository.findById('non_existent');
      expect(found, isNull);
    });

    test('should find all users', () async {
      final now = DateTime.now();
      
      // 插入多个用户
      for (int i = 1; i <= 3; i++) {
        final entity = UserEntity(
          id: 'user_$i',
          username: 'user$i',
          email: 'user$i@example.com',
          createdAt: now,
          updatedAt: now,
        );
        await userRepository.insert(entity);
      }

      final users = await userRepository.findAll();

      expect(users.length, 3);
      expect(users.map((u) => u.id), containsAll(['user_1', 'user_2', 'user_3']));
    });

    test('should support pagination', () async {
      final now = DateTime.now();
      
      // 插入10个用户
      for (int i = 1; i <= 10; i++) {
        final entity = UserEntity(
          id: 'user_$i',
          username: 'user$i',
          email: 'user$i@example.com',
          createdAt: now.add(Duration(minutes: i)), // 不同的创建时间
          updatedAt: now.add(Duration(minutes: i)),
        );
        await userRepository.insert(entity);
      }

      // 测试第一页
      final page1 = await userRepository.findPage(1, 3);
      expect(page1.data.length, 3);
      expect(page1.total, 10);
      expect(page1.page, 1);
      expect(page1.size, 3);
      expect(page1.totalPages, 4);
      expect(page1.hasNext, true);
      expect(page1.hasPrevious, false);

      // 测试第二页
      final page2 = await userRepository.findPage(2, 3);
      expect(page2.data.length, 3);
      expect(page2.page, 2);
      expect(page2.hasNext, true);
      expect(page2.hasPrevious, true);

      // 测试最后一页
      final lastPage = await userRepository.findPage(4, 3);
      expect(lastPage.data.length, 1);
      expect(lastPage.hasNext, false);
      expect(lastPage.hasPrevious, true);
    });

    test('should update user entity', () async {
      final now = DateTime.now();
      
      // 插入用户
      final entity = UserEntity(
        id: 'user_1',
        username: 'testuser',
        email: 'test@example.com',
        nickname: 'Original Name',
        createdAt: now,
        updatedAt: now,
      );
      await userRepository.insert(entity);

      // 更新用户
      final updatedEntity = entity.copyWith(
        nickname: 'Updated Name',
        updatedAt: now.add(const Duration(hours: 1)),
      );
      await userRepository.update(updatedEntity);

      // 验证更新
      final found = await userRepository.findById('user_1');
      expect(found!.nickname, 'Updated Name');
    });

    test('should delete user', () async {
      final now = DateTime.now();
      
      // 插入用户
      final entity = UserEntity(
        id: 'user_1',
        username: 'testuser',
        email: 'test@example.com',
        createdAt: now,
        updatedAt: now,
      );
      await userRepository.insert(entity);

      // 删除用户
      await userRepository.delete('user_1');

      // 验证删除
      final found = await userRepository.findById('user_1');
      expect(found, isNull);
    });

    test('should batch insert users', () async {
      final now = DateTime.now();
      final entities = <UserEntity>[];
      
      for (int i = 1; i <= 5; i++) {
        entities.add(UserEntity(
          id: 'user_$i',
          username: 'user$i',
          email: 'user$i@example.com',
          createdAt: now,
          updatedAt: now,
        ));
      }

      await userRepository.insertAll(entities);

      final users = await userRepository.findAll();
      expect(users.length, 5);
    });

    test('should batch delete users', () async {
      final now = DateTime.now();
      
      // 插入多个用户
      for (int i = 1; i <= 5; i++) {
        final entity = UserEntity(
          id: 'user_$i',
          username: 'user$i',
          email: 'user$i@example.com',
          createdAt: now,
          updatedAt: now,
        );
        await userRepository.insert(entity);
      }

      // 批量删除
      await userRepository.deleteAll(['user_1', 'user_3', 'user_5']);

      final remaining = await userRepository.findAll();
      expect(remaining.length, 2);
      expect(remaining.map((u) => u.id), containsAll(['user_2', 'user_4']));
    });

    test('should count users', () async {
      final now = DateTime.now();
      
      // 插入用户
      for (int i = 1; i <= 7; i++) {
        final entity = UserEntity(
          id: 'user_$i',
          username: 'user$i',
          email: 'user$i@example.com',
          createdAt: now,
          updatedAt: now,
        );
        await userRepository.insert(entity);
      }

      final count = await userRepository.count();
      expect(count, 7);
    });

    test('should check if user exists', () async {
      final now = DateTime.now();
      final entity = UserEntity(
        id: 'user_1',
        username: 'testuser',
        email: 'test@example.com',
        createdAt: now,
        updatedAt: now,
      );
      await userRepository.insert(entity);

      expect(await userRepository.exists('user_1'), true);
      expect(await userRepository.exists('non_existent'), false);
    });

    test('should find user by username', () async {
      final now = DateTime.now();
      final entity = UserEntity(
        id: 'user_1',
        username: 'testuser',
        email: 'test@example.com',
        createdAt: now,
        updatedAt: now,
      );
      await userRepository.insert(entity);

      final found = await userRepository.findByUsername('testuser');
      expect(found, isNotNull);
      expect(found!.id, 'user_1');
    });

    test('should find user by email', () async {
      final now = DateTime.now();
      final entity = UserEntity(
        id: 'user_1',
        username: 'testuser',
        email: 'test@example.com',
        createdAt: now,
        updatedAt: now,
      );
      await userRepository.insert(entity);

      final found = await userRepository.findByEmail('test@example.com');
      expect(found, isNotNull);
      expect(found!.id, 'user_1');
    });

    test('should search users by keyword', () async {
      final now = DateTime.now();
      
      // 插入测试用户
      final users = [
        UserEntity(
          id: 'user_1',
          username: 'john_doe',
          nickname: 'John Doe',
          email: 'john@example.com',
          createdAt: now,
          updatedAt: now,
        ),
        UserEntity(
          id: 'user_2',
          username: 'jane_smith',
          nickname: 'Jane Smith',
          email: 'jane@example.com',
          createdAt: now,
          updatedAt: now,
        ),
        UserEntity(
          id: 'user_3',
          username: 'bob_johnson',
          nickname: 'Bob Johnson',
          email: 'bob@test.com',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      for (final user in users) {
        await userRepository.insert(user);
      }

      // 搜索包含 "john" 的用户
      final results = await userRepository.searchUsers('john');
      expect(results.length, 2);
      expect(results.map((u) => u.id), containsAll(['user_1', 'user_3']));

      // 搜索邮箱包含 "example" 的用户
      final emailResults = await userRepository.searchUsers('example');
      expect(emailResults.length, 2);
      expect(emailResults.map((u) => u.id), containsAll(['user_1', 'user_2']));
    });

    test('should clear all users', () async {
      final now = DateTime.now();
      
      // 插入用户
      for (int i = 1; i <= 3; i++) {
        final entity = UserEntity(
          id: 'user_$i',
          username: 'user$i',
          email: 'user$i@example.com',
          createdAt: now,
          updatedAt: now,
        );
        await userRepository.insert(entity);
      }

      await userRepository.clear();

      final count = await userRepository.count();
      expect(count, 0);
    });
  });
}
