# 通用认证模块

基于您的设计需求，我们实现了一个通用的登录认证模块，支持多种认证方式和扩展性设计。

## 🎯 核心特性

- **策略模式**：支持多种认证类型（用户名密码、手机号、邮箱等）
- **验证码集成**：完整的验证码获取、刷新、验证流程
- **设备信息收集**：自动收集设备信息和客户端IP
- **配置驱动**：支持动态配置认证端点和参数
- **高度复用**：充分利用现有的NetworkService和StorageService
- **向后兼容**：保持与现有代码的兼容性

## 📁 模块结构

```
lib/features/auth/
├── models/                    # 数据模型
│   ├── auth_enums.dart       # 认证相关枚举
│   ├── auth_request.dart     # 认证请求模型
│   ├── captcha_model.dart    # 验证码模型
│   ├── common_result.dart    # 通用响应模型
│   └── user_model.dart       # 用户模型（已存在）
├── services/                  # 服务层
│   ├── auth_service.dart     # 认证服务（重构）
│   ├── auth_manager.dart     # 认证管理器
│   ├── captcha_service.dart  # 验证码服务
│   ├── device_info_service.dart # 设备信息服务
│   └── auth_service_initializer.dart # 服务初始化器
├── strategies/               # 认证策略
│   ├── auth_strategy.dart    # 策略接口
│   └── username_password_auth_strategy.dart # 用户名密码策略
├── config/                   # 配置管理
│   └── auth_config.dart      # 认证配置
├── controllers/              # 控制器
│   ├── auth_controller.dart  # 原有控制器
│   └── enhanced_login_controller.dart # 增强版控制器
└── pages/                    # 页面
    ├── login_page.dart       # 原有登录页
    ├── register_page.dart    # 原有注册页
    └── enhanced_login_page.dart # 增强版登录页
```

## 🚀 快速开始

### 1. 初始化认证服务

```dart
import 'package:flutter_application_base/features/auth/services/auth_service_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化认证服务
  await AuthServiceInitializer.initialize();
  
  runApp(MyApp());
}
```

### 2. 使用增强版登录

```dart
// 导航到增强版登录页面
Get.toNamed('/enhanced-login');

// 或者直接使用控制器
final controller = Get.put(EnhancedLoginController());
await controller.loginWithUsername();
```

### 3. 使用认证管理器

```dart
import 'package:flutter_application_base/features/auth/index.dart';

// 用户名密码认证
final result = await AuthManager.instance.authenticateWithUsername(
  username: 'testuser',
  password: 'password123',
  captcha: '1234',
  captchaSessionId: 'session-id',
);

if (result.isSuccess) {
  print('登录成功');
} else {
  print('登录失败: ${result.msg}');
}
```

## 🔧 API 接口对接

### 后端接口格式

本模块设计匹配您的Spring Boot后端接口：

```
POST /api/auth/login/username
Content-Type: application/json

{
  "username": "testuser",
  "password": "password123",
  "captcha": "1234",
  "captchaSessionId": "session-id-123",
  "authType": "USERNAME_PASSWORD",
  "deviceInfo": "Flutter/Android/1.0.0",
  "clientIp": "192.168.1.100",
  "context": {
    "tenantId": "tenant-001",
    "platform": "Android",
    "timestamp": 1640995200000
  }
}
```

### 响应格式

```json
{
  "code": 0,
  "msg": "登录成功",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh-token-here",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "id": "user-123",
      "username": "testuser",
      "email": "test@example.com",
      "nickname": "测试用户",
      "avatar": "https://example.com/avatar.jpg"
    }
  }
}
```

## 🎨 验证码功能

### 获取验证码

```dart
final result = await CaptchaService.instance.getCaptcha();
if (result.isSuccess) {
  final captcha = result.data!;
  print('验证码会话ID: ${captcha.sessionId}');
  print('验证码图片: ${captcha.imageDataUrl}');
}
```

### 刷新验证码

```dart
await CaptchaService.instance.refreshCaptcha(sessionId: 'session-id');
```

## 🔌 扩展新的认证策略

### 1. 创建认证策略

```dart
class PhoneCodeAuthStrategy extends BaseAuthStrategy {
  @override
  AuthTypeEnum get authType => AuthTypeEnum.phoneCode;
  
  @override
  String get endpoint => '/api/auth/login/phone-code';
  
  @override
  Future<CommonResult<AuthResponse>> authenticate(BaseAuthRequest request) async {
    // 实现手机验证码认证逻辑
  }
}
```

### 2. 注册策略

```dart
AuthManager.instance.registerStrategy(PhoneCodeAuthStrategy());
```

## ⚙️ 配置管理

### 动态配置端点

```dart
final configManager = AuthConfigManager.instance;

// 更新认证端点
configManager.setConfigValue('auth_endpoint_USERNAME_PASSWORD', '/api/v2/auth/login/username');

// 更新验证码过期时间
configManager.setConfigValue('captcha_expiry_minutes', 10);
```

## 🧪 测试和演示

运行示例应用来测试新的认证功能：

```bash
flutter run example/main.dart
```

在示例应用中，您可以：
1. 查看声明式权限配置演示
2. 测试增强版登录功能
3. 查看验证码获取和刷新
4. 测试设备信息收集

## 📊 监控和统计

### 获取认证统计

```dart
final stats = AuthManager.instance.getAuthStatistics();
print('认证尝试次数: ${stats['attempts']}');
print('认证成功次数: ${stats['successes']}');
print('认证失败次数: ${stats['failures']}');

// 获取成功率
final successRate = AuthManager.instance.getAuthSuccessRate(AuthTypeEnum.usernamePassword);
print('用户名密码认证成功率: ${(successRate * 100).toStringAsFixed(2)}%');
```

## 🔒 安全考虑

1. **验证码保护**：防止暴力破解
2. **设备信息收集**：用于异常登录检测
3. **Token管理**：自动刷新和过期处理
4. **错误处理**：统一的错误码和消息

## 🚧 后续扩展

1. **多因子认证(MFA)**：短信验证码、邮箱验证码
2. **第三方认证**：OAuth2.0、微信、支付宝
3. **生物识别**：指纹、面部识别
4. **安全增强**：请求签名、防重放攻击

## 📝 注意事项

1. 确保后端接口格式匹配
2. 配置正确的API基础URL
3. 处理网络异常和超时
4. 适当的错误提示和用户引导
5. 遵循数据保护和隐私法规
