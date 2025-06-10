# 业务分离架构使用指南

## 概述

本架构通过抽象基类、功能组合和装饰器模式，实现了业务逻辑与框架功能的完全分离，让开发者专注于业务实现，而无需关心权限检查、分析统计、加载状态等框架层面的功能。

## 核心设计理念

### 1. 组合优于继承
- 使用功能组合器（PageFeatureComposer）组装页面功能
- 每个功能都是独立的组件，可以自由组合
- 避免深层继承带来的耦合问题

### 2. 关注点分离
- **业务逻辑**：开发者只需关心页面的业务实现
- **框架功能**：权限、分析、加载等由框架自动处理
- **配置驱动**：通过配置控制功能行为

### 3. 声明式编程
- 通过链式调用声明页面需要的功能
- 配置即代码，功能组合一目了然

## 使用方式

### 1. 基础页面实现

#### 无状态页面
```dart
class HomePage extends BaseStatelessPage {
  const HomePage({super.key});

  @override
  PageConfig get pageConfig => PageConfigPresets.basic('/home', title: '首页');

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: const Center(
        child: Text('这里是业务内容'),
      ),
    );
  }
}
```

#### 有状态页面
```dart
class ProfilePage extends BaseStatefulPage {
  const ProfilePage({super.key});

  @override
  PageConfig get pageConfig => PageConfigPresets.basic('/profile', title: '个人资料');
}

class _ProfilePageState extends BaseStatefulPageState<ProfilePage> {
  String userName = '';

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人资料')),
      body: Column(
        children: [
          Text('用户名: $userName'),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userName = '新用户名';
              });
            },
            child: const Text('更新用户名'),
          ),
        ],
      ),
    );
  }
}
```

### 2. 功能组合使用

#### 相机页面（需要权限）
```dart
class CameraPage extends BaseStatelessPage {
  const CameraPage({super.key});

  @override
  PageConfig get pageConfig => PageFeatureComposer()
      .route('/camera')
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

#### 地图页面（需要网络和位置权限）
```dart
class MapPage extends BaseStatefulPage {
  const MapPage({super.key});

  @override
  PageConfig get pageConfig => PageFeatureComposer()
      .route('/map')
      .title('地图')
      .withPermissions(
        optional: [AppPermission.location],
      )
      .withLoading(
        enableNetworkCheck: true,
        preloadData: () async {
          // 预加载地图数据
          await Future.delayed(const Duration(seconds: 2));
          return true;
        },
      )
      .withAnalytics(pageName: 'map_page')
      .build();
}

class _MapPageState extends BaseStatefulPageState<MapPage> {
  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('地图')),
      body: const Center(
        child: Text('地图内容'),
      ),
    );
  }
}
```

### 3. 预设配置使用

#### 使用预设配置
```dart
class QuickCameraPage extends BaseStatelessPage {
  const QuickCameraPage({super.key});

  @override
  PageConfig get pageConfig => PageConfigPresets.camera('/quick_camera');

  @override
  Widget buildContent(BuildContext context) {
    // 只需要实现业务逻辑，权限检查由框架处理
    return const CameraWidget();
  }
}
```

#### 自定义预设配置
```dart
class CustomPage extends BaseStatelessPage {
  const CustomPage({super.key});

  @override
  PageConfig get pageConfig => PageConfigPresets.full(
    '/custom',
    title: '自定义页面',
    requiredPermissions: [AppPermission.storage],
    optionalPermissions: [AppPermission.camera, AppPermission.location],
    preloadData: () async {
      // 自定义数据预加载
      return await loadCustomData();
    },
    analyticsParams: {'page_type': 'custom'},
  );

  @override
  Widget buildContent(BuildContext context) {
    return const CustomBusinessWidget();
  }

