/// 功能组定义
///
/// 定义所有可测试的功能组和功能项
library;

import 'package:flutter/material.dart';
import 'feature_navigator.dart';
import 'test/test_management_page.dart';

/// 功能组集合
class FeatureGroups {
  static final List<FeatureGroup> groups = [
    // YAML 模块功能组
    FeatureGroup(
      name: 'YAML 模块',
      description: '通用 YAML 处理功能测试',
      icon: Icons.description,
      color: Colors.blue,
      features: [
        /* Feature(
          name: '配置文件处理',
          description: '测试配置文件的加载和解析',
          icon: Icons.settings,
          pageBuilder: (context) => const YamlConfigPage(),
        ),*/
      ],
    ),

    // 核心模块功能组
    FeatureGroup(
      name: '核心模块',
      description: '框架核心功能测试',
      icon: Icons.architecture,
      color: Colors.green,
      features: [],
    ),

    // UI 组件功能组
    FeatureGroup(
      name: 'UI 组件',
      description: '通用 UI 组件测试',
      icon: Icons.widgets,
      color: Colors.orange,
      features: [
        Feature(
          name: '基础组件',
          description: '测试按钮、输入框等基础组件',
          icon: Icons.view_module,
          pageBuilder: (context) => const Placeholder(), // TODO: 实现基础组件页面
        ),
        Feature(
          name: '表单组件',
          description: '测试表单验证和提交',
          icon: Icons.assignment,
          pageBuilder: (context) => const Placeholder(), // TODO: 实现表单组件页面
        ),
        Feature(
          name: '列表组件',
          description: '测试列表和网格组件',
          icon: Icons.list,
          pageBuilder: (context) => const Placeholder(), // TODO: 实现列表组件页面
        ),
      ],
    ),

    // 工具功能组
    FeatureGroup(
      name: '开发工具',
      description: '开发和调试工具',
      icon: Icons.build,
      color: Colors.purple,
      features: [
        Feature(
          name: '日志查看器',
          description: '查看应用日志和调试信息',
          icon: Icons.bug_report,
          pageBuilder: (context) => const Placeholder(), // TODO: 实现日志查看器
        ),
        Feature(
          name: '性能监控',
          description: '监控应用性能指标',
          icon: Icons.speed,
          pageBuilder: (context) => const Placeholder(), // TODO: 实现性能监控页面
        ),
        Feature(
          name: '缓存管理',
          description: '管理应用缓存数据',
          icon: Icons.cached,
          pageBuilder: (context) => const Placeholder(), // TODO: 实现缓存管理页面
        ),
        Feature(
          name: '测试管理',
          description: '统一管理和执行所有测试',
          icon: Icons.science,
          pageBuilder: (context) => const TestManagementPage(),
        ),
      ],
    ),
  ];
}
