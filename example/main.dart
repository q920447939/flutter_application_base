/// Flutter 框架示例应用入口
///
/// 这是一个独立的示例应用，用于演示框架功能
/// 不会污染主业务代码
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_base/core/app/framework_module_manager.dart';
import 'package:flutter_application_base/features/auth/services/auth_service_initializer.dart';
import 'example_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 使用框架模块管理器初始化
  await FrameworkModuleManager.initializeAll();

  // 初始化认证服务
  await AuthServiceInitializer.initialize();

  // 运行示例应用
  runApp(const ExampleApp());
}
