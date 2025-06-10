# 基于路由层拦截的业务分离架构使用指南

## 概述

本架构通过将功能检查上移到路由层，实现了业务逻辑与框架功能的完全分离。页面只需关注业务实现，权限检查、分析统计、加载管理等框架功能由路由层自动处理。

## 核心设计理念

### 1. 职责清晰分离
- **路由层**：负责导航、权限检查、分析统计、加载管理等框架功能
- **页面层**：专注于业务逻辑实现，不涉及框架功能
- **中间件层**：处理横切关注点，在路由跳转时自动执行

### 2. 配置驱动
- 通过路由配置声明页面需要的功能
- 功能特性可组合、可复用
- 配置即代码，功能一目了然

### 3. 依赖方向正确
```
路由层 → 页面层 → 业务层
```
页面不再依赖框架功能，实现真正的解耦

## 架构组件

### 1. 路由配置系统
```dart
// 路由配置
RouteConfig(
  path: '/camera',
  pageBuilder: () => CameraPage(),
  title: '相机',
  features: [
    PermissionRouteFeature(requiredPermissions: [AppPermission.camera]),
    AnalyticsRouteFeature(pageName: 'camera_page'),
  ],
)
```

### 2. 功能特性系统
- `PermissionRouteFeature`：权限检查功能
- `AnalyticsRouteFeature`：分析统计功能
- `LoadingRouteFeature`：加载管理功能

### 3. 中间件系统
- `PermissionMiddleware`：权限检查中间件
- `AnalyticsMiddleware`：分析统计中间件
- `LoadingMiddleware`：加载管理中间件

### 4. 简化页面基类
- `SimpleStatelessPage`：无状态页面基类
- `SimpleStatefulPage`：有状态页面基类

## 使用方式

### 1. 基础页面实现

#### 无状态页面
```dart
class CameraPage extends SimpleStatelessPage {
  const CameraPage({super.key});

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('相机')),
      body: const Center(
        child: Text('相机功能'),
      ),
    );
  }
}
```

#### 有状态页面
```dart
class MapPage extends SimpleStatefulPage {
  const MapPage({super.key});

  @override
  SimpleStatefulPageState createPageState() => _MapPageState();
}

class _MapPageState extends SimpleStatefulPageState<MapPage> {
  String _location = '获取中...';

  @override
  Future<void> onPageInit() async {
    // 页面初始化逻辑
    await _loadLocation();
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('地图')),
      body: Center(
        child: Text('当前位置: $_location'),
      ),
    );
  }

  Future<void> _loadLocation() async {
    // 业务逻辑：获取位置
    safeSetState(() {
      _location = '北京市朝阳区';
    });
  }
}
```

### 2. 路由配置

#### 使用路由构建器
```dart
final cameraRoute = RouteBuilder()
    .path('/camera')
    .page(() => const CameraPage())
    .title('相机')
    .withPermissions(
      required: [AppPermission.camera],
      optional: [AppPermission.storage],
      onGranted: (permissions) {
        print('权限已授权: $permissions');
      },
      onDenied: (permissions) async {
        Get.snackbar('提示', '相机权限被拒绝');
        return false; // 不允许进入页面
      },
    )
    .withAnalytics(
      pageName: 'camera_page',
      customParameters: {'feature': 'photo_capture'},
    )
    .build();
```

#### 使用预设配置
```dart
final routes = [
  RoutePresets.camera(() => const CameraPage()),
  RoutePresets.map(() => const MapPage()),
  RoutePresets.home(() => const HomePage()),
];
```

### 3. 路由组配置

```dart
final mediaGroup = RouteGroupBuilder()
    .name('media')
    .prefix('/media')
    .description('媒体相关页面')
    .withGroupPermissions(
      optional: [AppPermission.camera, AppPermission.microphone],
      showGuide: true,
    )
    .withGroupAnalytics(customParameters: {'group': 'media'})
    .routeBuilder((builder) => builder
        .path('/camera')
        .page(() => const MediaCameraPage())
        .title('相机')
        .withAnalytics(pageName: 'media_camera'))
    .routeBuilder((builder) => builder
        .path('/gallery')
        .page(() => const MediaGalleryPage())
        .title('相册')
        .withAnalytics(pageName: 'media_gallery'))
    .build();
```

### 4. 应用初始化

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化应用
  await AppInitializer.initialize();
  
  // 初始化路由系统
  await AppRouteManager.instance.initialize(
    routes: getAllRoutes(),
    routeGroups: getAllRouteGroups(),
    validateRoutes: true,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      getPages: AppRouteManager.instance.getGetPages(),
      initialRoute: '/',
    );
  }
}
```

## 功能特性详解

### 1. 权限功能特性

```dart
// 基础权限配置
PermissionRouteFeature(
  requiredPermissions: [AppPermission.camera],
  optionalPermissions: [AppPermission.storage],
  showGuide: true,
  allowSkipOptional: true,
  deniedRedirectRoute: '/permission_denied',
  onPermissionDenied: (permissions) async {
    // 自定义权限被拒绝处理
    return false;
  },
  onPermissionGranted: (permissions) {
    // 权限授权成功回调
    print('权限已授权: $permissions');
  },
)

