/// 路由预设配置
///
/// 提供常用的路由配置预设，简化路由定义
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'route_config.dart';
import 'route_builder.dart';
import 'declarative_permissions.dart';
import '../permissions/permission_service.dart';

/// 路由预设配置类
///
/// 提供常用页面类型的路由配置预设
class RoutePresets {
  /// 基础页面路由
  static RouteConfig basic(
    String path,
    Widget Function() pageBuilder, {
    String? title,
  }) {
    return RouteBuilderFactory.basic(path, pageBuilder, title: title).build();
  }

  /// 首页路由
  static RouteConfig home(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/')
        .page(pageBuilder)
        .title('首页')
        .withAnalytics(pageName: 'home')
        .build();
  }

  /// 登录页面路由
  static RouteConfig login(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/login')
        .page(pageBuilder)
        .title('登录')
        .withAnalytics(pageName: 'login')
        .transition(Transition.rightToLeft)
        .build();
  }

  /// 注册页面路由
  static RouteConfig register(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/register')
        .page(pageBuilder)
        .title('注册')
        .withAnalytics(pageName: 'register')
        .transition(Transition.rightToLeft)
        .build();
  }

  /// 个人资料页面路由
  static RouteConfig profile(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/profile')
        .page(pageBuilder)
        .title('个人资料')
        .withAnalytics(pageName: 'profile')
        .build();
  }

  /// 设置页面路由
  static RouteConfig settings(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/settings')
        .page(pageBuilder)
        .title('设置')
        .withAnalytics(pageName: 'settings')
        .build();
  }

  /// 相机页面路由
  static RouteConfig camera(
    Widget Function() pageBuilder, {
    bool required = false,
  }) {
    return RouteBuilderFactory.camera(
      '/camera',
      pageBuilder,
      required: required,
    ).build();
  }

  /// 相册页面路由
  static RouteConfig gallery(
    Widget Function() pageBuilder, {
    bool required = false,
  }) {
    return RouteBuilder()
        .path('/gallery')
        .page(pageBuilder)
        .title('相册')
        .withPermissions(
          required: required ? [AppPermission.photos] : [],
          optional: required ? [] : [AppPermission.photos],
        )
        .withAnalytics(pageName: 'gallery')
        .build();
  }

  /// 地图页面路由
  static RouteConfig map(
    Widget Function() pageBuilder, {
    bool required = false,
  }) {
    return RouteBuilderFactory.map(
      '/map',
      pageBuilder,
      required: required,
    ).build();
  }

  /// 联系人页面路由
  static RouteConfig contacts(
    Widget Function() pageBuilder, {
    bool required = false,
  }) {
    return RouteBuilder()
        .path('/contacts')
        .page(pageBuilder)
        .title('联系人')
        .withPermissions(
          required: required ? [AppPermission.contacts] : [],
          optional: required ? [] : [AppPermission.contacts],
        )
        .withAnalytics(pageName: 'contacts')
        .build();
  }

  /// 通话页面路由
  static RouteConfig call(
    Widget Function() pageBuilder, {
    bool required = true,
  }) {
    return RouteBuilder()
        .path('/call')
        .page(pageBuilder)
        .title('通话')
        .withPermissions(
          required:
              required ? [AppPermission.phone, AppPermission.microphone] : [],
          optional:
              required ? [] : [AppPermission.phone, AppPermission.microphone],
        )
        .withAnalytics(pageName: 'call')
        .build();
  }

  /// 录音页面路由
  static RouteConfig audioRecord(
    Widget Function() pageBuilder, {
    bool required = true,
  }) {
    return RouteBuilder()
        .path('/audio_record')
        .page(pageBuilder)
        .title('录音')
        .withPermissions(
          required:
              required ? [AppPermission.microphone, AppPermission.storage] : [],
          optional:
              required ? [] : [AppPermission.microphone, AppPermission.storage],
        )
        .withAnalytics(pageName: 'audio_record')
        .build();
  }

  /// 视频录制页面路由
  static RouteConfig videoRecord(
    Widget Function() pageBuilder, {
    bool required = true,
  }) {
    return RouteBuilder()
        .path('/video_record')
        .page(pageBuilder)
        .title('视频录制')
        .withPermissions(
          required:
              required
                  ? [
                    AppPermission.camera,
                    AppPermission.microphone,
                    AppPermission.storage,
                  ]
                  : [],
          optional:
              required
                  ? []
                  : [
                    AppPermission.camera,
                    AppPermission.microphone,
                    AppPermission.storage,
                  ],
        )
        .withAnalytics(pageName: 'video_record')
        .build();
  }

