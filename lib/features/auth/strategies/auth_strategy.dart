/// 认证策略接口
///
/// 定义认证策略的抽象接口，支持多种认证方式的扩展
library;

import '../models/auth_request.dart';
import '../models/auth_enums.dart';
import '../models/common_result.dart';
import '../models/login_response.dart';

/// 认证策略抽象类
abstract class AuthStrategy {
  /// 认证类型
  AuthTypeEnum get authType;

  /// 认证端点
  String get endpoint;

  /// 策略名称
  String get name;

  /// 策略描述
  String get description;

  /// 是否启用
  bool get enabled => true;

  /// 优先级（数字越小优先级越高）
  int get priority => 100;

  /// 执行认证
  Future<CommonResult<LoginResponse>> authenticate(BaseAuthRequest request);

  /// 验证请求参数
  bool validateRequest(BaseAuthRequest request);

  /// 预处理请求（可选）
  Future<BaseAuthRequest> preprocessRequest(BaseAuthRequest request) async {
    return request;
  }

  /// 后处理响应（可选）
  Future<CommonResult<LoginResponse>> postprocessResponse(
    CommonResult<LoginResponse> response,
  ) async {
    return response;
  }

  /// 获取错误消息映射
  Map<int, String> get errorMessages => {
    -1: '认证失败',
    -2: '参数错误',
    1001: '用户名或密码错误',
    1002: '验证码错误',
    1003: '账户被锁定',
    1004: '账户被禁用',
    1005: '验证码已过期',
    1006: '登录尝试次数过多',
  };

  /// 获取友好的错误消息
  String getFriendlyErrorMessage(int code, String defaultMessage) {
    return errorMessages[code] ?? defaultMessage;
  }
}

/// 认证策略基类
abstract class BaseAuthStrategy implements AuthStrategy {
  @override
  bool get enabled => true;

  @override
  int get priority => 100;

  @override
  Future<BaseAuthRequest> preprocessRequest(BaseAuthRequest request) async {
    // 默认不做预处理
    return request;
  }

  @override
  Future<CommonResult<LoginResponse>> postprocessResponse(
    CommonResult<LoginResponse> response,
  ) async {
    // 如果认证失败，转换错误消息为用户友好的消息
    if (response.isFailure) {
      final friendlyMessage = getFriendlyErrorMessage(
        response.code,
        response.msg,
      );
      return response.copyWith(msg: friendlyMessage);
    }
    return response;
  }

  @override
  Map<int, String> get errorMessages => {
    -1: '认证失败，请检查网络连接',
    -2: '请求参数错误',
    1001: '用户名或密码错误',
    1002: '验证码错误，请重新输入',
    1003: '账户已被锁定，请联系管理员',
    1004: '账户已被禁用，请联系管理员',
    1005: '验证码已过期，请重新获取',
    1006: '登录尝试次数过多，请稍后再试',
    1007: '用户不存在',
    1008: '密码格式不正确',
    1009: '验证码格式不正确',
    1010: '设备信息异常',
  };

  @override
  String getFriendlyErrorMessage(int code, String defaultMessage) {
    return errorMessages[code] ?? defaultMessage;
  }

  /// 验证通用请求参数
  bool validateBaseRequest(BaseAuthRequest request) {
    if (request.authType != authType) {
      return false;
    }
    return true;
  }

  /// 创建认证失败结果
  CommonResult<LoginResponse> createFailureResult({
    required int code,
    required String message,
  }) {
    final friendlyMessage = getFriendlyErrorMessage(code, message);
    return CommonResult<LoginResponse>.failure(
      code: code,
      msg: friendlyMessage,
    );
  }

  /// 创建参数错误结果
  CommonResult<LoginResponse> createParameterErrorResult({
    String message = '请求参数错误',
  }) {
    return createFailureResult(code: -2, message: message);
  }

  /// 创建网络错误结果
  CommonResult<LoginResponse> createNetworkErrorResult({
    String message = '网络连接失败',
  }) {
    return createFailureResult(code: -1, message: message);
  }
}

/// 认证策略工厂接口
abstract class AuthStrategyFactory {
  /// 创建认证策略
  AuthStrategy createStrategy(AuthTypeEnum authType);

  /// 获取所有支持的认证类型
  List<AuthTypeEnum> getSupportedAuthTypes();

  /// 检查是否支持指定的认证类型
  bool isSupported(AuthTypeEnum authType);
}

/// 认证策略注册器
class AuthStrategyRegistry {
  static final AuthStrategyRegistry _instance =
      AuthStrategyRegistry._internal();
  factory AuthStrategyRegistry() => _instance;
  AuthStrategyRegistry._internal();

  /// 策略映射
  final Map<AuthTypeEnum, AuthStrategy> _strategies = {};

  /// 注册策略
  void register(AuthStrategy strategy) {
    _strategies[strategy.authType] = strategy;
  }

  /// 获取策略
  AuthStrategy? getStrategy(AuthTypeEnum authType) {
    return _strategies[authType];
  }

  /// 获取所有策略
  List<AuthStrategy> getAllStrategies() {
    return _strategies.values.toList();
  }

  /// 获取启用的策略
  List<AuthStrategy> getEnabledStrategies() {
    return _strategies.values.where((strategy) => strategy.enabled).toList();
  }

  /// 按优先级排序的策略
  List<AuthStrategy> getStrategiesByPriority() {
    final strategies = getEnabledStrategies();
    strategies.sort((a, b) => a.priority.compareTo(b.priority));
    return strategies;
  }

  /// 清除所有策略
  void clear() {
    _strategies.clear();
  }

  /// 检查是否支持指定的认证类型
  bool isSupported(AuthTypeEnum authType) {
    final strategy = _strategies[authType];
    return strategy != null && strategy.enabled;
  }
}
