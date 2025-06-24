import 'package:flutter/foundation.dart';

// ========== 模型层 ==========
export 'models/member_models.dart';

// ========== 验证器层 ==========
export 'validators/member_validators.dart';

// ========== 配置层 ==========
export 'config/member_config.dart';

/// 会员模块工具类
class MemberModule {
  /// 私有构造函数
  MemberModule._();

  /// 模块名称
  static const String moduleName = 'member';

  /// 模块版本
  static const String moduleVersion = '1.0.0';

  /// 模块描述
  static const String moduleDescription = '通用会员信息管理模块';

  /// 初始化会员模块
  static Future<void> initialize() async {
    // 这里可以添加模块初始化逻辑
    // 例如：注册依赖、初始化服务等
    debugPrint('会员模块初始化完成');
  }

  /// 获取模块信息
  static Map<String, String> getModuleInfo() {
    return {
      'name': moduleName,
      'version': moduleVersion,
      'description': moduleDescription,
    };
  }
}
