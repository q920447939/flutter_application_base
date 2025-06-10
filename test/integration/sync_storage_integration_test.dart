/// 同步存储集成测试
///
/// 测试完整的认证流程和同步存储功能
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_base/core/storage/storage_service.dart';
import 'package:flutter_application_base/core/router/auth_middleware.dart';

void main() {
  group('同步存储集成测试', () {
    late StorageService storageService;

    setUpAll(() async {
      // 初始化测试环境
      SharedPreferences.setMockInitialValues({});
      await Hive.initFlutter();
    });

    setUp(() async {
      storageService = StorageService.instance;
      await storageService.initialize();
      // 清理测试数据
      storageService.clearTokenSync();
      storageService.clearUserInfoSync();
      storageService.clearMemoryCache();
    });

    test('完整的认证流程应该正常工作', () async {
      // 1. 初始状态：未认证
      expect(storageService.getTokenSync(), isNull);
      expect(storageService.hasTokenSync(), isFalse);

      // 2. 设置Token（模拟登录）
      const testToken = 'test_token_1234567890';
      final setResult = storageService.setTokenSync(testToken);
      expect(setResult, isTrue);
      expect(storageService.getTokenSync(), equals(testToken));
      expect(storageService.hasTokenSync(), isTrue);

      // 3. 设置用户信息
      final userInfo = {
        'id': 123,
        'name': 'Test User',
        'email': 'test@example.com',
      };
      storageService.setUserInfoSync(userInfo);
      expect(storageService.getUserInfoSync(), equals(userInfo));

      // 4. 测试认证中间件
      final middleware = AuthMiddleware();
      expect(middleware.redirect('/protected'), isNull); // 应该允许访问

      // 5. 清除Token（模拟登出）
      storageService.clearTokenSync();
      expect(storageService.getTokenSync(), isNull);
      expect(storageService.hasTokenSync(), isFalse);

      // 6. 认证中间件应该重定向到登录页
      final redirectResult = middleware.redirect('/protected');
      expect(redirectResult, isNotNull);
      expect(redirectResult!.name, equals('/login'));
    });

    test('异步和同步操作应该保持一致', () async {
      const testToken = 'async_sync_test_token';
      
      // 异步设置Token
      await storageService.setToken(testToken);
      
      // 同步获取应该返回相同的Token
      expect(storageService.getTokenSync(), equals(testToken));
      
      // 同步设置新Token
      const newToken = 'new_sync_token';
      storageService.setTokenSync(newToken);
      
      // 异步获取应该返回新Token
      final asyncToken = await storageService.getToken();
      expect(asyncToken, equals(newToken));
    });

    test('缓存策略应该正确工作', () {
      // 测试内存缓存策略
      storageService.setCacheStrategy('memory_key', CacheStrategy.memory);
      storageService.setStringSync('memory_key', 'memory_value');
      expect(storageService.getStringSync('memory_key'), equals('memory_value'));
      
      // 清除内存缓存后应该获取不到值
      storageService.clearMemoryCache();
      expect(storageService.getStringSync('memory_key'), isNull);
      
      // 测试持久化缓存策略
      storageService.setCacheStrategy('persistent_key', CacheStrategy.persistent);
      storageService.setStringSync('persistent_key', 'persistent_value');
      expect(storageService.getStringSync('persistent_key'), equals('persistent_value'));
      
      // 清除内存缓存不应该影响持久化数据
      storageService.clearMemoryCache();
      expect(storageService.getStringSync('persistent_key'), equals('persistent_value'));
    });

    test('认证策略应该正确工作', () {
      // TokenAuthStrategy 测试
      final tokenStrategy = TokenAuthStrategy(storageService);
      
      // 没有Token时应该未认证
      expect(tokenStrategy.isAuthenticated(), isFalse);
      
      // 设置有效Token后应该已认证
      storageService.setTokenSync('valid_token_1234567890');
      expect(tokenStrategy.isAuthenticated(), isTrue);
      
      // 设置无效Token（太短）应该未认证
      storageService.setTokenSync('short');
      expect(tokenStrategy.isAuthenticated(), isFalse);
      
      // UserInfoAuthStrategy 测试
      final userInfoStrategy = UserInfoAuthStrategy(storageService);
      
      // 只有Token没有用户信息应该未认证
      storageService.setTokenSync('valid_token_1234567890');
      expect(userInfoStrategy.isAuthenticated(), isFalse);
      
      // 有Token和用户信息应该已认证
      storageService.setUserInfoSync({'id': 123, 'name': 'Test'});
      expect(userInfoStrategy.isAuthenticated(), isTrue);
    });

    test('错误处理应该正确工作', () {
      // 测试JSON解析错误
      storageService.setCacheStrategy('invalid_json', CacheStrategy.memory);
      storageService.setStringSync('invalid_json', 'invalid json string');
      
      // getUserInfoSync 应该处理JSON解析错误
      expect(storageService.getUserInfoSync(), isNull);
      
      // 测试空值处理
      expect(storageService.getStringSync('non_existent_key'), isNull);
      expect(storageService.containsKeySync('non_existent_key'), isFalse);
    });

    test('内存缓存管理应该正确工作', () {
      // 设置一些测试数据
      storageService.setCacheStrategy('test1', CacheStrategy.memory);
      storageService.setCacheStrategy('test2', CacheStrategy.memory);
      
      storageService.setStringSync('test1', 'value1');
      storageService.setStringSync('test2', 'value2');
      
      expect(storageService.getStringSync('test1'), equals('value1'));
      expect(storageService.getStringSync('test2'), equals('value2'));
      
      // 清除内存缓存
      storageService.clearMemoryCache();
      
      expect(storageService.getStringSync('test1'), isNull);
      expect(storageService.getStringSync('test2'), isNull);
      
      // 手动更新内存缓存
      storageService.updateMemoryCache('test1', 'new_value1');
      expect(storageService.getStringSync('test1'), equals('new_value1'));
      
      // 删除特定缓存项
      storageService.updateMemoryCache('test1', null);
      expect(storageService.getStringSync('test1'), isNull);
    });

    test('混合缓存策略应该正确工作', () {
      storageService.setCacheStrategy('hybrid_key', CacheStrategy.hybrid);
      
      // 设置值应该同时存储在内存和持久化存储中
      storageService.setStringSync('hybrid_key', 'hybrid_value');
      expect(storageService.getStringSync('hybrid_key'), equals('hybrid_value'));
      
      // 清除内存缓存后应该从持久化存储获取
      storageService.clearMemoryCache();
      expect(storageService.getStringSync('hybrid_key'), equals('hybrid_value'));
    });
  });
}
