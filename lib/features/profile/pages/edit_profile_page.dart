/// 编辑资料页面
///
/// 用户编辑个人信息的页面
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../ui/index.dart';
import '../../../core/localization/app_localizations.dart';
import '../controllers/profile_controller.dart';
import '../../auth/models/user_model.dart';

/// 编辑资料页面
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(S.updateProfile),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isLoading ? null : controller.saveProfile,
              child: Text(
                S.save,
                style: TextStyle(
                  color: controller.isLoading ? Colors.grey : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.all16,
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              // 头像编辑
              _buildAvatarSection(context, controller),

              AppSpacing.verticalSpace24,

              // 基本信息
              _buildBasicInfoSection(context, controller),

              AppSpacing.verticalSpace24,

              // 联系信息
              _buildContactInfoSection(context, controller),

              AppSpacing.verticalSpace24,

              // 个人信息
              _buildPersonalInfoSection(context, controller),

              AppSpacing.verticalSpace32,

              // 保存按钮
              _buildSaveButton(context, controller),

              AppSpacing.verticalSpace32,
            ],
          ),
        ),
      ),
    );
  }

  /// 构建头像编辑区域
  Widget _buildAvatarSection(
    BuildContext context,
    EditProfileController controller,
  ) {
    return AppCard(
      type: AppCardType.elevated,
      child: Padding(
        padding: AppSpacing.all20,
        child: Column(
          children: [
            Text(
              S.avatar,
              style: AppTypography.titleMediumStyle.copyWith(
                color: AppColors.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.verticalSpace16,

            // 头像显示和编辑
            GestureDetector(
              onTap: controller.selectAvatar,
              child: Stack(
                children: [
                  Obx(
                    () => AppAvatar(
                      text:
                          controller.nicknameController.text.isNotEmpty
                              ? controller.nicknameController.text
                                  .substring(0, 1)
                                  .toUpperCase()
                              : 'U',
                      imageUrl:
                          controller.avatarUrl.value.isEmpty
                              ? null
                              : controller.avatarUrl.value,
                      size: AppAvatarSize.xl,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: AppSpacing.all8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.verticalSpace8,

            Text(
              '点击更换头像',
              style: AppTypography.bodySmallStyle.copyWith(
                color: AppColors.getTextColor(context, isPrimary: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建基本信息区域
  Widget _buildBasicInfoSection(
    BuildContext context,
    EditProfileController controller,
  ) {
    return AppCard(
      type: AppCardType.outlined,
      child: Padding(
        padding: AppSpacing.all20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本信息',
              style: AppTypography.titleMediumStyle.copyWith(
                color: AppColors.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.verticalSpace16,

            // 昵称
            AppTextField(
              controller: controller.nicknameController,
              label: S.nickname,
              hintText: S.enterNickname,
              prefixIcon: Icons.person_outline,
              validator: controller.validateNickname,
              showClearButton: true,
            ),

            AppSpacing.verticalSpace16,

            // 性别选择
            _buildGenderSelector(context, controller),

            AppSpacing.verticalSpace16,

            // 生日选择
            _buildBirthdaySelector(context, controller),
          ],
        ),
      ),
    );
  }

  /// 构建联系信息区域
  Widget _buildContactInfoSection(
    BuildContext context,
    EditProfileController controller,
  ) {
    return AppCard(
      type: AppCardType.outlined,
      child: Padding(
        padding: AppSpacing.all20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '联系信息',
              style: AppTypography.titleMediumStyle.copyWith(
                color: AppColors.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.verticalSpace16,

            // 邮箱
            AppTextField.email(
              controller: controller.emailController,
              label: '${S.email}（可选）',
              hintText: S.enterEmail,
              validator: controller.validateEmail,
            ),

            AppSpacing.verticalSpace16,

            // 手机号
            AppTextField.phone(
              controller: controller.phoneController,
              label: '${S.phone}（可选）',
              hintText: S.enterPhone,
              validator: controller.validatePhone,
            ),

            AppSpacing.verticalSpace16,

            // 地址
            AppTextField(
              controller: controller.addressController,
              label: '${S.address}（可选）',
              hintText: '请输入地址',
              //prefixIcon: Icons.location_on_outline,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建个人信息区域
  Widget _buildPersonalInfoSection(
    BuildContext context,
    EditProfileController controller,
  ) {
    return AppCard(
      type: AppCardType.outlined,
      child: Padding(
        padding: AppSpacing.all20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '个人信息',
              style: AppTypography.titleMediumStyle.copyWith(
                color: AppColors.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.verticalSpace16,

            // 个人简介
            AppTextField(
              controller: controller.bioController,
              label: '${S.bio}（可选）',
              hintText: '请输入个人简介',
              prefixIcon: Icons.info_outline,
              maxLines: 4,
              maxLength: 200,
              validator: controller.validateBio,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建性别选择器
  Widget _buildGenderSelector(
    BuildContext context,
    EditProfileController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.gender,
          style: AppTypography.bodyMediumStyle.copyWith(
            color: AppColors.getTextColor(context),
          ),
        ),
        AppSpacing.verticalSpace8,
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _buildGenderOption(
                  context,
                  controller,
                  Gender.male,
                  S.male,
                  Icons.male,
                ),
              ),
              AppSpacing.horizontalSpace8,
              Expanded(
                child: _buildGenderOption(
                  context,
                  controller,
                  Gender.female,
                  S.female,
                  Icons.female,
                ),
              ),
              AppSpacing.horizontalSpace8,
              Expanded(
                child: _buildGenderOption(
                  context,
                  controller,
                  Gender.other,
                  S.other,
                  Icons.transgender,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建性别选项
  Widget _buildGenderOption(
    BuildContext context,
    EditProfileController controller,
    Gender gender,
    String label,
    IconData icon,
  ) {
    final isSelected = controller.selectedGender.value == gender;

    return GestureDetector(
      onTap: () => controller.selectGender(gender),
      child: Container(
        padding: AppSpacing.all12,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
          border: Border.all(
            color:
                isSelected
                    ? AppColors.primary
                    : AppColors.getBorderColor(context),
          ),
          borderRadius: AppBorders.borderRadiusMd,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? AppColors.primary
                      : AppColors.getTextColor(context, isPrimary: false),
            ),
            AppSpacing.verticalSpace4,
            Text(
              label,
              style: AppTypography.bodySmallStyle.copyWith(
                color:
                    isSelected
                        ? AppColors.primary
                        : AppColors.getTextColor(context, isPrimary: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建生日选择器
  Widget _buildBirthdaySelector(
    BuildContext context,
    EditProfileController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.birthday,
          style: AppTypography.bodyMediumStyle.copyWith(
            color: AppColors.getTextColor(context),
          ),
        ),
        AppSpacing.verticalSpace8,
        GestureDetector(
          onTap: controller.selectBirthday,
          child: Container(
            width: double.infinity,
            padding: AppSpacing.all16,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.getBorderColor(context)),
              borderRadius: AppBorders.borderRadiusMd,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cake_outlined,
                  color: AppColors.getTextColor(context, isPrimary: false),
                ),
                AppSpacing.horizontalSpace12,
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.getBirthdayText(
                        controller.selectedBirthday.value,
                      ),
                      style: AppTypography.bodyMediumStyle.copyWith(
                        color:
                            controller.selectedBirthday.value == null
                                ? AppColors.getTextColor(
                                  context,
                                  isPrimary: false,
                                )
                                : AppColors.getTextColor(context),
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.getTextColor(context, isPrimary: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建保存按钮
  Widget _buildSaveButton(
    BuildContext context,
    EditProfileController controller,
  ) {
    return Obx(
      () => AppButton.primary(
        text: S.save,
        onPressed: controller.isLoading ? null : controller.saveProfile,
        isLoading: controller.isLoading,
        width: double.infinity,
        size: AppButtonSize.large,
      ),
    );
  }
}
