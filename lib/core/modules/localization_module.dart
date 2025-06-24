/// 国际化模块
///
/// 负责国际化相关的初始化和配置
library;

import 'package:flutter/material.dart';
import '../app/framework_module.dart';

/// 国际化模块
class LocalizationModule implements FrameworkModule {
  @override
  String get name => 'localization';

  @override
  String get description => '国际化模块，负责多语言支持和本地化管理';

  @override
  int get priority => 30; // 中等优先级

  @override
  List<String> get dependencies => ['storage']; // 依赖存储模块

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
    debugPrint('开始初始化国际化模块...');

    // 初始化国际化服务
    //await LocalizationService.instance.initialize();

    debugPrint('国际化模块初始化完成');
  }

  @override
  Future<void> dispose() async {
    debugPrint('开始销毁国际化模块...');
    // 清理国际化相关资源
    debugPrint('国际化模块已销毁');
  }
}
