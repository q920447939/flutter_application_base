# 统一验证框架使用指南

## 概述

本验证框架解决了您提出的重要问题：**避免每个调用方都需要自己编写UI提示逻辑**。通过统一的验证和提示机制，实现了：

- ✅ **零重复代码** - 调用方只需一行代码完成验证和提示
- ✅ **统一体验** - 所有错误提示风格一致
- ✅ **易于维护** - 验证规则集中管理
- ✅ **支持扩展** - 可以轻松添加新的验证规则
- ✅ **国际化友好** - 错误信息支持多语言

## 🏗️ 架构设计

```
┌─────────────────────────────────────┐
│           UI Layer                  │  ← 自动显示错误
├─────────────────────────────────────┤
│       ValidationMixin               │  ← 统一验证接口
├─────────────────────────────────────┤
│         Validator                   │  ← 验证逻辑
├─────────────────────────────────────┤
│      ValidationResult               │  ← 验证结果
└─────────────────────────────────────┘
```

## 🚀 快速开始

### 1. 控制器集成

```dart
class MyController extends GetxController with ValidationMixin {
  
  Future<void> submitForm() async {
    // 创建数据对象
    final request = UsernamePasswordAuthRequest(
      username: usernameController.text,
      password: passwordController.text,
      captcha: captchaController.text,
      captchaSessionId: sessionId,
    );
    
    // 一行代码完成验证和UI提示
    final validator = UsernamePasswordAuthRequestValidator();
    final result = validateAndShow(validator, request);
    
    if (!result.isValid) {
      return; // 验证失败，错误已自动显示
    }
    
    // 继续业务逻辑
    await doSubmit(request);
  }
}
```

### 2. UI组件集成

```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyController>(
      builder: (controller) => Column(
        children: [
          // 普通输入框
          TextFormField(
            controller: usernameController,
            decoration: InputDecoration(labelText: '用户名'),
          ),
          
          // 自动显示验证错误
          ValidationErrorDisplay(controller: controller),
          
          // 提交按钮
          ElevatedButton(
            onPressed: controller.submitForm,
            child: Text('提交'),
          ),
        ],
      ),
    );
  }
}
```

## 📋 核心组件

### 1. ValidationResult - 验证结果

```dart
class ValidationResult {
  final bool isValid;                           // 是否验证通过
  final Map<String, List<String>> fieldErrors;  // 字段错误
  final List<String> globalErrors;              // 全局错误
  final String? firstError;                     // 第一个错误
}

// 使用示例
final result = validator.validate(data);
if (!result.isValid) {
  print('验证失败: ${result.firstError}');
  print('所有错误: ${result.getAllErrors()}');
}
```

### 2. Validator - 验证器接口

```dart
abstract class Validator<T> {
  String get name;
  ValidationResult validate(T data);
}

// 自定义验证器
class MyValidator extends Validator<MyData> {
  @override
  String get name => 'MyValidator';
  
  @override
  ValidationResult validate(MyData data) {
    final errors = <String, List<String>>{};
    
    if (data.name.isEmpty) {
      errors['name'] = ['名称不能为空'];
    }
    
    return errors.isEmpty 
        ? ValidationResult.success()
        : ValidationResult.failure(fieldErrors: errors);
  }
}
```

### 3. ValidationMixin - 验证混入

```dart
mixin ValidationMixin on GetxController {
  // 验证并显示错误
  ValidationResult validateAndShow<T>(Validator<T> validator, T data);
  
  // 字段错误管理
  void addFieldError(String fieldName, String error);
  void clearFieldError(String fieldName);
  List<String> getFieldErrors(String fieldName);
  
  // 全局错误管理
  void addGlobalError(String error);
  void clearValidationErrors();
  
  // 消息显示
  void showSuccessMessage(String message);
  void showWarningMessage(String message);
  void showInfoMessage(String message);
}
```

### 4. ValidationErrorDisplay - 错误显示组件

```dart
ValidationErrorDisplay(
  controller: controller,                    // 控制器
  mode: ValidationErrorDisplayMode.all,     // 显示模式
  maxErrors: 5,                             // 最大显示错误数
  errorStyle: TextStyle(color: Colors.red), // 错误样式
)
```

## 🎯 认证验证器

框架已内置认证相关的验证器：

### 1. 用户名密码验证器

```dart
final validator = UsernamePasswordAuthRequestValidator();
final result = validateAndShow(validator, request);

// 自动验证：
// - 用户名长度、格式
// - 密码强度
// - 验证码格式
// - 会话ID有效性
```

### 2. 手机号密码验证器

```dart
final validator = PhonePasswordAuthRequestValidator();
final result = validateAndShow(validator, request);

// 自动验证：
// - 手机号格式
// - 密码强度
// - 验证码格式
```

