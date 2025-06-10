/// 声明式权限配置
///
/// 提供在路由配置中声明式设置权限的能力
library;

import '../permissions/permission_service.dart';
import 'features/permission_route_feature.dart';

/// 权限声明注解
///
/// 用于在路由配置中声明式地配置权限
class RequiresPermissions {
  /// 必需的权限列表
  final List<AppPermission> required;

  /// 可选的权限列表
  final List<AppPermission> optional;

  /// 是否显示权限引导
  final bool showGuide;

  /// 是否允许跳过可选权限
  final bool allowSkipOptional;

  /// 权限被拒绝时的重定向路由
  final String? deniedRedirectRoute;

  /// 权限描述（用于引导页面）
  final String? description;

  /// 自定义权限标题映射
  final Map<AppPermission, String>? customTitles;

  /// 自定义权限描述映射
  final Map<AppPermission, String>? customDescriptions;

  const RequiresPermissions({
    this.required = const [],
    this.optional = const [],
    this.showGuide = true,
    this.allowSkipOptional = true,
    this.deniedRedirectRoute,
    this.description,
    this.customTitles,
    this.customDescriptions,
  });

  /// 转换为权限路由功能特性
  PermissionRouteFeature toRouteFeature() {
    return PermissionRouteFeature(
      requiredPermissions: required,
      optionalPermissions: optional,
      showGuide: showGuide,
      allowSkipOptional: allowSkipOptional,
      deniedRedirectRoute: deniedRedirectRoute,
    );
  }

  /// 获取所有权限
  List<AppPermission> get allPermissions => [...required, ...optional];

  /// 是否有权限需要检查
  bool get hasPermissions => allPermissions.isNotEmpty;

  /// 获取权限配置摘要
  String get summary {
    final buffer = StringBuffer();
    if (required.isNotEmpty) {
      buffer.write('必需: ${required.map((p) => p.name).join(', ')}');
    }
    if (optional.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write('; ');
      buffer.write('可选: ${optional.map((p) => p.name).join(', ')}');
    }
    return buffer.toString();
  }
}

/// 常用权限配置预设
class PermissionPresets {
  /// 相机权限配置
  static const RequiresPermissions camera = RequiresPermissions(
    required: [AppPermission.camera],
    optional: [AppPermission.storage],
    description: '需要相机权限来拍照，存储权限用于保存照片',
    customTitles: {AppPermission.camera: '相机权限', AppPermission.storage: '存储权限'},
    customDescriptions: {
      AppPermission.camera: '用于拍照和录制视频',
      AppPermission.storage: '用于保存照片和视频到本地',
    },
  );

  /// 位置权限配置
  static const RequiresPermissions location = RequiresPermissions(
    optional: [AppPermission.location],
    description: '需要位置权限来提供基于位置的服务',
    customTitles: {AppPermission.location: '位置权限'},
    customDescriptions: {AppPermission.location: '用于获取您的当前位置，提供导航和附近服务'},
  );

  /// 多媒体权限配置
  static const RequiresPermissions multimedia = RequiresPermissions(
    required: [AppPermission.camera, AppPermission.microphone],
    optional: [AppPermission.storage],
    description: '需要相机和麦克风权限来录制视频',
    customTitles: {
      AppPermission.camera: '相机权限',
      AppPermission.microphone: '麦克风权限',
      AppPermission.storage: '存储权限',
    },
    customDescriptions: {
      AppPermission.camera: '用于录制视频画面',
      AppPermission.microphone: '用于录制音频',
      AppPermission.storage: '用于保存录制的视频文件',
    },
  );

