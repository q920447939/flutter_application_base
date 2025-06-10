/// 认证中间件
///
/// 用于保护需要认证的路由，采用策略模式和模板方法模式
/// 支持多种认证策略和可扩展的认证检查逻辑
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/storage_service.dart';

/// 认证策略接口
abstract class IAuthStrategy {
  /// 检查认证状态
  bool isAuthenticated();

  /// 获取重定向路由
  String getRedirectRoute();
}

/// Token认证策略
class TokenAuthStrategy implements IAuthStrategy {
  final StorageService _storageService;

  TokenAuthStrategy(this._storageService);

  @override
  bool isAuthenticated() {
    final token = _storageService.getTokenSync();
    return token != null && token.isNotEmpty && _isTokenValid(token);
  }

  @override
  String getRedirectRoute() => '/login';

  /// 检查Token是否有效（可扩展为JWT解析等）
  bool _isTokenValid(String token) {
    // 基础检查：token不为空且长度合理
    if (token.isEmpty || token.length < 10) {
      return false;
    }

    // TODO: 可以添加更复杂的Token验证逻辑
    // 例如：JWT解析、过期时间检查等
    return true;
  }
}

/// 用户信息认证策略
class UserInfoAuthStrategy implements IAuthStrategy {
  final StorageService _storageService;

  UserInfoAuthStrategy(this._storageService);

  @override
  bool isAuthenticated() {
    final token = _storageService.getTokenSync();
    final userInfo = _storageService.getUserInfoSync();
    return token != null &&
        token.isNotEmpty &&
        userInfo != null &&
        userInfo.isNotEmpty;
  }

  @override
  String getRedirectRoute() => '/login';
}

/// 认证中间件
class AuthMiddleware extends GetMiddleware {
  final IAuthStrategy _authStrategy;

  /// 构造函数，支持依赖注入
  AuthMiddleware({IAuthStrategy? authStrategy})
    : _authStrategy =
          authStrategy ?? TokenAuthStrategy(StorageService.instance);

  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // 使用策略模式检查认证状态
    if (!_authStrategy.isAuthenticated()) {
      // 未认证，重定向到登录页面
      return RouteSettings(name: _authStrategy.getRedirectRoute());
    }

    // 已认证，允许访问
    return null;
  }

  /// 获取当前认证策略
  IAuthStrategy get authStrategy => _authStrategy;
}
