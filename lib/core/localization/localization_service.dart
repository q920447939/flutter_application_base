/// 国际化服务
/// 
/// 提供语言切换和管理功能，包括：
/// - 语言切换
/// - 语言持久化
/// - 系统语言检测
/// - 语言回退机制
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/storage_service.dart';
import 'app_localizations.dart';

/// 国际化服务类
class LocalizationService extends GetxController {
  static LocalizationService? _instance;

  /// 当前语言
  final Rx<SupportedLanguage> _currentLanguage = SupportedLanguage.zhCN.obs;
  SupportedLanguage get currentLanguage => _currentLanguage.value;

  /// 当前Locale
  Locale get currentLocale => _currentLanguage.value.locale;

  /// 是否正在切换语言
  final RxBool _isSwitching = false.obs;
  bool get isSwitching => _isSwitching.value;

  LocalizationService._internal();

  /// 单例模式
  static LocalizationService get instance {
    _instance ??= LocalizationService._internal();
    return _instance!;
  }

  /// 初始化国际化服务
  Future<void> initialize() async {
    // 从存储中加载语言设置
    await _loadLanguageSettings();
    
    // 设置GetX的语言
    Get.updateLocale(currentLocale);
  }

  /// 从存储中加载语言设置
  Future<void> _loadLanguageSettings() async {
    try {
      final languageCode = StorageService.instance.getAppSetting<String>('language');
      
      if (languageCode != null) {
        // 从存储的语言代码恢复语言设置
        final language = _getLanguageFromCode(languageCode);
        if (language != null) {
          _currentLanguage.value = language;
          return;
        }
      }
      
      // 如果没有存储的语言设置，使用系统语言
      _detectSystemLanguage();
    } catch (e) {
      debugPrint('加载语言设置失败: $e');
      // 使用默认语言
      _currentLanguage.value = SupportedLanguage.zhCN;
    }
  }

  /// 保存语言设置
  Future<void> _saveLanguageSettings() async {
    try {
      await StorageService.instance.setAppSetting('language', _currentLanguage.value.code);
    } catch (e) {
      debugPrint('保存语言设置失败: $e');
    }
  }

  /// 检测系统语言
  void _detectSystemLanguage() {
    final systemLocale = Get.deviceLocale ?? const Locale('zh', 'CN');
    final detectedLanguage = AppLocalizations.fromLocale(systemLocale);
    
    if (detectedLanguage != null) {
      _currentLanguage.value = detectedLanguage;
    } else {
      // 如果系统语言不支持，使用默认语言
      _currentLanguage.value = SupportedLanguage.zhCN;
    }
  }

  /// 从语言代码获取语言
  SupportedLanguage? _getLanguageFromCode(String code) {
    for (final language in SupportedLanguage.values) {
      if (language.code == code) {
        return language;
      }
    }
    return null;
  }

  /// 切换语言
  Future<void> changeLanguage(SupportedLanguage language) async {
    if (_currentLanguage.value == language || _isSwitching.value) {
      return;
    }

    _isSwitching.value = true;

    try {
      // 更新当前语言
      _currentLanguage.value = language;
      
      // 更新GetX的语言设置
      await Get.updateLocale(language.locale);
      
      // 保存语言设置
      await _saveLanguageSettings();
      
      // 通知语言已切换
      _onLanguageChanged(language);
    } catch (e) {
      debugPrint('切换语言失败: $e');
    } finally {
      _isSwitching.value = false;
    }
  }

  /// 语言切换完成回调
  void _onLanguageChanged(SupportedLanguage language) {
    // 可以在这里添加语言切换后的处理逻辑
    debugPrint('语言已切换到: ${language.name}');
  }

  /// 切换到中文简体
  Future<void> changeToSimplifiedChinese() async {
    await changeLanguage(SupportedLanguage.zhCN);
  }

  /// 切换到中文繁体
  Future<void> changeToTraditionalChinese() async {
    await changeLanguage(SupportedLanguage.zhTW);
  }

  /// 切换到英文
  Future<void> changeToEnglish() async {
    await changeLanguage(SupportedLanguage.en);
  }

  /// 获取所有支持的语言
  List<SupportedLanguage> getSupportedLanguages() {
    return AppLocalizations.supportedLanguages;
  }

  /// 获取语言显示名称
  String getLanguageDisplayName(SupportedLanguage language) {
    return language.name;
  }

  /// 是否为当前语言
  bool isCurrentLanguage(SupportedLanguage language) {
    return _currentLanguage.value == language;
  }

  /// 获取语言信息
  Map<String, dynamic> getLanguageInfo() {
    return {
      'current': _currentLanguage.value.code,
      'name': _currentLanguage.value.name,
      'locale': _currentLanguage.value.locale.toString(),
      'supported': getSupportedLanguages().map((lang) => {
        'code': lang.code,
        'name': lang.name,
        'locale': lang.locale.toString(),
        'isCurrent': isCurrentLanguage(lang),
      }).toList(),
    };
  }

  /// 重置语言设置
  Future<void> resetLanguage() async {
    _detectSystemLanguage();
    await Get.updateLocale(currentLocale);
    await _saveLanguageSettings();
  }

  /// 获取文本方向
  TextDirection getTextDirection() {
    // 目前支持的语言都是从左到右
    return TextDirection.ltr;
  }

  /// 是否为RTL语言
  bool get isRTL => getTextDirection() == TextDirection.rtl;

  /// 获取当前语言的格式化器
  String formatNumber(num number) {
    // 根据当前语言格式化数字
    switch (_currentLanguage.value) {
      case SupportedLanguage.zhCN:
      case SupportedLanguage.zhTW:
        // 中文数字格式
        return number.toString();
      case SupportedLanguage.en:
        // 英文数字格式
        return number.toString();
    }
  }

  /// 格式化日期
  String formatDate(DateTime date) {
    // 根据当前语言格式化日期
    switch (_currentLanguage.value) {
      case SupportedLanguage.zhCN:
      case SupportedLanguage.zhTW:
        return '${date.year}年${date.month}月${date.day}日';
      case SupportedLanguage.en:
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  /// 格式化时间
  String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    
    switch (_currentLanguage.value) {
      case SupportedLanguage.zhCN:
      case SupportedLanguage.zhTW:
        return '$hour:$minute';
      case SupportedLanguage.en:
        final period = time.hour >= 12 ? 'PM' : 'AM';
        final hour12 = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
        return '$hour12:$minute $period';
    }
  }

  /// 获取相对时间描述
  String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return formatDate(dateTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
