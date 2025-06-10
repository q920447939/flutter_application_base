/// 简化的示例页面
///
/// 展示如何使用简化的页面基类实现纯业务逻辑
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_base/core/base/simple_page.dart';

/// 简单首页
class SimpleHomePage extends SimpleStatelessPage {
  const SimpleHomePage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              '欢迎使用新架构演示',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('所有框架功能由路由层自动处理'),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton(
                  onPressed: () => Get.toNamed('/camera_demo'),
                  child: const Text('相机演示'),
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/map_demo'),
                  child: const Text('地图演示'),
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/multimedia_demo'),
                  child: const Text('多媒体演示'),
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/user/profile'),
                  child: const Text('个人资料'),
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/media/camera'),
                  child: const Text('媒体相机'),
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/tools/qr_scan'),
                  child: const Text('二维码扫描'),
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/declarative'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('声明式权限配置'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 简单相机页面
class SimpleCameraPage extends SimpleStatelessPage {
  const SimpleCameraPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('相机演示')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('相机功能已就绪', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('权限检查由路由层自动处理'),
            Text('页面只需关注业务逻辑'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 这里实现拍照业务逻辑
          Get.snackbar('提示', '拍照功能执行中...');
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}

/// 简单地图页面
class SimpleMapPage extends SimpleStatefulPage {
  const SimpleMapPage({super.key});

  @override
  SimpleStatefulPageState<SimpleMapPage> createPageState() =>
      _SimpleMapPageState();
}

class _SimpleMapPageState extends SimpleStatefulPageState<SimpleMapPage>
    with PageMixin {
  String _currentLocation = '获取中...';
  bool _isLocationEnabled = false;

  @override
  Future<void> onPageInit() async {
    // 模拟位置获取
    await Future.delayed(const Duration(seconds: 1));
    safeSetState(() {
      _isLocationEnabled = true;
      _currentLocation = '北京市朝阳区';
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('地图演示')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('地图已加载', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text('当前位置: $_currentLocation'),
            Text('位置权限: ${_isLocationEnabled ? "已授权" : "未授权"}'),
            const SizedBox(height: 8),
            const Text('网络检查和数据预加载由路由层处理'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLocationEnabled ? _updateLocation : null,
              child: const Text('更新位置'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateLocation() {
    safeSetState(() {
      _currentLocation = '上海市浦东新区';
    });
    showMessage(context, '位置已更新');
  }
}

/// 简单多媒体页面
class SimpleMultimediaPage extends SimpleStatelessPage {
  const SimpleMultimediaPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('多媒体演示')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 48, color: Colors.blue),
                SizedBox(width: 16),
                Icon(Icons.mic, size: 48, color: Colors.red),
                SizedBox(width: 16),
                Icon(Icons.storage, size: 48, color: Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            const Text('多媒体功能已就绪', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            const Text('相机、麦克风、存储权限由路由层处理'),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              children: [
                ElevatedButton(
                  onPressed: () => Get.snackbar('提示', '录制视频功能'),
                  child: const Text('录制视频'),
                ),
                ElevatedButton(
                  onPressed: () => Get.snackbar('提示', '录制音频功能'),
                  child: const Text('录制音频'),
                ),
                ElevatedButton(
                  onPressed: () => Get.snackbar('提示', '保存文件功能'),
                  child: const Text('保存文件'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 简单文件页面
class SimpleFilePage extends SimpleStatelessPage {
  const SimpleFilePage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文件管理演示')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder, size: 64, color: Colors.brown),
            SizedBox(height: 16),
            Text('文件管理功能已就绪', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('存储权限由路由层自动处理'),
            Text('页面专注于文件操作业务逻辑'),
          ],
        ),
      ),
    );
  }
}

/// 简单关于页面
class SimpleAboutPage extends SimpleStatelessPage {
  const SimpleAboutPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('新架构演示应用', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('版本: 1.0.0'),
            Text('基于路由层拦截的业务分离架构'),
          ],
        ),
      ),
    );
  }
}

/// 简单帮助页面
class SimpleHelpPage extends SimpleStatelessPage {
  const SimpleHelpPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('帮助')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '使用说明',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('1. 权限检查在路由层自动处理'),
            Text('2. 页面只需关注业务逻辑实现'),
            Text('3. 分析统计由框架自动完成'),
            Text('4. 加载状态和网络检查自动管理'),
            SizedBox(height: 16),
            Text(
              '架构特点',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• 完全的业务分离'),
            Text('• 高度的可复用性'),
            Text('• 优雅的扩展性'),
            Text('• 统一的生命周期管理'),
            Text('• 声明式的功能配置'),
          ],
        ),
      ),
    );
  }
}

// 其他页面类（简化版本，只保留必要的）
class SimpleProfilePage extends SimpleStatelessPage {
  const SimpleProfilePage({super.key});
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人资料')),
      body: const Center(child: Text('个人资料页面')),
    );
  }
}

class SimpleSettingsPage extends SimpleStatelessPage {
  const SimpleSettingsPage({super.key});
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: const Center(child: Text('设置页面')),
    );
  }
}

class SimpleEditProfilePage extends SimpleStatelessPage {
  const SimpleEditProfilePage({super.key});
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('编辑资料')),
      body: const Center(child: Text('编辑资料页面')),
    );
  }
}

class SimpleMediaCameraPage extends SimpleStatelessPage {
  const SimpleMediaCameraPage({super.key});
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('媒体相机')),
      body: const Center(child: Text('媒体相机页面')),
    );
  }
}

class SimpleMediaGalleryPage extends SimpleStatelessPage {
  const SimpleMediaGalleryPage({super.key});
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('媒体相册')),
      body: const Center(child: Text('媒体相册页面')),
    );
  }
}

class SimpleMediaVideoPage extends SimpleStatelessPage {
  const SimpleMediaVideoPage({super.key});
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('媒体视频')),
      body: const Center(child: Text('媒体视频页面')),
    );
  }
}

class SimpleQRScanPage extends SimpleStatelessPage {
  const SimpleQRScanPage({super.key});
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('二维码扫描')),
      body: const Center(child: Text('二维码扫描页面')),
    );
  }
}

class SimpleBluetoothPage extends SimpleStatelessPage {
  const SimpleBluetoothPage({super.key});
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('蓝牙')),
      body: const Center(child: Text('蓝牙页面')),
    );
  }
}

class SimpleCalculatorPage extends SimpleStatelessPage {
  const SimpleCalculatorPage({super.key});
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('计算器')),
      body: const Center(child: Text('计算器页面')),
    );
  }
}

// 系统页面
class SimpleErrorPage extends SimpleStatelessPage {
  const SimpleErrorPage({super.key});
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('错误')),
      body: const Center(child: Text('发生错误')),
    );
  }
}

class SimplePermissionDeniedPage extends SimpleStatelessPage {
  const SimplePermissionDeniedPage({super.key});
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('权限被拒绝')),
      body: const Center(child: Text('权限被拒绝')),
    );
  }
}

class SimpleNetworkErrorPage extends SimpleStatelessPage {
  const SimpleNetworkErrorPage({super.key});
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('网络错误')),
      body: const Center(child: Text('网络连接失败')),
    );
  }
}

class SimpleLoadingErrorPage extends SimpleStatelessPage {
  const SimpleLoadingErrorPage({super.key});
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('加载错误')),
      body: const Center(child: Text('加载失败')),
    );
  }
}
