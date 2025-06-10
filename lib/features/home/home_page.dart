/// 主页
///
/// 应用主页面
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ui/index.dart';
import '../../core/localization/app_localizations.dart';
import '../auth/services/auth_service.dart';

/// 主页
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(S.appName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/profile'),
            icon: AppAvatar(
              text: user?.avatarText ?? 'U',
              imageUrl: user?.avatar,
              size: AppAvatarSize.sm,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.all16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎卡片
            _buildWelcomeCard(context, user),

            AppSpacing.verticalSpace24,

            // 功能网格
            _buildFeatureGrid(context),

            AppSpacing.verticalSpace24,

            // 最近活动
            _buildRecentActivity(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  /// 构建欢迎卡片
  Widget _buildWelcomeCard(BuildContext context, user) {
    return AppCard(
      type: AppCardType.elevated,
      child: Padding(
        padding: AppSpacing.all20,
        child: Row(
          children: [
            AppAvatar(
              text: user?.avatarText ?? 'U',
              size: AppAvatarSize.lg,
              backgroundColor: AppColors.primary,
            ),
            AppSpacing.horizontalSpace16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.welcomeUser(user?.displayName ?? 'User'),
                    style: AppTypography.titleLargeStyle.copyWith(
                      color: AppColors.getTextColor(context),
                    ),
                  ),
                  AppSpacing.verticalSpace4,
                  Text(
                    '今天是美好的一天！',
                    style: AppTypography.bodyMediumStyle.copyWith(
                      color: AppColors.getTextColor(context, isPrimary: false),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建功能网格
  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.person_outline,
        title: S.profile,
        subtitle: '个人资料管理',
        onTap: () => Get.toNamed('/profile'),
      ),
      _FeatureItem(
        icon: Icons.settings_outlined,
        title: S.settings,
        subtitle: '应用设置',
        onTap: () => Get.toNamed('/settings'),
      ),
      _FeatureItem(
        icon: Icons.language_outlined,
        title: S.language,
        subtitle: '语言设置',
        onTap: () => _showLanguageSelector(),
      ),
      _FeatureItem(
        icon: Icons.palette_outlined,
        title: S.theme,
        subtitle: '主题设置',
        onTap: () => _showThemeSelector(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '功能',
          style: AppTypography.titleMediumStyle.copyWith(
            color: AppColors.getTextColor(context),
          ),
        ),
        AppSpacing.verticalSpace16,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return AppCard(
              type: AppCardType.outlined,
              onTap: feature.onTap,
              child: Padding(
                padding: AppSpacing.all16,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(feature.icon, size: 32, color: AppColors.primary),
                    AppSpacing.verticalSpace8,
                    Text(
                      feature.title,
                      style: AppTypography.titleSmallStyle.copyWith(
                        color: AppColors.getTextColor(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.verticalSpace4,
                    Text(
                      feature.subtitle,
                      style: AppTypography.bodySmallStyle.copyWith(
                        color: AppColors.getTextColor(
                          context,
                          isPrimary: false,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// 构建最近活动
  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最近活动',
          style: AppTypography.titleMediumStyle.copyWith(
            color: AppColors.getTextColor(context),
          ),
        ),
        AppSpacing.verticalSpace16,
        AppCard(
          type: AppCardType.outlined,
          child: Column(
            children: [
              AppListTile(
                leadingIcon: Icons.login,
                titleText: '登录成功',
                subtitleText: '刚刚',
                trailingIcon: Icons.check_circle,
              ),
              Divider(color: AppColors.getBorderColor(context)),
              AppListTile(
                leadingIcon: Icons.update,
                titleText: '更新资料',
                subtitleText: '2小时前',
                trailingIcon: Icons.edit,
              ),
              Divider(color: AppColors.getBorderColor(context)),
              AppListTile(
                leadingIcon: Icons.security,
                titleText: '安全检查',
                subtitleText: '今天',
                trailingIcon: Icons.shield,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建底部导航
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '首页',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore),
          label: '发现',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          activeIcon: Icon(Icons.notifications),
          label: '通知',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '我的',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // 首页
            break;
          case 1:
            // 发现
            Get.snackbar('提示', '发现功能开发中');
            break;
          case 2:
            // 通知
            Get.snackbar('提示', '通知功能开发中');
            break;
          case 3:
            // 我的
            Get.toNamed('/profile');
            break;
        }
      },
    );
  }

  /// 显示语言选择器
  void _showLanguageSelector() {
    Get.snackbar('提示', '语言切换功能开发中');
  }

  /// 显示主题选择器
  void _showThemeSelector() {
    Get.snackbar('提示', '主题切换功能开发中');
  }
}

/// 功能项模型
class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