// 使用工厂方法
PermissionRouteFeatureFactory.camera(required: true)
PermissionRouteFeatureFactory.multimedia(required: false)
```

### 2. 分析功能特性

```dart
// 基础分析配置
AnalyticsRouteFeature(
  pageName: 'camera_page',
  enablePageView: true,
  enableDuration: true,
  customParameters: {'feature': 'photo_capture'},
  onPageEnter: (route, params) {
    print('进入页面: $route');
  },
  onPageExit: (route, duration) {
    print('离开页面: $route, 停留时间: ${duration.inSeconds}秒');
  },
)

// 使用工厂方法
AnalyticsRouteFeatureFactory.ecommerce(
  pageName: 'product_detail',
  category: 'electronics',
  productId: 'phone_001',
  price: 999.0,
)
```

### 3. 加载功能特性

```dart
// 基础加载配置
LoadingRouteFeature(
  enableGlobalLoading: true,
  enableNetworkCheck: true,
  minLoadingDuration: 500,
  loadingTimeout: 30000,
  onPreloadData: () async {
    // 数据预加载逻辑
    await loadMapData();
    return true;
  },
  onNetworkStatusChanged: (isConnected) {
    print('网络状态: ${isConnected ? '已连接' : '已断开'}');
  },
)

// 使用工厂方法
LoadingRouteFeatureFactory.withPreload(() async {
  return await loadUserData();
})
```

## 最佳实践

### 1. 页面设计原则

#### ✅ 正确的做法
```dart
class CameraPage extends SimpleStatelessPage {
  @override
  Widget buildContent(BuildContext context) {
    // 只关注业务逻辑
    return Scaffold(
      appBar: AppBar(title: const Text('相机')),
      body: CameraWidget(),
    );
  }
}
```

#### ❌ 错误的做法
```dart
class CameraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 不要在页面中处理权限检查
    return FutureBuilder(
      future: checkCameraPermission(),
      builder: (context, snapshot) {
        // 这些逻辑应该在路由层处理
        if (!snapshot.hasData) return LoadingWidget();
        if (!snapshot.data) return PermissionDeniedWidget();
        return CameraWidget();
      },
    );
  }
}
```

### 2. 路由配置原则

- **功能组合**：按需添加功能特性，避免过度配置
- **职责单一**：每个功能特性只负责一个方面
- **配置集中**：在路由定义处统一配置所有功能

### 3. 错误处理策略

```dart
// 在路由配置中处理错误
RouteBuilder()
    .path('/camera')
    .page(() => const CameraPage())
    .withPermissions(
      required: [AppPermission.camera],
      deniedRedirectRoute: '/permission_denied',
      onDenied: (permissions) async {
        // 统一的错误处理逻辑
        await showPermissionDialog(permissions);
        return false;
      },
    )
    .build()
```

### 4. 性能优化

- **懒加载**：页面构建器使用懒加载
- **缓存配置**：路由配置支持缓存
- **批量初始化**：功能特性批量初始化

## 架构优势

### 1. 完全的业务分离
- 页面代码只包含业务逻辑
- 框架功能由路由层自动处理
- 开发者专注于业务实现

### 2. 高度的可复用性
- 功能特性可在不同路由间复用
- 路由组支持组级功能配置
- 预设配置减少重复代码

### 3. 优雅的扩展性
- 新功能通过实现接口添加
- 中间件支持链式处理
- 配置驱动的功能控制

### 4. 统一的生命周期管理
- 路由级别的生命周期控制
- 功能特性自动初始化和清理
- 错误状态统一处理

### 5. 声明式的功能配置
- 通过配置声明页面功能
- 功能组合一目了然
- 易于维护和修改

## 迁移指南

### 从旧架构迁移

1. **页面重构**：将页面基类改为 `SimpleStatelessPage` 或 `SimpleStatefulPage`
2. **移除框架代码**：删除页面中的权限检查、分析统计等代码
3. **配置路由**：在路由配置中添加相应的功能特性
4. **测试验证**：确保功能正常工作

### 渐进式迁移

- 可以新旧架构并存
- 逐步迁移现有页面
- 新页面直接使用新架构

## 调试和监控

### 1. 路由信息查看
```dart
// 打印路由信息
AppRouteManager.instance.printRouteInfo();

// 获取统计信息
final stats = AppRouteManager.instance.getStatistics();
print('路由总数: ${stats['route_count']}');
```

### 2. 功能特性监控
```dart
// 查看功能特性状态
final featureStats = RouteFeatureManager.instance.getStatistics();
print('功能特性统计: $featureStats');
```

### 3. 中间件监控
```dart
// 查看中间件状态
final middlewareStats = MiddlewareManager.instance.getStatistics();
print('中间件统计: $middlewareStats');
```

这种基于路由层拦截的架构设计完全实现了业务与框架功能的分离，让开发者能够专注于业务逻辑实现，同时享受框架提供的强大功能。
