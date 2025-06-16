# Token存储功能说明

## 概述

本认证模块已完全集成Token存储功能，支持自动保存、读取和管理认证Token，确保用户登录状态的持久化。

## 🔑 Token存储架构

### 1. 数据模型

#### LoginResponse（简化响应）
```dart
class LoginResponse {
  final String token;  // JWT Token
  
  String get authorizationHeader => 'Bearer $token';
  bool get hasToken => token.isNotEmpty;
}
```

#### ExtendedAuthResponse（扩展响应）
```dart
class ExtendedAuthResponse {
  final String token;                    // JWT Token
  final Map<String, dynamic>? user;      // 用户信息（可选）
  final List<String>? permissions;       // 权限列表（可选）
  final List<String>? roles;             // 角色列表（可选）
}
```

### 2. 存储层次

```
┌─────────────────────────────────────┐
│           AuthService               │  ← 业务逻辑层
├─────────────────────────────────────┤
│         StorageService              │  ← 存储抽象层
├─────────────────────────────────────┤
│      SharedPreferences              │  ← 本地存储实现
└─────────────────────────────────────┘
```

## 🚀 使用方式

### 1. 登录并自动存储Token

```dart
// 方式1：简单登录（返回bool）
final success = await AuthService.instance.loginWithUsername(
  username: 'testuser',
  password: 'password123',
  captcha: '1234',
  captchaSessionId: 'session-id',
);

if (success) {
  print('登录成功，Token已自动保存');
}

// 方式2：详细登录（返回完整结果）
final result = await AuthService.instance.loginWithUsernameDetailed(
  username: 'testuser',
  password: 'password123',
  captcha: '1234',
  captchaSessionId: 'session-id',
);

if (result.isSuccess) {
  print('Token: ${result.data!.token}');
}
```

### 2. 获取存储的Token

```dart
// 获取当前Token
final token = AuthService.instance.accessToken;

// 获取Authorization头部
final authHeader = AuthService.instance.getAuthorizationHeader();
// 返回: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

// 检查认证状态
final isAuthenticated = AuthService.instance.isAuthenticated;
```

### 3. 自动Token恢复

```dart
// 应用启动时自动恢复Token
await AuthService.instance.initialize();

// 检查是否有有效的Token
if (AuthService.instance.isAuthenticated) {
  print('用户已登录');
} else {
  print('用户未登录');
}
```

### 4. 清除Token

```dart
// 退出登录并清除Token
await AuthService.instance.logout();
```

## 🔧 后端API对接

### 登录接口响应格式

根据您的后端LoginResponseDTO，期望的响应格式：

```json
{
  "code": 0,
  "msg": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0dXNlciIsImlhdCI6MTY0MDk5NTIwMCwiZXhwIjoxNjQwOTk4ODAwfQ.signature"
  }
}
```

### HTTP请求自动添加Token

NetworkService会自动添加Authorization头部：

```dart
// 自动添加到所有需要认证的请求
final response = await NetworkService.instance.get('/api/user/profile');
// 请求头自动包含: Authorization: Bearer <token>
```

## 📱 存储位置

### Android
- 路径: `/data/data/<package_name>/shared_prefs/FlutterSharedPreferences.xml`
- 键名: `flutter.access_token`

### iOS
- 路径: `NSUserDefaults`
- 键名: `flutter.access_token`

### Web
- 路径: `localStorage`
- 键名: `flutter.access_token`

## 🔒 安全考虑

### 1. Token加密存储
```dart
// 可以在StorageService中添加加密逻辑
class StorageService {
  Future<void> setToken(String token) async {
    final encryptedToken = _encrypt(token);  // 加密Token
    await _prefs.setString(_tokenKey, encryptedToken);
  }
}
```

### 2. Token过期处理
```dart
// 检查Token是否需要刷新
if (AuthService.instance.shouldRefreshToken()) {
  await AuthService.instance.refreshToken();
}
```

### 3. 自动清理
```dart
// 应用卸载时自动清理
@override
void dispose() {
  AuthService.instance.logout();
  super.dispose();
}
```

## 🧪 测试功能

运行示例应用测试Token存储：

```bash
flutter run example/main.dart
```

在"认证功能测试"页面中：
1. 点击"测试认证"进行登录
2. 点击"获取Token"查看存储的Token信息
3. 点击"清除Token"测试退出登录
4. 重启应用验证Token持久化

## 📊 监控和调试

### 1. Token状态监控
```dart
// 监听认证状态变化
AuthService.instance.authStatusStream.listen((status) {
  print('认证状态变化: $status');
});
```

### 2. 调试信息
```dart
// 获取详细的Token信息
final tokenInfo = {
  'hasToken': AuthService.instance.accessToken.isNotEmpty,
  'tokenLength': AuthService.instance.accessToken.length,
  'isAuthenticated': AuthService.instance.isAuthenticated,
  'authStatus': AuthService.instance.authStatus.toString(),
};
print('Token调试信息: $tokenInfo');
```

## 🔄 扩展功能

### 1. Refresh Token支持
```dart
// 可以扩展支持refresh token
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
}
```

### 2. 多用户支持
```dart
// 支持多用户Token存储
await StorageService.instance.setToken(token, userId: 'user123');
```

### 3. Token生命周期管理
```dart
// 自动刷新即将过期的Token
class TokenManager {
  Timer? _refreshTimer;
  
  void scheduleTokenRefresh(Duration expiresIn) {
    _refreshTimer = Timer(expiresIn - Duration(minutes: 5), () {
      AuthService.instance.refreshToken();
    });
  }
}
```

Token存储功能已完全集成到认证架构中，提供了完整的Token生命周期管理，确保用户登录状态的可靠性和安全性。
