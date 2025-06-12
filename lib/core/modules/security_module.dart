/// 安全模块
///
/// 负责安全相关的初始化和配置
library;

import 'package:flutter/material.dart';
import '../app/framework_module.dart';
import '../security/security_detector.dart';
import '../security/certificate_pinning_service.dart';

/// 安全模块
class SecurityModule implements FrameworkModule {
  @override
  String get name => 'security';

  @override
  String get description => '安全模块，负责安全检测和证书绑定管理';

  @override
  int get priority => 25; // 中等优先级

  @override
  List<String> get dependencies => []; // 无依赖

  @override
  String get version => '1.0.0';

  @override
  bool get enabled => true;

  @override
  Map<String, dynamic> getModuleInfo() {
    return {
      'name': name,
      'description': description,
      'version': version,
      'priority': priority,
      'dependencies': dependencies,
      'enabled': enabled,
    };
  }

  @override
  Future<void> initialize() async {
    debugPrint('开始初始化安全模块...');

    // 初始化安全检测服务
    SecurityDetector.instance;

    // 初始化证书绑定
    CertificatePinningService.instance.initializeCommonConfigs();

    debugPrint('安全模块初始化完成');
  }

  @override
  Future<void> dispose() async {
    debugPrint('开始销毁安全模块...');
    // 清理安全相关资源
    debugPrint('安全模块已销毁');
  }
}
