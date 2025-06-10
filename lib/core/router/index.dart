/// 路由模块导出文件
///
/// 统一导出路由管理相关的所有类和方法
library;

// 核心路由配置
export 'route_config.dart';
export 'route_feature.dart';
export 'app_route_manager.dart';

// 路由构建器
export 'route_builder.dart';

// 路由预设
export 'route_presets.dart';

// 声明式权限配置
export 'declarative_permissions.dart';

// 中间件
export 'middlewares/base_middleware.dart';
export 'middlewares/permission_middleware.dart';
export 'middlewares/analytics_middleware.dart';
export 'middlewares/loading_middleware.dart';

// 功能特性
export 'features/permission_route_feature.dart';
export 'features/analytics_route_feature.dart';
export 'features/loading_route_feature.dart';

// 简化的页面基类
export '../base/simple_page.dart';
