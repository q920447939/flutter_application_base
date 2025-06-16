/// 增强版登录演示页面
///
/// 演示新的认证架构功能
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_base/core/validation/validated_text_field.dart';

import '../controllers/enhanced_login_demo_controller.dart';

/// 增强版登录演示页面
class EnhancedLoginDemoPage extends StatelessWidget {
  const EnhancedLoginDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EnhancedLoginDemoController>(
      init: EnhancedLoginDemoController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text('增强版登录演示'), centerTitle: true),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  // 标题
                  const Text(
                    '用户名密码登录',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // 用户名输入框
                  TextFormField(
                    controller: controller.usernameController,
                    decoration: const InputDecoration(
                      labelText: '用户名',
                      hintText: '请输入用户名（6-30位）',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: controller.validateUsername,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  // 密码输入框
                  Obx(
                    () => TextFormField(
                      controller: controller.passwordController,
                      decoration: InputDecoration(
                        labelText: '密码',
                        hintText: '请输入密码',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.showPassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: !controller.showPassword.value,
                      validator: controller.validatePassword,
                      textInputAction: TextInputAction.next,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 验证码输入框和图片
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: controller.captchaController,
                          decoration: const InputDecoration(
                            labelText: '验证码',
                            hintText: '请输入验证码',
                            prefixIcon: Icon(Icons.security),
                            border: OutlineInputBorder(),
                          ),
                          validator: controller.validateCaptcha,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(flex: 1, child: _buildCaptchaImage(controller)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 记住登录
                  Obx(
                    () => CheckboxListTile(
                      title: const Text('记住登录'),
                      value: controller.rememberMe.value,
                      onChanged: (_) => controller.toggleRememberMe(),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 验证错误显示
                  ValidationErrorDisplay(controller: controller),

                  const SizedBox(height: 8),

                  // 登录按钮
                  Obx(
                    () => ElevatedButton(
                      onPressed:
                          controller.isLoading.value
                              ? null
                              : controller.loginWithUsername,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          controller.isLoading.value
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                '登录',
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 其他操作
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: controller.forgotPassword,
                        child: const Text('忘记密码？'),
                      ),
                      TextButton(
                        onPressed: controller.goToRegister,
                        child: const Text('注册账号'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 调试信息
                  _buildDebugInfo(controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建验证码图片
  Widget _buildCaptchaImage(EnhancedLoginDemoController controller) {
    return Obx(() {
      if (controller.isLoadingCaptcha.value) {
        return Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      final captcha = controller.captchaInfo.value;
      if (captcha == null) {
        return Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(child: Text('加载失败')),
        );
      }

      return GestureDetector(
        onTap: controller.refreshCaptcha,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.memory(
              base64Decode(captcha.imageBase64),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.refresh, size: 16),
                      Text(
                        '点击刷新',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }

  /// 构建调试信息
  Widget _buildDebugInfo(EnhancedLoginDemoController controller) {
    return Obx(() {
      final captcha = controller.captchaInfo.value;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '调试信息',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text('认证类型: ${controller.authType.value.description}'),
              Text('验证码会话ID: ${captcha?.sessionId ?? '无'}'),
              Text('验证码长度: ${captcha?.length ?? 0}'),
              Text('验证码过期时间: ${captcha?.expiresAt.toString() ?? '无'}'),
              Text('是否过期: ${captcha?.isExpired ?? true}'),
              Text('剩余时间: ${controller.getCaptchaRemainingSeconds()}秒'),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: controller.refreshCaptcha,
                    child: const Text('刷新验证码'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: controller.loadCaptcha,
                    child: const Text('重新获取'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
