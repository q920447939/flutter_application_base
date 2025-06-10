# 声明式权限配置演示应用

这是一个完整的Flutter应用示例，展示了如何使用新的路由架构和声明式权限配置功能。

## 🚀 快速开始

### 1. 安装依赖
```bash
flutter pub get
```

### 2. 运行应用
```bash
flutter run
```

### 3. 体验功能
- 启动应用后，您将看到主页面
- 点击"声明式权限配置"按钮进入演示页面
- 尝试不同的权限配置示例

## 📱 功能演示

### 主要演示页面

1. **相机演示** - 使用预设权限配置
   - 路由: `/declarative/camera`
   - 配置: `PermissionPresets.camera`
   - 权限: 相机(必需) + 存储(可选)

2. **位置演示** - 可选权限配置
   - 路由: `/declarative/location`
   - 配置: `PermissionPresets.location`
   - 权限: 位置(可选)

3. **多媒体演示** - 多权限组合
   - 路由: `/declarative/multimedia`
   - 配置: `PermissionPresets.multimedia`
   - 权限: 相机+麦克风(必需) + 存储(可选)

4. **自定义演示** - 构建器模式
   - 路由: `/declarative/custom`
   - 配置: `PermissionConfigBuilder`
   - 权限: 自定义配置

5. **工厂演示** - 工厂方法创建
   - 路由: `/declarative/factory`
   - 配置: `PermissionConfigFactory`
   - 权限: 工厂方法配置

## 🏗️ 架构特点

### 1. 完全的业务分离
- 页面代码只包含业务逻辑
- 权限检查由路由层自动处理
- 配置即代码，一目了然

### 2. 声明式权限配置
```dart
// 使用预设配置
RoutePresets.withDeclarativePermissions(
  '/camera',
  () => CameraPage(),
  PermissionPresets.camera,
)

// 使用构建器模式
RouteBuilder()
    .path('/custom')
    .withDeclarativePermissions(
      PermissionConfigBuilder()
          .required([AppPermission.camera])
          .optional([AppPermission.storage])
          .build(),
    )
    .build()
```

### 3. 多种配置方式
- **预设配置**: `PermissionPresets.camera`
- **构建器模式**: `PermissionConfigBuilder()`
- **工厂方法**: `PermissionConfigFactory.multimedia()`
- **直接配置**: `RequiresPermissions(...)`

## 📂 项目结构

```
lib/
├── main.dart                           # 应用入口
├── example_app.dart                     # 示例应用主类
├── core/                               # 核心框架
│   ├── app_initializer.dart            # 应用初始化器
│   ├── router/                         # 路由系统
│   │   ├── index.dart                  # 路由模块导出
│   │   ├── route_config.dart           # 路由配置
│   │   ├── route_feature.dart          # 路由功能特性
│   │   ├── route_builder.dart          # 路由构建器
│   │   ├── route_presets.dart          # 路由预设
│   │   ├── declarative_permissions.dart # 声明式权限配置
│   │   ├── app_route_manager.dart      # 路由管理器
│   │   ├── middlewares/                # 中间件
│   │   └── features/                   # 功能特性
│   ├── base/                           # 基础组件
│   │   └── simple_page.dart            # 简化页面基类
│   └── permissions/                    # 权限系统
│       └── permission_service.dart     # 权限服务
└── example/                            # 示例代码
    ├── routes/                         # 示例路由
    │   ├── example_routes.dart         # 主路由配置
    │   └── declarative_permission_routes.dart # 声明式权限路由
    └── pages/                          # 示例页面
        ├── simple_example_pages.dart   # 基础示例页面
        └── declarative_permission_demo_pages.dart # 权限演示页面
```

## 🔧 配置选项

### 权限类型
- **必需权限**: 用户必须授权才能进入页面
- **可选权限**: 用户可以选择是否授权

### 配置参数
- `required`: 必需权限列表
- `optional`: 可选权限列表
- `showGuide`: 是否显示权限引导
- `allowSkipOptional`: 是否允许跳过可选权限
- `deniedRedirectRoute`: 权限被拒绝时的重定向路由
- `customTitles`: 自定义权限标题
- `customDescriptions`: 自定义权限描述

## 💡 使用示例

### 示例1: 预设配置
```dart
RoutePresets.withDeclarativePermissions(
  '/camera',
  () => CameraPage(),
  PermissionPresets.camera,
  title: '相机',
)
```

### 示例2: 构建器模式
```dart
RouteBuilder()
    .path('/multimedia')
    .page(() => MultimediaPage())
    .withDeclarativePermissions(
      PermissionConfigBuilder()
          .required([AppPermission.camera, AppPermission.microphone])
          .optional([AppPermission.storage])
          .description('多媒体功能需要相机和麦克风权限')
          .build(),
    )
    .build()
```

### 示例3: 工厂方法
```dart
RouteBuilder()
    .path('/custom')
    .withDeclarativePermissions(
      PermissionConfigFactory.multimedia(
        cameraRequired: true,
        micRequired: false,
      ),
    )
    .build()
```

## 🎯 核心优势

1. **零权限代码**: 页面中无需任何权限处理代码
2. **类型安全**: 编译时权限检查
3. **高度复用**: 权限配置可在多个路由间复用
4. **配置驱动**: 通过配置声明页面功能
5. **易于维护**: 权限逻辑集中管理

## 📖 相关文档

- [路由架构使用指南](ROUTE_BASED_ARCHITECTURE_GUIDE.md)
- [声明式权限配置指南](DECLARATIVE_PERMISSIONS_GUIDE.md)

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个示例！

## 📄 许可证

MIT License
