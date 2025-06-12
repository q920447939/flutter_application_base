/// 主题模块
///
/// 负责主题相关的初始化和配置
library;

import 'package:flutter/material.dart';
import '../app/framework_module.dart';
import '../theme/theme_initializer.dart';

/// 主题模块
class ThemeModule implements FrameworkModule {
  @override
  String get name => 'theme';

  @override
  String get description => '主题模块，负责主题系统初始化和管理';

  @override
  int get priority => 15; // 中等优先级

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
    debugPrint('开始初始化主题模块...');

    // 使用主题初始化器进行完整的主题系统初始化
    final result = await ThemeInitializer.instance.initialize();

    if (!result.success) {
      debugPrint('主题初始化失败: ${result.error}');
      // 注意：这里不抛出异常，因为已经有降级方案
    } else {
      debugPrint('主题初始化成功，耗时: ${result.duration.inMilliseconds}ms');
      if (result.appliedTheme != null) {
        debugPrint('已应用主题: ${result.appliedTheme!.name}');
      }
    }

    debugPrint('主题模块初始化完成');
  }

  @override
  Future<void> dispose() async {
    debugPrint('开始销毁主题模块...');
    // 清理主题相关资源
    debugPrint('主题模块已销毁');
  }
}
