/// 声明式权限配置演示页面
/// 
/// 展示如何在路由配置中使用声明式权限配置
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_base/core/base/simple_page.dart';

/// 声明式权限演示首页
class DeclarativePermissionHomePage extends SimpleStatelessPage {
  const DeclarativePermissionHomePage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('声明式权限配置演示'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '声明式权限配置演示',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '以下页面展示了如何在路由配置中声明式地设置权限，无需在页面代码中处理权限逻辑。',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDemoCard(
                    title: '相机演示',
                    subtitle: '使用预设权限配置',
                    icon: Icons.camera_alt,
                    color: Colors.green,
                    route: '/declarative/camera',
                    description: 'PermissionPresets.camera',
                  ),
                  _buildDemoCard(
                    title: '位置演示',
                    subtitle: '可选权限配置',
                    icon: Icons.location_on,
                    color: Colors.orange,
                    route: '/declarative/location',
                    description: 'PermissionPresets.location',
                  ),
                  _buildDemoCard(
                    title: '多媒体演示',
                    subtitle: '多权限组合',
                    icon: Icons.videocam,
                    color: Colors.red,
                    route: '/declarative/multimedia',
                    description: 'PermissionPresets.multimedia',
                  ),
                  _buildDemoCard(
                    title: '通讯演示',
                    subtitle: '通讯录权限',
                    icon: Icons.contacts,
                    color: Colors.blue,
                    route: '/declarative/communication',
                    description: 'PermissionPresets.communication',
                  ),
                  _buildDemoCard(
                    title: '存储演示',
                    subtitle: '文件系统权限',
                    icon: Icons.folder,
                    color: Colors.brown,
                    route: '/declarative/storage',
                    description: 'PermissionPresets.storage',
                  ),
                  _buildDemoCard(
                    title: '蓝牙演示',
                    subtitle: '蓝牙设备权限',
                    icon: Icons.bluetooth,
                    color: Colors.indigo,
                    route: '/declarative/bluetooth',
                    description: 'PermissionPresets.bluetooth',
                  ),
                  _buildDemoCard(
                    title: '自定义演示',
                    subtitle: '构建器模式',
                    icon: Icons.build,
                    color: Colors.purple,
                    route: '/declarative/custom',
                    description: 'PermissionConfigBuilder',
                  ),
                  _buildDemoCard(
                    title: '工厂演示',
                    subtitle: '工厂方法创建',
                    icon: Icons.factory,
                    color: Colors.teal,
                    route: '/declarative/factory',
                    description: 'PermissionConfigFactory',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
    required String description,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => Get.toNamed(route),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  description,
                  style: TextStyle(fontSize: 10, color: color),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 相机演示页面（使用预设权限配置）
class DeclarativeCameraPage extends SimpleStatelessPage {
  const DeclarativeCameraPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('相机演示'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text(
              '相机功能已就绪',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('使用 PermissionPresets.camera 配置'),
            Text('必需权限: 相机'),
            Text('可选权限: 存储'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.snackbar('提示', '拍照功能执行中...', backgroundColor: Colors.green);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.camera),
      ),
    );
  }
}

/// 位置演示页面（可选权限配置）
class DeclarativeLocationPage extends SimpleStatefulPage {
  const DeclarativeLocationPage({super.key});

  @override
  SimpleStatefulPageState createPageState() => _DeclarativeLocationPageState();
}

class _DeclarativeLocationPageState extends SimpleStatefulPageState<DeclarativeLocationPage> {
  String _location = '获取中...';

  @override
  Future<void> onPageInit() async {
    await Future.delayed(const Duration(seconds: 1));
    safeSetState(() {
      _location = '北京市朝阳区';
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('位置演示'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              '位置服务已就绪',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('当前位置: $_location'),
            const SizedBox(height: 8),
            const Text('使用 PermissionPresets.location 配置'),
            const Text('可选权限: 位置'),
          ],
        ),
      ),
    );
  }
}

/// 多媒体演示页面（多权限组合）
class DeclarativeMultimediaPage extends SimpleStatelessPage {
  const DeclarativeMultimediaPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('多媒体演示'),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 48, color: Colors.red),
                SizedBox(width: 16),
                Icon(Icons.mic, size: 48, color: Colors.red),
                SizedBox(width: 16),
                Icon(Icons.storage, size: 48, color: Colors.red),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '多媒体功能已就绪',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('使用 PermissionPresets.multimedia 配置'),
            Text('必需权限: 相机、麦克风'),
            Text('可选权限: 存储'),
          ],
        ),
      ),
    );
  }
}

/// 自定义权限配置演示页面
class DeclarativeCustomPage extends SimpleStatelessPage {
  const DeclarativeCustomPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义权限配置'),
        backgroundColor: Colors.purple,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 80, color: Colors.purple),
            SizedBox(height: 16),
            Text(
              '自定义权限配置演示',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('使用 PermissionConfigBuilder 构建'),
          ],
        ),
      ),
    );
  }
}

/// 工厂方法演示页面
class DeclarativeFactoryPage extends SimpleStatelessPage {
  const DeclarativeFactoryPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('工厂方法演示'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.factory, size: 80, color: Colors.teal),
            SizedBox(height: 16),
            Text(
              '工厂方法权限配置',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('使用 PermissionConfigFactory 创建'),
          ],
        ),
      ),
    );
  }
}

/// 其他演示页面（简化版本）
class DeclarativeCommunicationPage extends SimpleStatelessPage {
  const DeclarativeCommunicationPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('通讯演示'), backgroundColor: Colors.blue),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.contacts, size: 80, color: Colors.blue),
            SizedBox(height: 16),
            Text('通讯功能已就绪', style: TextStyle(fontSize: 20)),
            Text('使用 PermissionPresets.communication'),
          ],
        ),
      ),
    );
  }
}

class DeclarativeStoragePage extends SimpleStatelessPage {
  const DeclarativeStoragePage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('存储演示'), backgroundColor: Colors.brown),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder, size: 80, color: Colors.brown),
            SizedBox(height: 16),
            Text('存储功能已就绪', style: TextStyle(fontSize: 20)),
            Text('使用 PermissionPresets.storage'),
          ],
        ),
      ),
    );
  }
}

class DeclarativeBluetoothPage extends SimpleStatelessPage {
  const DeclarativeBluetoothPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('蓝牙演示'), backgroundColor: Colors.indigo),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth, size: 80, color: Colors.indigo),
            SizedBox(height: 16),
            Text('蓝牙功能已就绪', style: TextStyle(fontSize: 20)),
            Text('使用 PermissionPresets.bluetooth'),
          ],
        ),
      ),
    );
  }
}
