/// 认证中间件测试
///
/// 测试认证中间件的各种策略和功能
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_base/core/router/auth_middleware.dart';
import 'package:flutter_application_base/core/storage/storage_service.dart';

/// 模拟认证策略
class MockAuthStrategy implements IAuthStrategy {
  bool _isAuthenticated;
  String _redirectRoute;

  MockAuthStrategy({
    bool isAuthenticated = false,
    String redirectRoute = '/login',
  }) : _isAuthenticated = isAuthenticated,
       _redirectRoute = redirectRoute;

  @override
  bool isAuthenticated() => _isAuthenticated;

  @override
  String getRedirectRoute() => _redirectRoute;

  void setAuthenticated(bool value) => _isAuthenticated = value;
  void setRedirectRoute(String route) => _redirectRoute = route;
}

void main() {
  group('AuthMiddleware Tests', () {
    late StorageService storageService;

    setUpAll(() async {
      // 初始化测试环境
      SharedPreferences.setMockInitialValues({});
      await Hive.initFlutter();
    });

    setUp(() async {
      storageService = StorageService.instance;
      await storageService.initialize();
      // 清理之前的测试数据
      storageService.clearTokenSync();
      storageService.clearUserInfoSync();
    });

    group('TokenAuthStrategy Tests', () {
      test('应该在有有效Token时返回已认证', () {
        final strategy = TokenAuthStrategy(storageService);

        // 设置有效Token
        storageService.setTokenSync('valid_token_1234567890');

        expect(strategy.isAuthenticated(), isTrue);
        expect(strategy.getRedirectRoute(), equals('/login'));
      });

      test('应该在没有Token时返回未认证', () {
        final strategy = TokenAuthStrategy(storageService);

        expect(strategy.isAuthenticated(), isFalse);
      });

      test('应该在Token太短时返回未认证', () {
        final strategy = TokenAuthStrategy(storageService);

        // 设置过短的Token
        storageService.setTokenSync('short');

        expect(strategy.isAuthenticated(), isFalse);
      });

      test('应该在Token为空时返回未认证', () {
        final strategy = TokenAuthStrategy(storageService);

        // 设置空Token
        storageService.setTokenSync('');

        expect(strategy.isAuthenticated(), isFalse);
      });
    });

    group('UserInfoAuthStrategy Tests', () {
      test('应该在有Token和用户信息时返回已认证', () {
        final strategy = UserInfoAuthStrategy(storageService);

        // 设置Token和用户信息
        storageService.setTokenSync('valid_token_1234567890');
        storageService.setUserInfoSync({'id': 123, 'name': 'Test User'});

        expect(strategy.isAuthenticated(), isTrue);
      });

      test('应该在只有Token没有用户信息时返回未认证', () {
        final strategy = UserInfoAuthStrategy(storageService);

        // 只设置Token
        storageService.setTokenSync('valid_token_1234567890');

        expect(strategy.isAuthenticated(), isFalse);
      });

      test('应该在只有用户信息没有Token时返回未认证', () {
        final strategy = UserInfoAuthStrategy(storageService);

        // 只设置用户信息
        storageService.setUserInfoSync({'id': 123, 'name': 'Test User'});

        expect(strategy.isAuthenticated(), isFalse);
      });
    });

    group('AuthMiddleware Tests', () {
      test('应该在已认证时允许访问', () {
        final mockStrategy = MockAuthStrategy(isAuthenticated: true);
        final middleware = AuthMiddleware(authStrategy: mockStrategy);

        final result = middleware.redirect('/protected');

        expect(result, isNull);
      });

      test('应该在未认证时重定向到登录页', () {
        final mockStrategy = MockAuthStrategy(
          isAuthenticated: false,
          redirectRoute: '/login',
        );
        final middleware = AuthMiddleware(authStrategy: mockStrategy);

        final result = middleware.redirect('/protected');

        expect(result, isNotNull);
        expect(result!.name, equals('/login'));
      });

      test('应该支持自定义重定向路由', () {
        final mockStrategy = MockAuthStrategy(
          isAuthenticated: false,
          redirectRoute: '/custom-login',
        );
        final middleware = AuthMiddleware(authStrategy: mockStrategy);

        final result = middleware.redirect('/protected');

        expect(result, isNotNull);
        expect(result!.name, equals('/custom-login'));
      });

      test('应该使用默认TokenAuthStrategy', () {
        final middleware = AuthMiddleware();

        expect(middleware.authStrategy, isA<TokenAuthStrategy>());
      });

      test('应该有正确的优先级', () {
        final middleware = AuthMiddleware();

        expect(middleware.priority, equals(1));
      });
    });

    group('集成测试', () {
      test('完整的认证流程应该正常工作', () {
        // 创建使用真实存储的中间件
        final middleware = AuthMiddleware();

        // 初始状态应该未认证
        var result = middleware.redirect('/protected');
        expect(result, isNotNull);
        expect(result!.name, equals('/login'));

        // 设置Token后应该已认证
        storageService.setTokenSync('valid_token_1234567890');
        result = middleware.redirect('/protected');
        expect(result, isNull);

        // 清除Token后应该未认证
        storageService.clearTokenSync();
        result = middleware.redirect('/protected');
        expect(result, isNotNull);
        expect(result!.name, equals('/login'));
      });
    });
  });
}
