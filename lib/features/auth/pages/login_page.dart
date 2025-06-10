/// 登录页面
///
/// 用户登录界面
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../ui/index.dart';
import '../../../core/localization/app_localizations.dart';
import '../controllers/auth_controller.dart';

/// 登录页面
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.all24,
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 顶部间距
                AppSpacing.verticalSpace48,

                // Logo和标题
                _buildHeader(context),

                AppSpacing.verticalSpace48,

                // 登录表单
                _buildLoginForm(controller),

                AppSpacing.verticalSpace24,

                // 登录按钮
                _buildLoginButton(controller),

                AppSpacing.verticalSpace16,

                // 忘记密码
                _buildForgotPassword(controller),

                AppSpacing.verticalSpace32,

                // 分割线
                _buildDivider(),

                AppSpacing.verticalSpace32,

                // 注册链接
                _buildRegisterLink(controller),
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
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppBorders.borderRadiusXl,
          ),
          child: const Icon(
            Icons.flutter_dash,
            size: 40,
            color: AppColors.white,
          ),
        ),

        AppSpacing.verticalSpace24,

        // 标题
        Text(
          S.login,
          style: AppTypography.headlineMediumStyle.copyWith(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),

        AppSpacing.verticalSpace8,

        // 副标题
        Text(
          '欢迎回来，请登录您的账户',
          style: AppTypography.bodyMediumStyle.copyWith(
            color: AppColors.getTextColor(context, isPrimary: false),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 构建登录表单
  Widget _buildLoginForm(LoginController controller) {
    return Column(
      children: [
        // 邮箱/手机号输入框
        AppTextField(
          controller: controller.identifierController,
          label: '邮箱/手机号',
          hintText: '请输入邮箱或手机号',
          prefixIcon: Icons.person_outline,
          //keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: controller.validateIdentifier,
          showClearButton: true,
        ),

        AppSpacing.verticalSpace16,

        // 密码输入框
        Obx(
          () => AppTextField.password(
            controller: controller.passwordController,
            label: S.password,
            hintText: S.enterPassword,
            textInputAction: TextInputAction.done,
            validator: controller.validatePassword,
            //showPasswordToggle: true,
            onSubmitted: (_) => controller.login(),
          ),
        ),

        AppSpacing.verticalSpace16,

        // 记住登录状态
        Obx(
          () => Row(
            children: [
              Checkbox(
                value: controller.rememberMe.value,
                onChanged: (_) => controller.toggleRememberMe(),
                activeColor: AppColors.primary,
              ),
              Text(
                '记住登录状态',
                style: AppTypography.bodyMediumStyle.copyWith(
                  color: AppColors.getTextColor(Get.context!, isPrimary: false),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建登录按钮
  Widget _buildLoginButton(LoginController controller) {
    return Obx(
      () => AppButton.primary(
        text: S.login,
        onPressed: controller.isLoading ? null : controller.login,
        isLoading: controller.isLoading,
        width: double.infinity,
        size: AppButtonSize.large,
      ),
    );
  }

  /// 构建忘记密码
  Widget _buildForgotPassword(LoginController controller) {
    return Center(
      child: AppButton.text(
        text: S.forgotPassword,
        onPressed: controller.forgotPassword,
        size: AppButtonSize.medium,
      ),
    );
  }

  /// 构建分割线
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.getBorderColor(Get.context!))),
        Padding(
          padding: AppSpacing.horizontal16,
          child: Text(
            '或',
            style: AppTypography.bodySmallStyle.copyWith(
              color: AppColors.getTextColor(Get.context!, isPrimary: false),
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.getBorderColor(Get.context!))),
      ],
    );
  }

  /// 构建注册链接
  Widget _buildRegisterLink(LoginController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账户？',
          style: AppTypography.bodyMediumStyle.copyWith(
            color: AppColors.getTextColor(Get.context!, isPrimary: false),
          ),
        ),
        AppSpacing.horizontalSpace8,
        AppButton.text(
          text: S.register,
          onPressed: controller.goToRegister,
          size: AppButtonSize.medium,
        ),
      ],
    );
  }
}
