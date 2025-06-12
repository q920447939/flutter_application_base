/// 网络模块
///
/// 负责网络相关的初始化和配置
library;

import 'package:flutter/material.dart';
import '../app/framework_module.dart';
import '../network/network_initializer.dart';

/// 网络模块
class NetworkModule implements FrameworkModule {
  @override
  String get name => 'network';

  @override
  String get description => '网络模块，负责网络配置和初始化';

  @override
  int get priority => 10; // 高优先级，需要早期初始化

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
    debugPrint('开始初始化网络模块...');

    // 使用网络初始化器进行完整的网络层初始化
    final result = await NetworkInitializer.instance.initialize();

    if (!result.success) {
      debugPrint('网络初始化失败: ${result.error}');
      // 注意：这里不抛出异常，因为应用可能需要在离线模式下运行
    } else {
      debugPrint('网络初始化成功，耗时: ${result.duration.inMilliseconds}ms');
    }

    debugPrint('网络模块初始化完成');
  }

  @override
  Future<void> dispose() async {
    debugPrint('开始销毁网络模块...');
    // 清理网络相关资源
    debugPrint('网络模块已销毁');
  }
}
