/// 认证控制器
/// 
/// 管理认证相关的UI状态和业务逻辑
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/state/base_controller.dart';
import '../../../core/localization/app_localizations.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

/// 登录控制器
class LoginController extends BaseController {
  /// 表单Key
  final formKey = GlobalKey<FormState>();
  
  /// 邮箱/手机号控制器
  final identifierController = TextEditingController();
  
  /// 密码控制器
  final passwordController = TextEditingController();
  
  /// 是否显示密码
  final RxBool showPassword = false.obs;
  
  /// 是否记住登录状态
  final RxBool rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 可以在这里预填充一些测试数据
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      identifierController.text = args['identifier'] ?? '';
    }
  }

  @override
  void onClose() {
    identifierController.dispose();
    passwordController.dispose();
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

  /// 登录
  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final request = LoginRequest(
      identifier: identifierController.text.trim(),
      password: passwordController.text,
      rememberMe: rememberMe.value,
    );

    await executeAsync(
      () async {
        final success = await AuthService.instance.login(request);
        if (success) {
          showSuccess(S.loginSuccess);
          // 登录成功后导航到主页
          Get.offAllNamed('/home');
        } else {
          throw Exception(S.loginFailed);
        }
      },
      errorMessage: S.loginFailed,
    );
  }

  /// 忘记密码
  void forgotPassword() {
    Get.toNamed('/forgot-password', arguments: {
      'identifier': identifierController.text.trim(),
    });
  }

  /// 去注册页面
  void goToRegister() {
    Get.toNamed('/register');
  }

  /// 验证邮箱/手机号
  String? validateIdentifier(String? value) {
    if (value == null || value.isEmpty) {
      return S.required;
    }
    
    // 检查是否为邮箱格式
    if (value.contains('@')) {
      if (!GetUtils.isEmail(value)) {
        return S.invalidEmail;
      }
    } else {
      // 检查是否为手机号格式
      if (!GetUtils.isPhoneNumber(value)) {
        return S.invalidPhone;
      }
    }
    
    return null;
  }

  /// 验证密码
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return S.required;
    }
    
    if (value.length < 6) {
      return S.passwordTooShort;
    }
    
    return null;
  }
}

/// 注册控制器
class RegisterController extends BaseController {
  /// 表单Key
  final formKey = GlobalKey<FormState>();
  
  /// 用户名控制器
  final usernameController = TextEditingController();
  
  /// 邮箱控制器
  final emailController = TextEditingController();
  
  /// 手机号控制器
  final phoneController = TextEditingController();
  
  /// 密码控制器
  final passwordController = TextEditingController();
  
  /// 确认密码控制器
  final confirmPasswordController = TextEditingController();
  
  /// 昵称控制器
  final nicknameController = TextEditingController();
  
  /// 验证码控制器
  final verificationCodeController = TextEditingController();
  
  /// 是否显示密码
  final RxBool showPassword = false.obs;
  
  /// 是否显示确认密码
  final RxBool showConfirmPassword = false.obs;
  
  /// 验证码倒计时
  final RxInt codeCountdown = 0.obs;

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nicknameController.dispose();
    verificationCodeController.dispose();
    super.onClose();
  }

  /// 切换密码显示状态
  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  /// 切换确认密码显示状态
  void toggleConfirmPasswordVisibility() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }

  /// 发送验证码
  Future<void> sendVerificationCode() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty || !GetUtils.isPhoneNumber(phone)) {
      showError(S.invalidPhone);
      return;
    }

    if (codeCountdown.value > 0) {
      return;
    }

    await executeAsync(
      () async {
        final success = await AuthService.instance.sendVerificationCode(phone);
        if (success) {
          showSuccess('验证码已发送');
          _startCountdown();
        } else {
          throw Exception('发送验证码失败');
        }
      },
      showLoading: false,
    );
  }

  /// 开始倒计时
  void _startCountdown() {
    codeCountdown.value = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      codeCountdown.value--;
      return codeCountdown.value > 0;
    });
  }

  /// 注册
  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final request = RegisterRequest(
      username: usernameController.text.trim().isEmpty ? null : usernameController.text.trim(),
      email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
      phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
      nickname: nicknameController.text.trim().isEmpty ? null : nicknameController.text.trim(),
      verificationCode: verificationCodeController.text.trim().isEmpty ? null : verificationCodeController.text.trim(),
    );

    await executeAsync(
      () async {
        final success = await AuthService.instance.register(request);
        if (success) {
          showSuccess(S.registerSuccess);
          // 注册成功后导航到主页
          Get.offAllNamed('/home');
        } else {
          throw Exception(S.registerFailed);
        }
      },
      errorMessage: S.registerFailed,
    );
  }

  /// 去登录页面
  void goToLogin() {
    Get.back();
  }

  /// 验证用户名
  String? validateUsername(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length < 3) {
        return '用户名至少3个字符';
      }
      if (value.length > 20) {
        return '用户名最多20个字符';
      }
    }
    return null;
  }

  /// 验证邮箱
  String? validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!GetUtils.isEmail(value)) {
        return S.invalidEmail;
      }
    }
    return null;
  }

  /// 验证手机号
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return S.required;
    }
    if (!GetUtils.isPhoneNumber(value)) {
      return S.invalidPhone;
    }
    return null;
  }

  /// 验证密码
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return S.required;
    }
    if (value.length < 6) {
      return S.passwordTooShort;
    }
    return null;
  }

  /// 验证确认密码
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return S.required;
    }
    if (value != passwordController.text) {
      return S.passwordMismatch;
    }
    return null;
  }

  /// 验证昵称
  String? validateNickname(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length > 20) {
        return '昵称最多20个字符';
      }
    }
    return null;
  }

  /// 验证验证码
  String? validateVerificationCode(String? value) {
    if (phoneController.text.isNotEmpty) {
      if (value == null || value.isEmpty) {
        return S.required;
      }
      if (value.length != 6) {
        return '验证码为6位数字';
      }
    }
    return null;
  }
}
