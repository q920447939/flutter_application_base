/// 应用国际化
/// 
/// 提供多语言支持，包括：
/// - 中文简体
/// - 中文繁体
/// - 英文
/// - 动态语言切换
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 支持的语言枚举
enum SupportedLanguage {
  zhCN,  // 中文简体
  zhTW,  // 中文繁体
  en,    // 英文
}

/// 语言扩展
extension SupportedLanguageExtension on SupportedLanguage {
  /// 获取Locale
  Locale get locale {
    switch (this) {
      case SupportedLanguage.zhCN:
        return const Locale('zh', 'CN');
      case SupportedLanguage.zhTW:
        return const Locale('zh', 'TW');
      case SupportedLanguage.en:
        return const Locale('en', 'US');
    }
  }

  /// 获取语言名称
  String get name {
    switch (this) {
      case SupportedLanguage.zhCN:
        return '简体中文';
      case SupportedLanguage.zhTW:
        return '繁體中文';
      case SupportedLanguage.en:
        return 'English';
    }
  }

  /// 获取语言代码
  String get code {
    switch (this) {
      case SupportedLanguage.zhCN:
        return 'zh_CN';
      case SupportedLanguage.zhTW:
        return 'zh_TW';
      case SupportedLanguage.en:
        return 'en_US';
    }
  }
}

/// 应用国际化类
class AppLocalizations {
  static const List<SupportedLanguage> supportedLanguages = [
    SupportedLanguage.zhCN,
    SupportedLanguage.zhTW,
    SupportedLanguage.en,
  ];

  static List<Locale> get supportedLocales {
    return supportedLanguages.map((lang) => lang.locale).toList();
  }

  /// 从Locale获取支持的语言
  static SupportedLanguage? fromLocale(Locale locale) {
    for (final lang in supportedLanguages) {
      if (lang.locale.languageCode == locale.languageCode &&
          lang.locale.countryCode == locale.countryCode) {
        return lang;
      }
    }
    
    // 如果没有完全匹配，尝试只匹配语言代码
    for (final lang in supportedLanguages) {
      if (lang.locale.languageCode == locale.languageCode) {
        return lang;
      }
    }
    
    return null;
  }

  /// 获取当前语言
  static SupportedLanguage get currentLanguage {
    final locale = Get.locale ?? const Locale('zh', 'CN');
    return fromLocale(locale) ?? SupportedLanguage.zhCN;
  }
}

/// 国际化文本类
class S {
  S._();

  // ==================== 通用 ====================
  
  static String get appName => 'Flutter Base Framework'.tr;
  static String get ok => 'ok'.tr;
  static String get cancel => 'cancel'.tr;
  static String get confirm => 'confirm'.tr;
  static String get save => 'save'.tr;
  static String get delete => 'delete'.tr;
  static String get edit => 'edit'.tr;
  static String get add => 'add'.tr;
  static String get search => 'search'.tr;
  static String get loading => 'loading'.tr;
  static String get retry => 'retry'.tr;
  static String get refresh => 'refresh'.tr;
  static String get submit => 'submit'.tr;
  static String get reset => 'reset'.tr;
  static String get clear => 'clear'.tr;
  static String get close => 'close'.tr;
  static String get back => 'back'.tr;
  static String get next => 'next'.tr;
  static String get previous => 'previous'.tr;
  static String get done => 'done'.tr;
  static String get skip => 'skip'.tr;
  static String get yes => 'yes'.tr;
  static String get no => 'no'.tr;

  // ==================== 错误信息 ====================
  
  static String get error => 'error'.tr;
  static String get networkError => 'network_error'.tr;
  static String get serverError => 'server_error'.tr;
  static String get unknownError => 'unknown_error'.tr;
  static String get timeoutError => 'timeout_error'.tr;
  static String get noDataFound => 'no_data_found'.tr;
  static String get loadFailed => 'load_failed'.tr;
  static String get saveFailed => 'save_failed'.tr;
  static String get deleteFailed => 'delete_failed'.tr;

  // ==================== 验证信息 ====================
  
  static String get required => 'required'.tr;
  static String get invalidEmail => 'invalid_email'.tr;
  static String get invalidPhone => 'invalid_phone'.tr;
  static String get passwordTooShort => 'password_too_short'.tr;
  static String get passwordMismatch => 'password_mismatch'.tr;
  static String get invalidFormat => 'invalid_format'.tr;