  /// 通讯权限配置
  static const RequiresPermissions communication = RequiresPermissions(
    required: [AppPermission.contacts],
    optional: [AppPermission.phone, AppPermission.sms],
    description: '需要通讯录权限来管理联系人',
    customTitles: {
      AppPermission.contacts: '通讯录权限',
      AppPermission.phone: '电话权限',
      AppPermission.sms: '短信权限',
    },
    customDescriptions: {
      AppPermission.contacts: '用于读取和管理您的联系人',
      AppPermission.phone: '用于拨打电话',
      AppPermission.sms: '用于发送短信',
    },
  );

  /// 存储权限配置
  static const RequiresPermissions storage = RequiresPermissions(
    required: [AppPermission.storage],
    description: '需要存储权限来读写文件',
    customTitles: {AppPermission.storage: '存储权限'},
    customDescriptions: {AppPermission.storage: '用于读取和保存文件到设备存储'},
  );

  /// 蓝牙权限配置
  static const RequiresPermissions bluetooth = RequiresPermissions(
    required: [AppPermission.bluetooth],
    optional: [AppPermission.bluetoothScan, AppPermission.bluetoothConnect],
    description: '需要蓝牙权限来连接蓝牙设备',
    customTitles: {
      AppPermission.bluetooth: '蓝牙权限',
      AppPermission.bluetoothScan: '蓝牙扫描权限',
      AppPermission.bluetoothConnect: '蓝牙连接权限',
    },
    customDescriptions: {
      AppPermission.bluetooth: '用于启用蓝牙功能',
      AppPermission.bluetoothScan: '用于扫描附近的蓝牙设备',
      AppPermission.bluetoothConnect: '用于连接蓝牙设备',
    },
  );

  /// 通知权限配置
  static const RequiresPermissions notification = RequiresPermissions(
    optional: [AppPermission.notification],
    description: '需要通知权限来发送重要提醒',
    allowSkipOptional: true,
    customTitles: {AppPermission.notification: '通知权限'},
    customDescriptions: {AppPermission.notification: '用于向您发送重要消息和提醒'},
  );

  /// Web相机权限配置
  static const RequiresPermissions webCamera = RequiresPermissions(
    required: [AppPermission.webCamera],
    optional: [AppPermission.webMicrophone],
    description: '需要浏览器相机权限来进行视频通话',
    customTitles: {
      AppPermission.webCamera: '浏览器相机权限',
      AppPermission.webMicrophone: '浏览器麦克风权限',
    },
    customDescriptions: {
      AppPermission.webCamera: '用于在浏览器中访问摄像头',
      AppPermission.webMicrophone: '用于在浏览器中访问麦克风',
    },
  );

  /// 桌面文件系统权限配置
  static const RequiresPermissions desktopFileSystem = RequiresPermissions(
    required: [AppPermission.desktopFileSystem],
    description: '需要文件系统权限来访问本地文件',
    allowSkipOptional: false,
    customTitles: {AppPermission.desktopFileSystem: '文件系统权限'},
    customDescriptions: {AppPermission.desktopFileSystem: '用于读取和写入本地文件系统'},
  );
}

/// 权限配置构建器
///
/// 提供流式API来构建权限配置
class PermissionConfigBuilder {
  List<AppPermission> _required = [];
  List<AppPermission> _optional = [];
  bool _showGuide = true;
  bool _allowSkipOptional = true;
  String? _deniedRedirectRoute;
  String? _description;
  Map<AppPermission, String>? _customTitles;
  Map<AppPermission, String>? _customDescriptions;

  /// 添加必需权限
  PermissionConfigBuilder required(List<AppPermission> permissions) {
    _required = permissions;
    return this;
  }

  /// 添加单个必需权限
  PermissionConfigBuilder addRequired(AppPermission permission) {
    _required = [..._required, permission];
    return this;
  }

  /// 添加可选权限
  PermissionConfigBuilder optional(List<AppPermission> permissions) {
    _optional = permissions;
    return this;
  }

  /// 添加单个可选权限
  PermissionConfigBuilder addOptional(AppPermission permission) {
    _optional = [..._optional, permission];
    return this;
  }

