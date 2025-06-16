/// 认证请求验证器
/// 
/// 提供统一的认证请求验证逻辑和错误提示
library;

import '../../../core/validation/validator.dart';
import '../../../core/validation/validation_result.dart';
import '../models/auth_request.dart';
import '../config/auth_config.dart';

/// 用户名密码认证请求验证器
class UsernamePasswordAuthRequestValidator extends Validator<UsernamePasswordAuthRequest> {
  @override
  String get name => 'UsernamePasswordAuthRequestValidator';

  @override
  ValidationResult validate(UsernamePasswordAuthRequest request) {
    final fieldErrors = <String, List<String>>{};
    final config = AuthConfigManager.instance;

    // 验证用户名
    final usernameErrors = _validateUsername(request.username, config);
    if (usernameErrors.isNotEmpty) {
      fieldErrors['username'] = usernameErrors;
    }

    // 验证密码
    final passwordErrors = _validatePassword(request.password, config);
    if (passwordErrors.isNotEmpty) {
      fieldErrors['password'] = passwordErrors;
    }

    // 验证验证码
    final captchaErrors = _validateCaptcha(request.captcha);
    if (captchaErrors.isNotEmpty) {
      fieldErrors['captcha'] = captchaErrors;
    }

    // 验证验证码会话ID
    final sessionErrors = _validateCaptchaSessionId(request.captchaSessionId);
    if (sessionErrors.isNotEmpty) {
      fieldErrors['captchaSessionId'] = sessionErrors;
    }

    if (fieldErrors.isEmpty) {
      return ValidationResult.success();
    }

    return ValidationResult.failure(fieldErrors: fieldErrors);
  }

  /// 验证用户名
  List<String> _validateUsername(String username, AuthConfigManager config) {
    final errors = <String>[];

    if (username.isEmpty) {
      errors.add('用户名不能为空');
      return errors;
    }

    final minLength = config.getUsernameMinLength();
    final maxLength = config.getUsernameMaxLength();

    if (username.length < minLength) {
      errors.add('用户名至少需要$minLength个字符');
    }

    if (username.length > maxLength) {
      errors.add('用户名最多允许$maxLength个字符');
    }

    // 用户名格式验证（字母、数字、下划线）
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(username)) {
      errors.add('用户名只能包含字母、数字和下划线');
    }

    // 用户名不能以数字开头
    if (RegExp(r'^\d').hasMatch(username)) {
      errors.add('用户名不能以数字开头');
    }

    return errors;
  }

  /// 验证密码
  List<String> _validatePassword(String password, AuthConfigManager config) {
    final errors = <String>[];

    if (password.isEmpty) {
      errors.add('密码不能为空');
      return errors;
    }

    final minLength = config.getPasswordMinLength();
    if (password.length < minLength) {
      errors.add('密码至少需要$minLength个字符');
    }

    // 密码强度验证
    if (config.isPasswordComplexityEnabled()) {
      if (!RegExp(r'[A-Z]').hasMatch(password)) {
        errors.add('密码必须包含至少一个大写字母');
      }

      if (!RegExp(r'[a-z]').hasMatch(password)) {
        errors.add('密码必须包含至少一个小写字母');
      }

      if (!RegExp(r'\d').hasMatch(password)) {
        errors.add('密码必须包含至少一个数字');
      }

      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
        errors.add('密码必须包含至少一个特殊字符');
      }
    }

    return errors;
  }

  /// 验证验证码
  List<String> _validateCaptcha(String captcha) {
    final errors = <String>[];

    if (captcha.isEmpty) {
      errors.add('验证码不能为空');
      return errors;
    }

    if (captcha.length < 4) {
      errors.add('验证码至少需要4个字符');
    }

    if (captcha.length > 6) {
      errors.add('验证码最多允许6个字符');
    }

    // 验证码只能包含字母和数字
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(captcha)) {
      errors.add('验证码只能包含字母和数字');
    }

    return errors;
  }

  /// 验证验证码会话ID
  List<String> _validateCaptchaSessionId(String sessionId) {
    final errors = <String>[];

    if (sessionId.isEmpty) {
      errors.add('验证码会话ID不能为空');
    }

    return errors;
  }

  @override
  Map<String, String> get errorMessages => {
    'username.required': '用户名不能为空',
    'username.minLength': '用户名长度不足',
    'username.maxLength': '用户名长度超限',
    'username.format': '用户名格式不正确',
    'password.required': '密码不能为空',
    'password.minLength': '密码长度不足',
    'password.complexity': '密码强度不足',
    'captcha.required': '验证码不能为空',
    'captcha.length': '验证码长度不正确',
    'captcha.format': '验证码格式不正确',
    'captchaSessionId.required': '验证码会话ID不能为空',
  };
}

