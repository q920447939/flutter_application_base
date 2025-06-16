/// 认证模块统一导出文件
///
/// 统一导出认证相关的所有类和方法
library;

// 模型类
export 'models/user_model.dart';
export 'models/auth_enums.dart';
export 'models/auth_request.dart';
export 'models/captcha_model.dart';
export 'models/common_result.dart';
export 'models/login_response.dart';

// 服务类
export 'services/auth_service.dart';
export 'services/auth_manager.dart';
export 'services/captcha_service.dart';
export 'services/device_info_service.dart';

// 策略类
export 'strategies/auth_strategy.dart';
export 'strategies/username_password_auth_strategy.dart';

// 验证器
export 'validators/auth_request_validator.dart';

// 配置类
export 'config/auth_config.dart';

// 控制器
export 'controllers/auth_controller.dart';

// 服务初始化器
export 'services/auth_service_initializer.dart';

// 页面
export 'pages/login_page.dart';
export 'pages/register_page.dart';
