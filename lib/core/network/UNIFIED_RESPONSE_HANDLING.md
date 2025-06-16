# 统一响应处理机制

## 概述

本文档介绍了统一响应处理机制的设计和使用方法，解决了您提出的重要问题：**避免在每个服务中重复编写HTTP状态码判断逻辑**。

## 🎯 解决的问题

### ❌ 旧方式的问题
```dart
// 每个服务都要重复写这些逻辑
if (response.statusCode == 200) {
  final result = CommonResult<T>.fromJson(response.data, fromJson);
  if (result.isSuccess) {
    return result;
  } else {
    return CommonResult.failure(code: result.code, msg: result.msg);
  }
} else {
  return CommonResult.failure(
    code: response.statusCode ?? -1,
    msg: 'HTTP错误: ${response.statusCode}',
  );
}
```

### ✅ 新方式的优势
```dart
// 一行代码搞定所有响应处理
final result = await NetworkService.instance.postCommonResult<T>(
  endpoint,
  data: requestData,
  fromJson: (json) => T.fromJson(json),
);
```

## 🏗️ 架构设计

```
┌─────────────────────────────────────┐
│           Service Layer             │  ← 业务服务层
├─────────────────────────────────────┤
│         NetworkService              │  ← 网络服务层
├─────────────────────────────────────┤
│      CommonResultHandler            │  ← 统一响应处理器
├─────────────────────────────────────┤
│         ResponseHandler             │  ← 响应处理抽象
├─────────────────────────────────────┤
│            Dio/HTTP                 │  ← 底层网络库
└─────────────────────────────────────┘
```

## 📋 核心组件

### 1. ResponseHandler (抽象接口)
```dart
abstract class ResponseHandler {
  Future<T> handleResponse<T>(
    Response response, {
    T Function(Map<String, dynamic>)? fromJson,
    bool expectWrapper = true,
  });

  T handleError<T>(
    ErrorType type,
    dynamic error, {
    Response? response,
    StackTrace? stackTrace,
  });
}
```

### 2. CommonResultHandler (具体实现)
```dart
class CommonResultHandler extends DefaultResponseHandler {
  // 专门处理CommonResult<T>格式的响应
  @override
  Future<CommonResult<T>> handleResponse<T>(...) async {
    // 统一处理HTTP状态码
    // 统一处理业务状态码
    // 统一错误映射
  }
}
```

### 3. ErrorType (错误分类)
```dart
enum ErrorType {
  network,     // 网络错误 (无网络、超时等)
  http,        // HTTP错误 (4xx, 5xx)
  business,    // 业务错误 (code != 0)
  parse,       // 解析错误
  unknown,     // 未知错误
}
```

## 🚀 使用方式

### 1. NetworkService新增方法

```dart
// GET请求 - 返回CommonResult
Future<CommonResult<T>> getCommonResult<T>(
  String path, {
  T Function(Map<String, dynamic>)? fromJson,
  // ... 其他参数
});

// POST请求 - 返回CommonResult
Future<CommonResult<T>> postCommonResult<T>(
  String path, {
  dynamic data,
  T Function(Map<String, dynamic>)? fromJson,
  // ... 其他参数
});

// PUT/DELETE请求同样支持
```

### 2. 服务层使用示例

#### 验证码服务
```dart
// 旧方式 ❌
Future<CommonResult<CaptchaInfo>> getCaptcha() async {
  final response = await NetworkService.instance.get('/api/auth/captcha/generate');
  
  if (response.statusCode == 200) {
    final result = CommonResult<CaptchaInfo>.fromJson(
      response.data,
      (json) => CaptchaInfo.fromJson(json),
    );
    // ... 更多处理逻辑
  } else {
    // ... 错误处理逻辑
  }
}

// 新方式 ✅
Future<CommonResult<CaptchaInfo>> getCaptcha() async {
  return await NetworkService.instance.getCommonResult<Map<String, dynamic>>(
    '/api/auth/captcha/generate',
    fromJson: (json) => json,
  ).then((result) {
    if (result.isSuccess && result.data != null) {
      final captchaInfo = CaptchaInfo.fromJson(result.data!);
      return CommonResult.success(data: captchaInfo);
    }
    return result;
  });
}
```

#### 认证策略
```dart
// 旧方式 ❌
Future<CommonResult<LoginResponse>> authenticate(request) async {
  final response = await NetworkService.instance.post(endpoint, data: request.toJson());
  
  if (response.statusCode == 200) {
    final result = CommonResult<LoginResponse>.fromJson(
      response.data,
      (json) => LoginResponse.fromJson(json),
    );
    return result;
  } else {
    return CommonResult.failure(/* ... */);
  }
}

// 新方式 ✅
Future<CommonResult<LoginResponse>> authenticate(request) async {
  return await NetworkService.instance.postCommonResult<LoginResponse>(
    endpoint,
    data: request.toJson(),
    fromJson: (json) => LoginResponse.fromJson(json),
  );
}
```

