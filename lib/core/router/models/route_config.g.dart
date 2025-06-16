// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteConfigResponse _$RouteConfigResponseFromJson(Map<String, dynamic> json) =>
    RouteConfigResponse(
      routes: (json['routes'] as List<dynamic>)
          .map((e) => RouteConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      version: json['version'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$RouteConfigResponseToJson(
        RouteConfigResponse instance) =>
    <String, dynamic>{
      'routes': instance.routes.map((e) => e.toJson()).toList(),
      'version': instance.version,
      'updated_at': instance.updatedAt.toIso8601String(),
    };

RouteConfig _$RouteConfigFromJson(Map<String, dynamic> json) => RouteConfig(
      path: json['path'] as String,
      name: json['name'] as String,
      pageType: $enumDecode(_$PageTypeEnumMap, json['page_type']),
      title: json['title'] as String?,
      pageConfig: json['page_config'] == null
          ? null
          : PageConfig.fromJson(json['page_config'] as Map<String, dynamic>),
      requiresAuth: json['requires_auth'] as bool? ?? false,
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      parameters: json['parameters'] as Map<String, dynamic>?,
      enabled: json['enabled'] as bool? ?? true,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RouteConfigToJson(RouteConfig instance) =>
    <String, dynamic>{
      'path': instance.path,
      'name': instance.name,
      'page_type': _$PageTypeEnumMap[instance.pageType]!,
      if (instance.title case final value?) 'title': value,
      if (instance.pageConfig?.toJson() case final value?) 'page_config': value,
      'requires_auth': instance.requiresAuth,
      if (instance.permissions case final value?) 'permissions': value,
      if (instance.parameters case final value?) 'parameters': value,
      'enabled': instance.enabled,
      'order': instance.order,
    };

const _$PageTypeEnumMap = {
  PageType.static: 'static',
  PageType.dynamic: 'dynamic',
  PageType.list: 'list',
  PageType.detail: 'detail',
  PageType.form: 'form',
  PageType.webview: 'webview',
  PageType.external: 'external',
};

PageConfig _$PageConfigFromJson(Map<String, dynamic> json) => PageConfig(
      componentName: json['component_name'] as String?,
      layout: json['layout'] == null
          ? null
          : LayoutConfig.fromJson(json['layout'] as Map<String, dynamic>),
      dataSource: json['data_source'] == null
          ? null
          : DataSourceConfig.fromJson(
              json['data_source'] as Map<String, dynamic>),
      webView: json['web_view'] == null
          ? null
          : WebViewConfig.fromJson(json['web_view'] as Map<String, dynamic>),
      form: json['form'] == null
          ? null
          : FormConfig.fromJson(json['form'] as Map<String, dynamic>),
      customStyles: json['custom_styles'] as Map<String, dynamic>?,
      extensions: json['extensions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PageConfigToJson(PageConfig instance) =>
    <String, dynamic>{
      if (instance.componentName case final value?) 'component_name': value,
      if (instance.layout?.toJson() case final value?) 'layout': value,
      if (instance.dataSource?.toJson() case final value?) 'data_source': value,
      if (instance.webView?.toJson() case final value?) 'web_view': value,
      if (instance.form?.toJson() case final value?) 'form': value,
      if (instance.customStyles case final value?) 'custom_styles': value,
      if (instance.extensions case final value?) 'extensions': value,
    };

LayoutConfig _$LayoutConfigFromJson(Map<String, dynamic> json) => LayoutConfig(
      type: $enumDecode(_$LayoutTypeEnumMap, json['type']),
      components: (json['components'] as List<dynamic>)
          .map((e) => ComponentConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      parameters: json['parameters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$LayoutConfigToJson(LayoutConfig instance) =>
    <String, dynamic>{
      'type': _$LayoutTypeEnumMap[instance.type]!,
      'components': instance.components.map((e) => e.toJson()).toList(),
      if (instance.parameters case final value?) 'parameters': value,
    };

const _$LayoutTypeEnumMap = {
  LayoutType.column: 'column',
  LayoutType.row: 'row',
  LayoutType.stack: 'stack',
  LayoutType.grid: 'grid',
  LayoutType.list: 'list',
  LayoutType.custom: 'custom',
};

ComponentConfig _$ComponentConfigFromJson(Map<String, dynamic> json) =>
    ComponentConfig(
      type: json['type'] as String,
      properties: json['properties'] as Map<String, dynamic>,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => ComponentConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      events: json['events'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ComponentConfigToJson(ComponentConfig instance) =>
    <String, dynamic>{
      'type': instance.type,
      'properties': instance.properties,
      if (instance.children?.map((e) => e.toJson()).toList() case final value?)
        'children': value,
      if (instance.events case final value?) 'events': value,
    };

DataSourceConfig _$DataSourceConfigFromJson(Map<String, dynamic> json) =>
    DataSourceConfig(
      endpoint: json['endpoint'] as String,
      method: json['method'] as String? ?? 'GET',
      parameters: json['parameters'] as Map<String, dynamic>?,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      transform: json['transform'] == null
          ? null
          : DataTransformConfig.fromJson(
              json['transform'] as Map<String, dynamic>),
      cache: json['cache'] == null
          ? null
          : CacheConfig.fromJson(json['cache'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DataSourceConfigToJson(DataSourceConfig instance) =>
    <String, dynamic>{
      'endpoint': instance.endpoint,
      'method': instance.method,
      if (instance.parameters case final value?) 'parameters': value,
      if (instance.headers case final value?) 'headers': value,
      if (instance.transform?.toJson() case final value?) 'transform': value,
      if (instance.cache?.toJson() case final value?) 'cache': value,
    };

DataTransformConfig _$DataTransformConfigFromJson(Map<String, dynamic> json) =>
    DataTransformConfig(
      dataPath: json['data_path'] as String?,
      fieldMapping: (json['field_mapping'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      filters: json['filters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$DataTransformConfigToJson(
        DataTransformConfig instance) =>
    <String, dynamic>{
      if (instance.dataPath case final value?) 'data_path': value,
      if (instance.fieldMapping case final value?) 'field_mapping': value,
      if (instance.filters case final value?) 'filters': value,
    };

CacheConfig _$CacheConfigFromJson(Map<String, dynamic> json) => CacheConfig(
      duration: (json['duration'] as num).toInt(),
      key: json['key'] as String?,
      enabled: json['enabled'] as bool? ?? true,
    );

Map<String, dynamic> _$CacheConfigToJson(CacheConfig instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      if (instance.key case final value?) 'key': value,
      'enabled': instance.enabled,
    };

WebViewConfig _$WebViewConfigFromJson(Map<String, dynamic> json) =>
    WebViewConfig(
      url: json['url'] as String,
      showNavigationBar: json['show_navigation_bar'] as bool? ?? true,
      userAgent: json['user_agent'] as String?,
      javascriptEnabled: json['javascript_enabled'] as bool? ?? true,
    );

Map<String, dynamic> _$WebViewConfigToJson(WebViewConfig instance) =>
    <String, dynamic>{
      'url': instance.url,
      'show_navigation_bar': instance.showNavigationBar,
      if (instance.userAgent case final value?) 'user_agent': value,
      'javascript_enabled': instance.javascriptEnabled,
    };

FormConfig _$FormConfigFromJson(Map<String, dynamic> json) => FormConfig(
      fields: (json['fields'] as List<dynamic>)
          .map((e) => FormFieldConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      submitEndpoint: json['submit_endpoint'] as String,
      submitMethod: json['submit_method'] as String? ?? 'POST',
      validationRules: json['validation_rules'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$FormConfigToJson(FormConfig instance) =>
    <String, dynamic>{
      'fields': instance.fields.map((e) => e.toJson()).toList(),
      'submit_endpoint': instance.submitEndpoint,
      'submit_method': instance.submitMethod,
      if (instance.validationRules case final value?) 'validation_rules': value,
    };

FormFieldConfig _$FormFieldConfigFromJson(Map<String, dynamic> json) =>
    FormFieldConfig(
      name: json['name'] as String,
      type: json['type'] as String,
      label: json['label'] as String,
      required: json['required'] as bool? ?? false,
      defaultValue: json['default_value'],
      properties: json['properties'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$FormFieldConfigToJson(FormFieldConfig instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'label': instance.label,
      'required': instance.required,
      if (instance.defaultValue case final value?) 'default_value': value,
      if (instance.properties case final value?) 'properties': value,
    };
