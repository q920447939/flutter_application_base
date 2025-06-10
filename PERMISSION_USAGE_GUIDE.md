# 权限管理系统使用指南

## 概述

本权限管理系统是一个高度可配置、平台自适应的权限管理解决方案，支持：

- **多平台适配**：移动端（iOS/Android）、桌面端（Windows/macOS/Linux）、Web端
- **权限分级**：必要权限、可选权限
- **多场景触发**：应用启动、页面进入、操作触发
- **完全可配置**：支持本地配置和远程配置
- **策略化处理**：权限被拒绝后的多种处理策略

## 核心组件

### 1. 权限类型定义

```dart
// 平台类型
enum PlatformType { mobile, desktop, web }

// 权限重要性级别
enum PermissionPriority { required, optional }

// 权限触发场景
enum PermissionTrigger { appLaunch, pageEnter, actionTrigger, background }

// 权限被拒绝后的处理策略
enum PermissionDeniedStrategy {
  showDialog,    // 显示对话框
  showSnackbar,  // 显示提示条
  exitApp,       // 退出应用（仅限必要权限）
  disableFeature, // 禁用相关功能
  silent,        // 静默处理
}
```

### 2. 权限配置

权限配置支持两种方式：

#### 本地配置文件 (`assets/config/permission_config.json`)

```json
{
  "permissions": [
    {
      "permission": "camera",
      "priority": "optional",
      "triggers": ["actionTrigger"],
      "supportedPlatforms": ["mobile"],
      "customTitle": "相机权限",
      "customDescription": "用于拍照和扫描二维码",
      "allowSkip": true,
      "deniedStrategy": "disableFeature",
      "maxRetryCount": 2,
      "relatedRoutes": ["/camera", "/qr_scan"]
    }
  ]
}
```

#### 代码配置

```dart
final config = PermissionConfig(
  permission: AppPermission.camera,
  priority: PermissionPriority.optional,
  triggers: [PermissionTrigger.actionTrigger],
  supportedPlatforms: [PlatformType.mobile],
  customTitle: '相机权限',
  customDescription: '用于拍照和扫描二维码',
  allowSkip: true,
  deniedStrategy: PermissionDeniedStrategy.disableFeature,
  maxRetryCount: 2,
  relatedRoutes: ['/camera', '/qr_scan'],
);

PermissionConfigManager.instance.addOrUpdateConfig(config);
```

## 使用方法

### 1. 应用启动时初始化

权限系统已集成到应用初始化流程中，会自动处理应用启动时需要的权限：

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 应用初始化（包含权限初始化）
  await AppInitializer.initialize();
  
  runApp(MyApp());
}
```

### 2. 页面权限检查

#### 使用装饰器

```dart
class CameraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PermissionChecker.withPagePermissions(
      route: '/camera',
      child: Scaffold(
        appBar: AppBar(title: Text('相机')),
        body: CameraWidget(),
      ),
      loadingWidget: Center(child: CircularProgressIndicator()),
      deniedWidget: PermissionDeniedPage(),
    );
  }
}
```

#### 使用控制器基类

```dart
class CameraController extends PermissionController {
  @override
  List<AppPermission> get requiredPermissions => [AppPermission.camera];
  
  @override
  List<AppPermission> get optionalPermissions => [AppPermission.storage];
  
  void takePhoto() async {
    final hasPermission = await checkPermission(AppPermission.camera);
    if (hasPermission) {
      // 执行拍照逻辑
    }
  }
  
  @override
  void onPermissionDenied(List<AppPermission> deniedPermissions) {
    Get.snackbar('权限不足', '无法使用相机功能');
  }
}
```

### 3. 操作权限检查

#### 使用混入

```dart
class PhotoService with PermissionMixin {
  Future<void> savePhoto() async {
    await withPermission([AppPermission.storage], () async {
      // 保存照片逻辑
    });
  }
}
```

#### 直接检查

```dart
class PhotoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final hasPermission = await PermissionInitializer.instance
            .checkActionPermissions([AppPermission.camera]);
        
        if (hasPermission) {
          // 执行拍照
        }
      },
      child: Text('拍照'),
    );
  }
}
```

#### 使用装饰器

```dart
PermissionChecker.withActionPermissions(
  permissions: [AppPermission.camera],
  child: ElevatedButton(
    onPressed: () => takePhoto(),
    child: Text('拍照'),
  ),
  onPermissionDenied: () {
    Get.snackbar('提示', '需要相机权限');
  },
)
```

### 4. 路由守卫

在路由配置中添加权限中间件：

```dart
GetPage(
  name: '/camera',
  page: () => CameraPage(),
  middlewares: [PermissionMiddleware()],
)
```

### 5. 动态配置管理

#### 设置远程配置URL

```dart
await PermissionConfigManager.instance.initialize(
  remoteConfigUrl: 'https://api.example.com/permission-config',
  useCache: true,
);
```

#### 刷新配置

```dart
await PermissionConfigManager.instance.refreshConfigs();
```

#### 查询配置

```dart
// 获取应用启动时需要的权限
final appLaunchConfigs = PermissionConfigManager.instance.getAppLaunchConfigs();

