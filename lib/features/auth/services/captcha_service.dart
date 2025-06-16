/// 验证码服务
///
/// 提供验证码获取、刷新、验证等功能
library;

import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/network_service.dart';
import '../models/captcha_model.dart';
import '../models/common_result.dart';
import '../models/auth_enums.dart';

/// 验证码服务
class CaptchaService extends GetxService {
  static CaptchaService get instance => Get.find<CaptchaService>();

  /// 当前验证码信息
  final Rx<CaptchaInfo?> _currentCaptcha = Rx<CaptchaInfo?>(null);

  /// 验证码缓存（按sessionId存储）
  final Map<String, CaptchaInfo> _captchaCache = {};

  /// 最大缓存数量
  static const int _maxCacheSize = 10;

  /// 当前验证码信息
  CaptchaInfo? get currentCaptcha => _currentCaptcha.value;

  /// 当前验证码信息流
  Rx<CaptchaInfo?> get currentCaptchaStream => _currentCaptcha;

  @override
  void onInit() {
    super.onInit();
    debugPrint('验证码服务初始化完成');
  }

  @override
  void onClose() {
    _captchaCache.clear();
    super.onClose();
  }

  /// 获取图形验证码
  Future<CommonResult<CaptchaInfo>> getCaptcha({
    CaptchaRequest? request,
  }) async {
    try {
      // 使用统一的响应处理 - GET请求获取验证码
      final result = await NetworkService.instance
          .getCommonResult<Map<String, dynamic>>(
            '/api/auth/captcha/generate',
            fromJson: (json) => json,
          );

      if (result.isSuccess && result.data != null) {
        // 从后端响应数据构建CaptchaInfo
        final data = result.data!;
        final captchaInfo = CaptchaInfo(
          sessionId: data['sessionId'] as String,
          imageBase64: data['imageBase64'] as String,
          expireSeconds: data['expireSeconds'] as int,
          createdAt: DateTime.now(),
        );

        _updateCurrentCaptcha(captchaInfo);
        _addToCache(captchaInfo);
        debugPrint(
          '获取验证码成功: ${captchaInfo.sessionId}, 过期时间: ${captchaInfo.expireSeconds}秒',
        );

        return CommonResult.success(data: captchaInfo);
      } else {
        debugPrint('获取验证码失败: ${result.msg}');
        return CommonResult.failure(code: result.code, msg: result.msg);
      }
    } catch (e) {
      debugPrint('获取验证码异常: $e');
      return CommonResult.networkError(msg: '获取验证码异常: $e');
    }
  }

  /// 刷新验证码
  Future<CommonResult<CaptchaInfo>> refreshCaptcha({
    String? sessionId,
    CaptchaRequest? request,
  }) async {
    try {
      // 如果提供了sessionId，尝试刷新指定的验证码
      if (sessionId != null && sessionId.isNotEmpty) {
        final result = await NetworkService.instance
            .postCommonResult<CaptchaInfo>(
              '/api/auth/captcha/refresh',
              data: {'sessionId': sessionId},
              fromJson: (json) => CaptchaInfo.fromJson(json),
            );

        if (result.isSuccess && result.data != null) {
          final captchaInfo = result.data!;
          _updateCurrentCaptcha(captchaInfo);
          _addToCache(captchaInfo);
          debugPrint('刷新验证码成功: ${captchaInfo.sessionId}');
          return result;
        } else {
          debugPrint('刷新验证码失败: ${result.msg}');
          // 刷新失败，继续获取新验证码
        }
      }

      // 如果刷新失败或没有提供sessionId，获取新的验证码
      return await getCaptcha(request: request);
    } catch (e) {
      debugPrint('刷新验证码异常: $e');
      // 刷新失败时，尝试获取新的验证码
      return await getCaptcha(request: request);
    }
  }

  /// 验证验证码（可选的预验证）
  Future<CommonResult<bool>> verifyCaptcha({
    required String sessionId,
    required String code,
    CaptchaTypeEnum type = CaptchaTypeEnum.image,
  }) async {
    try {
      if (sessionId.isEmpty || code.isEmpty) {
        return CommonResult.parameterError(msg: '验证码参数不能为空');
      }

      final verifyRequest = CaptchaVerifyRequest(
        sessionId: sessionId,
        code: code,
        type: type,
      );

      final result = await NetworkService.instance.postCommonResult<bool>(
        '/api/auth/captcha/verify',
        data: verifyRequest.toJson(),
        fromJson: (json) => json['verified'] as bool? ?? false,
      );

      debugPrint('验证码验证结果: ${result.isSuccess}');
      return result;
    } catch (e) {
      debugPrint('验证码验证异常: $e');
      return CommonResult.networkError(msg: '验证码验证异常: $e');
    }
  }

  /// 获取短信验证码
  Future<CommonResult<CaptchaInfo>> getSmsCode({
    required String phone,
    int length = 6,
  }) async {
    final request = CaptchaRequest.sms(phone: phone, length: length);
    return await getCaptcha(request: request);
  }

  /// 获取邮箱验证码
  Future<CommonResult<CaptchaInfo>> getEmailCode({
    required String email,
    int length = 6,
  }) async {
    final request = CaptchaRequest.email(email: email, length: length);
    return await getCaptcha(request: request);
  }

  /// 检查当前验证码是否有效
  bool isCurrentCaptchaValid() {
    final captcha = _currentCaptcha.value;
    return captcha != null && !captcha.isExpired;
  }

  /// 检查当前验证码是否即将过期
  bool isCurrentCaptchaExpiringSoon() {
    final captcha = _currentCaptcha.value;
    return captcha != null && captcha.isExpiringSoon;
  }

  /// 清除当前验证码
  void clearCurrentCaptcha() {
    _currentCaptcha.value = null;
    debugPrint('已清除当前验证码');
  }

  /// 清除所有缓存的验证码
  void clearAllCaptcha() {
    _captchaCache.clear();
    _currentCaptcha.value = null;
    debugPrint('已清除所有验证码缓存');
  }

  /// 根据sessionId获取验证码信息
  CaptchaInfo? getCaptchaBySessionId(String sessionId) {
    return _captchaCache[sessionId];
  }

  /// 更新当前验证码
  void _updateCurrentCaptcha(CaptchaInfo captchaInfo) {
    _currentCaptcha.value = captchaInfo;
  }

  /// 添加到缓存
  void _addToCache(CaptchaInfo captchaInfo) {
    // 如果缓存已满，移除最旧的
    if (_captchaCache.length >= _maxCacheSize) {
      final oldestKey = _captchaCache.keys.first;
      _captchaCache.remove(oldestKey);
    }

    _captchaCache[captchaInfo.sessionId] = captchaInfo;
  }

  /// 清理过期的验证码缓存
  void _cleanExpiredCaptcha() {
    final now = DateTime.now();
    _captchaCache.removeWhere(
      (key, captcha) => captcha.expiresAt.isBefore(now),
    );
  }
}
