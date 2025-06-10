/// 动态页面工厂
///
/// 根据路由配置动态创建页面，支持：
/// - 静态页面映射
/// - 动态布局渲染
/// - 数据驱动页面
/// - WebView页面
/// - 表单页面
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'models/route_config.dart';
import '../network/network_service.dart';
import '../../ui/components/dynamic_page.dart';
import '../../ui/components/dynamic_list_page.dart';
import '../../ui/components/dynamic_detail_page.dart';
import '../../ui/components/dynamic_form_page.dart';
import '../../ui/components/dynamic_webview_page.dart';

// 导入静态页面
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/splash/splash_page.dart';
import '../../features/home/home_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/pages/edit_profile_page.dart';
import '../../features/settings/pages/settings_page.dart';

/// 动态页面工厂
class DynamicPageFactory {
  /// 静态页面映射表
  static final Map<String, Widget Function()> _staticPageMap = {
    'SplashPage': () => const SplashPage(),
    'LoginPage': () => const LoginPage(),
    'RegisterPage': () => const RegisterPage(),
    'HomePage': () => const HomePage(),
    'ProfilePage': () => const ProfilePage(),
    'EditProfilePage': () => const EditProfilePage(),
    'SettingsPage': () => const SettingsPage(),
  };

  /// 根据路由配置创建页面
  static Widget createPage(
    RouteConfig config, {
    Map<String, dynamic>? arguments,
  }) {
    try {
      switch (config.pageType) {
        case PageType.static:
          return _createStaticPage(config, arguments);
        case PageType.dynamic:
          return _createDynamicPage(config, arguments);
        case PageType.list:
          return _createListPage(config, arguments);
        case PageType.detail:
          return _createDetailPage(config, arguments);
        case PageType.form:
          return _createFormPage(config, arguments);
        case PageType.webview:
          return _createWebViewPage(config, arguments);
        case PageType.external:
          return _createExternalLinkPage(config, arguments);
        default:
          return _createErrorPage('不支持的页面类型: ${config.pageType}');
      }
    } catch (e) {
      return _createErrorPage('创建页面失败: $e');
    }
  }

  /// 创建静态页面
  static Widget _createStaticPage(
    RouteConfig config,
    Map<String, dynamic>? arguments,
  ) {
    final componentName = config.pageConfig?.componentName;
    if (componentName == null) {
      return _createErrorPage('静态页面缺少组件名称配置');
    }

    final pageBuilder = _staticPageMap[componentName];
    if (pageBuilder == null) {
      return _createErrorPage('未找到静态页面组件: $componentName');
    }

    return pageBuilder();
  }

  /// 创建动态页面
  static Widget _createDynamicPage(
    RouteConfig config,
    Map<String, dynamic>? arguments,
  ) {
    final layout = config.pageConfig?.layout;
    if (layout == null) {
      return _createErrorPage('动态页面缺少布局配置');
    }

    return DynamicPage(
      title: config.title ?? config.name,
      layout: layout,
      dataSource: config.pageConfig?.dataSource,
      arguments: arguments,
      customStyles: config.pageConfig?.customStyles,
    );
  }

  /// 创建列表页面
  static Widget _createListPage(
    RouteConfig config,
    Map<String, dynamic>? arguments,
  ) {
    final dataSource = config.pageConfig?.dataSource;
    if (dataSource == null) {
      return _createErrorPage('列表页面缺少数据源配置');
    }

    return DynamicListPage(
      title: config.title ?? config.name,
      dataSource: dataSource,
      arguments: arguments,
      customStyles: config.pageConfig?.customStyles,
    );
  }

  /// 创建详情页面
  static Widget _createDetailPage(
    RouteConfig config,
    Map<String, dynamic>? arguments,
  ) {
    final dataSource = config.pageConfig?.dataSource;
    if (dataSource == null) {
      return _createErrorPage('详情页面缺少数据源配置');
    }

    return DynamicDetailPage(
      title: config.title ?? config.name,
      dataSource: dataSource,
      layout: config.pageConfig?.layout,
      arguments: arguments,
      customStyles: config.pageConfig?.customStyles,
    );
  }