  // ==================== 认证相关 ====================
  
  static String get login => 'login'.tr;
  static String get logout => 'logout'.tr;
  static String get register => 'register'.tr;
  static String get forgotPassword => 'forgot_password'.tr;
  static String get resetPassword => 'reset_password'.tr;
  static String get changePassword => 'change_password'.tr;
  static String get email => 'email'.tr;
  static String get password => 'password'.tr;
  static String get confirmPassword => 'confirm_password'.tr;
  static String get username => 'username'.tr;
  static String get phone => 'phone'.tr;
  static String get verificationCode => 'verification_code'.tr;
  static String get sendCode => 'send_code'.tr;
  static String get resendCode => 'resend_code'.tr;
  static String get loginSuccess => 'login_success'.tr;
  static String get loginFailed => 'login_failed'.tr;
  static String get registerSuccess => 'register_success'.tr;
  static String get registerFailed => 'register_failed'.tr;
  static String get logoutConfirm => 'logout_confirm'.tr;

  // ==================== 用户资料 ====================
  
  static String get profile => 'profile'.tr;
  static String get personalInfo => 'personal_info'.tr;
  static String get avatar => 'avatar'.tr;
  static String get nickname => 'nickname'.tr;
  static String get gender => 'gender'.tr;
  static String get birthday => 'birthday'.tr;
  static String get address => 'address'.tr;
  static String get bio => 'bio'.tr;
  static String get male => 'male'.tr;
  static String get female => 'female'.tr;
  static String get other => 'other'.tr;
  static String get updateProfile => 'update_profile'.tr;
  static String get updateSuccess => 'update_success'.tr;
  static String get updateFailed => 'update_failed'.tr;

  // ==================== 设置 ====================
  
  static String get settings => 'settings'.tr;
  static String get general => 'general'.tr;
  static String get account => 'account'.tr;
  static String get security => 'security'.tr;
  static String get privacy => 'privacy'.tr;
  static String get notification => 'notification'.tr;
  static String get language => 'language'.tr;
  static String get theme => 'theme'.tr;
  static String get lightTheme => 'light_theme'.tr;
  static String get darkTheme => 'dark_theme'.tr;
  static String get systemTheme => 'system_theme'.tr;
  static String get about => 'about'.tr;
  static String get version => 'version'.tr;
  static String get feedback => 'feedback'.tr;
  static String get help => 'help'.tr;

  // ==================== 权限相关 ====================
  
  static String get permission => 'permission'.tr;
  static String get permissionDenied => 'permission_denied'.tr;
  static String get permissionRequired => 'permission_required'.tr;
  static String get grantPermission => 'grant_permission'.tr;
  static String get cameraPermission => 'camera_permission'.tr;
  static String get storagePermission => 'storage_permission'.tr;
  static String get locationPermission => 'location_permission'.tr;
  static String get microphonePermission => 'microphone_permission'.tr;
  static String get contactsPermission => 'contacts_permission'.tr;
  static String get notificationPermission => 'notification_permission'.tr;

  // ==================== 时间相关 ====================
  
  static String get today => 'today'.tr;
  static String get yesterday => 'yesterday'.tr;
  static String get tomorrow => 'tomorrow'.tr;
  static String get thisWeek => 'this_week'.tr;
  static String get thisMonth => 'this_month'.tr;
  static String get thisYear => 'this_year'.tr;

  // ==================== 动态文本 ====================
  
  static String itemCount(int count) => 'item_count'.trParams({'count': count.toString()});
  static String timeAgo(String time) => 'time_ago'.trParams({'time': time});
  static String welcomeUser(String name) => 'welcome_user'.trParams({'name': name});
  static String fileSize(String size) => 'file_size'.trParams({'size': size});
  static String pageInfo(int current, int total) => 'page_info'.trParams({
    'current': current.toString(),
    'total': total.toString(),
  });

  // ==================== 占位符文本 ====================
  
  static String get enterEmail => 'enter_email'.tr;
  static String get enterPassword => 'enter_password'.tr;
  static String get enterPhone => 'enter_phone'.tr;
  static String get enterNickname => 'enter_nickname'.tr;
  static String get enterMessage => 'enter_message'.tr;
  static String get searchHint => 'search_hint'.tr;
  static String get noData => 'no_data'.tr;
  static String get emptyList => 'empty_list'.tr;
  static String get comingSoon => 'coming_soon'.tr;
}
