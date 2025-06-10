/// 动态路由配置模型
///
/// 定义从后端获取的路由配置数据结构
library;

import 'package:json_annotation/json_annotation.dart';

part 'route_config.g.dart';

/// 路由配置响应
@JsonSerializable()
class RouteConfigResponse {
  /// 路由配置列表
  final List<RouteConfig> routes;
  
  /// 版本号，用于缓存控制
  final String version;
  
  /// 更新时间
  final DateTime updatedAt;

  const RouteConfigResponse({
    required this.routes,
    required this.version,
    required this.updatedAt,
  });

  factory RouteConfigResponse.fromJson(Map<String, dynamic> json) =>
      _$RouteConfigResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RouteConfigResponseToJson(this);
}

/// 单个路由配置
@JsonSerializable()
class RouteConfig {
  /// 路由路径
  final String path;
  
  /// 路由名称
  final String name;
  
  /// 页面类型
  final PageType pageType;
  
  /// 页面标题
  final String? title;
  
  /// 页面配置
  final PageConfig? pageConfig;
  
  /// 是否需要认证
  final bool requiresAuth;
  
  /// 权限要求
  final List<String>? permissions;
  
  /// 路由参数配置
  final Map<String, dynamic>? parameters;
  
  /// 是否启用
  final bool enabled;
  
  /// 排序权重
  final int order;

  const RouteConfig({
    required this.path,
    required this.name,
    required this.pageType,
    this.title,
    this.pageConfig,
    this.requiresAuth = false,
    this.permissions,
    this.parameters,
    this.enabled = true,
    this.order = 0,
  });

  factory RouteConfig.fromJson(Map<String, dynamic> json) =>
      _$RouteConfigFromJson(json);

  Map<String, dynamic> toJson() => _$RouteConfigToJson(this);
}

/// 页面类型枚举
enum PageType {
  /// 静态页面 - 使用预定义的Flutter页面
  @JsonValue('static')
  static,
  
  /// 动态页面 - 根据配置动态生成
  @JsonValue('dynamic')
  dynamic,
  
  /// 列表页面 - 数据驱动的列表页面
  @JsonValue('list')
  list,
  
  /// 详情页面 - 数据驱动的详情页面
  @JsonValue('detail')
  detail,
  
  /// 表单页面 - 动态表单页面
  @JsonValue('form')
  form,
  
  /// WebView页面 - 内嵌网页
  @JsonValue('webview')
  webview,
  
  /// 外部链接 - 打开外部应用
  @JsonValue('external')
  external,
}

/// 页面配置
@JsonSerializable()
class PageConfig {
  /// 静态页面的组件名称
  final String? componentName;
  
  /// 动态页面的布局配置
  final LayoutConfig? layout;
  
  /// 数据源配置
  final DataSourceConfig? dataSource;
  
  /// WebView配置
  final WebViewConfig? webView;
  
  /// 表单配置
  final FormConfig? form;
  
  /// 自定义样式
  final Map<String, dynamic>? customStyles;
  
  /// 扩展配置
  final Map<String, dynamic>? extensions;

  const PageConfig({
    this.componentName,
    this.layout,
    this.dataSource,
    this.webView,
    this.form,
    this.customStyles,
    this.extensions,
  });

  factory PageConfig.fromJson(Map<String, dynamic> json) =>
      _$PageConfigFromJson(json);

  Map<String, dynamic> toJson() => _$PageConfigToJson(this);
}

/// 布局配置
@JsonSerializable()
class LayoutConfig {
  /// 布局类型
  final LayoutType type;
  
  /// 组件列表
  final List<ComponentConfig> components;
  
  /// 布局参数
  final Map<String, dynamic>? parameters;

  const LayoutConfig({
    required this.type,
    required this.components,
    this.parameters,
  });

  factory LayoutConfig.fromJson(Map<String, dynamic> json) =>
      _$LayoutConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LayoutConfigToJson(this);
}

/// 布局类型
enum LayoutType {
  @JsonValue('column')
  column,
  @JsonValue('row')
  row,
  @JsonValue('stack')
  stack,
  @JsonValue('grid')
  grid,
  @JsonValue('list')
  list,
  @JsonValue('custom')
  custom,
}

/// 组件配置
@JsonSerializable()
class ComponentConfig {
  /// 组件类型
  final String type;
  
  /// 组件属性
  final Map<String, dynamic> properties;
  
