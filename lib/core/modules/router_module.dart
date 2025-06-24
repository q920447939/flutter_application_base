/// 路由模块
///
/// 负责路由相关的初始化和配置
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/framework_module.dart';

/// 路由模块
class RouterModule implements FrameworkModule {
  @override
  String get name => 'router';

  @override
  String get description => '路由模块，负责动态路由系统初始化和管理';

  @override
  int get priority => 40; // 较低优先级，依赖其他基础模块

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
    debugPrint('开始初始化路由模块...');

    debugPrint('路由模块初始化完成');
  }

  @override
  Future<void> dispose() async {
    debugPrint('开始销毁路由模块...');
    // 清理路由相关资源
    debugPrint('路由模块已销毁');
  }
}