### 3. 邮箱密码验证器

```dart
final validator = EmailPasswordAuthRequestValidator();
final result = validateAndShow(validator, request);

// 自动验证：
// - 邮箱格式
// - 密码强度
// - 验证码格式
```

## 🔧 高级用法

### 1. 字段级验证

```dart
// 实时验证单个字段
final fieldValidator = FieldValidator(
  fieldName: 'username',
  rules: [
    ValidationRule.required(),
    ValidationRule.minLength(6),
    ValidationRule.pattern(r'^[a-zA-Z0-9_]+$', '只能包含字母数字下划线'),
  ],
);

final result = validateFieldAndShow(fieldValidator, value);
```

### 2. 复合验证器

```dart
final compositeValidator = CompositeValidator<MyData>(
  validators: [
    BasicValidator(),
    AdvancedValidator(),
    BusinessValidator(),
  ],
);

final result = validateAndShow(compositeValidator, data);
```

### 3. 条件验证器

```dart
final conditionalValidator = ConditionalValidator<MyData>(
  validator: AdvancedValidator(),
  condition: (data) => data.isAdvancedMode,
);

final result = validateAndShow(conditionalValidator, data);
```

### 4. 自定义错误显示

```dart
// 自定义Snackbar样式
void showCustomError(String message) {
  Get.snackbar(
    '验证失败',
    message,
    backgroundColor: Colors.red.withOpacity(0.8),
    colorText: Colors.white,
    icon: Icon(Icons.error_outline, color: Colors.white),
  );
}

// 在ValidationMixin中重写
@override
void _showErrorSnackbar(String message) {
  showCustomError(message);
}
```

## 📱 UI集成模式

### 1. 表单验证模式

```dart
ValidatedForm(
  controller: controller,
  child: Column(
    children: [
      ValidatedTextField(
        controller: controller,
        fieldName: 'username',
        textController: usernameController,
        decoration: InputDecoration(labelText: '用户名'),
      ),
      ValidatedTextField(
        controller: controller,
        fieldName: 'password',
        textController: passwordController,
        decoration: InputDecoration(labelText: '密码'),
        obscureText: true,
      ),
    ],
  ),
)
```

### 2. 实时验证模式

```dart
TextFormField(
  onChanged: (value) {
    // 实时验证
    final validator = FieldValidator(
      fieldName: 'username',
      rules: [ValidationRule.required(), ValidationRule.minLength(6)],
    );
    controller.validateFieldAndShow(validator, value);
  },
)
```

### 3. 批量验证模式

```dart
final validationController = ValidationController();

// 注册验证器
validationController.registerValidator('user', UserValidator());
validationController.registerValidator('profile', ProfileValidator());

// 批量验证
final result = validationController.validateBatch({
  'user': userData,
  'profile': profileData,
});
```

## 🌍 国际化支持

```dart
class I18nValidator extends Validator<MyData> {
  @override
  Map<String, String> get errorMessages => {
    'username.required': S.current.usernameRequired,
    'username.minLength': S.current.usernameMinLength,
    'password.required': S.current.passwordRequired,
  };
  
  @override
  ValidationResult validate(MyData data) {
    // 使用国际化错误消息
    if (data.username.isEmpty) {
      return ValidationResult.fieldError(
        'username', 
        errorMessages['username.required']!,
      );
    }
    return ValidationResult.success();
  }
}
```

## 🧪 测试支持

```dart
void main() {
  group('Validation Tests', () {
    test('should validate username correctly', () {
      final validator = UsernamePasswordAuthRequestValidator();
      final request = UsernamePasswordAuthRequest(
        username: 'test',  // 太短
        password: 'password123',
        captcha: '1234',
        captchaSessionId: 'session-id',
      );
      
      final result = validator.validate(request);
      
      expect(result.isValid, false);
      expect(result.hasFieldError('username'), true);
      expect(result.getFieldErrors('username').first, contains('至少需要6个字符'));
    });
  });
}
```

## 📊 性能优化

1. **延迟验证**：只在需要时进行验证
2. **缓存结果**：避免重复验证相同数据
3. **异步验证**：支持异步验证规则
4. **批量更新**：减少UI更新频率

## 🔄 迁移指南

### 从旧的验证方式迁移

```dart
// 旧方式 - 每个地方都要写验证逻辑
if (username.isEmpty) {
  Get.snackbar('错误', '用户名不能为空');
  return;
}
if (username.length < 6) {
  Get.snackbar('错误', '用户名至少6个字符');
  return;
}

// 新方式 - 一行代码搞定
final result = validateAndShow(validator, request);
if (!result.isValid) return;
```

这个统一验证框架完全解决了您提出的问题，让验证逻辑集中管理，UI提示自动处理，大大减少了重复代码和维护成本！
