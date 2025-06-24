/// YAML 模块
///
/// 提供统一的 YAML 处理能力，支持配置、本地化、主题等多种场景
library;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../app/framework_module.dart';
import 'interfaces/yaml_service_interface.dart';
import 'services/yaml_service.dart';

/// YAML 模块实现
class YamlModule implements FrameworkModule {
  @override
  String get name => 'yaml';

  @override
  String get description => 'YAML 处理模块，提供配置、本地化、主题等 YAML 文件的统一处理能力';

  @override
  int get priority => 8; // 较高优先级，其他模块可能依赖

  @override
  List<String> get dependencies => ['storage']; // 依赖存储模块用于缓存

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
      'processors': ['config', 'localization', 'theme', 'data_template'],
    };
  }

  @override
  Future<void> initialize() async {
    debugPrint('开始初始化 YAML 模块...');

    try {
      // 创建并注册 YAML 服务到依赖注入容器
      final yamlService = YamlService();
      Get.put<IYamlService>(yamlService, permanent: true);

      // 初始化服务
      await yamlService.initialize();

      debugPrint('YAML 模块初始化完成');
    } catch (e) {
      debugPrint('YAML 模块初始化失败: $e');
      // 不抛出异常，允许应用在没有 YAML 支持的情况下运行
    }
  }

  @override
  Future<void> dispose() async {
    debugPrint('开始销毁 YAML 模块...');

    try {
      // 销毁 YAML 服务
      if (Get.isRegistered<IYamlService>()) {
        final yamlService = Get.find<IYamlService>();
        await yamlService.dispose();
        Get.delete<IYamlService>();
      }

      debugPrint('YAML 模块已销毁');
    } catch (e) {
      debugPrint('YAML 模块销毁失败: $e');
    }
  }
}

/// YAML 模块便捷访问类
class YamlHelper {
  YamlHelper._();

  /// 获取 YAML 服务实例
  static IYamlService get service {
    if (!Get.isRegistered<IYamlService>()) {
      throw Exception('YAML 服务未初始化，请确保 YamlModule 已正确加载');
    }
    return Get.find<IYamlService>();
  }

  /// 清除缓存
  static Future<void> clearCache({String? pattern}) async {
    await service.clearCache(pattern: pattern);
  }
}