## 🔧 错误处理机制

### 1. HTTP状态码映射
```dart
switch (statusCode) {
  case 400: return '请求参数错误';
  case 401: return '未授权访问，请重新登录';
  case 403: return '访问被禁止，权限不足';
  case 404: return '请求的资源不存在';
  case 429: return '请求过于频繁，请稍后重试';
  case 500: return '服务器内部错误';
  // ... 更多映射
}
```

### 2. 网络错误处理
```dart
if (error is DioException) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return '连接超时';
    case DioExceptionType.sendTimeout:
      return '发送超时';
    case DioExceptionType.receiveTimeout:
      return '接收超时';
    // ... 更多处理
  }
}
```

### 3. 业务错误处理
```dart
// 自动检查业务状态码
final code = data['code'] as int;
if (code != 0) {
  return CommonResult.failure(
    code: code,
    msg: data['msg'] ?? '业务处理失败',
  );
}
```

## 📊 使用效果对比

### 代码行数对比
- **旧方式**: 每个服务方法 ~20-30 行
- **新方式**: 每个服务方法 ~5-8 行
- **减少**: 约 70% 的重复代码

### 维护性对比
- **旧方式**: 修改错误处理需要更新所有服务
- **新方式**: 只需要在ResponseHandler中修改一次

### 一致性对比
- **旧方式**: 不同开发者可能写出不同的错误处理逻辑
- **新方式**: 所有服务的错误处理行为完全一致

## 🔄 迁移指南

### 1. 逐步迁移策略
```dart
// 第一步：保留旧方法，添加新方法
class MyService {
  // 旧方法（保持向后兼容）
  Future<CommonResult<T>> oldMethod() async {
    // 原有逻辑
  }
  
  // 新方法（使用统一处理）
  Future<CommonResult<T>> newMethod() async {
    return await NetworkService.instance.postCommonResult<T>(...);
  }
}

// 第二步：逐步替换调用方
// 第三步：删除旧方法
```

### 2. 批量替换模式
```bash
# 查找需要替换的模式
grep -r "if (response.statusCode == 200)" lib/

# 替换为统一处理
# 使用IDE的查找替换功能进行批量替换
```

## 🧪 测试验证

### 1. 单元测试
```dart
test('统一响应处理 - 成功场景', () async {
  final mockResponse = Response(
    data: {'code': 0, 'msg': '成功', 'data': {'id': 1}},
    statusCode: 200,
  );
  
  final result = await CommonResultHandler.instance.handleResponse<TestModel>(
    mockResponse,
    fromJson: (json) => TestModel.fromJson(json),
  );
  
  expect(result.isSuccess, true);
  expect(result.data?.id, 1);
});
```

### 2. 集成测试
```dart
test('验证码服务 - 使用统一处理', () async {
  final result = await CaptchaService.instance.getCaptcha();
  
  // 验证结果格式
  expect(result, isA<CommonResult<CaptchaInfo>>());
  
  if (result.isSuccess) {
    expect(result.data, isNotNull);
    expect(result.data!.sessionId, isNotEmpty);
  }
});
```

## 🔮 扩展功能

### 1. 自定义响应处理器
```dart
class CustomResponseHandler extends DefaultResponseHandler {
  @override
  Future<MyCustomResult<T>> handleResponse<T>(...) async {
    // 自定义处理逻辑
  }
}
```

### 2. 响应拦截器集成
```dart
class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 在这里可以统一预处理所有响应
    final processedResponse = CommonResultHandler.instance.preprocess(response);
    handler.next(processedResponse);
  }
}
```

### 3. 缓存集成
```dart
class CachedResponseHandler extends CommonResultHandler {
  @override
  Future<CommonResult<T>> handleResponse<T>(...) async {
    // 先检查缓存
    final cached = await _checkCache<T>(request);
    if (cached != null) return cached;
    
    // 调用父类处理
    final result = await super.handleResponse<T>(...);
    
    // 缓存结果
    await _cacheResult(request, result);
    
    return result;
  }
}
```

## 📈 性能优化

1. **减少重复代码**: 约70%的代码减少
2. **统一错误处理**: 避免重复的错误处理逻辑
3. **类型安全**: 泛型支持确保类型安全
4. **内存优化**: 减少重复的对象创建

这个统一响应处理机制完全解决了您提出的架构问题，将所有HTTP状态码判断逻辑抽象到统一的地方，大大提升了代码的可维护性、复用性和扩展性！