  /// 文件管理页面路由
  static RouteConfig fileManager(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/file_manager')
        .page(pageBuilder)
        .title('文件管理')
        .withPermissions(required: [AppPermission.storage])
        .withAnalytics(pageName: 'file_manager')
        .build();
  }

  /// 二维码扫描页面路由
  static RouteConfig qrScan(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/qr_scan')
        .page(pageBuilder)
        .title('二维码扫描')
        .withPermissions(required: [AppPermission.camera])
        .withAnalytics(pageName: 'qr_scan')
        .build();
  }

  /// 蓝牙设备页面路由
  static RouteConfig bluetooth(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/bluetooth')
        .page(pageBuilder)
        .title('蓝牙设备')
        .withPermissions(
          required: [AppPermission.bluetooth],
          optional: [
            AppPermission.bluetoothScan,
            AppPermission.bluetoothConnect,
          ],
        )
        .withAnalytics(pageName: 'bluetooth')
        .build();
  }

  /// 通知设置页面路由
  static RouteConfig notificationSettings(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/notification_settings')
        .page(pageBuilder)
        .title('通知设置')
        .withPermissions(optional: [AppPermission.notification])
        .withAnalytics(pageName: 'notification_settings')
        .build();
  }

  /// 网络请求页面路由（需要网络检查）
  static RouteConfig networkPage(
    String path,
    Widget Function() pageBuilder, {
    String? title,
    Future<bool> Function()? preloadData,
  }) {
    return RouteBuilderFactory.network(
      path,
      pageBuilder,
      title: title,
      preloadData: preloadData,
    ).build();
  }

  /// 错误页面路由
  static RouteConfig error(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/error')
        .page(pageBuilder)
        .title('错误')
        .withAnalytics(pageName: 'error')
        .build();
  }

  /// 权限被拒绝页面路由
  static RouteConfig permissionDenied(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/permission_denied')
        .page(pageBuilder)
        .title('权限被拒绝')
        .withAnalytics(pageName: 'permission_denied')
        .build();
  }

  /// 网络错误页面路由
  static RouteConfig networkError(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/network_error')
        .page(pageBuilder)
        .title('网络错误')
        .withAnalytics(pageName: 'network_error')
        .build();
  }

  /// 加载错误页面路由
  static RouteConfig loadingError(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/loading_error')
        .page(pageBuilder)
        .title('加载错误')
        .withAnalytics(pageName: 'loading_error')
        .build();
  }

  /// 关于页面路由
  static RouteConfig about(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/about')
        .page(pageBuilder)
        .title('关于')
        .withAnalytics(pageName: 'about')
        .build();
  }

  /// 帮助页面路由
  static RouteConfig help(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/help')
        .page(pageBuilder)
        .title('帮助')
        .withAnalytics(pageName: 'help')
        .build();
  }

  /// 反馈页面路由
  static RouteConfig feedback(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/feedback')
        .page(pageBuilder)
        .title('反馈')
        .withAnalytics(pageName: 'feedback')
        .build();
  }

  /// 隐私政策页面路由
  static RouteConfig privacyPolicy(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/privacy_policy')
        .page(pageBuilder)
        .title('隐私政策')
        .withAnalytics(pageName: 'privacy_policy')
        .build();
  }

  /// 用户协议页面路由
  static RouteConfig userAgreement(Widget Function() pageBuilder) {
    return RouteBuilder()
        .path('/user_agreement')
        .page(pageBuilder)
        .title('用户协议')
        .withAnalytics(pageName: 'user_agreement')
        .build();
  }

  /// 使用声明式权限配置创建路由
  static RouteConfig withDeclarativePermissions(
    String path,
    Widget Function() pageBuilder,
    RequiresPermissions permissions, {
    String? title,
    String? analyticsPageName,
  }) {
    return RouteBuilder()
        .path(path)
        .page(pageBuilder)
        .title(title)
        .withDeclarativePermissions(permissions)
        .withAnalytics(pageName: analyticsPageName)
        .build();
  }
}

/// 路由组预设配置类
///
/// 提供常用的路由组配置预设
class RouteGroupPresets {
  /// 认证相关路由组
  static RouteGroup auth({
    required Widget Function() loginPageBuilder,
    required Widget Function() registerPageBuilder,
    Widget Function()? forgotPasswordPageBuilder,
  }) {
    final routes = [
      RoutePresets.login(loginPageBuilder),
      RoutePresets.register(registerPageBuilder),
    ];

    if (forgotPasswordPageBuilder != null) {
      routes.add(
        RouteBuilder()
            .path('/forgot_password')
            .page(forgotPasswordPageBuilder)
            .title('忘记密码')
            .withAnalytics(pageName: 'forgot_password')
            .build(),
      );
    }

    return RouteGroup(
      name: 'auth',
      prefix: '/auth',
      routes: routes,
      description: '认证相关页面',
    );
  }