/// 手机号密码认证请求验证器
class PhonePasswordAuthRequestValidator extends Validator<PhonePasswordAuthRequest> {
  @override
  String get name => 'PhonePasswordAuthRequestValidator';

  @override
  ValidationResult validate(PhonePasswordAuthRequest request) {
    final fieldErrors = <String, List<String>>{};
    final config = AuthConfigManager.instance;

    // 验证手机号
    final phoneErrors = _validatePhone(request.phone);
    if (phoneErrors.isNotEmpty) {
      fieldErrors['phone'] = phoneErrors;
    }

    // 验证密码
    final passwordErrors = _validatePassword(request.password, config);
    if (passwordErrors.isNotEmpty) {
      fieldErrors['password'] = passwordErrors;
    }

    // 验证验证码
    final captchaErrors = _validateCaptcha(request.captcha);
    if (captchaErrors.isNotEmpty) {
      fieldErrors['captcha'] = captchaErrors;
    }

    if (fieldErrors.isEmpty) {
      return ValidationResult.success();
    }

    return ValidationResult.failure(fieldErrors: fieldErrors);
  }

  /// 验证手机号
  List<String> _validatePhone(String phone) {
    final errors = <String>[];

    if (phone.isEmpty) {
      errors.add('手机号不能为空');
      return errors;
    }

    // 中国大陆手机号验证
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(phone)) {
      errors.add('请输入有效的手机号码');
    }

    return errors;
  }

  /// 验证密码（复用用户名密码验证器的逻辑）
  List<String> _validatePassword(String password, AuthConfigManager config) {
    final usernameValidator = UsernamePasswordAuthRequestValidator();
    return usernameValidator._validatePassword(password, config);
  }

  /// 验证验证码（复用用户名密码验证器的逻辑）
  List<String> _validateCaptcha(String captcha) {
    final usernameValidator = UsernamePasswordAuthRequestValidator();
    return usernameValidator._validateCaptcha(captcha);
  }
}

/// 邮箱密码认证请求验证器
class EmailPasswordAuthRequestValidator extends Validator<EmailPasswordAuthRequest> {
  @override
  String get name => 'EmailPasswordAuthRequestValidator';

  @override
  ValidationResult validate(EmailPasswordAuthRequest request) {
    final fieldErrors = <String, List<String>>{};
    final config = AuthConfigManager.instance;

    // 验证邮箱
    final emailErrors = _validateEmail(request.email);
    if (emailErrors.isNotEmpty) {
      fieldErrors['email'] = emailErrors;
    }

    // 验证密码
    final passwordErrors = _validatePassword(request.password, config);
    if (passwordErrors.isNotEmpty) {
      fieldErrors['password'] = passwordErrors;
    }

    // 验证验证码
    final captchaErrors = _validateCaptcha(request.captcha);
    if (captchaErrors.isNotEmpty) {
      fieldErrors['captcha'] = captchaErrors;
    }

    if (fieldErrors.isEmpty) {
      return ValidationResult.success();
    }

    return ValidationResult.failure(fieldErrors: fieldErrors);
  }

  /// 验证邮箱
  List<String> _validateEmail(String email) {
    final errors = <String>[];

    if (email.isEmpty) {
      errors.add('邮箱不能为空');
      return errors;
    }

    // 邮箱格式验证
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      errors.add('请输入有效的邮箱地址');
    }

    return errors;
  }

  /// 验证密码（复用用户名密码验证器的逻辑）
  List<String> _validatePassword(String password, AuthConfigManager config) {
    final usernameValidator = UsernamePasswordAuthRequestValidator();
    return usernameValidator._validatePassword(password, config);
  }

  /// 验证验证码（复用用户名密码验证器的逻辑）
  List<String> _validateCaptcha(String captcha) {
    final usernameValidator = UsernamePasswordAuthRequestValidator();
    return usernameValidator._validateCaptcha(captcha);
  }
}
