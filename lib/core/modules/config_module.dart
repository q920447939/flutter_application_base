/// 配置模块
///
/// 负责远程配置系统的初始化和管理
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/framework_module.dart';
import '../config/remote_config_manager.dart';

/// 配置模块
class ConfigModule implements FrameworkModule {
  @override
  String get name => 'config';

  @override
  String get description => '配置模块，负责远程配置系统的初始化和管理';

  @override
  int get priority => 12; // 中等优先级，依赖存储和网络模块

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
    debugPrint('开始初始化配置模块...');

    try {
      // 注册配置管理器到依赖注入容器
      Get.put<RemoteConfigManager>(
        RemoteConfigManager.instance,
        permanent: true,
      );

      // 初始化配置管理器
      await RemoteConfigManager.instance.initialize();

      // 启动定时更新任务（可选）
      RemoteConfigManager.instance.startPeriodicUpdate(
        interval: const Duration(minutes: 30),
      );

      debugPrint('配置模块初始化完成');
    } catch (e) {
      debugPrint('配置模块初始化失败: $e');
      // 不抛出异常，允许应用使用默认配置运行
    }
  }

  @override
  Future<void> dispose() async {
    debugPrint('开始销毁配置模块...');

    try {
      // 销毁配置管理器
      await RemoteConfigManager.instance.dispose();

      // 从依赖注入容器中移除
      if (Get.isRegistered<RemoteConfigManager>()) {
        Get.delete<RemoteConfigManager>();
      }

      debugPrint('配置模块已销毁');
    } catch (e) {
      debugPrint('配置模块销毁失败: $e');
    }
  }
}
