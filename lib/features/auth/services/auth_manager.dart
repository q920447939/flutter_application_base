/// 认证管理器
///
/// 统一管理各种认证策略，提供认证服务的统一入口
library;

import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/auth_request.dart';
import '../models/auth_enums.dart';
import '../models/common_result.dart';
import '../models/login_response.dart';
import '../strategies/auth_strategy.dart';
import '../strategies/username_password_auth_strategy.dart';
import 'auth_service.dart';

/// 认证管理器
class AuthManager extends GetxService {
  static AuthManager get instance => Get.find<AuthManager>();

  /// 认证策略注册器
  final AuthStrategyRegistry _strategyRegistry = AuthStrategyRegistry();

  /// 当前认证状态
  final Rx<AuthStatus> _authStatus = Rx<AuthStatus>(AuthStatus.initial);

  /// 认证统计信息
  final Map<AuthTypeEnum, int> _authAttempts = {};
  final Map<AuthTypeEnum, int> _authSuccesses = {};
  final Map<AuthTypeEnum, int> _authFailures = {};

  /// 当前认证状态
  AuthStatus get authStatus => _authStatus.value;

  /// 认证状态流
  Rx<AuthStatus> get authStatusStream => _authStatus;

  @override
  void onInit() {
    super.onInit();
    _initializeStrategies();
    debugPrint('认证管理器初始化完成');
  }

  @override
  void onClose() {
    _strategyRegistry.clear();
    _authAttempts.clear();
    _authSuccesses.clear();
    _authFailures.clear();
    super.onClose();
  }

  /// 执行认证
  Future<CommonResult<LoginResponse>> authenticate(
    BaseAuthRequest request,
  ) async {
    try {
      _authStatus.value = AuthStatus.loading;
      _recordAuthAttempt(request.authType);

      // 获取对应的认证策略
      final strategy = _strategyRegistry.getStrategy(request.authType);
      if (strategy == null) {
        final errorMsg = '不支持的认证类型: ${request.authType.description}';
        debugPrint(errorMsg);
        _authStatus.value = AuthStatus.unauthenticated;
        _recordAuthFailure(request.authType);
        return CommonResult.failure(code: -3, msg: errorMsg);
      }

      // 检查策略是否启用
      if (!strategy.enabled) {
        final errorMsg = '认证策略已禁用: ${strategy.name}';
        debugPrint(errorMsg);
        _authStatus.value = AuthStatus.unauthenticated;
        _recordAuthFailure(request.authType);
        return CommonResult.failure(code: -4, msg: errorMsg);
      }

      debugPrint('开始执行认证，策略: ${strategy.name}');

      // 执行认证
      final result = await strategy.authenticate(request);

      if (result.isSuccess) {
        _authStatus.value = AuthStatus.authenticated;
        _recordAuthSuccess(request.authType);
        debugPrint('认证成功，策略: ${strategy.name}');
      } else {
        _authStatus.value = AuthStatus.unauthenticated;
        _recordAuthFailure(request.authType);
        debugPrint('认证失败，策略: ${strategy.name}, 错误: ${result.msg}');
      }

      return result;
    } catch (e) {
      _authStatus.value = AuthStatus.unauthenticated;
      _recordAuthFailure(request.authType);
      debugPrint('认证异常: $e');
      return CommonResult.networkError(msg: '认证过程发生异常: $e');
    }
  }

  /// 用户名密码认证（便捷方法）
  Future<CommonResult<LoginResponse>> authenticateWithUsername({
    required String username,
    required String password,
    required String captcha,
    required String captchaSessionId,
    Map<String, Object>? context,
  }) async {
    final request = UsernamePasswordAuthRequest(
      username: username,
      password: password,
      captcha: captcha,
      captchaSessionId: captchaSessionId,
      context: context,
    );

    return await authenticate(request);
  }

  /// 注册新的认证策略
  void registerStrategy(AuthStrategy strategy) {
    _strategyRegistry.register(strategy);
    debugPrint('注册认证策略: ${strategy.name}');
  }

  /// 获取所有支持的认证类型
  List<AuthTypeEnum> getSupportedAuthTypes() {
    return _strategyRegistry
        .getEnabledStrategies()
        .map((strategy) => strategy.authType)
        .toList();
  }

  /// 检查是否支持指定的认证类型
  bool isAuthTypeSupported(AuthTypeEnum authType) {
    return _strategyRegistry.isSupported(authType);
  }

  /// 获取认证策略信息
  AuthStrategy? getAuthStrategy(AuthTypeEnum authType) {
    return _strategyRegistry.getStrategy(authType);
  }

  /// 获取所有启用的认证策略
  List<AuthStrategy> getEnabledStrategies() {
    return _strategyRegistry.getEnabledStrategies();
  }

  /// 按优先级获取认证策略
  List<AuthStrategy> getStrategiesByPriority() {
    return _strategyRegistry.getStrategiesByPriority();
  }

  /// 获取认证统计信息
  Map<String, dynamic> getAuthStatistics() {
    return {
      'attempts': Map<String, int>.from(
        _authAttempts.map((key, value) => MapEntry(key.value, value)),
      ),
      'successes': Map<String, int>.from(
        _authSuccesses.map((key, value) => MapEntry(key.value, value)),
      ),
      'failures': Map<String, int>.from(
        _authFailures.map((key, value) => MapEntry(key.value, value)),
      ),
    };
  }

  /// 获取认证成功率
  double getAuthSuccessRate(AuthTypeEnum authType) {
    final attempts = _authAttempts[authType] ?? 0;
    final successes = _authSuccesses[authType] ?? 0;

    if (attempts == 0) return 0.0;
    return successes / attempts;
  }

  /// 清除认证统计信息
  void clearAuthStatistics() {
    _authAttempts.clear();
    _authSuccesses.clear();
    _authFailures.clear();
    debugPrint('认证统计信息已清除');
  }

  /// 重置认证状态
  void resetAuthStatus() {
    _authStatus.value = AuthStatus.initial;
    debugPrint('认证状态已重置');
  }

  /// 初始化认证策略
  void _initializeStrategies() {
    // 注册用户名密码认证策略
    registerStrategy(UsernamePasswordAuthStrategy());

    // 这里可以注册其他认证策略
    // registerStrategy(PhonePasswordAuthStrategy());
    // registerStrategy(EmailPasswordAuthStrategy());
    // registerStrategy(PhoneCodeAuthStrategy());
    // registerStrategy(EmailCodeAuthStrategy());

    debugPrint('认证策略初始化完成，支持的认证类型: ${getSupportedAuthTypes()}');
  }

  /// 记录认证尝试
  void _recordAuthAttempt(AuthTypeEnum authType) {
    _authAttempts[authType] = (_authAttempts[authType] ?? 0) + 1;
  }

  /// 记录认证成功
  void _recordAuthSuccess(AuthTypeEnum authType) {
    _authSuccesses[authType] = (_authSuccesses[authType] ?? 0) + 1;
  }

  /// 记录认证失败
  void _recordAuthFailure(AuthTypeEnum authType) {
    _authFailures[authType] = (_authFailures[authType] ?? 0) + 1;
  }
}
