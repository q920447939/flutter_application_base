/// Flutter 自建框架主应用入口
///
/// 集成了核心框架组件：
/// - 应用初始化
/// - 路由管理
/// - 状态管理
/// - 主题系统
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_base/core/app/app_initializer.dart';

// 核心框架导入
import 'example_app.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 初始化应用
    await AppInitializer.initialize();

    // 运行示例应用
    runApp(const ExampleApp());
  } catch (e) {
    debugPrint('应用启动失败: $e');

    // 显示错误页面
    runApp(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('启动错误')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('应用启动失败', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 8),
                Text('错误信息: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => main(),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
