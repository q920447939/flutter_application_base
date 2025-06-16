# 会员信息管理框架

## 📋 概述

这是一个基于Flutter + GetX架构的通用会员信息管理框架，提供完整的会员信息获取、更新等功能。框架设计遵循高内聚低耦合原则，充分复用现有的网络服务和验证框架。

## 🎯 设计特点

### 核心优势
- **复用现有架构**: 充分利用项目中已有的`NetworkService`、`CommonResult`、`ValidationMixin`等基础设施
- **分层清晰**: Model → Service → Controller → UI 四层架构，职责明确
- **统一验证**: 集成现有验证框架，提供一致的数据验证体验
- **响应式编程**: 基于GetX的响应式状态管理
- **扩展性强**: 支持新增会员操作类型和验证规则

### 技术栈
- **状态管理**: GetX
- **网络请求**: Dio (复用现有NetworkService)
- **数据验证**: 自定义验证框架
- **JSON序列化**: json_annotation

## 🏗️ 架构设计

```
lib/features/member/
├── models/              # 数据模型层
│   └── member_models.dart
├── services/            # 服务层
│   └── member_service.dart
├── controllers/         # 控制器层
│   └── member_controller.dart
├── validators/          # 验证器层
│   └── member_validators.dart
├── config/             # 配置层
│   └── member_config.dart
├── index.dart          # 统一导出
└── README.md           # 文档
```

## 🚀 快速开始

### 1. 基本使用

```dart
import 'package:flutter_application_base/features/member/index.dart';

// 在页面中使用
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MemberController>(
      init: MemberController(),
      builder: (controller) {
        return Scaffold(
          body: Obx(() {
            final memberInfo = controller.memberInfo.value;
            return memberInfo != null 
                ? Text('欢迎，${memberInfo.displayName}')
                : CircularProgressIndicator();
          }),
        );
      },
    );
  }
}
```

### 2. 获取会员信息

```dart
final controller = Get.put(MemberController());

// 自动加载（在onInit中）
// 或手动加载
await controller.loadMemberInfo();

// 访问会员信息
final memberInfo = controller.memberInfo.value;
print('昵称: ${memberInfo?.nickName}');
print('头像: ${memberInfo?.avatarUrl}');
```

### 3. 更新会员信息

```dart
// 更新昵称
controller.nickNameController.text = '新昵称';
await controller.updateNickName();

// 更新头像
controller.avatarUrlController.text = 'https://example.com/avatar.jpg';
await controller.updateAvatar();

// 批量更新
await controller.batchUpdateMemberInfo();
```

### 4. 直接使用服务层

```dart
// 如果只需要数据，不需要UI状态管理
final memberService = MemberService.instance;

// 获取会员信息
final result = await memberService.getMemberInfo();
if (result.isSuccess) {
  print('会员信息: ${result.data}');
} else {
  print('获取失败: ${result.msg}');
}

// 更新昵称
final updateResult = await memberService.updateNickName('新昵称');
print('更新结果: ${updateResult.isSuccess}');
```

## 🔧 配置说明

### API端点配置

框架默认使用以下API端点（在`MemberConfig`中定义）：

```dart
// 获取会员信息
GET /api/member/get

// 更新昵称
GET /api/member/updateNickName?nickName=新昵称

// 更新头像  
GET /api/member/updateAvatar?avatarUrl=头像URL
```

### 验证规则配置

```dart
class MemberConfig {
  // 昵称长度限制
  static const int nickNameMinLength = 2;
  static const int nickNameMaxLength = 20;
  
  // 支持的图片格式
  static const List<String> supportedImageFormats = [
    '.jpg', '.jpeg', '.png', '.gif', '.webp'
  ];
  
  // 敏感词过滤
  static const List<String> sensitiveWords = [
    'admin', '管理员', 'test', '测试'
  ];
}
```

## 📝 数据模型

### MemberInfo - 会员信息模型

```dart
class MemberInfo {
  final int? id;                    // 会员ID
  final String? memberCode;         // 会员编码
  final String? nickName;           // 昵称
  final int? simpleId;             // 简单ID
  final int? inviterSimpleId;      // 邀请人ID
  final String? avatarUrl;         // 头像URL
  final String? createTime;        // 创建时间
  
  // 便捷属性
  bool get hasAvatar;              // 是否有头像
  String get displayName;          // 显示名称
}
```

### 请求模型

