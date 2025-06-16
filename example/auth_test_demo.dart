/// 认证功能测试演示
///
/// 演示如何使用新的认证架构进行各种认证操作
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_base/features/auth/index.dart';

/// 认证测试演示页面
class AuthTestDemoPage extends StatelessWidget {
  const AuthTestDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthTestController>(
      init: AuthTestController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text('认证功能测试'), centerTitle: true),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 服务状态检查
                _buildServiceStatusCard(controller),

                const SizedBox(height: 16),

                // 验证码测试
                _buildCaptchaTestCard(controller),

                const SizedBox(height: 16),

                // 认证测试
                _buildAuthTestCard(controller),

                const SizedBox(height: 16),

                // 统计信息
                _buildStatsCard(controller),

                const SizedBox(height: 16),

                // Token信息
                _buildTokenCard(controller),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建服务状态卡片
  Widget _buildServiceStatusCard(AuthTestController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '服务状态检查',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Obx(() => Text(controller.serviceStatus.value)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: controller.checkServiceStatus,
              child: const Text('检查服务状态'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建验证码测试卡片
  Widget _buildCaptchaTestCard(AuthTestController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '验证码测试',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final captcha = controller.currentCaptcha.value;
              if (captcha != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('会话ID: ${captcha.sessionId}'),
                    Text('过期时间: ${captcha.expireSeconds}秒'),
                    Text('是否过期: ${captcha.isExpired}'),
                    const SizedBox(height: 8),
                    Container(
                      height: 50,
                      width: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child:
                          captcha.imageBase64.isNotEmpty
                              ? Image.memory(
                                base64Decode(captcha.imageBase64),
                                fit: BoxFit.cover,
                              )
                              : const Center(child: Text('无图片')),
                    ),
                  ],
                );
              } else {
                return const Text('暂无验证码');
              }
            }),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: controller.getCaptcha,
                  child: const Text('获取验证码'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: controller.refreshCaptcha,
                  child: const Text('刷新验证码'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建认证测试卡片
  Widget _buildAuthTestCard(AuthTestController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '认证测试',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Obx(() => Text('认证状态: ${controller.authStatus.value}')),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: controller.testAuthentication,
              child: const Text('测试认证'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计信息卡片
  Widget _buildStatsCard(AuthTestController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '认证统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Obx(() => Text(controller.authStats.value)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: controller.getAuthStats,
              child: const Text('获取统计信息'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建Token信息卡片
  Widget _buildTokenCard(AuthTestController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Token信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Obx(() => Text(controller.tokenInfo.value)),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: controller.getTokenInfo,
                  child: const Text('获取Token'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: controller.clearToken,
                  child: const Text('清除Token'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 认证测试控制器
class AuthTestController extends GetxController {
  /// 服务状态
  final RxString serviceStatus = '未检查'.obs;

  /// 当前验证码
  final Rx<CaptchaInfo?> currentCaptcha = Rx<CaptchaInfo?>(null);

  /// 认证状态
  final RxString authStatus = '未认证'.obs;

  /// 认证统计
  final RxString authStats = '暂无数据'.obs;

  /// Token信息
  final RxString tokenInfo = '暂无Token'.obs;

  @override
  void onInit() {
    super.onInit();
    checkServiceStatus();
  }

  /// 检查服务状态
  void checkServiceStatus() {
    final report = AuthServiceInitializer.getStatusReport();
    serviceStatus.value = report;
  }

  /// 获取验证码
  Future<void> getCaptcha() async {
    try {
      final result = await CaptchaService.instance.getCaptcha();
      if (result.isSuccess && result.data != null) {
        currentCaptcha.value = result.data;
        Get.snackbar('成功', '获取验证码成功');
      } else {
        Get.snackbar('失败', '获取验证码失败: ${result.msg}');
      }
    } catch (e) {
      Get.snackbar('错误', '获取验证码异常: $e');
    }
  }

  /// 刷新验证码
  Future<void> refreshCaptcha() async {
    final captcha = currentCaptcha.value;
    if (captcha == null) {
      await getCaptcha();
      return;
    }

    try {
      final result = await CaptchaService.instance.refreshCaptcha(
        sessionId: captcha.sessionId,
      );
      if (result.isSuccess && result.data != null) {
        currentCaptcha.value = result.data;
        Get.snackbar('成功', '刷新验证码成功');
      } else {
        Get.snackbar('失败', '刷新验证码失败: ${result.msg}');
      }
    } catch (e) {
      Get.snackbar('错误', '刷新验证码异常: $e');
    }
  }

  /// 测试认证
  Future<void> testAuthentication() async {
    final captcha = currentCaptcha.value;
    if (captcha == null) {
      Get.snackbar('提示', '请先获取验证码');
      return;
    }

    try {
      final result = await AuthManager.instance.authenticateWithUsername(
        username: 'testuser',
        password: 'password123',
        captcha: '1234',
        captchaSessionId: captcha.sessionId,
      );

      if (result.isSuccess) {
        authStatus.value = '认证成功';
        Get.snackbar('成功', '认证成功');
      } else {
        authStatus.value = '认证失败: ${result.msg}';
        Get.snackbar('失败', '认证失败: ${result.msg}');
      }
    } catch (e) {
      authStatus.value = '认证异常: $e';
      Get.snackbar('错误', '认证异常: $e');
    }
  }

  /// 获取认证统计
  void getAuthStats() {
    final stats = AuthManager.instance.getAuthStatistics();
    final buffer = StringBuffer();
    buffer.writeln('认证统计信息:');
    buffer.writeln('尝试次数: ${stats['attempts']}');
    buffer.writeln('成功次数: ${stats['successes']}');
    buffer.writeln('失败次数: ${stats['failures']}');

    authStats.value = buffer.toString();
  }

  /// 获取Token信息
  void getTokenInfo() {
    final authService = AuthService.instance;
    final buffer = StringBuffer();

    buffer.writeln('Token信息:');
    buffer.writeln('认证状态: ${authService.authStatus}');
    buffer.writeln('是否已认证: ${authService.isAuthenticated}');

    final authHeader = authService.getAuthorizationHeader();
    if (authHeader != null) {
      buffer.writeln('Authorization头: $authHeader');
      buffer.writeln('Token长度: ${authService.accessToken.length}');
    } else {
      buffer.writeln('暂无Token');
    }

    tokenInfo.value = buffer.toString();
  }

  /// 清除Token
  Future<void> clearToken() async {
    try {
      await AuthService.instance.logout();
      tokenInfo.value = 'Token已清除';
      authStatus.value = '已退出登录';
      Get.snackbar('成功', 'Token已清除');
    } catch (e) {
      Get.snackbar('错误', '清除Token失败: $e');
    }
  }
}
