# 声明式权限配置使用指南

## 概述

声明式权限配置是新路由架构的核心特性之一，允许开发者在路由配置中声明式地设置页面所需的权限，而无需在页面代码中处理任何权限逻辑。

## 核心优势

### 1. 完全的业务分离
- 页面代码只关注业务逻辑
- 权限检查由路由层自动处理
- 配置即代码，一目了然

### 2. 高度的可复用性
- 权限配置可在多个路由间复用
- 预设配置减少重复代码
- 支持组合和继承

### 3. 类型安全
- 编译时权限检查
- 自动补全和错误提示
- 防止运行时错误

## 使用方式

### 1. 预设权限配置

#### 使用内置预设
```dart
// 相机权限配置
RoutePresets.withDeclarativePermissions(
  '/camera',
  () => CameraPage(),
  PermissionPresets.camera,
  title: '相机',
)

// 位置权限配置
RoutePresets.withDeclarativePermissions(
  '/map',
  () => MapPage(),
  PermissionPresets.location,
  title: '地图',
)

// 多媒体权限配置
RoutePresets.withDeclarativePermissions(
  '/multimedia',
  () => MultimediaPage(),
  PermissionPresets.multimedia,
  title: '多媒体',
)
```

#### 可用的预设配置
- `PermissionPresets.camera` - 相机权限
- `PermissionPresets.location` - 位置权限
- `PermissionPresets.multimedia` - 多媒体权限
- `PermissionPresets.communication` - 通讯权限
- `PermissionPresets.storage` - 存储权限
- `PermissionPresets.bluetooth` - 蓝牙权限
- `PermissionPresets.notification` - 通知权限
- `PermissionPresets.webCamera` - Web相机权限
- `PermissionPresets.desktopFileSystem` - 桌面文件系统权限

### 2. 构建器模式配置

#### 基础构建器使用
```dart
RouteBuilder()
    .path('/custom')
    .page(() => CustomPage())
    .title('自定义页面')
    .withDeclarativePermissions(
      PermissionConfigBuilder()
          .required([AppPermission.camera])
          .optional([AppPermission.storage])
          .description('需要相机权限来拍照')
          .showGuide(true)
          .allowSkipOptional(true)
          .build(),
    )
    .build()
```

#### 高级构建器配置
```dart
PermissionConfigBuilder()
    .required([AppPermission.camera, AppPermission.microphone])
    .optional([AppPermission.storage, AppPermission.location])
    .description('多媒体应用需要相机和麦克风权限')
    .showGuide(true)
    .allowSkipOptional(true)
    .deniedRedirectRoute('/permission_denied')
    .customTitles({
      AppPermission.camera: '专业相机',
      AppPermission.microphone: '高品质录音',
    })
    .customDescriptions({
      AppPermission.camera: '提供4K高清视频录制',
      AppPermission.microphone: '支持降噪和音效处理',
    })
    .build()
```

### 3. 工厂方法配置

#### 快速创建常用配置
```dart
// 相机权限（必需）
PermissionConfigFactory.camera(required: true)

// 位置权限（可选）
PermissionConfigFactory.location(required: false)

// 多媒体权限（相机必需，麦克风可选）
PermissionConfigFactory.multimedia(
  cameraRequired: true,
  micRequired: false,
)

// 自定义配置
PermissionConfigFactory.custom(
  required: [AppPermission.camera],
  optional: [AppPermission.storage],
  description: '自定义权限配置',
)
```

### 4. 直接配置

#### 使用常量配置
```dart
const RequiresPermissions(
  required: [AppPermission.camera, AppPermission.microphone],
  optional: [AppPermission.storage],
  showGuide: true,
  allowSkipOptional: true,
  description: '录制视频需要相机和麦克风权限',
  customTitles: {
    AppPermission.camera: '相机权限',
    AppPermission.microphone: '麦克风权限',
  },
  customDescriptions: {
    AppPermission.camera: '用于录制视频画面',
    AppPermission.microphone: '用于录制音频',
  },
)
```

## 配置选项详解

### 权限类型
- **必需权限 (required)**：用户必须授权才能进入页面
- **可选权限 (optional)**：用户可以选择是否授权

### 配置参数

#### 基础参数
- `required: List<AppPermission>` - 必需权限列表
- `optional: List<AppPermission>` - 可选权限列表
- `showGuide: bool` - 是否显示权限引导页面
- `allowSkipOptional: bool` - 是否允许跳过可选权限

#### 高级参数
- `deniedRedirectRoute: String?` - 权限被拒绝时的重定向路由
- `description: String?` - 权限配置描述
- `customTitles: Map<AppPermission, String>?` - 自定义权限标题
- `customDescriptions: Map<AppPermission, String>?` - 自定义权限描述

## 实际应用示例

### 示例1：相机应用
```dart
// 路由配置
final cameraRoute = RouteBuilder()
    .path('/camera')
    .page(() => CameraPage())
    .title('相机')
    .withDeclarativePermissions(PermissionPresets.camera)
    .withAnalytics(pageName: 'camera_page')
    .build();

// 页面实现
class CameraPage extends SimpleStatelessPage {
  @override
  Widget buildContent(BuildContext context) {
    // 只需关注业务逻辑，权限已由路由层处理
    return Scaffold(
      appBar: AppBar(title: const Text('相机')),
      body: CameraWidget(), // 相机组件
      floatingActionButton: FloatingActionButton(
        onPressed: takePicture, // 拍照业务逻辑
        child: const Icon(Icons.camera),
      ),
    );
  }
}
```

