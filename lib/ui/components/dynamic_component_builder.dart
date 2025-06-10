/// 动态组件构建器
///
/// 根据配置动态构建Flutter组件
library;

import 'package:flutter/material.dart';
import '../../core/router/models/route_config.dart';

/// 动态组件构建器
class DynamicComponentBuilder {
  /// 构建布局
  static Widget buildLayout(
    LayoutConfig layout, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? customStyles,
  }) {
    switch (layout.type) {
      case LayoutType.column:
        return _buildColumn(layout, data, arguments, customStyles);
      case LayoutType.row:
        return _buildRow(layout, data, arguments, customStyles);
      case LayoutType.stack:
        return _buildStack(layout, data, arguments, customStyles);
      case LayoutType.grid:
        return _buildGrid(layout, data, arguments, customStyles);
      case LayoutType.list:
        return _buildList(layout, data, arguments, customStyles);
      case LayoutType.custom:
        return _buildCustom(layout, data, arguments, customStyles);
      default:
        return _buildColumn(layout, data, arguments, customStyles);
    }
  }

  /// 构建列布局
  static Widget _buildColumn(
    LayoutConfig layout,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? customStyles,
  ) {
    final children = layout.components
        .map((component) => buildComponent(component, data, arguments, customStyles))
        .toList();

    final parameters = layout.parameters ?? {};
    
    return SingleChildScrollView(
      padding: _parseEdgeInsets(parameters['padding']),
      child: Column(
        mainAxisAlignment: _parseMainAxisAlignment(parameters['mainAxisAlignment']),
        crossAxisAlignment: _parseCrossAxisAlignment(parameters['crossAxisAlignment']),
        children: children,
      ),
    );
  }

  /// 构建行布局
  static Widget _buildRow(
    LayoutConfig layout,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? customStyles,
  ) {
    final children = layout.components
        .map((component) => buildComponent(component, data, arguments, customStyles))
        .toList();

    final parameters = layout.parameters ?? {};
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: _parseEdgeInsets(parameters['padding']),
      child: Row(
        mainAxisAlignment: _parseMainAxisAlignment(parameters['mainAxisAlignment']),
        crossAxisAlignment: _parseCrossAxisAlignment(parameters['crossAxisAlignment']),
        children: children,
      ),
    );
  }

  /// 构建堆叠布局
  static Widget _buildStack(
    LayoutConfig layout,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? customStyles,
  ) {
    final children = layout.components
        .map((component) => buildComponent(component, data, arguments, customStyles))
        .toList();

    return Stack(
      children: children,
    );
  }

  /// 构建网格布局
  static Widget _buildGrid(
    LayoutConfig layout,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? customStyles,
  ) {
    final children = layout.components
        .map((component) => buildComponent(component, data, arguments, customStyles))
        .toList();

    final parameters = layout.parameters ?? {};
    final crossAxisCount = parameters['crossAxisCount'] as int? ?? 2;
    final childAspectRatio = (parameters['childAspectRatio'] as num?)?.toDouble() ?? 1.0;
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      padding: _parseEdgeInsets(parameters['padding']),
      children: children,
    );
  }

  /// 构建列表布局
  static Widget _buildList(
    LayoutConfig layout,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? customStyles,
  ) {
    final children = layout.components
        .map((component) => buildComponent(component, data, arguments, customStyles))
        .toList();

    return ListView(
      padding: _parseEdgeInsets(layout.parameters?['padding']),
      children: children,
    );
  }

  /// 构建自定义布局
  static Widget _buildCustom(
    LayoutConfig layout,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? customStyles,
  ) {
    // 自定义布局的实现可以根据具体需求扩展
    return _buildColumn(layout, data, arguments, customStyles);
  }

  /// 构建组件
  static Widget buildComponent(
    ComponentConfig component,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? customStyles,
  ) {
    switch (component.type.toLowerCase()) {
      case 'text':
        return _buildText(component, data, arguments, customStyles);
      case 'image':
        return _buildImage(component, data, arguments, customStyles);
      case 'button':
        return _buildButton(component, data, arguments, customStyles);
      case 'card':
        return _buildCard(component, data, arguments, customStyles);
      case 'container':
        return _buildContainer(component, data, arguments, customStyles);
      case 'divider':
        return _buildDivider(component, data, arguments, customStyles);
      case 'spacer':
        return _buildSpacer(component, data, arguments, customStyles);
      case 'icon':
        return _buildIcon(component, data, arguments, customStyles);
      default:
        return _buildUnknownComponent(component);
    }
  }

  /// 构建文本组件
  static Widget _buildText(
    ComponentConfig component,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? customStyles,
  ) {
    final properties = component.properties;
    final text = _resolveValue(properties['text'], data, arguments)?.toString() ?? '';
    
    return Text(
      text,
      style: _parseTextStyle(properties['style']),
      textAlign: _parseTextAlign(properties['textAlign']),
      maxLines: properties['maxLines'] as int?,
      overflow: _parseTextOverflow(properties['overflow']),
    );
  }

  /// 构建图片组件
  static Widget _buildImage(
    ComponentConfig component,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? customStyles,
  ) {
    final properties = component.properties;
    final src = _resolveValue(properties['src'], data, arguments)?.toString();
    
    if (src == null || src.isEmpty) {
      return const Icon(Icons.image_not_supported, size: 100);
    }

    final width = (properties['width'] as num?)?.toDouble();
    final height = (properties['height'] as num?)?.toDouble();
    final fit = _parseBoxFit(properties['fit']);

    if (src.startsWith('http')) {
      return Image.network(
        src,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 100);
        },
      );
    } else {
      return Image.asset(
        src,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 100);
        },
      );
    }
  }

  /// 构建按钮组件
  static Widget _buildButton(
    ComponentConfig component,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? customStyles,
  ) {
    final properties = component.properties;
    final text = _resolveValue(properties['text'], data, arguments)?.toString() ?? '';
    final type = properties['type']?.toString() ?? 'elevated';
    
    VoidCallback? onPressed;
    if (component.events?['onPressed'] != null) {
      onPressed = () {
        // 处理按钮点击事件
        _handleEvent(component.events!['onPressed'], data, arguments);
      };
    }

    switch (type.toLowerCase()) {
      case 'elevated':
        return ElevatedButton(
          onPressed: onPressed,
          child: Text(text),
        );
      case 'outlined':
        return OutlinedButton(
          onPressed: onPressed,
          child: Text(text),
        );
      case 'text':
        return TextButton(
          onPressed: onPressed,
          child: Text(text),
        );
      default:
        return ElevatedButton(
          onPressed: onPressed,
          child: Text(text),
        );
    }
  }

  /// 构建卡片组件
  static Widget _buildCard(
    ComponentConfig component,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? customStyles,
  ) {
    final children = component.children
        ?.map((child) => buildComponent(child, data, arguments, customStyles))
        .toList() ?? [];

    return Card(
      margin: _parseEdgeInsets(component.properties['margin']),
      child: Padding(
        padding: _parseEdgeInsets(component.properties['padding']) ?? 
                 const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  /// 构建容器组件
  static Widget _buildContainer(
    ComponentConfig component,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? customStyles,
  ) {
    final properties = component.properties;
    final children = component.children
        ?.map((child) => buildComponent(child, data, arguments, customStyles))
        .toList() ?? [];

    Widget child;
    if (children.length == 1) {
      child = children.first;
    } else if (children.length > 1) {
      child = Column(children: children);
    } else {
      child = const SizedBox.shrink();
    }

    return Container(
      width: (properties['width'] as num?)?.toDouble(),
      height: (properties['height'] as num?)?.toDouble(),
      padding: _parseEdgeInsets(properties['padding']),
      margin: _parseEdgeInsets(properties['margin']),
      decoration: _parseBoxDecoration(properties['decoration']),
      child: child,
    );
  }

  /// 构建分割线组件
  static Widget _buildDivider(
    ComponentConfig component,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? customStyles,
  ) {
    final properties = component.properties;
    final height = (properties['height'] as num?)?.toDouble();
    final thickness = (properties['thickness'] as num?)?.toDouble();
    final color = _parseColor(properties['color']);

    return Divider(
      height: height,
      thickness: thickness,
      color: color,
    );
  }

  /// 构建间距组件
  static Widget _buildSpacer(
    ComponentConfig component,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? customStyles,
  ) {
    final properties = component.properties;
    final height = (properties['height'] as num?)?.toDouble() ?? 16;
    final width = (properties['width'] as num?)?.toDouble() ?? 16;

    return SizedBox(height: height, width: width);
  }

  /// 构建图标组件
  static Widget _buildIcon(
    ComponentConfig component,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? customStyles,
  ) {
    final properties = component.properties;
    final iconName = properties['icon']?.toString();
    final size = (properties['size'] as num?)?.toDouble();
    final color = _parseColor(properties['color']);

    IconData? iconData;
    if (iconName != null) {
      iconData = _parseIconData(iconName);
    }

    return Icon(
      iconData ?? Icons.help_outline,
      size: size,
      color: color,
    );
  }

  /// 构建未知组件
  static Widget _buildUnknownComponent(ComponentConfig component) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '未知组件: ${component.type}',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  // 辅助方法
  static dynamic _resolveValue(
    dynamic value,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
  ) {
    if (value is String && value.startsWith('{{') && value.endsWith('}}')) {
      // 解析模板变量
      final key = value.substring(2, value.length - 2).trim();
      return data?[key] ?? arguments?[key] ?? value;
    }
    return value;
  }

  static void _handleEvent(
    dynamic event,
    Map<String, dynamic>? data,
    Map<String, dynamic>? arguments,
  ) {
    // 处理事件的实现
    // 可以根据事件类型执行不同的操作，如导航、API调用等
    print('处理事件: $event');
  }

  // 样式解析方法
  static EdgeInsets? _parseEdgeInsets(dynamic value) {
    if (value == null) return null;
    if (value is num) return EdgeInsets.all(value.toDouble());
    if (value is Map<String, dynamic>) {
      return EdgeInsets.fromLTRB(
        (value['left'] as num?)?.toDouble() ?? 0,
        (value['top'] as num?)?.toDouble() ?? 0,
        (value['right'] as num?)?.toDouble() ?? 0,
        (value['bottom'] as num?)?.toDouble() ?? 0,
      );
    }
    return null;
  }

  static MainAxisAlignment _parseMainAxisAlignment(dynamic value) {
    switch (value?.toString()) {
      case 'start': return MainAxisAlignment.start;
      case 'end': return MainAxisAlignment.end;
      case 'center': return MainAxisAlignment.center;
      case 'spaceBetween': return MainAxisAlignment.spaceBetween;
      case 'spaceAround': return MainAxisAlignment.spaceAround;
      case 'spaceEvenly': return MainAxisAlignment.spaceEvenly;
      default: return MainAxisAlignment.start;
    }
  }

  static CrossAxisAlignment _parseCrossAxisAlignment(dynamic value) {
    switch (value?.toString()) {
      case 'start': return CrossAxisAlignment.start;
      case 'end': return CrossAxisAlignment.end;
      case 'center': return CrossAxisAlignment.center;
      case 'stretch': return CrossAxisAlignment.stretch;
      case 'baseline': return CrossAxisAlignment.baseline;
      default: return CrossAxisAlignment.start;
    }
  }

  static TextStyle? _parseTextStyle(dynamic value) {
    if (value is! Map<String, dynamic>) return null;
    
    return TextStyle(
      fontSize: (value['fontSize'] as num?)?.toDouble(),
      fontWeight: _parseFontWeight(value['fontWeight']),
      color: _parseColor(value['color']),
      fontStyle: value['italic'] == true ? FontStyle.italic : null,
    );
  }

  static FontWeight? _parseFontWeight(dynamic value) {
    switch (value?.toString()) {
      case 'bold': return FontWeight.bold;
      case 'normal': return FontWeight.normal;
      case '100': return FontWeight.w100;
      case '200': return FontWeight.w200;
      case '300': return FontWeight.w300;
      case '400': return FontWeight.w400;
      case '500': return FontWeight.w500;
      case '600': return FontWeight.w600;
      case '700': return FontWeight.w700;
      case '800': return FontWeight.w800;
      case '900': return FontWeight.w900;
      default: return null;
    }
  }

  static TextAlign? _parseTextAlign(dynamic value) {
    switch (value?.toString()) {
      case 'left': return TextAlign.left;
      case 'right': return TextAlign.right;
      case 'center': return TextAlign.center;
      case 'justify': return TextAlign.justify;
      case 'start': return TextAlign.start;
      case 'end': return TextAlign.end;
      default: return null;
    }
  }

  static TextOverflow? _parseTextOverflow(dynamic value) {
    switch (value?.toString()) {
      case 'clip': return TextOverflow.clip;
      case 'fade': return TextOverflow.fade;
      case 'ellipsis': return TextOverflow.ellipsis;
      case 'visible': return TextOverflow.visible;
      default: return null;
    }
  }

  static BoxFit? _parseBoxFit(dynamic value) {
    switch (value?.toString()) {
      case 'fill': return BoxFit.fill;
      case 'contain': return BoxFit.contain;
      case 'cover': return BoxFit.cover;
      case 'fitWidth': return BoxFit.fitWidth;
      case 'fitHeight': return BoxFit.fitHeight;
      case 'none': return BoxFit.none;
      case 'scaleDown': return BoxFit.scaleDown;
      default: return null;
    }
  }

  static Color? _parseColor(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      if (value.startsWith('#')) {
        return Color(int.parse(value.substring(1), radix: 16) + 0xFF000000);
      }
      // 可以添加更多颜色解析逻辑
    }
    return null;
  }

  static BoxDecoration? _parseBoxDecoration(dynamic value) {
    if (value is! Map<String, dynamic>) return null;
    
    return BoxDecoration(
      color: _parseColor(value['color']),
      borderRadius: value['borderRadius'] != null 
          ? BorderRadius.circular((value['borderRadius'] as num).toDouble())
          : null,
      border: value['border'] != null 
          ? Border.all(
              color: _parseColor(value['border']['color']) ?? Colors.grey,
              width: (value['border']['width'] as num?)?.toDouble() ?? 1,
            )
          : null,
    );
  }

  static IconData? _parseIconData(String iconName) {
    // 这里可以添加图标名称到IconData的映射
    switch (iconName.toLowerCase()) {
      case 'home': return Icons.home;
      case 'person': return Icons.person;
      case 'settings': return Icons.settings;
      case 'search': return Icons.search;
      case 'favorite': return Icons.favorite;
      case 'star': return Icons.star;
      case 'add': return Icons.add;
      case 'edit': return Icons.edit;
      case 'delete': return Icons.delete;
      case 'share': return Icons.share;
      default: return Icons.help_outline;
    }
  }
}
