/// 用户名密码认证策略
///
/// 实现基于用户名密码的认证逻辑
library;

import 'package:flutter/foundation.dart';
import '../../../core/network/network_service.dart';
import '../models/auth_request.dart';
import '../models/auth_enums.dart';
import '../models/common_result.dart';
import '../models/login_response.dart';
import '../services/device_info_service.dart';
import 'auth_strategy.dart';

/// 用户名密码认证策略
class UsernamePasswordAuthStrategy extends BaseAuthStrategy {
  @override
  AuthTypeEnum get authType => AuthTypeEnum.usernamePassword;

  @override
  String get endpoint => '/api/auth/login/username';

  @override
  String get name => '用户名密码认证';

  @override
  String get description => '使用用户名和密码进行认证，需要图形验证码';

  @override
  int get priority => 10; // 高优先级

  @override
  Future<CommonResult<LoginResponse>> authenticate(
    BaseAuthRequest request,
  ) async {
    try {
      // 验证请求参数
      if (!validateRequest(request)) {
        return createParameterErrorResult(message: '请求参数验证失败');
      }

      // 预处理请求
      final processedRequest = await preprocessRequest(request);

      // 使用统一响应处理发送认证请求
      final result = await NetworkService.instance
          .postCommonResult<LoginResponse>(
            endpoint,
            data: processedRequest.toJson(),
            fromJson: (json) => LoginResponse.fromJson(json),
          );

      debugPrint('用户名密码认证结果: ${result.isSuccess}');

      // 后处理响应
      return await postprocessResponse(result);
    } catch (e) {
      debugPrint('用户名密码认证异常: $e');
      return createNetworkErrorResult(message: '认证请求失败: $e');
    }
  }

  @override
  bool validateRequest(BaseAuthRequest request) {
    // 验证基础请求参数
    if (!validateBaseRequest(request)) {
      return false;
    }

    // 验证具体的用户名密码请求参数
    if (request is! UsernamePasswordAuthRequest) {
      debugPrint('请求类型不匹配，期望: UsernamePasswordAuthRequest');
      return false;
    }

    return request.validate();
  }

  @override
  Future<BaseAuthRequest> preprocessRequest(BaseAuthRequest request) async {
    if (request is! UsernamePasswordAuthRequest) {
      return request;
    }

    try {
      // 自动填充设备信息和客户端IP
      final deviceInfo = await DeviceInfoService.instance.getDeviceInfo();
      final clientIp = await DeviceInfoService.instance.getClientIp();

      // 构建上下文信息
      final context = DeviceInfoService.instance.buildContext(
        additional: request.context,
      );

      // 创建增强的请求
      final enhancedRequest = request.copyWith(
        deviceInfo: deviceInfo,
        clientIp: clientIp,
        context: context,
      );

      debugPrint('用户名密码认证请求预处理完成');
      return enhancedRequest;
    } catch (e) {
      debugPrint('用户名密码认证请求预处理失败: $e');
      // 预处理失败时返回原始请求
      return request;
    }
  }

  @override
  Future<CommonResult<LoginResponse>> postprocessResponse(
    CommonResult<LoginResponse> response,
  ) async {
    // 调用基类的后处理
    final processedResponse = await super.postprocessResponse(response);

    // 如果认证成功，可以进行额外的处理
    if (processedResponse.isSuccess && processedResponse.data != null) {
      final loginResponse = processedResponse.data!;
      debugPrint('用户名密码认证成功，token: ${loginResponse.hasToken ? '已获取' : '未获取'}');

      // 这里可以添加认证成功后的额外逻辑
      // 例如：记录登录日志、更新用户状态等
    } else {
      debugPrint('用户名密码认证失败: ${processedResponse.msg}');
    }

    return processedResponse;
  }

  @override
  Map<int, String> get errorMessages => {
    ...super.errorMessages,
    // 用户名密码认证特有的错误码
    2001: '用户名格式不正确，应为6-30位字符',
    2002: '密码不能为空',
    2003: '验证码不能为空',
    2004: '验证码格式不正确，应为4-6位字符',
    2005: '验证码会话ID不能为空',
    2006: '用户名不存在',
    2007: '密码错误',
    2008: '验证码错误',
    2009: '验证码已过期',
    2010: '账户已被锁定',
    2011: '账户已被禁用',
    2012: '登录尝试次数过多，请稍后再试',
  };

  /// 验证用户名格式
  bool _validateUsername(String username) {
    if (username.isEmpty) return false;
    if (username.length < 6 || username.length > 30) return false;

    // 可以添加更多的用户名格式验证规则
    // 例如：只允许字母、数字、下划线等
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{6,30}$');
    return usernameRegex.hasMatch(username);
  }

  /// 验证密码格式
  bool _validatePassword(String password) {
    if (password.isEmpty) return false;

    // 可以添加密码强度验证规则
    // 例如：最少8位，包含大小写字母和数字等
    return password.length >= 6; // 简单验证，实际项目中应该更严格
  }

  /// 验证验证码格式
  bool _validateCaptcha(String captcha) {
    if (captcha.isEmpty) return false;
    if (captcha.length < 4 || captcha.length > 6) return false;

    // 验证码通常只包含字母和数字
    final captchaRegex = RegExp(r'^[a-zA-Z0-9]{4,6}$');
    return captchaRegex.hasMatch(captcha);
  }

  /// 获取详细的验证错误信息
  String getValidationErrorMessage(UsernamePasswordAuthRequest request) {
    if (!_validateUsername(request.username)) {
      return '用户名格式不正确，应为6-30位字母、数字或下划线';
    }

    if (!_validatePassword(request.password)) {
      return '密码不能为空且至少6位';
    }

    if (!_validateCaptcha(request.captcha)) {
      return '验证码格式不正确，应为4-6位字母或数字';
    }

    if (request.captchaSessionId.isEmpty) {
      return '验证码会话ID不能为空';
    }

    return '请求参数验证通过';
  }
}
