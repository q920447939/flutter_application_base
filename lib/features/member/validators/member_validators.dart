/// 会员信息验证器
///
/// 提供会员信息相关的数据验证逻辑
library;

import '../../../core/validation/validator.dart';
import '../../../core/validation/validation_result.dart';
import '../models/member_models.dart';

/// 更新昵称请求验证器
class UpdateNickNameRequestValidator extends Validator<UpdateNickNameRequest> {
  @override
  String get name => 'UpdateNickNameRequestValidator';

  @override
  ValidationResult validate(UpdateNickNameRequest data) {
    final errors = <String, List<String>>{};

    // 验证昵称不能为空
    if (data.nickName.trim().isEmpty) {
      return ValidationResult.fieldError('nickName', '昵称不能为空');
    }

    // 验证昵称长度
    final trimmedNickName = data.nickName.trim();
    if (trimmedNickName.length < 2) {
      errors['nickName'] = ['昵称长度不能少于2个字符'];
    } else if (trimmedNickName.length > 20) {
      errors['nickName'] = ['昵称长度不能超过20个字符'];
    }

    // 验证昵称格式（只允许中文、英文、数字、下划线）
    final nickNameRegex = RegExp(r'^[\u4e00-\u9fa5a-zA-Z0-9_]+$');
    if (!nickNameRegex.hasMatch(trimmedNickName)) {
      errors['nickName'] = ['昵称只能包含中文、英文、数字和下划线'];
    }

    // 验证昵称不能包含敏感词（示例）
    final sensitiveWords = ['admin', '管理员', 'test', '测试'];
    final lowerNickName = trimmedNickName.toLowerCase();
    for (final word in sensitiveWords) {
      if (lowerNickName.contains(word.toLowerCase())) {
        errors['nickName'] = ['昵称不能包含敏感词汇'];
        break;
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(fieldErrors: errors);
    }

    return ValidationResult.success();
  }
}

/// 更新头像请求验证器
class UpdateAvatarRequestValidator extends Validator<UpdateAvatarRequest> {
  @override
  String get name => 'UpdateAvatarRequestValidator';

  @override
  ValidationResult validate(UpdateAvatarRequest data) {
    final errors = <String, List<String>>{};

    // 验证头像URL不能为空
    if (data.avatarUrl.trim().isEmpty) {
      return ValidationResult.fieldError('avatarUrl', '头像URL不能为空');
    }

    final trimmedUrl = data.avatarUrl.trim();

    // 验证URL格式
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(trimmedUrl)) {
      return ValidationResult.fieldError('avatarUrl', '请输入有效的头像URL地址');
    }

    // 验证是否为HTTPS（安全考虑）
    if (!trimmedUrl.startsWith('https://')) {
      errors['avatarUrl'] = ['头像URL必须使用HTTPS协议'];
    }

    // 验证URL长度
    if (trimmedUrl.length > 500) {
      errors['avatarUrl'] = ['URL长度不能超过500个字符'];
    }

    // 验证图片文件扩展名
    final supportedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final hasValidExtension = supportedExtensions.any(
      (ext) => trimmedUrl.toLowerCase().contains(ext),
    );

    if (!hasValidExtension) {
      errors['avatarUrl'] = ['头像必须是图片文件（支持jpg、png、gif、webp格式）'];
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(fieldErrors: errors);
    }

    return ValidationResult.success();
  }
}

/// 会员信息验证工具类
class MemberValidationUtils {
  /// 验证昵称是否可用（静态方法）
  static ValidationResult validateNickName(String nickName) {
    final request = UpdateNickNameRequest(nickName: nickName);
    final validator = UpdateNickNameRequestValidator();
    return validator.validate(request);
  }

  /// 验证头像URL是否可用（静态方法）
  static ValidationResult validateAvatarUrl(String avatarUrl) {
    final request = UpdateAvatarRequest(avatarUrl: avatarUrl);
    final validator = UpdateAvatarRequestValidator();
    return validator.validate(request);
  }

  /// 验证会员信息完整性
  static ValidationResult validateMemberInfo(MemberInfo memberInfo) {
    final errors = <String, List<String>>{};

    // 验证基本信息
    if (memberInfo.id == null || memberInfo.id! <= 0) {
      errors['id'] = ['会员ID无效'];
    }

    if (memberInfo.memberCode?.isEmpty == true) {
      errors['memberCode'] = ['会员编码不能为空'];
    }

    // 验证昵称（如果存在）
    if (memberInfo.nickName?.isNotEmpty == true) {
      final nickNameResult = validateNickName(memberInfo.nickName!);
      if (!nickNameResult.isValid) {
        errors.addAll(nickNameResult.fieldErrors);
      }
    }

    // 验证头像URL（如果存在）
    if (memberInfo.avatarUrl?.isNotEmpty == true) {
      final avatarResult = validateAvatarUrl(memberInfo.avatarUrl!);
      if (!avatarResult.isValid) {
        errors.addAll(avatarResult.fieldErrors);
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(fieldErrors: errors);
    }

    return ValidationResult.success();
  }

  /// 检查昵称是否包含特殊字符
  static bool containsSpecialCharacters(String nickName) {
    final specialCharsRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    return specialCharsRegex.hasMatch(nickName);
  }

  /// 检查是否为有效的图片URL
  static bool isValidImageUrl(String url) {
    final validator = UpdateAvatarRequestValidator();
    final request = UpdateAvatarRequest(avatarUrl: url);
    return validator.validate(request).isValid;
  }

  /// 生成昵称建议（当昵称不可用时）
  static List<String> generateNickNameSuggestions(String originalNickName) {
    final suggestions = <String>[];
    final base = originalNickName.trim();

    if (base.isEmpty) {
      return ['用户${DateTime.now().millisecondsSinceEpoch % 10000}'];
    }

    // 添加数字后缀
    for (int i = 1; i <= 5; i++) {
      suggestions.add('$base$i');
    }

    // 添加随机后缀
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    suggestions.add('$base$random');

    return suggestions;
  }
}
