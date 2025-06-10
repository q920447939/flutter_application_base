/// 设置页面
///
/// 应用设置和配置页面
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../ui/index.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/localization_service.dart';
import '../../../core/theme/theme_service.dart';

/// 设置页面
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(S.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.all16,
        child: Column(
          children: [
            // 通用设置
            _buildGeneralSection(context),

            AppSpacing.verticalSpace16,

            // 外观设置
            _buildAppearanceSection(context),

            AppSpacing.verticalSpace16,

            // 关于设置
            _buildAboutSection(context),

            AppSpacing.verticalSpace32,
          ],
        ),
      ),
    );
  }

  /// 构建通用设置区域
  Widget _buildGeneralSection(BuildContext context) {
    return AppCard(
      type: AppCardType.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.all16,
            child: Text(
              S.general,
              style: AppTypography.titleMediumStyle.copyWith(
                color: AppColors.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AppListTile(
            leadingIcon: Icons.language_outlined,
            titleText: S.language,
            subtitleText: _getCurrentLanguageName(),
            trailingIcon: Icons.chevron_right,
            onTap: () => _showLanguageSelector(context),
          ),
          Divider(color: AppColors.getBorderColor(context)),
          AppListTile(
            leadingIcon: Icons.notifications_outlined,
            titleText: S.notification,
            subtitleText: '通知设置',
            trailingIcon: Icons.chevron_right,
            onTap: () => _showNotificationSettings(),
          ),
        ],
      ),
    );
  }

  /// 构建外观设置区域
  Widget _buildAppearanceSection(BuildContext context) {
    return AppCard(
      type: AppCardType.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.all16,
            child: Text(
              '外观',
              style: AppTypography.titleMediumStyle.copyWith(
                color: AppColors.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AppListTile(
            leadingIcon: Icons.palette_outlined,
            titleText: S.theme,
            subtitleText: _getCurrentThemeName(),
            trailingIcon: Icons.chevron_right,
            onTap: () => _showThemeSelector(context),
          ),
        ],
      ),
    );
  }

  /// 构建关于设置区域
  Widget _buildAboutSection(BuildContext context) {
    return AppCard(
      type: AppCardType.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.all16,
            child: Text(
              '关于',
              style: AppTypography.titleMediumStyle.copyWith(
                color: AppColors.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AppListTile(
            leadingIcon: Icons.info_outline,
            titleText: S.version,
            subtitleText: 'v1.0.0',
            onTap: () => _showVersionInfo(),
          ),
          Divider(color: AppColors.getBorderColor(context)),
          AppListTile(
            leadingIcon: Icons.feedback_outlined,
            titleText: S.feedback,
            subtitleText: '意见反馈',
            trailingIcon: Icons.chevron_right,
            onTap: () => _showFeedback(),
          ),
          Divider(color: AppColors.getBorderColor(context)),
          AppListTile(
            leadingIcon: Icons.help_outline,
            titleText: S.help,
            subtitleText: '帮助中心',
            trailingIcon: Icons.chevron_right,
            onTap: () => _showHelp(),
          ),
        ],
      ),
    );
  }

  /// 获取当前语言名称
  String _getCurrentLanguageName() {
    final currentLanguage = LocalizationService.instance.currentLanguage;
    return currentLanguage.name;
  }

  /// 获取当前主题名称
  String _getCurrentThemeName() {
    /* final themeMode = ThemeService.instance.currentThemeMode;
    switch (themeMode) {
      case ThemeMode.light:
        return S.lightTheme;
      case ThemeMode.dark:
        return S.darkTheme;
      case ThemeMode.system:
        return S.systemTheme;
    } */
    return '';
  }

  /// 显示语言选择器
  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: AppSpacing.all16,
                  child: Text(
                    S.language,
                    style: AppTypography.titleMediumStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...LocalizationService.instance.getSupportedLanguages().map(
                  (language) => ListTile(
                    title: Text(language.name),
                    trailing:
                        LocalizationService.instance.isCurrentLanguage(language)
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                    onTap: () {
                      LocalizationService.instance.changeLanguage(language);
                      Get.back();
                    },
                  ),
                ),
                AppSpacing.verticalSpace16,
              ],
            ),
          ),
    );
  }

  /// 显示主题选择器
  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: AppSpacing.all16,
                  child: Text(
                    S.theme,
                    style: AppTypography.titleMediumStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.light_mode),
                  title: Text(S.lightTheme),
                  /* trailing: ThemeService.instance.currentThemeMode == ThemeMode.light
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null, */
                  onTap: () {
                    //ThemeService.instance.setThemeMode(ThemeMode.light);
                    Get.back();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: Text(S.darkTheme),
                  /*  trailing: ThemeService.instance.currentThemeMode == ThemeMode.dark
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null, */
                  onTap: () {
                    //hemeService.instance.setThemeMode(ThemeMode.dark);
                    Get.back();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.auto_mode),
                  title: Text(S.systemTheme),
                  /*  trailing: ThemeService.instance.currentThemeMode == ThemeMode.system
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null, */
                  onTap: () {
                    //ThemeService.instance.setThemeMode(ThemeMode.system);
                    Get.back();
                  },
                ),
                AppSpacing.verticalSpace16,
              ],
            ),
          ),
    );
  }

  /// 显示通知设置
  void _showNotificationSettings() {
    Get.snackbar('提示', '通知设置功能开发中');
  }

  /// 显示版本信息
  void _showVersionInfo() {
    Get.dialog(
      AlertDialog(
        title: Text(S.version),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本号: v1.0.0'),
            Text('构建号: 1'),
            Text('发布日期: 2024-01-01'),
          ],
        ),
        actions: [TextButton(onPressed: () => Get.back(), child: Text(S.ok))],
      ),
    );
  }

  /// 显示意见反馈
  void _showFeedback() {
    Get.snackbar('提示', '意见反馈功能开发中');
  }

  /// 显示帮助
  void _showHelp() {
    Get.snackbar('提示', '帮助功能开发中');
  }
}
