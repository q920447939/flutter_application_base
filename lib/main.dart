/// Flutter 自建框架主应用入口
///
/// 这是框架的主入口文件，仅包含框架核心功能
/// 测试和示例代码请参考 example/ 目录
library;

import 'package:flutter/material.dart';
import 'core/app/framework_module_manager.dart';
import 'core/app/app_init_info.dart';

/// 框架主应用类
class FrameworkApp extends StatelessWidget {
  const FrameworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Framework',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const FrameworkHomePage(),
    );
  }
}

/// 框架主页
class FrameworkHomePage extends StatelessWidget {
  const FrameworkHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Framework'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.widgets, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Flutter 自建框架',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('框架已成功初始化', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 24),
            Text(
              '要查看示例和测试，请运行 example/main.dart',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  // 使用新的模块化初始化系统
  final initInfo = AppInitInfo(
    child: const FrameworkApp(),
    openDevicePreview: false,
  );

  await FrameworkModuleManager.initialize(initInfo);

  // 运行框架主应用
  //runApp(const FrameworkApp());
}
