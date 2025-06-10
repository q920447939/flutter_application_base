# StorageService 同步存储使用指南

## 概述

StorageService 现在支持同步存储操作，特别适用于需要立即获取数据的场景，如认证中间件、路由守卫等。

## 设计特点

### 1. 扩展性
- 实现了 `ISyncStorage` 接口，支持扩展
- 支持多种缓存策略：内存、持久化、混合
- 可以轻松添加新的存储策略

### 2. 复用性
- 提供通用的同步存储接口
- 支持不同数据类型的同步操作
- 可在多个组件中复用

### 3. 抽象性
- 使用接口抽象存储操作
- 策略模式支持不同的缓存策略
- 模板方法模式统一操作流程

### 4. 设计模式
- **单例模式**: StorageService 使用单例确保全局唯一
- **策略模式**: 支持不同的缓存策略
- **接口隔离**: ISyncStorage 接口分离同步操作

## 缓存策略

### CacheStrategy.memory
- 数据仅存储在内存中
- 适用于敏感数据，如 Token
- 应用重启后数据丢失

### CacheStrategy.persistent
- 数据存储在持久化存储中
- 适用于应用设置等需要持久化的数据
- 应用重启后数据保留

### CacheStrategy.hybrid
- 数据同时存储在内存和持久化存储中
- 读取时优先从内存获取，提高性能
- 适用于用户信息等需要快速访问的数据

## 基本使用

### 1. 同步Token操作

```dart
final storage = StorageService.instance;

// 设置Token
storage.setTokenSync('your_token_here');

// 获取Token
final token = storage.getTokenSync();

// 检查Token是否存在
final hasToken = storage.hasTokenSync();

// 清除Token
storage.clearTokenSync();
```

### 2. 同步用户信息操作

```dart
final userInfo = {
  'id': 123,
  'name': 'John Doe',
  'email': 'john@example.com',
};

// 设置用户信息
storage.setUserInfoSync(userInfo);

// 获取用户信息
final retrievedUserInfo = storage.getUserInfoSync();

// 清除用户信息
storage.clearUserInfoSync();
```

### 3. 通用同步操作

```dart
// 设置字符串
storage.setStringSync('key', 'value');

// 获取字符串
final value = storage.getStringSync('key');

// 检查键是否存在
final exists = storage.containsKeySync('key');

// 删除键值对
storage.removeSync('key');
```

## 高级使用

### 1. 自定义缓存策略

```dart
// 为特定键设置缓存策略
storage.setCacheStrategy('sensitive_data', CacheStrategy.memory);
storage.setCacheStrategy('user_preference', CacheStrategy.persistent);
storage.setCacheStrategy('user_profile', CacheStrategy.hybrid);

// 获取缓存策略
final strategy = storage.getCacheStrategy('sensitive_data');
```

### 2. 内存缓存管理

```dart
// 手动更新内存缓存
storage.updateMemoryCache('key', 'new_value');

// 清除所有内存缓存
storage.clearMemoryCache();
```

## 认证中间件集成

### 1. 使用默认Token策略

```dart
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final token = StorageService.instance.getTokenSync();
    if (token == null || token.isEmpty) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}
```

### 2. 使用策略模式

```dart
// 创建自定义认证策略
class CustomAuthStrategy implements IAuthStrategy {
  @override
  bool isAuthenticated() {
    final storage = StorageService.instance;
    final token = storage.getTokenSync();
    final userInfo = storage.getUserInfoSync();
    
    return token != null && 
           token.isNotEmpty && 
           userInfo != null &&
           _isTokenValid(token);
  }
  
  @override
  String getRedirectRoute() => '/custom-login';
  
  bool _isTokenValid(String token) {
    // 自定义Token验证逻辑
    return token.length > 10;
  }
}

// 使用自定义策略
final middleware = AuthMiddleware(
  authStrategy: CustomAuthStrategy(),
);
```

## 最佳实践

### 1. 敏感数据处理
```dart
// 敏感数据使用内存缓存策略
storage.setCacheStrategy('user_token', CacheStrategy.memory);
storage.setCacheStrategy('refresh_token', CacheStrategy.memory);
```

### 2. 异步同步配合
```dart
// 异步设置后自动更新内存缓存
await storage.setToken('new_token');
// 内存缓存已自动更新，可以立即同步获取
final token = storage.getTokenSync();
```

### 3. 错误处理
```dart
try {
  final userInfo = storage.getUserInfoSync();
  if (userInfo != null) {
    // 处理用户信息
  }
} catch (e) {
  // 处理JSON解析错误等异常
  print('获取用户信息失败: $e');
}
```

### 4. 性能优化
```dart
// 预加载关键数据在应用启动时完成
// 这在 StorageService.initialize() 中自动完成

// 使用混合策略平衡性能和持久化
storage.setCacheStrategy('frequently_accessed_data', CacheStrategy.hybrid);
```

## 注意事项

1. **内存缓存限制**: 内存缓存在应用重启后会丢失
2. **同步操作限制**: SharedPreferences 的写操作本质上是异步的
3. **JSON序列化**: 复杂对象需要正确的JSON序列化/反序列化
4. **线程安全**: 内存缓存操作是线程安全的
5. **缓存一致性**: 异步操作会自动同步内存缓存状态

## 扩展示例

### 创建自定义存储策略

```dart
class EncryptedSyncStorage implements ISyncStorage {
  final StorageService _baseStorage;
  final EncryptionService _encryption;
  
  EncryptedSyncStorage(this._baseStorage, this._encryption);
  
  @override
  String? getStringSync(String key) {
    final encrypted = _baseStorage.getStringSync(key);
    return encrypted != null ? _encryption.decrypt(encrypted) : null;
  }
  
  @override
  bool setStringSync(String key, String value) {
    final encrypted = _encryption.encrypt(value);
    return _baseStorage.setStringSync(key, encrypted);
  }
  
  // ... 其他方法实现
}
```

这个设计充分体现了扩展性、复用性、抽象性和设计模式的应用，为Flutter应用提供了强大而灵活的同步存储解决方案。
