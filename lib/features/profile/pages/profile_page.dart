/// 用户资料页面
///
/// 显示和管理用户个人信息
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../ui/index.dart';
import '../../../core/localization/app_localizations.dart';
import '../controllers/profile_controller.dart';
import '../../auth/models/user_model.dart';

/// 用户资料页面
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: Obx(() {
        if (!controller.isUserLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            // 自定义AppBar
            _buildSliverAppBar(context, controller),

            // 内容区域
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.all16,
                child: Column(
                  children: [
                    // 用户信息卡片
                    _buildUserInfoCard(context, controller),

                    AppSpacing.verticalSpace16,

                    // 功能菜单
                    _buildMenuSection(context, controller),

                    AppSpacing.verticalSpace16,

                    // 设置菜单
                    _buildSettingsSection(context, controller),

                    AppSpacing.verticalSpace16,

                    // 退出登录
                    _buildLogoutSection(context, controller),

                    AppSpacing.verticalSpace32,
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// 构建SliverAppBar
  Widget _buildSliverAppBar(
    BuildContext context,
    ProfileController controller,
  ) {
    final user = controller.currentUser;

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(S.profile, style: const TextStyle(color: AppColors.white)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppSpacing.verticalSpace32,

                // 头像
                AppAvatar(
                  text: user?.avatarText ?? 'U',
                  imageUrl: user?.avatar,
                  size: AppAvatarSize.xl,
                  backgroundColor: AppColors.white.withOpacity(0.2),
                  //textColor: AppColors.white,
                ),

                AppSpacing.verticalSpace12,

                // 用户名
                Text(
                  user?.displayName ?? 'User',
                  style: AppTypography.titleLargeStyle.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                AppSpacing.verticalSpace4,

                // 用户状态
                Container(
                  padding: AppSpacing.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: AppBorders.borderRadiusSm,
                  ),
                  child: Text(
                    user?.isActive == true ? '活跃用户' : '非活跃用户',
                    style: AppTypography.bodySmallStyle.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: controller.editProfile,
          icon: const Icon(Icons.edit, color: AppColors.white),
        ),
      ],
    );
  }

  /// 构建用户信息卡片
  Widget _buildUserInfoCard(
    BuildContext context,
    ProfileController controller,
  ) {
    final user = controller.currentUser;

    return AppCard(
      type: AppCardType.elevated,
      child: Padding(
        padding: AppSpacing.all20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.personalInfo,
              style: AppTypography.titleMediumStyle.copyWith(
                color: AppColors.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.verticalSpace16,

            // 基本信息
            _buildInfoRow(
              context,
              icon: Icons.person_outline,
              label: S.nickname,
              value: user?.nickname ?? '未设置',
            ),

            _buildInfoRow(
              context,
              icon: Icons.email_outlined,
              label: S.email,
              value: user?.email ?? '未设置',
              verified: user?.emailVerified == true,
            ),

            _buildInfoRow(
              context,
              icon: Icons.phone_outlined,
              label: S.phone,
              value: user?.phone ?? '未设置',
              verified: user?.phoneVerified == true,
            ),

            if (user?.gender != null)
              _buildInfoRow(
                context,
                icon: Icons.wc_outlined,
                label: S.gender,
                value: _getGenderText(user!.gender!),
              ),

            if (user?.birthday != null)
              _buildInfoRow(
                context,
                icon: Icons.cake_outlined,
                label: S.birthday,
                value: _formatBirthday(user!.birthday!),
              ),

            if (user?.address != null && user!.address!.isNotEmpty)
              _buildInfoRow(
                context,
                icon: Icons.location_on_outlined,
                label: S.address,
                value: user.address!,
              ),

            if (user?.bio != null && user!.bio!.isNotEmpty)
              _buildInfoRow(
                context,
                icon: Icons.info_outline,
                label: S.bio,
                value: user.bio!,
                maxLines: 3,
              ),
          ],
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool verified = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: AppSpacing.buttonSmallPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.getTextColor(context, isPrimary: false),
          ),
          AppSpacing.horizontalSpace12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: AppTypography.bodySmallStyle.copyWith(
                        color: AppColors.getTextColor(
                          context,
                          isPrimary: false,
                        ),
                      ),
                    ),
                    if (verified) ...[
                      AppSpacing.horizontalSpace4,
                      Icon(Icons.verified, size: 16, color: AppColors.success),
                    ],
                  ],
                ),
                AppSpacing.verticalSpace2,
                Text(
                  value,
                  style: AppTypography.bodyMediumStyle.copyWith(
                    color: AppColors.getTextColor(context),
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建功能菜单
  Widget _buildMenuSection(BuildContext context, ProfileController controller) {
    return AppCard(
      type: AppCardType.outlined,
      child: Column(
        children: [
          AppListTile(
            leadingIcon: Icons.edit_outlined,
            titleText: S.updateProfile,
            subtitleText: '编辑个人信息',
            trailingIcon: Icons.chevron_right,
            onTap: controller.editProfile,
          ),
          Divider(color: AppColors.getBorderColor(context)),
          AppListTile(
            leadingIcon: Icons.lock_outline,
            titleText: S.changePassword,
            subtitleText: '修改登录密码',
            trailingIcon: Icons.chevron_right,
            onTap: controller.changePassword,
          ),
        ],
      ),
    );
  }

  /// 构建设置菜单
  Widget _buildSettingsSection(
    BuildContext context,
    ProfileController controller,
  ) {
    return AppCard(
      type: AppCardType.outlined,
      child: Column(
        children: [
          AppListTile(
            leadingIcon: Icons.settings_outlined,
            titleText: S.settings,
            subtitleText: '应用设置',
            trailingIcon: Icons.chevron_right,
            onTap: controller.openSettings,
          ),
          Divider(color: AppColors.getBorderColor(context)),
          AppListTile(
            leadingIcon: Icons.help_outline,
            titleText: S.help,
            subtitleText: '帮助与反馈',
            trailingIcon: Icons.chevron_right,
            onTap: controller.openHelp,
          ),
          Divider(color: AppColors.getBorderColor(context)),
          AppListTile(
            leadingIcon: Icons.info_outline,
            titleText: S.about,
            subtitleText: '关于应用',
            trailingIcon: Icons.chevron_right,
            onTap: controller.openAbout,
          ),
        ],
      ),
    );
  }

  /// 构建退出登录区域
  Widget _buildLogoutSection(
    BuildContext context,
    ProfileController controller,
  ) {
    return AppCard(
      type: AppCardType.outlined,
      child: AppListTile(
        leadingIcon: Icons.logout,
        titleText: S.logout,
        subtitleText: '退出当前账户',
        //titleColor: AppColors.error,
        onTap: controller.logout,
      ),
    );
  }

  /// 获取性别文本
  String _getGenderText(Gender gender) {
    switch (gender) {
      case Gender.male:
        return S.male;
      case Gender.female:
        return S.female;
      case Gender.other:
        return S.other;
    }
  }

  /// 格式化生日
  String _formatBirthday(DateTime birthday) {
    return '${birthday.year}年${birthday.month}月${birthday.day}日';
  }
}
