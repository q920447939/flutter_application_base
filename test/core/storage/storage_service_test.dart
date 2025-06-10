/// 存储服务测试
///
/// 测试同步和异步存储功能
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_base/core/storage/storage_service.dart';

void main() {
  group('StorageService Tests', () {
    late StorageService storageService;

    setUpAll(() async {
      // 初始化测试环境
      SharedPreferences.setMockInitialValues({});
      await Hive.initFlutter();
    });

    setUp(() async {
      storageService = StorageService.instance;
      await storageService.initialize();
    });

    tearDown(() async {
      // 清理测试数据
      storageService.clearMemoryCache();
    });

    group('同步Token操作', () {
      test('应该能够同步设置和获取Token', () {
        const testToken = 'test_token_12345';

        // 设置Token
        final setResult = storageService.setTokenSync(testToken);
        expect(setResult, isTrue);

        // 获取Token
        final retrievedToken = storageService.getTokenSync();
        expect(retrievedToken, equals(testToken));
      });

      test('应该能够检查Token是否存在', () {
        const testToken = 'test_token_12345';

        // 初始状态应该没有Token
        expect(storageService.hasTokenSync(), isFalse);

        // 设置Token后应该存在
        storageService.setTokenSync(testToken);
        expect(storageService.hasTokenSync(), isTrue);

        // 清除Token后应该不存在
        storageService.clearTokenSync();
        expect(storageService.hasTokenSync(), isFalse);
      });

      test('应该能够清除Token', () {
        const testToken = 'test_token_12345';

        // 设置Token
        storageService.setTokenSync(testToken);
        expect(storageService.getTokenSync(), equals(testToken));

        // 清除Token
        final clearResult = storageService.clearTokenSync();
        expect(clearResult, isTrue);
        expect(storageService.getTokenSync(), isNull);
      });
    });

    group('同步用户信息操作', () {
      test('应该能够同步设置和获取用户信息', () {
        final testUserInfo = {
          'id': 123,
          'name': 'Test User',
          'email': 'test@example.com',
        };

        // 设置用户信息
        final setResult = storageService.setUserInfoSync(testUserInfo);
        expect(setResult, isTrue);

        // 获取用户信息
        final retrievedUserInfo = storageService.getUserInfoSync();
        expect(retrievedUserInfo, equals(testUserInfo));
      });

      test('应该能够清除用户信息', () {
        final testUserInfo = {'id': 123, 'name': 'Test User'};

        // 设置用户信息
        storageService.setUserInfoSync(testUserInfo);
        expect(storageService.getUserInfoSync(), equals(testUserInfo));

        // 清除用户信息
        final clearResult = storageService.clearUserInfoSync();
        expect(clearResult, isTrue);
        expect(storageService.getUserInfoSync(), isNull);
      });
    });

    group('缓存策略测试', () {
      test('应该能够获取和设置缓存策略', () {
        const testKey = 'test_key';

        // 默认策略应该是persistent
        expect(
          storageService.getCacheStrategy(testKey),
          equals(CacheStrategy.persistent),
        );

        // 设置为memory策略
        storageService.setCacheStrategy(testKey, CacheStrategy.memory);
        expect(
          storageService.getCacheStrategy(testKey),
          equals(CacheStrategy.memory),
        );
      });

      test('内存缓存策略应该只在内存中存储', () {
        const testKey = 'memory_test_key';
        const testValue = 'memory_test_value';

        // 设置为内存缓存策略
        storageService.setCacheStrategy(testKey, CacheStrategy.memory);

        // 设置值
        final setResult = storageService.setStringSync(testKey, testValue);
        expect(setResult, isTrue);

        // 应该能够获取值
        final retrievedValue = storageService.getStringSync(testKey);
        expect(retrievedValue, equals(testValue));

        // 清除内存缓存后应该获取不到值
        storageService.clearMemoryCache();
        final valueAfterClear = storageService.getStringSync(testKey);
        expect(valueAfterClear, isNull);
      });
    });

    group('ISyncStorage接口实现测试', () {
      test('应该正确实现同步存储接口', () {
        const testKey = 'interface_test_key';
        const testValue = 'interface_test_value';

        // 测试setStringSync
        final setResult = storageService.setStringSync(testKey, testValue);
        expect(setResult, isTrue);

        // 测试getStringSync
        final retrievedValue = storageService.getStringSync(testKey);
        expect(retrievedValue, equals(testValue));

        // 测试containsKeySync
        expect(storageService.containsKeySync(testKey), isTrue);

        // 测试removeSync
        final removeResult = storageService.removeSync(testKey);
        expect(removeResult, isTrue);
        expect(storageService.containsKeySync(testKey), isFalse);
      });
    });
  });
}