### 示例2：地图应用
```dart
// 路由配置
final mapRoute = RouteBuilder()
    .path('/map')
    .page(() => MapPage())
    .title('地图')
    .withDeclarativePermissions(
      PermissionConfigBuilder()
          .optional([AppPermission.location])
          .description('位置权限可以提供更精确的定位服务')
          .allowSkipOptional(true)
          .build(),
    )
    .withLoading(enableNetworkCheck: true)
    .withAnalytics(pageName: 'map_page')
    .build();

// 页面实现
class MapPage extends SimpleStatefulPage {
  @override
  SimpleStatefulPageState createPageState() => _MapPageState();
}

class _MapPageState extends SimpleStatefulPageState<MapPage> {
  @override
  Widget buildContent(BuildContext context) {
    // 专注于地图业务逻辑
    return Scaffold(
      appBar: AppBar(title: const Text('地图')),
      body: MapWidget(), // 地图组件
    );
  }
}
```

### 示例3：多媒体应用
```dart
// 路由配置
final multimediaRoute = RouteBuilder()
    .path('/multimedia')
    .page(() => MultimediaPage())
    .title('多媒体')
    .withDeclarativePermissions(
      PermissionConfigBuilder()
          .required([AppPermission.camera, AppPermission.microphone])
          .optional([AppPermission.storage])
          .description('录制高质量视频需要相机和麦克风权限')
          .customTitles({
            AppPermission.camera: '4K相机',
            AppPermission.microphone: '专业录音',
            AppPermission.storage: '云端存储',
          })
          .build(),
    )
    .build();
```

## 平台特定配置

### Web平台
```dart
PermissionPresets.webCamera // Web相机权限
PermissionPresets.webMicrophone // Web麦克风权限
```

### 桌面平台
```dart
PermissionPresets.desktopFileSystem // 桌面文件系统权限
```

### 移动平台
```dart
PermissionPresets.camera // 移动相机权限
PermissionPresets.location // 移动位置权限
```

## 条件权限配置

### 根据平台动态配置
```dart
RequiresPermissions getPermissionConfig() {
  if (kIsWeb) {
    return PermissionPresets.webCamera;
  } else if (Platform.isAndroid || Platform.isIOS) {
    return PermissionPresets.camera;
  } else {
    return PermissionPresets.desktopFileSystem;
  }
}

// 在路由配置中使用
RouteBuilder()
    .path('/camera')
    .page(() => CameraPage())
    .withDeclarativePermissions(getPermissionConfig())
    .build()
```

## 错误处理

### 权限被拒绝处理
```dart
PermissionConfigBuilder()
    .required([AppPermission.camera])
    .deniedRedirectRoute('/permission_denied')
    .build()
```

### 自定义错误页面
```dart
// 权限被拒绝页面
class PermissionDeniedPage extends SimpleStatelessPage {
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('权限被拒绝')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('应用需要相应权限才能正常工作'),
            Text('请在设置中开启权限'),
          ],
        ),
      ),
    );
  }
}
```

## 最佳实践

### 1. 权限配置原则
- **最小权限原则**：只请求必要的权限
- **渐进式权限**：优先使用可选权限
- **用户友好**：提供清晰的权限说明

### 2. 配置复用
```dart
// 定义常用配置
class AppPermissionConfigs {
  static const multimedia = RequiresPermissions(
    required: [AppPermission.camera, AppPermission.microphone],
    optional: [AppPermission.storage],
    description: '多媒体功能权限配置',
  );
  
  static const socialMedia = RequiresPermissions(
    required: [AppPermission.camera],
    optional: [AppPermission.contacts, AppPermission.storage],
    description: '社交媒体功能权限配置',
  );
}

// 在多个路由中复用
RoutePresets.withDeclarativePermissions(
  '/video_call',
  () => VideoCallPage(),
  AppPermissionConfigs.multimedia,
)
```

### 3. 权限组合
```dart
// 组合多个预设配置
final combinedConfig = PermissionConfigBuilder()
    .required([
      ...PermissionPresets.camera.required,
      ...PermissionPresets.location.required,
    ])
    .optional([
      ...PermissionPresets.camera.optional,
      ...PermissionPresets.storage.optional,
    ])
    .build();
```

## 调试和监控

### 权限配置验证
```dart
// 验证权限配置
final config = PermissionPresets.camera;
print('权限摘要: ${config.summary}');
print('是否有权限: ${config.hasPermissions}');
print('所有权限: ${config.allPermissions.map((p) => p.name).join(', ')}');
```

### 路由权限统计
```dart
// 获取路由权限统计
final stats = DeclarativePermissionRoutes.getRouteStatistics();
print('权限路由统计: $stats');
```

这种声明式权限配置方式完全实现了权限逻辑与业务逻辑的分离，让开发者能够专注于业务实现，同时享受类型安全和高度可复用的权限管理功能。