  /// 创建表单页面
  static Widget _createFormPage(
    RouteConfig config,
    Map<String, dynamic>? arguments,
  ) {
    final form = config.pageConfig?.form;
    if (form == null) {
      return _createErrorPage('表单页面缺少表单配置');
    }

    return DynamicFormPage(
      title: config.title ?? config.name,
      form: form,
      arguments: arguments,
      customStyles: config.pageConfig?.customStyles,
    );
  }

  /// 创建WebView页面
  static Widget _createWebViewPage(
    RouteConfig config,
    Map<String, dynamic>? arguments,
  ) {
    final webView = config.pageConfig?.webView;
    if (webView == null) {
      return _createErrorPage('WebView页面缺少WebView配置');
    }

    return DynamicWebViewPage(
      title: config.title ?? config.name,
      webView: webView,
      arguments: arguments,
    );
  }

  /// 创建外部链接页面
  static Widget _createExternalLinkPage(
    RouteConfig config,
    Map<String, dynamic>? arguments,
  ) {
    // 外部链接页面通常会打开外部应用或浏览器
    // 这里返回一个提示页面
    return Scaffold(
      appBar: AppBar(title: Text(config.title ?? config.name)),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.open_in_new, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('正在打开外部链接...'),
          ],
        ),
      ),
    );
  }

  /// 创建错误页面
  static Widget _createErrorPage(String error) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面错误')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }

  /// 注册静态页面组件
  static void registerStaticPage(String name, Widget Function() builder) {
    _staticPageMap[name] = builder;
  }

  /// 获取所有已注册的静态页面
  static List<String> getRegisteredStaticPages() {
    return _staticPageMap.keys.toList();
  }

  /// 检查静态页面是否已注册
  static bool isStaticPageRegistered(String name) {
    return _staticPageMap.containsKey(name);
  }

  /// 转换数据
  static dynamic _transformData(dynamic data, DataTransformConfig transform) {
    // 提取数据路径
    if (transform.dataPath != null && data is Map<String, dynamic>) {
      final pathParts = transform.dataPath!.split('.');
      dynamic result = data;
      for (final part in pathParts) {
        if (result is Map<String, dynamic> && result.containsKey(part)) {
          result = result[part];
        } else {
          break;
        }
      }
      data = result;
    }

    // 应用字段映射
    if (transform.fieldMapping != null && data is Map<String, dynamic>) {
      final mappedData = <String, dynamic>{};
      transform.fieldMapping!.forEach((newKey, oldKey) {
        if (data.containsKey(oldKey)) {
          mappedData[newKey] = data[oldKey];
        }
      });
      data = mappedData;
    }

    // 应用过滤条件
    if (transform.filters != null && data is List) {
      data =
          data.where((item) {
            if (item is! Map<String, dynamic>) return true;

            return transform.filters!.entries.every((filter) {
              final fieldValue = item[filter.key];
              final filterValue = filter.value;

              if (filterValue is Map<String, dynamic>) {
                // 支持复杂过滤条件
                if (filterValue.containsKey('\$eq')) {
                  return fieldValue == filterValue['\$eq'];
                }
                if (filterValue.containsKey('\$ne')) {
                  return fieldValue != filterValue['\$ne'];
                }
                if (filterValue.containsKey('\$gt')) {
                  return fieldValue != null && fieldValue > filterValue['\$gt'];
                }
                if (filterValue.containsKey('\$lt')) {
                  return fieldValue != null && fieldValue < filterValue['\$lt'];
                }
                if (filterValue.containsKey('\$in')) {
                  return filterValue['\$in'] is List &&
                      (filterValue['\$in'] as List).contains(fieldValue);
                }
              } else {
                // 简单相等比较
                return fieldValue == filterValue;
              }

              return true;
            });
          }).toList();
    }

    return data;
  }
}