  /// 设置是否显示引导
  PermissionConfigBuilder showGuide(bool show) {
    _showGuide = show;
    return this;
  }

  /// 设置是否允许跳过可选权限
  PermissionConfigBuilder allowSkipOptional(bool allow) {
    _allowSkipOptional = allow;
    return this;
  }

  /// 设置权限被拒绝时的重定向路由
  PermissionConfigBuilder deniedRedirectRoute(String route) {
    _deniedRedirectRoute = route;
    return this;
  }

  /// 设置权限描述
  PermissionConfigBuilder description(String desc) {
    _description = desc;
    return this;
  }

  /// 设置自定义权限标题
  PermissionConfigBuilder customTitles(Map<AppPermission, String> titles) {
    _customTitles = titles;
    return this;
  }

  /// 添加自定义权限标题
  PermissionConfigBuilder addCustomTitle(
    AppPermission permission,
    String title,
  ) {
    _customTitles ??= {};
    _customTitles![permission] = title;
    return this;
  }

  /// 设置自定义权限描述
  PermissionConfigBuilder customDescriptions(
    Map<AppPermission, String> descriptions,
  ) {
    _customDescriptions = descriptions;
    return this;
  }

  /// 添加自定义权限描述
  PermissionConfigBuilder addCustomDescription(
    AppPermission permission,
    String description,
  ) {
    _customDescriptions ??= {};
    _customDescriptions![permission] = description;
    return this;
  }

  /// 构建权限配置
  RequiresPermissions build() {
    return RequiresPermissions(
      required: _required,
      optional: _optional,
      showGuide: _showGuide,
      allowSkipOptional: _allowSkipOptional,
      deniedRedirectRoute: _deniedRedirectRoute,
      description: _description,
      customTitles: _customTitles,
      customDescriptions: _customDescriptions,
    );
  }

  /// 重置构建器
  PermissionConfigBuilder reset() {
    _required = [];
    _optional = [];
    _showGuide = true;
    _allowSkipOptional = true;
    _deniedRedirectRoute = null;
    _description = null;
    _customTitles = null;
    _customDescriptions = null;
    return this;
  }
}

/// 权限配置工厂
class PermissionConfigFactory {
  /// 创建相机权限配置
  static RequiresPermissions camera({bool required = false}) {
    return RequiresPermissions(
      required: required ? [AppPermission.camera] : [],
      optional:
          required
              ? [AppPermission.storage]
              : [AppPermission.camera, AppPermission.storage],
      description: '相机功能需要相机权限来拍照',
    );
  }

  /// 创建位置权限配置
  static RequiresPermissions location({bool required = false}) {
    return RequiresPermissions(
      required: required ? [AppPermission.location] : [],
      optional: required ? [] : [AppPermission.location],
      description: '地图功能需要位置权限来定位',
    );
  }

  /// 创建多媒体权限配置
  static RequiresPermissions multimedia({
    bool cameraRequired = true,
    bool micRequired = true,
  }) {
    final required = <AppPermission>[];
    final optional = <AppPermission>[];

    if (cameraRequired) {
      required.add(AppPermission.camera);
    } else {
      optional.add(AppPermission.camera);
    }

    if (micRequired) {
      required.add(AppPermission.microphone);
    } else {
      optional.add(AppPermission.microphone);
    }

    optional.add(AppPermission.storage);

    return RequiresPermissions(
      required: required,
      optional: optional,
      description: '多媒体功能需要相机和麦克风权限',
    );
  }

  /// 创建自定义权限配置
  static RequiresPermissions custom({
    List<AppPermission> required = const [],
    List<AppPermission> optional = const [],
    String? description,
    bool showGuide = true,
    bool allowSkipOptional = true,
  }) {
    return RequiresPermissions(
      required: required,
      optional: optional,
      description: description,
      showGuide: showGuide,
      allowSkipOptional: allowSkipOptional,
    );
  }
}
