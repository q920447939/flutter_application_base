/// 注册页面
///
/// 用户注册界面
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../ui/index.dart';
import '../../../core/localization/app_localizations.dart';
import '../controllers/auth_controller.dart';

/// 注册页面
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController());

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(S.register),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.all24,
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 标题
                _buildHeader(context),

                AppSpacing.verticalSpace32,

                // 注册表单
                _buildRegisterForm(controller),

                AppSpacing.verticalSpace24,

                // 注册按钮
                _buildRegisterButton(controller),

                AppSpacing.verticalSpace16,

                // 登录链接
                _buildLoginLink(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          '创建新账户',
          style: AppTypography.headlineMediumStyle.copyWith(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),

        AppSpacing.verticalSpace8,

        Text(
          '请填写以下信息完成注册',
          style: AppTypography.bodyMediumStyle.copyWith(
            color: AppColors.getTextColor(context, isPrimary: false),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 构建注册表单
  Widget _buildRegisterForm(RegisterController controller) {
    return Column(
      children: [
        // 用户名输入框（可选）
        AppTextField(
          controller: controller.usernameController,
          label: S.username,
          hintText: '请输入用户名（可选）',
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          validator: controller.validateUsername,
          showClearButton: true,
        ),

        AppSpacing.verticalSpace16,

        // 邮箱输入框（可选）
        AppTextField.email(
          controller: controller.emailController,
          label: '${S.email}（可选）',
          hintText: '请输入邮箱地址（可选）',
          textInputAction: TextInputAction.next,
          validator: controller.validateEmail,
        ),

        AppSpacing.verticalSpace16,

        // 手机号输入框
        AppTextField.phone(
          controller: controller.phoneController,
          label: S.phone,
          hintText: S.enterPhone,
          textInputAction: TextInputAction.next,
          validator: controller.validatePhone,
        ),

        AppSpacing.verticalSpace16,

        // 验证码输入框
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AppTextField(
                controller: controller.verificationCodeController,
                label: S.verificationCode,
                hintText: '请输入验证码',
                prefixIcon: Icons.sms_outlined,
                //keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: controller.validateVerificationCode,
                maxLength: 6,
              ),
            ),
            AppSpacing.horizontalSpace12,
            Expanded(
              child: Obx(
                () => AppButton.outline(
                  text:
                      controller.codeCountdown.value > 0
                          ? '${controller.codeCountdown.value}s'
                          : S.sendCode,
                  onPressed:
                      controller.codeCountdown.value > 0
                          ? null
                          : controller.sendVerificationCode,
                  size: AppButtonSize.large,
                ),
              ),
            ),
          ],
        ),

        AppSpacing.verticalSpace16,

        // 昵称输入框（可选）
        AppTextField(
          controller: controller.nicknameController,
          label: '${S.nickname}（可选）',
          hintText: '请输入昵称（可选）',
          prefixIcon: Icons.badge_outlined,
          textInputAction: TextInputAction.next,
          validator: controller.validateNickname,
          showClearButton: true,
        ),

        AppSpacing.verticalSpace16,

        // 密码输入框
        Obx(
          () => AppTextField.password(
            controller: controller.passwordController,
            label: S.password,
            hintText: S.enterPassword,
            textInputAction: TextInputAction.next,
            validator: controller.validatePassword,
            //showPasswordToggle: true,
          ),
        ),

        AppSpacing.verticalSpace16,

        // 确认密码输入框
        Obx(
          () => AppTextField.password(
            controller: controller.confirmPasswordController,
            label: S.confirmPassword,
            hintText: '请再次输入密码',
            textInputAction: TextInputAction.done,
            validator: controller.validateConfirmPassword,
            //showPasswordToggle: true,
            onSubmitted: (_) => controller.register(),
          ),
        ),
      ],
    );
  }

  /// 构建注册按钮
  Widget _buildRegisterButton(RegisterController controller) {
    return Obx(
      () => AppButton.primary(
        text: S.register,
        onPressed: controller.isLoading ? null : controller.register,
        isLoading: controller.isLoading,
        width: double.infinity,
        size: AppButtonSize.large,
      ),
    );
  }

  /// 构建登录链接
  Widget _buildLoginLink(RegisterController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '已有账户？',
          style: AppTypography.bodyMediumStyle.copyWith(
            color: AppColors.getTextColor(Get.context!, isPrimary: false),
          ),
        ),
        AppSpacing.horizontalSpace8,
        AppButton.text(
          text: S.login,
          onPressed: controller.goToLogin,
          size: AppButtonSize.medium,
        ),
      ],
    );
  }
}
