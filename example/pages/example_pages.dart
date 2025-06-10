/// 页面基类使用示例
///
/// 展示如何使用页面基类实现业务与框架功能的分离
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_base/core/base/index.dart';
import 'package:flutter_application_base/core/permissions/permission_service.dart';

/// 示例1：基础页面（无特殊功能）
class BasicExamplePage extends BaseStatelessPage {
  const BasicExamplePage({super.key});

  @override
  PageConfig get pageConfig => PageConfigPresets.basic('/basic', title: '基础页面');

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('基础页面示例')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 64),
            SizedBox(height: 16),
            Text('这是一个基础页面，没有特殊功能'),
            Text('开发者只需要关注业务逻辑实现'),
          ],
        ),
      ),
    );
  }
}

/// 示例2：相机页面（需要权限检查）
class CameraExamplePage extends BaseStatelessPage {
  const CameraExamplePage({super.key});

  @override
  PageConfig get pageConfig =>
      PageFeatureComposer()
          .route('/camera_example')
          .title('相机示例')
          .withPermissions(
            required: [AppPermission.camera],
            optional: [AppPermission.storage],
            onGranted: (permissions) {
              Get.snackbar(
                '成功',
                '权限已授权: ${permissions.map((p) => p.name).join(', ')}',
              );
            },
            onDenied: (permissions) async {
              Get.snackbar(
                '错误',
                '权限被拒绝: ${permissions.map((p) => p.name).join(', ')}',
              );
              return false; // 不允许进入页面
            },
          )
          .withAnalytics(
            pageName: 'camera_example',
            customParameters: {'feature': 'photo_capture'},
            onEnter: (route, params) {
              debugPrint('📊 进入相机页面: $route, 参数: $params');
            },
            onExit: (route, duration) {
              debugPrint('📊 离开相机页面: $route, 停留时间: ${duration.inSeconds}秒');
            },
          )
          .build();

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('相机示例')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 64),
            const SizedBox(height: 16),
            const Text('相机功能已就绪'),
            const SizedBox(height: 8),
            const Text('权限检查由框架自动处理'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 这里实现拍照业务逻辑
                Get.snackbar('提示', '拍照功能执行中...');
              },
              child: const Text('拍照'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 示例4：VIP页面（需要业务级别检查）
class VipExamplePage extends BaseStatelessPage {
  const VipExamplePage({super.key});

  @override
  PageConfig get pageConfig =>
      PageConfigPresets.basic('/vip_example', title: 'VIP页面');

  @override
  Future<bool> onBusinessCheck(BuildContext context) async {
    // 模拟VIP状态检查
    await Future.delayed(const Duration(milliseconds: 500));

    // 这里可以调用实际的用户服务检查VIP状态
    final isVip = DateTime.now().millisecond % 2 == 0; // 随机模拟

    if (!isVip) {
      Get.dialog(
        AlertDialog(
          title: const Text('访问受限'),
          content: const Text('此页面仅限VIP用户访问'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.back(); // 返回上一页
              },
              child: const Text('返回'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar('提示', '跳转到VIP购买页面');
              },
              child: const Text('购买VIP'),
            ),
          ],
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VIP页面'), backgroundColor: Colors.amber),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, size: 64, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              '欢迎VIP用户！',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('这里是VIP专属内容'),
            Text('业务检查由框架自动处理'),
          ],
        ),
      ),
    );
  }
}

/// 示例5：自定义功能页面
class CustomFeatureExamplePage extends BaseStatelessPage {
  const CustomFeatureExamplePage({super.key});

  @override
  PageConfig get pageConfig =>
      PageFeatureComposer()
          .route('/custom_feature_example')
          .title('自定义功能示例')
          .withFeature(_CustomBorderFeature())
          .withFeature(_CustomLogFeature())
          .withAnalytics(pageName: 'custom_feature_example')
          .build();

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自定义功能示例')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.extension, size: 64),
            SizedBox(height: 16),
            Text('这个页面使用了自定义功能'),
            SizedBox(height: 8),
            Text('1. 自定义边框功能'),
            Text('2. 自定义日志功能'),
            SizedBox(height: 8),
            Text('查看控制台输出了解功能执行情况'),
          ],
        ),
      ),
    );
  }
}

/// 自定义边框功能
class _CustomBorderFeature implements IPageFeature {
  @override
  String get featureName => 'CustomBorderFeature';

  @override
  Future<bool> onPageEnter(BuildContext context, String route) async {
    debugPrint('🎨 自定义边框功能：页面进入 $route');
    return true;
  }

  @override
  Widget onPageBuild(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(8),
      child: child,
    );
  }

  @override
  Future<bool> onPageExit(BuildContext context, String route) async {
    debugPrint('🎨 自定义边框功能：页面退出 $route');
    return true;
  }

  @override
  void onPageDispose() {
    debugPrint('🎨 自定义边框功能：页面销毁');
  }
}

/// 自定义日志功能
class _CustomLogFeature implements IPageFeature {
  @override
  String get featureName => 'CustomLogFeature';

  @override
  Future<bool> onPageEnter(BuildContext context, String route) async {
    debugPrint('📝 自定义日志功能：记录页面访问 $route');
    return true;
  }

  @override
  Widget onPageBuild(BuildContext context, Widget child) {
    debugPrint('📝 自定义日志功能：页面构建完成');
    return child;
  }

  @override
  Future<bool> onPageExit(BuildContext context, String route) async {
    debugPrint('📝 自定义日志功能：记录页面离开 $route');
    return true;
  }

  @override
  void onPageDispose() {
    debugPrint('📝 自定义日志功能：清理日志资源');
  }
}

/// 示例页面路由配置
class ExampleRoutes {
  static final routes = [
    GetPage(name: '/basic', page: () => const BasicExamplePage()),
    GetPage(name: '/camera_example', page: () => const CameraExamplePage()),
    GetPage(name: '/vip_example', page: () => const VipExamplePage()),
    GetPage(
      name: '/custom_feature_example',
      page: () => const CustomFeatureExamplePage(),
    ),
  ];
}