  /// 子组件
  final List<ComponentConfig>? children;
  
  /// 事件配置
  final Map<String, dynamic>? events;

  const ComponentConfig({
    required this.type,
    required this.properties,
    this.children,
    this.events,
  });

  factory ComponentConfig.fromJson(Map<String, dynamic> json) =>
      _$ComponentConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ComponentConfigToJson(this);
}

/// 数据源配置
@JsonSerializable()
class DataSourceConfig {
  /// API端点
  final String endpoint;
  
  /// HTTP方法
  final String method;
  
  /// 请求参数
  final Map<String, dynamic>? parameters;
  
  /// 请求头
  final Map<String, String>? headers;
  
  /// 数据转换配置
  final DataTransformConfig? transform;
  
  /// 缓存配置
  final CacheConfig? cache;

  const DataSourceConfig({
    required this.endpoint,
    this.method = 'GET',
    this.parameters,
    this.headers,
    this.transform,
    this.cache,
  });

  factory DataSourceConfig.fromJson(Map<String, dynamic> json) =>
      _$DataSourceConfigFromJson(json);

  Map<String, dynamic> toJson() => _$DataSourceConfigToJson(this);
}

/// 数据转换配置
@JsonSerializable()
class DataTransformConfig {
  /// 数据路径
  final String? dataPath;
  
  /// 字段映射
  final Map<String, String>? fieldMapping;
  
  /// 过滤条件
  final Map<String, dynamic>? filters;

  const DataTransformConfig({
    this.dataPath,
    this.fieldMapping,
    this.filters,
  });

  factory DataTransformConfig.fromJson(Map<String, dynamic> json) =>
      _$DataTransformConfigFromJson(json);

  Map<String, dynamic> toJson() => _$DataTransformConfigToJson(this);
}

/// 缓存配置
@JsonSerializable()
class CacheConfig {
  /// 缓存时长（秒）
  final int duration;
  
  /// 缓存键
  final String? key;
  
  /// 是否启用缓存
  final bool enabled;

  const CacheConfig({
    required this.duration,
    this.key,
    this.enabled = true,
  });

  factory CacheConfig.fromJson(Map<String, dynamic> json) =>
      _$CacheConfigFromJson(json);

  Map<String, dynamic> toJson() => _$CacheConfigToJson(this);
}

/// WebView配置
@JsonSerializable()
class WebViewConfig {
  /// URL地址
  final String url;
  
  /// 是否显示导航栏
  final bool showNavigationBar;
  
  /// 自定义用户代理
  final String? userAgent;
  
  /// JavaScript是否启用
  final bool javascriptEnabled;

  const WebViewConfig({
    required this.url,
    this.showNavigationBar = true,
    this.userAgent,
    this.javascriptEnabled = true,
  });

  factory WebViewConfig.fromJson(Map<String, dynamic> json) =>
      _$WebViewConfigFromJson(json);

  Map<String, dynamic> toJson() => _$WebViewConfigToJson(this);
}

/// 表单配置
@JsonSerializable()
class FormConfig {
  /// 表单字段
  final List<FormFieldConfig> fields;
  
  /// 提交端点
  final String submitEndpoint;
  
  /// 提交方法
  final String submitMethod;
  
  /// 验证规则
  final Map<String, dynamic>? validationRules;

  const FormConfig({
    required this.fields,
    required this.submitEndpoint,
    this.submitMethod = 'POST',
    this.validationRules,
  });

  factory FormConfig.fromJson(Map<String, dynamic> json) =>
      _$FormConfigFromJson(json);

  Map<String, dynamic> toJson() => _$FormConfigToJson(this);
}

/// 表单字段配置
@JsonSerializable()
class FormFieldConfig {
  /// 字段名称
  final String name;
  
  /// 字段类型
  final String type;
  
  /// 字段标签
  final String label;
  
  /// 是否必填
  final bool required;
  
  /// 默认值
  final dynamic defaultValue;
  
  /// 字段属性
  final Map<String, dynamic>? properties;

  const FormFieldConfig({
    required this.name,
    required this.type,
    required this.label,
    this.required = false,
    this.defaultValue,
    this.properties,
  });

  factory FormFieldConfig.fromJson(Map<String, dynamic> json) =>
      _$FormFieldConfigFromJson(json);

  Map<String, dynamic> toJson() => _$FormFieldConfigToJson(this);
}