```dart
// 更新昵称请求
class UpdateNickNameRequest {
  final String nickName;
}

// 更新头像请求  
class UpdateAvatarRequest {
  final String avatarUrl;
}
```

## ✅ 数据验证

### 内置验证器

```dart
// 昵称验证
final validator = UpdateNickNameRequestValidator();
final result = validator.validate(request);

// 头像URL验证
final avatarValidator = UpdateAvatarRequestValidator();
final avatarResult = avatarValidator.validate(avatarRequest);

// 工具类验证
final nickNameResult = MemberValidationUtils.validateNickName('昵称');
final avatarResult = MemberValidationUtils.validateAvatarUrl('URL');
```

### 验证规则

**昵称验证**:
- 长度: 2-20个字符
- 格式: 中文、英文、数字、下划线
- 敏感词: 不能包含预定义敏感词

**头像URL验证**:
- 格式: 有效的HTTP/HTTPS URL
- 安全: 必须使用HTTPS协议
- 文件类型: 支持jpg、png、gif、webp格式
- 长度: 不超过500字符

## 🎨 UI组件集成

### 与验证框架集成

```dart
// 使用ValidatedTextField
ValidatedTextField(
  controller: controller.nickNameController,
  labelText: '昵称',
  validator: (value) {
    final result = MemberValidationUtils.validateNickName(value!);
    return result.isValid ? null : result.firstError?.message;
  },
)
```

### 响应式UI更新

```dart
// 监听会员信息变化
Obx(() {
  final memberInfo = controller.memberInfo.value;
  return memberInfo != null 
      ? MemberInfoWidget(memberInfo)
      : LoadingWidget();
})

// 监听加载状态
Obx(() {
  return ElevatedButton(
    onPressed: controller.isUpdating ? null : controller.updateNickName,
    child: controller.isUpdating 
        ? CircularProgressIndicator() 
        : Text('更新昵称'),
  );
})
```

## 🔄 扩展指南

### 添加新的会员操作

1. **扩展枚举**:
```dart
enum MemberOperationType {
  updatePhone('更新手机号'),  // 新增
}
```

2. **添加服务方法**:
```dart
class MemberService {
  Future<CommonResult<bool>> updatePhone(String phone) async {
    // 实现逻辑
  }
}
```

3. **添加验证器**:
```dart
class UpdatePhoneRequestValidator extends Validator<UpdatePhoneRequest> {
  // 验证逻辑
}
```

4. **扩展控制器**:
```dart
class MemberController {
  Future<void> updatePhone() async {
    // 控制器逻辑
  }
}
```

### 自定义验证规则

```dart
class CustomMemberValidator extends Validator<MemberInfo> {
  @override
  ValidationResult validate(MemberInfo data) {
    final result = ValidationResult();
    
    // 自定义验证逻辑
    if (data.nickName?.contains('特殊规则') == true) {
      result.addError('nickName', '不符合特殊规则');
    }
    
    return result;
  }
}
```

## 🧪 测试建议

### 单元测试

```dart
// 测试服务层
test('获取会员信息成功', () async {
  final service = MemberService.instance;
  final result = await service.getMemberInfo();
  expect(result.isSuccess, true);
});

// 测试验证器
test('昵称验证失败 - 长度不足', () {
  final validator = UpdateNickNameRequestValidator();
  final request = UpdateNickNameRequest(nickName: 'a');
  final result = validator.validate(request);
  expect(result.isValid, false);
});
```

### 集成测试

```dart
// 测试完整流程
testWidgets('会员信息更新流程', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // 输入昵称
  await tester.enterText(find.byKey(Key('nickNameField')), '新昵称');
  
  // 点击更新按钮
  await tester.tap(find.byKey(Key('updateButton')));
  await tester.pumpAndSettle();
  
  // 验证结果
  expect(find.text('更新成功'), findsOneWidget);
});
```

## 📚 最佳实践

1. **错误处理**: 始终检查`CommonResult.isSuccess`
2. **加载状态**: 使用响应式变量管理UI状态
3. **数据验证**: 在UI和服务层都进行验证
4. **缓存策略**: 合理使用会员信息缓存
5. **权限控制**: 根据用户权限显示/隐藏功能

## 🔗 相关文档

- [网络服务文档](../../core/network/README.md)
- [验证框架文档](../../core/validation/README.md)
- [认证模块文档](../auth/README.md)
