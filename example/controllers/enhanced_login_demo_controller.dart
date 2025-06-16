/// 增强版登录演示控制器
///
/// 支持新的认证架构，包括验证码、多种认证方式等
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_base/features/auth/services/auth_service.dart';
import 'package:flutter_application_base/features/auth/services/captcha_service.dart';
import 'package:flutter_application_base/features/auth/models/captcha_model.dart';
import 'package:flutter_application_base/features/auth/models/auth_enums.dart';
import 'package:flutter_application_base/features/auth/models/auth_request.dart';
import 'package:flutter_application_base/features/auth/config/auth_config.dart';
import 'package:flutter_application_base/features/auth/services/auth_manager.dart';
import 'package:flutter_application_base/features/auth/validators/auth_request_validator.dart';
import 'package:flutter_application_base/core/validation/validation_mixin.dart';

/// 增强版登录演示控制器
class EnhancedLoginDemoController extends GetxController with ValidationMixin {
  /// 表单Key
  final formKey = GlobalKey<FormState>();

  /// 用户名控制器
  final usernameController = TextEditingController();

  /// 密码控制器
  final passwordController = TextEditingController();

  /// 验证码控制器
  final captchaController = TextEditingController();

  /// 是否显示密码
  final RxBool showPassword = false.obs;

  /// 记住登录状态
  final RxBool rememberMe = false.obs;

  /// 当前验证码信息
  final Rx<CaptchaInfo?> captchaInfo = Rx<CaptchaInfo?>(null);

  /// 认证类型
  final Rx<AuthTypeEnum> authType = AuthTypeEnum.usernamePassword.obs;

  /// 是否正在加载验证码
  final RxBool isLoadingCaptcha = false.obs;

  /// 是否正在加载（登录过程）
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 自动加载验证码
    loadCaptcha();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    captchaController.dispose();
    super.onClose();
  }

  /// 切换密码显示状态
  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  /// 切换记住登录状态
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  /// 加载验证码
  Future<void> loadCaptcha() async {
    try {
      isLoadingCaptcha.value = true;

      final result = await CaptchaService.instance.getCaptcha();

      if (result.isSuccess && result.data != null) {
        captchaInfo.value = result.data;
        captchaController.clear(); // 清空验证码输入
      } else {
        addGlobalError(result.msg);
      }
    } catch (e) {
      addGlobalError('获取验证码失败: $e');
    } finally {
      isLoadingCaptcha.value = false;
    }
  }

  /// 刷新验证码
  Future<void> refreshCaptcha() async {
    final currentCaptcha = captchaInfo.value;
    if (currentCaptcha != null) {
      try {
        isLoadingCaptcha.value = true;

        final result = await CaptchaService.instance.refreshCaptcha(
          sessionId: currentCaptcha.sessionId,
        );

        if (result.isSuccess && result.data != null) {
          captchaInfo.value = result.data;
          captchaController.clear(); // 清空验证码输入
        } else {
          // 刷新失败，重新获取
          await loadCaptcha();
        }
      } catch (e) {
        // 刷新失败，重新获取
        await loadCaptcha();
      } finally {
        isLoadingCaptcha.value = false;
      }
    } else {
      await loadCaptcha();
    }
  }

  /// 用户名密码登录
  Future<void> loginWithUsername() async {
    // 清除之前的验证错误
    clearValidationErrors();

    final captcha = captchaInfo.value;
    if (captcha == null) {
      showWarningMessage('请先获取验证码');
      return;
    }

    if (captcha.isExpired) {
      showWarningMessage('验证码已过期，请重新获取');
      await loadCaptcha();
      return;
    }

    // 创建认证请求对象
    final request = UsernamePasswordAuthRequest(
      username: usernameController.text.trim(),
      password: passwordController.text,
      captcha: captchaController.text.trim(),
      captchaSessionId: captcha.sessionId,
    );

    // 使用统一验证框架进行验证
    final validator = UsernamePasswordAuthRequestValidator();
    final validationResult = validateAndShow(validator, request);

    if (!validationResult.isValid) {
      // 验证失败，错误信息已自动显示
      return;
    }

    try {
      isLoading.value = true;

      final success = await AuthService.instance.loginWithUsername(
        username: request.username,
        password: request.password,
        captcha: request.captcha,
        captchaSessionId: request.captchaSessionId,
      );

      if (success) {
        showSuccessMessage('登录成功');
        // 登录成功后导航到主页
        Get.offAllNamed('/home');
      } else {
        addGlobalError('登录失败，请检查用户名、密码和验证码');
        // 登录失败时刷新验证码
        await refreshCaptcha();
      }
    } catch (e) {
      addGlobalError('登录失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 忘记密码
  void forgotPassword() {
    Get.toNamed(
      '/forgot-password',
      arguments: {'username': usernameController.text.trim()},
    );
  }

  /// 去注册页面
  void goToRegister() {
    Get.toNamed('/register');
  }

  /// 验证用户名
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '用户名不能为空';
    }

    final config = AuthConfigManager.instance;
    final minLength = config.getUsernameMinLength();
    final maxLength = config.getUsernameMaxLength();

    if (value.length < minLength) {
      return '用户名至少$minLength个字符';
    }

    if (value.length > maxLength) {
      return '用户名最多$maxLength个字符';
    }

    // 用户名格式验证（字母、数字、下划线）
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return '用户名只能包含字母、数字和下划线';
    }

    return null;
  }

  /// 验证密码
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '密码不能为空';
    }

    final config = AuthConfigManager.instance;
    final minLength = config.getPasswordMinLength();

    if (value.length < minLength) {
      return '密码至少$minLength个字符';
    }

    return null;
  }

  /// 验证验证码
  String? validateCaptcha(String? value) {
    if (value == null || value.isEmpty) {
      return '验证码不能为空';
    }

    final captcha = captchaInfo.value;
    if (captcha == null) {
      return '请先获取验证码';
    }

    if (captcha.isExpired) {
      return '验证码已过期';
    }

    if (value.length != captcha.length) {
      return '验证码长度不正确';
    }

    return null;
  }

  /// 检查验证码是否即将过期
  bool isCaptchaExpiringSoon() {
    final captcha = captchaInfo.value;
    return captcha?.isExpiringSoon ?? false;
  }

  /// 获取验证码剩余时间
  int getCaptchaRemainingSeconds() {
    final captcha = captchaInfo.value;
    return captcha?.remainingSeconds ?? 0;
  }

  /// 获取支持的认证类型
  List<AuthTypeEnum> getSupportedAuthTypes() {
    return AuthManager.instance.getSupportedAuthTypes();
  }

  /// 切换认证类型
  void switchAuthType(AuthTypeEnum type) {
    if (AuthManager.instance.isAuthTypeSupported(type)) {
      authType.value = type;
      // 清空表单
      _clearForm();
      // 重新加载验证码
      loadCaptcha();
    } else {
      addGlobalError('不支持的认证类型: ${type.description}');
    }
  }

  /// 清空表单
  void _clearForm() {
    usernameController.clear();
    passwordController.clear();
    captchaController.clear();
    formKey.currentState?.reset();
  }

  /// 获取认证类型显示名称
  String getAuthTypeDisplayName(AuthTypeEnum type) {
    return type.description;
  }
}
