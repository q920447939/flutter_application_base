/// Flutter Application Base Framework
///
/// 这是 Flutter 应用基础框架的主要导出文件
/// 提供了完整的模块化架构和核心功能
library flutter_application_base;

// 核心应用模块
export 'core/app/framework_module_manager.dart';
export 'core/app/framework_module.dart';

// 模块注册器
export 'core/modules/module_registry.dart';

// 基础页面类
export 'core/base/index.dart';

// 路由系统
export 'core/router/index.dart';

// 网络服务
export 'core/network/index.dart';

// 权限管理
export 'core/permissions/index.dart';

// 配置管理
export 'core/config/index.dart';

// 本地化
export 'core/localization/index.dart';

// 安全服务
export 'core/security/index.dart';

// 状态管理
export 'core/state/base_controller.dart';

// 验证框架
export 'core/validation/index.dart';

// 功能模块
export 'features/auth/index.dart';

// UI 组件
export 'ui/index.dart';

// 通用组件
export 'component/no_data.dart';
