/// 认证模块
///
/// 负责认证相关的初始化和配置
library;

import 'package:flutter/material.dart';
import '../app/framework_module.dart';
import '../../features/auth/services/auth_service.dart';

/// 认证模块
class AuthModule implements FrameworkModule {
  @override
  String get name => 'auth';

  @override
  String get description => '认证模块，负责用户认证和授权管理';

  @override
  int get priority => 35; // 较低优先级，依赖其他基础模块

  @override
  List<String> get dependencies => ['storage', 'network']; // 依赖存储和网络模块

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
    debugPrint('开始初始化认证模块...');

    // 初始化认证服务
    await AuthService.instance.initialize();

    debugPrint('认证模块初始化完成');
  }

  @override
  Future<void> dispose() async {
    debugPrint('开始销毁认证模块...');
    // 清理认证相关资源
    debugPrint('认证模块已销毁');
  }
}
