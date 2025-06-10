# 动态路由系统使用指南

## 概述

动态路由系统允许通过后端API动态配置应用的页面和路由，无需重新发布应用即可添加、修改或删除页面。这大大提高了应用的灵活性和可维护性。

## 核心特性

### 1. 动态页面类型支持
- **静态页面** (`static`): 使用预定义的Flutter页面组件
- **动态页面** (`dynamic`): 根据配置动态生成页面布局
- **列表页面** (`list`): 数据驱动的列表页面，支持分页
- **详情页面** (`detail`): 数据驱动的详情页面
- **表单页面** (`form`): 动态表单页面，支持多种字段类型
- **WebView页面** (`webview`): 内嵌网页页面
- **外部链接** (`external`): 打开外部应用或浏览器

### 2. 数据源配置
- 支持RESTful API调用
- 数据转换和字段映射
- 请求缓存机制
- 错误处理

### 3. 布局系统
- 支持多种布局类型：列、行、堆叠、网格、列表
- 丰富的组件类型：文本、图片、按钮、卡片、容器等
- 样式配置和主题支持
- 事件处理机制

### 4. 权限和认证
- 路由级别的认证控制
- 细粒度权限检查
- 认证中间件支持

## 使用方法

### 1. 后端API接口

#### 获取路由配置
```
GET /api/config/routes
```

响应格式：
```json
{
  "routes": [...],
  "version": "1.0.0",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

#### 检查版本
```
GET /api/config/routes/version
```

响应格式：
```json
{
  "version": "1.0.0"
}
```

### 2. 路由配置格式

#### 基本路由配置
```json
{
  "path": "/dynamic/example",
  "name": "示例页面",
  "pageType": "dynamic",
  "title": "页面标题",
  "requiresAuth": false,
  "permissions": ["example.view"],
  "enabled": true,
  "order": 1,
  "pageConfig": {
    // 页面配置
  }
}
```

#### 列表页面配置
```json
{
  "pageType": "list",
  "pageConfig": {
    "dataSource": {
      "endpoint": "/api/items",
      "method": "GET",
      "transform": {
        "dataPath": "data.items",
        "fieldMapping": {
          "title": "name",
          "description": "desc"
        }
      },
      "cache": {
        "duration": 300,
        "enabled": true
      }
    }
  }
}
```

#### 动态页面配置
```json
{
  "pageType": "dynamic",
  "pageConfig": {
    "layout": {
      "type": "column",
      "components": [
        {
          "type": "text",
          "properties": {
            "text": "{{title}}",
            "style": {
              "fontSize": 24,
              "fontWeight": "bold"
            }
          }
        },
        {
          "type": "image",
          "properties": {
            "src": "{{imageUrl}}",
            "width": 300,
            "height": 200
          }
        }
      ]
    },
    "dataSource": {
      "endpoint": "/api/content/{id}",
      "method": "GET"
    }
  }
}
```

#### 表单页面配置
```json
{
  "pageType": "form",
  "pageConfig": {
    "form": {
      "fields": [
        {
          "name": "title",
          "type": "text",
          "label": "标题",
          "required": true,
          "properties": {
            "placeholder": "请输入标题",
            "maxLength": 100
          }
        },
        {
          "name": "type",
          "type": "select",
          "label": "类型",
          "required": true,
          "properties": {
            "options": [
              {"value": "news", "label": "新闻"},
              {"value": "blog", "label": "博客"}
            ]
          }
        }
      ],
      "submitEndpoint": "/api/submit",
      "submitMethod": "POST"
    }
  }
}
```

### 3. 客户端使用

#### 初始化动态路由
```dart
// 在应用启动时自动初始化
await AppInitializer.initialize();
```

#### 导航到动态路由
```dart
// 使用AppRouter导航
await AppRouter.navigateTo('/dynamic/news');

// 带参数导航
await AppRouter.navigateTo('/dynamic/news/123', arguments: {
  'id': '123',
  'source': 'home'
});
```

#### 刷新路由配置
```dart
// 强制刷新路由配置
await AppRouter.refreshDynamicRoutes();
```

#### 检查路由是否存在
```dart
bool exists = AppRouter.routeExists('/dynamic/news');
```

### 4. 组件类型和属性

#### 文本组件 (`text`)
```json
{
  "type": "text",
  "properties": {
    "text": "显示文本或{{变量}}",
    "style": {
      "fontSize": 16,
      "fontWeight": "bold",
      "color": "#333333"
    },
    "textAlign": "center",
    "maxLines": 2,
    "overflow": "ellipsis"
  }
}
```

#### 图片组件 (`image`)
```json
{
  "type": "image",
  "properties": {
    "src": "https://example.com/image.jpg",
    "width": 200,
    "height": 150,
    "fit": "cover"
  }
}
```

#### 按钮组件 (`button`)
```json
{
  "type": "button",
  "properties": {
    "text": "点击按钮",
    "type": "elevated"
  },
  "events": {
    "onPressed": {
      "type": "navigate",
      "target": "/target/page"
    }
  }
}
```

#### 卡片组件 (`card`)
```json
{
  "type": "card",
  "properties": {
    "margin": {"all": 8},
    "padding": {"all": 16}
  },
  "children": [
    // 子组件列表
  ]
}
```

### 5. 数据绑定

使用双花括号语法绑定数据：
```json
{
  "type": "text",
  "properties": {
    "text": "标题：{{title}}"
  }
}
```

数据来源：
1. API响应数据
2. 路由参数 (`Get.arguments`)
3. URL参数

### 6. 缓存机制

```json
{
  "cache": {
    "duration": 300,    // 缓存时长（秒）
    "key": "custom_key", // 自定义缓存键
    "enabled": true      // 是否启用缓存
  }
}
```

## 最佳实践

### 1. 路由设计
- 使用语义化的路由路径
- 合理设置路由优先级（order）
- 为需要认证的路由设置权限

### 2. 数据源设计
- 使用统一的API响应格式
- 合理设置缓存时长
- 提供数据转换配置

### 3. 布局设计
- 保持组件层次简单
- 使用响应式设计
- 提供加载和错误状态

### 4. 性能优化
- 合理使用缓存
- 避免过深的组件嵌套
- 使用分页加载大量数据

## 扩展开发

### 1. 添加新的页面类型
在 `DynamicPageFactory` 中添加新的页面类型处理：

```dart
case PageType.custom:
  return _createCustomPage(config, arguments);
```

### 2. 添加新的组件类型
在 `DynamicComponentBuilder` 中添加新的组件构建方法：

```dart
case 'custom_component':
  return _buildCustomComponent(component, data, arguments, customStyles);
```

### 3. 添加新的事件类型
在事件处理方法中添加新的事件类型：

```dart
case 'custom_action':
  _handleCustomAction(event, data, arguments);
  break;
```

## 故障排除

### 1. 路由不生效
- 检查路由配置格式是否正确
- 确认路由已启用 (`enabled: true`)
- 检查网络连接和API响应

### 2. 页面显示异常
- 检查页面配置是否完整
- 确认数据源API返回正确格式
- 查看控制台错误信息

### 3. 数据加载失败
- 检查API端点是否正确
- 确认请求参数格式
- 检查网络权限和认证

### 4. 组件渲染错误
- 检查组件类型是否支持
- 确认组件属性格式正确
- 查看组件构建错误日志

## 示例项目

参考 `example_dynamic_routes_config.json` 文件查看完整的配置示例。

## 技术支持

如有问题，请查看：
1. 控制台错误日志
2. 网络请求日志
3. 路由配置验证结果

或联系开发团队获取技术支持。