// 获取页面相关权限
final pageConfigs = PermissionConfigManager.instance.getConfigsByRoute('/camera');

// 获取必要权限
final requiredConfigs = PermissionConfigManager.instance.getRequiredConfigs();
```

## 平台特定处理

### 移动端

```dart
// 检查当前平台
if (PlatformDetector.instance.isMobile) {
  // 移动端特定逻辑
  final supportedPermissions = PlatformDetector.instance.getSupportedPermissions();
}
```

### Web端

```dart
if (PlatformDetector.instance.isWeb) {
  // Web端权限处理
  await PermissionInitializer.instance.checkActionPermissions([
    AppPermission.webCamera,
    AppPermission.webMicrophone,
  ]);
}
```

### 桌面端

```dart
if (PlatformDetector.instance.isDesktop) {
  // 桌面端权限处理
  await PermissionInitializer.instance.checkActionPermissions([
    AppPermission.desktopFileSystem,
    AppPermission.desktopSystemTray,
  ]);
}
```

## 最佳实践

### 1. 权限配置原则

- **最小权限原则**：只请求应用必需的权限
- **分级管理**：区分必要权限和可选权限
- **场景化请求**：在需要时才请求权限
- **用户友好**：提供清晰的权限说明

### 2. 错误处理

```dart
try {
  final result = await PermissionInitializer.instance.initialize();
  if (!result.success) {
    // 处理初始化失败
    if (result.shouldExitApp) {
      // 退出应用
    } else {
      // 降级处理
    }
  }
} catch (e) {
  // 异常处理
}
```

### 3. 性能优化

- 使用缓存避免重复检查
- 批量请求相关权限
- 异步处理权限检查

### 4. 用户体验

- 提供权限说明页面
- 支持权限重新请求
- 优雅的降级处理

## 调试和测试

### 1. 权限状态查看

```dart
final summary = await PermissionUtils.getPermissionSummary([
  AppPermission.camera,
  AppPermission.location,
]);
print(summary);
```

### 2. 权限分组查看

```dart
final groups = PermissionUtils.groupPermissions([
  AppPermission.camera,
  AppPermission.microphone,
  AppPermission.location,
]);
```

### 3. 重置权限状态

```dart
// 重置初始化状态
PermissionInitializer.instance.reset();

// 清除配置缓存
await PermissionConfigManager.instance.clearCache();
```

## 扩展和自定义

### 1. 自定义权限策略

```dart
class CustomPermissionStrategy extends PermissionDeniedStrategy {
  // 实现自定义策略
}
```

### 2. 自定义权限UI

```dart
class CustomPermissionGuidePage extends StatelessWidget {
  // 实现自定义权限引导页面
}
```

### 3. 添加新的权限类型

```dart
enum AppPermission {
  // 现有权限...
  customPermission, // 新增权限
}
```

## 常见问题

### Q: 如何处理权限被永久拒绝的情况？
A: 系统会自动检测永久拒绝状态，并引导用户到设置页面手动开启权限。

### Q: 如何在不同平台使用不同的权限策略？
A: 在权限配置中设置 `supportedPlatforms` 字段，系统会自动过滤当前平台支持的权限。

### Q: 如何实现权限的热更新？
A: 设置远程配置URL，调用 `refreshConfigs()` 方法即可更新权限配置。

### Q: 如何自定义权限被拒绝后的处理逻辑？
A: 在权限配置中设置 `deniedStrategy` 字段，或者重写控制器的 `onPermissionDenied` 方法。
