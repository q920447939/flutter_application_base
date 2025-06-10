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
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RouteConfigResponseToJson(
        RouteConfigResponse instance) =>
    <String, dynamic>{
      'routes': instance.routes,
      'version': instance.version,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

RouteConfig _$RouteConfigFromJson(Map<String, dynamic> json) => RouteConfig(
      path: json['path'] as String,
      name: json['name'] as String,
      pageType: $enumDecode(_$PageTypeEnumMap, json['pageType']),
      title: json['title'] as String?,
      pageConfig: json['pageConfig'] == null
          ? null
          : PageConfig.fromJson(json['pageConfig'] as Map<String, dynamic>),
      requiresAuth: json['requiresAuth'] as bool? ?? false,
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      parameters: json['parameters'] as Map<String, dynamic>?,
      enabled: json['enabled'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
    );

Map<String, dynamic> _$RouteConfigToJson(RouteConfig instance) =>
    <String, dynamic>{
      'path': instance.path,
      'name': instance.name,
      'pageType': _$PageTypeEnumMap[instance.pageType]!,
      'title': instance.title,
      'pageConfig': instance.pageConfig,
      'requiresAuth': instance.requiresAuth,
      'permissions': instance.permissions,
      'parameters': instance.parameters,
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
      componentName: json['componentName'] as String?,
      layout: json['layout'] == null
          ? null
          : LayoutConfig.fromJson(json['layout'] as Map<String, dynamic>),
      dataSource: json['dataSource'] == null
          ? null
          : DataSourceConfig.fromJson(
              json['dataSource'] as Map<String, dynamic>),
      webView: json['webView'] == null
          ? null
          : WebViewConfig.fromJson(json['webView'] as Map<String, dynamic>),
      form: json['form'] == null
          ? null
          : FormConfig.fromJson(json['form'] as Map<String, dynamic>),
      customStyles: json['customStyles'] as Map<String, dynamic>?,
      extensions: json['extensions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PageConfigToJson(PageConfig instance) =>
    <String, dynamic>{
      'componentName': instance.componentName,
      'layout': instance.layout,
      'dataSource': instance.dataSource,
      'webView': instance.webView,
      'form': instance.form,
      'customStyles': instance.customStyles,
      'extensions': instance.extensions,
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
      'components': instance.components,
      'parameters': instance.parameters,
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
      'children': instance.children,
      'events': instance.events,
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
      'parameters': instance.parameters,
      'headers': instance.headers,
      'transform': instance.transform,
      'cache': instance.cache,
    };

DataTransformConfig _$DataTransformConfigFromJson(
        Map<String, dynamic> json) =>
    DataTransformConfig(
      dataPath: json['dataPath'] as String?,
      fieldMapping: (json['fieldMapping'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      filters: json['filters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$DataTransformConfigToJson(
        DataTransformConfig instance) =>
    <String, dynamic>{
      'dataPath': instance.dataPath,
      'fieldMapping': instance.fieldMapping,
      'filters': instance.filters,
    };

CacheConfig _$CacheConfigFromJson(Map<String, dynamic> json) => CacheConfig(
      duration: json['duration'] as int,
      key: json['key'] as String?,
      enabled: json['enabled'] as bool? ?? true,
    );

Map<String, dynamic> _$CacheConfigToJson(CacheConfig instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'key': instance.key,
      'enabled': instance.enabled,
    };

WebViewConfig _$WebViewConfigFromJson(Map<String, dynamic> json) =>
    WebViewConfig(
      url: json['url'] as String,
      showNavigationBar: json['showNavigationBar'] as bool? ?? true,
      userAgent: json['userAgent'] as String?,
      javascriptEnabled: json['javascriptEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$WebViewConfigToJson(WebViewConfig instance) =>
    <String, dynamic>{
      'url': instance.url,
      'showNavigationBar': instance.showNavigationBar,
      'userAgent': instance.userAgent,
      'javascriptEnabled': instance.javascriptEnabled,
    };

FormConfig _$FormConfigFromJson(Map<String, dynamic> json) => FormConfig(
      fields: (json['fields'] as List<dynamic>)
          .map((e) => FormFieldConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      submitEndpoint: json['submitEndpoint'] as String,
      submitMethod: json['submitMethod'] as String? ?? 'POST',
      validationRules: json['validationRules'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$FormConfigToJson(FormConfig instance) =>
    <String, dynamic>{
      'fields': instance.fields,
      'submitEndpoint': instance.submitEndpoint,
      'submitMethod': instance.submitMethod,
      'validationRules': instance.validationRules,
    };

FormFieldConfig _$FormFieldConfigFromJson(Map<String, dynamic> json) =>
    FormFieldConfig(
      name: json['name'] as String,
      type: json['type'] as String,
      label: json['label'] as String,
      required: json['required'] as bool? ?? false,
      defaultValue: json['defaultValue'],
      properties: json['properties'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$FormFieldConfigToJson(FormFieldConfig instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'label': instance.label,
      'required': instance.required,
      'defaultValue': instance.defaultValue,
      'properties': instance.properties,
    };

K $enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}
