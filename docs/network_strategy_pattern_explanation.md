# 网络策略模式详细解释

## 一、策略链模式 (Strategy Chain Pattern)

### 1.1 核心概念

`wrappedRequest()` 是策略链模式的核心实现，它代表一个被策略包装后的请求函数。

### 1.2 工作原理

```dart
// 原始请求函数
Future<Response<T>> Function() originalRequest = () => dio.get('/api/users');

// 第一个策略包装
Future<Response<T>> Function() wrappedRequest1 = () => retryStrategy.apply(options, originalRequest);

// 第二个策略包装
Future<Response<T>> Function() wrappedRequest2 = () => cacheStrategy.apply(options, wrappedRequest1);

// 第三个策略包装
Future<Response<T>> Function() wrappedRequest3 = () => securityStrategy.apply(options, wrappedRequest2);

// 最终执行
final response = await wrappedRequest3();
```

### 1.3 策略应用顺序

```
原始请求 → 重试策略 → 缓存策略 → 安全策略 → 限流策略 → 降级策略
```

## 二、详细执行流程

### 2.1 策略链构建过程

```dart
Future<Response<T>> applyStrategies<T>(
  RequestOptions options,
  Future<Response<T>> Function() request,
) async {
  // 步骤1: 初始化为原始请求
  Future<Response<T>> Function() wrappedRequest = request;
  
  // 步骤2: 逐个应用策略
  for (final strategy in enabledStrategies) {
    final currentRequest = wrappedRequest;  // 保存当前函数引用
    
    // 创建新的包装函数
    wrappedRequest = () => strategy.apply(options, currentRequest);
  }
  
  // 步骤3: 执行最终的包装函数
  return await wrappedRequest();
}
```

### 2.2 具体示例

假设我们有以下策略：RetryStrategy、CacheStrategy、SecurityStrategy

```dart
// 原始请求
Future<Response<String>> originalRequest() async {
  return await dio.get<String>('/api/users');
}

// 应用策略后的执行流程：

// 1. 第一次循环 - 应用 RetryStrategy
wrappedRequest = () => retryStrategy.apply(options, originalRequest);

// 2. 第二次循环 - 应用 CacheStrategy
final temp1 = wrappedRequest; // 保存上一步的函数
wrappedRequest = () => cacheStrategy.apply(options, temp1);

// 3. 第三次循环 - 应用 SecurityStrategy
final temp2 = wrappedRequest; // 保存上一步的函数
wrappedRequest = () => securityStrategy.apply(options, temp2);

// 4. 最终执行
final response = await wrappedRequest();
```

## 三、策略执行顺序的重要性

### 3.1 正确的策略顺序

```
1. SecurityStrategy   - 首先验证安全性
2. RateLimitStrategy  - 然后检查请求频率
3. CacheStrategy      - 接着检查缓存
4. RetryStrategy      - 最后处理重试
5. FallbackStrategy   - 最终降级处理
```

### 3.2 为什么这个顺序很重要

1. **安全策略优先**: 确保所有请求都经过安全验证
2. **限流在缓存前**: 避免缓存绕过限流检查
3. **缓存在重试前**: 避免重试时重复检查缓存
4. **重试在降级前**: 先尝试重试，失败后再降级
5. **降级最后执行**: 作为最后的保障机制

## 四、Response 类型说明

### 4.1 Response 来源

```dart
import 'package:dio/dio.dart';  // Dio 的 Response 类型
import 'package:get/get.dart' hide Response;  // 隐藏 GetX 的 Response 类型
```

### 4.2 Response 类型定义

```dart
// Dio 的 Response 类型
class Response<T> {
  T? data;              // 响应数据
  int? statusCode;      // HTTP状态码
  String? statusMessage; // 状态消息
  Headers headers;      // 响应头
  RequestOptions requestOptions; // 请求选项
  bool isRedirect;      // 是否重定向
  List<RedirectRecord> redirects; // 重定向记录
  Map<String, dynamic> extra; // 额外数据
}
```

## 五、策略模式的优势

### 5.1 可扩展性

```dart
// 添加自定义策略
class CustomLoggingStrategy extends NetworkStrategy {
  @override
  Future<Response<T>> apply<T>(
    RequestOptions options,
    Future<Response<T>> Function() request,
  ) async {
    print('请求开始: ${options.uri}');
    final stopwatch = Stopwatch()..start();
    
    try {
      final response = await request();
      stopwatch.stop();
      print('请求成功: ${options.uri}, 耗时: ${stopwatch.elapsedMilliseconds}ms');
      return response;
    } catch (e) {
      stopwatch.stop();
      print('请求失败: ${options.uri}, 耗时: ${stopwatch.elapsedMilliseconds}ms, 错误: $e');
      rethrow;
    }
  }
}

// 添加到策略工厂
NetworkStrategyFactory.instance.addStrategy(CustomLoggingStrategy());
```

### 5.2 可配置性

```dart
// 根据环境配置不同的策略
if (AppConfig.current.isDevelopment) {
  // 开发环境：启用详细日志，禁用缓存
  factory.addStrategy(DetailedLoggingStrategy(enabled: true));
  factory.getStrategy<CacheStrategy>()?.enabled = false;
} else {
  // 生产环境：禁用日志，启用缓存
  factory.getStrategy<CacheStrategy>()?.enabled = true;
}
```

### 5.3 可测试性

```dart
// 测试时可以 Mock 特定策略
class MockRetryStrategy extends NetworkStrategy {
  @override
  Future<Response<T>> apply<T>(
    RequestOptions options,
    Future<Response<T>> Function() request,
  ) async {
    // 测试环境下不重试，直接返回
    return await request();
  }
}
```

## 六、常见问题解答

### Q1: 为什么使用函数包装而不是直接调用？

**A**: 函数包装允许我们延迟执行和组合多个策略。每个策略都可以在执行前后添加自己的逻辑。

### Q2: 策略的执行顺序可以改变吗？

**A**: 可以，但需要谨慎考虑。不同的顺序可能导致不同的行为。建议按照安全→限流→缓存→重试→降级的顺序。

### Q3: 如何禁用某个策略？

**A**: 每个策略都有 `enabled` 属性，设置为 `false` 即可禁用。

```dart
final retryStrategy = NetworkStrategyFactory.instance.getStrategy<RetryStrategy>();
retryStrategy?.enabled = false;
```

### Q4: 策略会影响性能吗？

**A**: 策略本身的开销很小，主要是函数调用的开销。但某些策略（如缓存）实际上可以提升性能。

## 七、最佳实践

### 7.1 策略设计原则

1. **单一职责**: 每个策略只负责一个特定的功能
2. **无状态**: 策略应该是无状态的，避免副作用
3. **可配置**: 提供配置选项，支持运行时调整
4. **错误处理**: 妥善处理异常，不影响其他策略

### 7.2 性能优化

1. **策略缓存**: 避免重复创建策略实例
2. **条件执行**: 根据请求类型选择性应用策略
3. **异步优化**: 合理使用异步操作，避免阻塞

### 7.3 调试技巧

1. **日志策略**: 添加日志策略跟踪执行流程
2. **性能监控**: 监控每个策略的执行时间
3. **错误追踪**: 记录策略执行过程中的错误

这种策略链模式为网络层提供了强大的扩展性和灵活性，是现代网络框架的核心设计模式之一。