  /// 用户相关路由组
  static RouteGroup user({
    required Widget Function() profilePageBuilder,
    required Widget Function() settingsPageBuilder,
    Widget Function()? editProfilePageBuilder,
  }) {
    final routes = [
      RoutePresets.profile(profilePageBuilder),
      RoutePresets.settings(settingsPageBuilder),
    ];

    if (editProfilePageBuilder != null) {
      routes.add(
        RouteBuilder()
            .path('/edit_profile')
            .page(editProfilePageBuilder)
            .title('编辑资料')
            .withAnalytics(pageName: 'edit_profile')
            .build(),
      );
    }

    return RouteGroup(
      name: 'user',
      prefix: '/user',
      routes: routes,
      description: '用户相关页面',
    );
  }

  /// 媒体相关路由组
  static RouteGroup media({
    required Widget Function() cameraPageBuilder,
    required Widget Function() galleryPageBuilder,
    Widget Function()? videoRecordPageBuilder,
    Widget Function()? audioRecordPageBuilder,
  }) {
    final routes = [
      RoutePresets.camera(cameraPageBuilder),
      RoutePresets.gallery(galleryPageBuilder),
    ];

    if (videoRecordPageBuilder != null) {
      routes.add(RoutePresets.videoRecord(videoRecordPageBuilder));
    }

    if (audioRecordPageBuilder != null) {
      routes.add(RoutePresets.audioRecord(audioRecordPageBuilder));
    }

    return RouteGroup(
      name: 'media',
      prefix: '/media',
      routes: routes,
      description: '媒体相关页面',
    );
  }

  /// 工具相关路由组
  static RouteGroup tools({
    Widget Function()? qrScanPageBuilder,
    Widget Function()? fileManagerPageBuilder,
    Widget Function()? bluetoothPageBuilder,
  }) {
    final routes = <RouteConfig>[];

    if (qrScanPageBuilder != null) {
      routes.add(RoutePresets.qrScan(qrScanPageBuilder));
    }

    if (fileManagerPageBuilder != null) {
      routes.add(RoutePresets.fileManager(fileManagerPageBuilder));
    }

    if (bluetoothPageBuilder != null) {
      routes.add(RoutePresets.bluetooth(bluetoothPageBuilder));
    }

    return RouteGroup(
      name: 'tools',
      prefix: '/tools',
      routes: routes,
      description: '工具相关页面',
    );
  }

  /// 系统相关路由组
  static RouteGroup system({
    required Widget Function() errorPageBuilder,
    required Widget Function() permissionDeniedPageBuilder,
    required Widget Function() networkErrorPageBuilder,
    Widget Function()? loadingErrorPageBuilder,
  }) {
    final routes = [
      RoutePresets.error(errorPageBuilder),
      RoutePresets.permissionDenied(permissionDeniedPageBuilder),
      RoutePresets.networkError(networkErrorPageBuilder),
    ];

    if (loadingErrorPageBuilder != null) {
      routes.add(RoutePresets.loadingError(loadingErrorPageBuilder));
    }

    return RouteGroup(
      name: 'system',
      prefix: '/system',
      routes: routes,
      description: '系统相关页面',
    );
  }

  /// 信息相关路由组
  static RouteGroup info({
    Widget Function()? aboutPageBuilder,
    Widget Function()? helpPageBuilder,
    Widget Function()? feedbackPageBuilder,
    Widget Function()? privacyPolicyPageBuilder,
    Widget Function()? userAgreementPageBuilder,
  }) {
    final routes = <RouteConfig>[];

    if (aboutPageBuilder != null) {
      routes.add(RoutePresets.about(aboutPageBuilder));
    }

    if (helpPageBuilder != null) {
      routes.add(RoutePresets.help(helpPageBuilder));
    }

    if (feedbackPageBuilder != null) {
      routes.add(RoutePresets.feedback(feedbackPageBuilder));
    }

    if (privacyPolicyPageBuilder != null) {
      routes.add(RoutePresets.privacyPolicy(privacyPolicyPageBuilder));
    }

    if (userAgreementPageBuilder != null) {
      routes.add(RoutePresets.userAgreement(userAgreementPageBuilder));
    }

    return RouteGroup(
      name: 'info',
      prefix: '/info',
      routes: routes,
      description: '信息相关页面',
    );
  }
}
