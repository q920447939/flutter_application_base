/// 权限模块
///
/// 负责权限相关的初始化和配置
library;

import 'package:flutter/material.dart';
import '../app/framework_module.dart';
import '../permissions/permission_service.dart';
import '../permissions/permission_initializer.dart';

/// 权限模块
class PermissionModule implements FrameworkModule {
  @override
  String get name => 'permission';

  @override
  String get description => '权限模块，负责权限系统初始化和管理';

  @override
  int get priority => 20; // 中等优先级

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
    debugPrint('开始初始化权限模块...');

    // 初始化权限服务
    PermissionService.instance;

    // 初始化权限系统
    final result = await PermissionInitializer.instance.initialize(
      showGuideOnStartup: true,
      useCache: true,
    );

    if (!result.success) {
      debugPrint('权限初始化失败: ${result.errorMessage}');
      if (result.shouldExitApp) {
        debugPrint('应用将退出');
        // 这里可以添加退出应用的逻辑
      }
    } else {
      debugPrint('权限初始化成功');
      debugPrint(
        '已授权权限: ${result.grantedPermissions.map((p) => p.name).join(', ')}',
      );
      if (result.deniedPermissions.isNotEmpty) {
        debugPrint(
          '被拒绝权限: ${result.deniedPermissions.map((p) => p.name).join(', ')}',
        );
      }
    }
    debugPrint('权限模块初始化完成');
  }

  @override
  Future<void> dispose() async {
    debugPrint('开始销毁权限模块...');
    // 清理权限相关资源
    debugPrint('权限模块已销毁');
  }
}
