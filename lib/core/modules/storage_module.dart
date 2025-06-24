/// 存储模块
///
/// 负责存储相关的初始化和配置
library;

import 'package:flutter/material.dart';
import '../app/framework_module.dart';

/// 存储模块
class StorageModule implements FrameworkModule {
  @override
  String get name => 'storage';

  @override
  String get description => '存储模块，负责数据库和本地存储初始化';

  @override
  int get priority => 5; // 最高优先级，其他模块可能依赖存储

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
    debugPrint('开始初始化存储模块...');

    // 初始化Hive数据库
    await _initializeHive();

    // 初始化存储服务
    //await StorageService.instance.initialize();

    debugPrint('存储模块初始化完成');
  }

  @override
  Future<void> dispose() async {
    debugPrint('开始销毁存储模块...');

    debugPrint('存储模块已销毁');
  }

  /// 初始化Hive数据库
  Future<void> _initializeHive() async {
    // 注册适配器
    // 这里可以注册自定义的Hive适配器
    // Hive.registerAdapter(UserAdapter());

    debugPrint('Hive数据库初始化完成');
  }
}