  Future<bool> loadCustomData() async {
    // 业务数据加载逻辑
    return true;
  }
}
```

### 4. 页面工厂使用

#### 动态创建页面
```dart
Widget createDynamicPage(String route, Map<String, dynamic> config) {
  return PageFactory.createStatelessPage(
    config: PageFeatureComposer()
        .route(route)
        .title(config['title'])
        .withPermissions(
          required: List<AppPermission>.from(config['permissions'] ?? []),
        )
        .build(),
    builder: (context) {
      return Scaffold(
        appBar: AppBar(title: Text(config['title'])),
        body: Text('动态页面内容'),
      );
    },
  );
}
```

### 5. 业务检查扩展

#### 自定义业务检查
```dart
class VipPage extends BaseStatelessPage {
  const VipPage({super.key});

  @override
  PageConfig get pageConfig => PageConfigPresets.basic('/vip', title: 'VIP页面');

  @override
  Future<bool> onBusinessCheck(BuildContext context) async {
    // 检查用户是否为VIP
    final userService = Get.find<UserService>();
    final isVip = await userService.checkVipStatus();
    
    if (!isVip) {
      Get.snackbar('提示', '需要VIP权限才能访问');
      return false;
    }
    
    return true;
  }

  @override
  Widget buildContent(BuildContext context) {
    return const VipContentWidget();
  }
}
```

## 自定义功能扩展

### 1. 创建自定义功能
```dart
class CustomFeature implements IPageFeature {
  @override
  String get featureName => 'CustomFeature';

  @override
  Future<bool> onPageEnter(BuildContext context, String route) async {
    // 页面进入前的自定义逻辑
    return true;
  }

  @override
  Widget onPageBuild(BuildContext context, Widget child) {
    // 包装页面内容
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
      ),
      child: child,
    );
  }

  @override
  Future<bool> onPageExit(BuildContext context, String route) async {
    // 页面退出前的自定义逻辑
    return true;
  }

  @override
  void onPageDispose() {
    // 页面销毁时的清理逻辑
  }
}
```

### 2. 使用自定义功能
```dart
class CustomPage extends BaseStatelessPage {
  @override
  PageConfig get pageConfig => PageFeatureComposer()
      .route('/custom')
      .withFeature(CustomFeature())
      .build();

  @override
  Widget buildContent(BuildContext context) {
    return const Text('自定义功能页面');
  }
}
```

## 架构优势

### 1. 完全的业务分离
- 开发者只需要实现 `buildContent` 方法
- 框架功能通过配置自动处理
- 业务代码与框架代码零耦合

### 2. 高度的可复用性
- 功能组件可以在不同页面间复用
- 预设配置减少重复代码
- 页面工厂支持动态创建

### 3. 优雅的扩展性
- 新功能通过实现 `IPageFeature` 接口添加
- 功能组合器支持链式调用
- 配置驱动的功能控制

### 4. 统一的生命周期管理
- 页面进入、构建、退出、销毁的统一处理
- 错误状态和加载状态的统一管理
- 功能执行顺序的自动控制

### 5. 声明式的功能配置
- 通过配置声明页面需要的功能
- 功能组合一目了然
- 易于维护和修改

## 最佳实践

### 1. 功能组合原则
- 按需添加功能，避免过度配置
- 相关功能组合使用，如权限+分析
- 使用预设配置减少重复代码

### 2. 业务逻辑分离
- 业务逻辑只在 `buildContent` 中实现
- 使用 `onBusinessCheck` 进行业务级别的访问控制
- 避免在业务代码中直接调用框架功能

### 3. 错误处理策略
- 重写 `onError` 方法自定义错误页面
- 使用 `onBusinessCheck` 进行业务验证
- 合理使用加载状态提升用户体验

### 4. 性能优化
- 使用数据预加载减少页面等待时间
- 合理配置最小加载时间避免闪烁
- 按需启用功能避免不必要的开销

这种架构设计完全实现了您提出的需求：通过抽象基类和组合模式，将权限检查等框架功能与业务逻辑完全分离，开发者只需要关注业务实现，框架功能通过配置自动处理。
