/// 模块注册器
///
/// 负责自动发现和注册所有框架模块
library;

import '../app/framework_module.dart';
import '../app/framework_module_manager.dart';
import 'storage_module.dart';
import 'network_module.dart';
import 'permission_module.dart';
import 'theme_module.dart';
import 'auth_module.dart';
import 'router_module.dart';
import 'security_module.dart';
import 'localization_module.dart';
import 'config_module.dart';

/// 模块注册器
class ModuleRegistry {
  static final modules = <FrameworkModule>[
    // 按优先级顺序注册
    StorageModule(), // 优先级 5 - 最高优先级
    NetworkModule(), // 优先级 10
    ConfigModule(), // 优先级 12 - 配置模块
    ThemeModule(), // 优先级 15
    PermissionModule(), // 优先级 20
    SecurityModule(), // 优先级 25
    LocalizationModule(), // 优先级 30
    AuthModule(), // 优先级 35
    RouterModule(), // 优先级 40
  ];

  /// 注册所有核心模块
  static void registerCoreModules() {
    FrameworkModuleManager.registerModules(modules);
  }

  /// 注册自定义模块
  static void registerCustomModules(List<FrameworkModule> modules) {
    FrameworkModuleManager.registerModules(modules);
  }

  /// 获取所有可用的核心模块
  static List<FrameworkModule> getCoreModules() {
    return modules;
  }

  /// 根据名称获取模块
  static FrameworkModule? getModuleByName(String name) {
    final modules = getCoreModules();
    try {
      return modules.firstWhere((module) => module.name == name);
    } catch (e) {
      return null;
    }
  }

  /// 检查模块是否存在
  static bool hasModule(String name) {
    return getModuleByName(name) != null;
  }

  /// 获取模块依赖图
  static Map<String, List<String>> getDependencyGraph() {
    final modules = getCoreModules();
    final graph = <String, List<String>>{};

    for (final module in modules) {
      graph[module.name] = module.dependencies;
    }

    return graph;
  }

  /// 验证模块依赖关系
  static bool validateDependencies() {
    final modules = getCoreModules();
    final moduleNames = modules.map((m) => m.name).toSet();

    for (final module in modules) {
      for (final dependency in module.dependencies) {
        if (!moduleNames.contains(dependency)) {
          return false;
        }
      }
    }

    return true;
  }
}
