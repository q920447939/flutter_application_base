/// 存储模块
///
/// 负责存储相关的初始化和配置
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/framework_module.dart';
import '../storage/services/storage_service.dart';
import '../storage/services/sqlite_storage_service.dart';

/// 存储模块
class StorageModule implements FrameworkModule {
  @override
  String get name => 'storage';

  @override
  String get description => 'SQLite存储模块，负责数据库和本地存储初始化';

  @override
  int get priority => 5; // 最高优先级，其他模块可能依赖存储

  @override
  List<String> get dependencies => []; // 无依赖

  @override
  String get version => '2.0.0';

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

    // 初始化SQLite存储服务
    final storageService = SqliteStorageService();
    await storageService.initialize();

    // 注册到依赖注入容器
    Get.put<IStorageService>(storageService);

    debugPrint('存储模块初始化完成');
  }

  @override
  Future<void> dispose() async {
    debugPrint('开始销毁存储模块...');

    try {
      final storageService = Get.find<IStorageService>();
      await storageService.dispose();
    } catch (e) {
      debugPrint('销毁存储服务时出错: $e');
    }

    debugPrint('存储模块已销毁');
  }
}
