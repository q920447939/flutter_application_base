/// 会员信息控制器
///
/// 提供会员信息管理的UI控制逻辑，复用现有的验证框架和响应式编程模式
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/validation/validation_mixin.dart';
import '../../../core/validation/validation_result.dart';
import '../../../core/state/base_controller.dart';
import '../models/member_models.dart';
import '../services/member_service.dart';
import '../validators/member_validators.dart';

/// 会员信息控制器
class MemberController extends BaseController with ValidationMixin {
  /// 会员服务实例
  final MemberService _memberService = MemberService.instance;

  /// 当前会员信息
  final Rx<MemberInfo?> memberInfo = Rx<MemberInfo?>(null);

  /// 昵称输入控制器
  final TextEditingController nickNameController = TextEditingController();

  /// 头像URL输入控制器
  final TextEditingController avatarUrlController = TextEditingController();

  /// 表单Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// 是否正在加载会员信息
  final RxBool isLoadingMemberInfo = false.obs;

  /// 是否正在更新昵称
  final RxBool isUpdatingNickName = false.obs;

  /// 是否正在更新头像
  final RxBool isUpdatingAvatar = false.obs;

  /// 是否处于编辑模式
  final RxBool isEditMode = false.obs;

  /// 最后更新时间
  final Rx<DateTime?> lastUpdateTime = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    // 初始化缓存服务并加载会员信息
    _initializeAndLoadMemberInfo();
  }

  /// 初始化缓存服务并加载会员信息
  Future<void> _initializeAndLoadMemberInfo() async {
    try {
      // 初始化缓存服务
      await _memberService.initializeCacheService();
      // 预热缓存
      await _memberService.preloadCache();
      // 加载会员信息（优先从缓存）
      await loadMemberInfo();
    } catch (e) {
      debugPrint('初始化会员信息服务失败: $e');
      // 即使初始化失败，也尝试加载会员信息
      await loadMemberInfo();
    }
  }

  @override
  void onClose() {
    nickNameController.dispose();
    avatarUrlController.dispose();
    super.onClose();
  }

  /// 加载会员信息
  Future<void> loadMemberInfo() async {
    isLoadingMemberInfo.value = true;

    await executeAsync(
      () async {
        final result = await _memberService.getMemberInfo();

        if (result.isSuccess && result.data != null) {
          memberInfo.value = result.data;
          _updateFormFields();
          showSuccess('会员信息加载成功');
          return result.data;
        } else {
          throw Exception(result.msg);
        }
      },
      showLoading: false, // 我们手动管理加载状态
      errorMessage: '加载会员信息失败',
      onSuccess: (_) => isLoadingMemberInfo.value = false,
      onError: (_) => isLoadingMemberInfo.value = false,
    );
  }

  /// 更新昵称
  Future<void> updateNickName() async {
    // 清除之前的验证错误
    clearValidationErrors();

    final newNickName = nickNameController.text.trim();

    // 验证昵称
    final validationResult = MemberValidationUtils.validateNickName(
      newNickName,
    );
    if (!validationResult.isValid) {
      _showValidationErrors(validationResult);
      return;
    }

    // 检查是否有变化
    if (newNickName == memberInfo.value?.nickName) {
      showWarning('昵称未发生变化');
      return;
    }

    isUpdatingNickName.value = true;

    await executeAsync(
      () async {
        final result = await _memberService.updateNickName(newNickName);

        if (result.isSuccess) {
          // 更新本地数据
          memberInfo.value = memberInfo.value?.copyWith(nickName: newNickName);
          lastUpdateTime.value = DateTime.now();
          isEditMode.value = false;
          showSuccess('昵称更新成功');
          return true;
        } else {
          throw Exception(result.msg);
        }
      },
      showLoading: false,
      errorMessage: '更新昵称失败',
      onSuccess: (_) => isUpdatingNickName.value = false,
      onError: (_) => isUpdatingNickName.value = false,
    );
  }

  /// 更新头像
  Future<void> updateAvatar() async {
    // 清除之前的验证错误
    clearValidationErrors();

    final newAvatarUrl = avatarUrlController.text.trim();

    // 验证头像URL
    final validationResult = MemberValidationUtils.validateAvatarUrl(
      newAvatarUrl,
    );
    if (!validationResult.isValid) {
      _showValidationErrors(validationResult);
      return;
    }

    // 检查是否有变化
    if (newAvatarUrl == memberInfo.value?.avatarUrl) {
      showWarning('头像未发生变化');
      return;
    }

    isUpdatingAvatar.value = true;

    await executeAsync(
      () async {
        final result = await _memberService.updateAvatar(newAvatarUrl);

        if (result.isSuccess) {
          // 更新本地数据
          memberInfo.value = memberInfo.value?.copyWith(
            avatarUrl: newAvatarUrl,
          );
          lastUpdateTime.value = DateTime.now();
          isEditMode.value = false;
          showSuccess('头像更新成功');
          return true;
        } else {
          throw Exception(result.msg);
        }
      },
      showLoading: false,
      errorMessage: '更新头像失败',
      onSuccess: (_) => isUpdatingAvatar.value = false,
      onError: (_) => isUpdatingAvatar.value = false,
    );
  }

  /// 批量更新会员信息
  Future<void> batchUpdateMemberInfo() async {
    // 清除之前的验证错误
    clearValidationErrors();

    final newNickName = nickNameController.text.trim();
    final newAvatarUrl = avatarUrlController.text.trim();

    // 检查是否有任何变化
    final hasNickNameChange =
        newNickName != memberInfo.value?.nickName && newNickName.isNotEmpty;
    final hasAvatarChange =
        newAvatarUrl != memberInfo.value?.avatarUrl && newAvatarUrl.isNotEmpty;

    if (!hasNickNameChange && !hasAvatarChange) {
      showWarning('没有检测到任何变化');
      return;
    }

    // 验证输入
    bool hasValidationError = false;

    if (hasNickNameChange) {
      final nickNameValidation = MemberValidationUtils.validateNickName(
        newNickName,
      );
      if (!nickNameValidation.isValid) {
        _showValidationErrors(nickNameValidation);
        hasValidationError = true;
      }
    }

    if (hasAvatarChange) {
      final avatarValidation = MemberValidationUtils.validateAvatarUrl(
        newAvatarUrl,
      );
      if (!avatarValidation.isValid) {
        _showValidationErrors(avatarValidation);
        hasValidationError = true;
      }
    }

    if (hasValidationError) return;

    await executeAsync(() async {
      final result = await _memberService.batchUpdateMemberInfo(
        nickName: hasNickNameChange ? newNickName : null,
        avatarUrl: hasAvatarChange ? newAvatarUrl : null,
      );

      if (result.isSuccess && result.data != null) {
        // 更新本地数据
        memberInfo.value = memberInfo.value?.copyWith(
          nickName:
              hasNickNameChange ? newNickName : memberInfo.value?.nickName,
          avatarUrl:
              hasAvatarChange ? newAvatarUrl : memberInfo.value?.avatarUrl,
        );
        lastUpdateTime.value = DateTime.now();
        isEditMode.value = false;

        // 显示详细结果
        final successCount = result.data!.where((r) => r.success).length;
        final totalCount = result.data!.length;
        showSuccess('批量更新完成：$successCount/$totalCount 项成功');
      } else {
        throw Exception(result.msg);
      }
    }, errorMessage: '批量更新失败');
  }

  /// 切换编辑模式
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;

    if (isEditMode.value) {
      // 进入编辑模式，更新表单字段
      _updateFormFields();
    } else {
      // 退出编辑模式，重置表单
      _resetFormFields();
    }
  }

  /// 取消编辑
  void cancelEdit() {
    isEditMode.value = false;
    _resetFormFields();
    clearValidationErrors();
  }

  /// 刷新会员信息
  Future<void> refreshMemberInfo() async {
    await loadMemberInfo();
  }

  /// 更新表单字段
  void _updateFormFields() {
    final info = memberInfo.value;
    if (info != null) {
      nickNameController.text = info.nickName ?? '';
      avatarUrlController.text = info.avatarUrl ?? '';
    }
  }

  /// 重置表单字段
  void _resetFormFields() {
    _updateFormFields();
  }

  /// 显示验证错误
  void _showValidationErrors(ValidationResult result) {
    if (result.firstError != null) {
      showError(result.firstError!);
    }

    // 设置字段级错误
    result.fieldErrors.forEach((fieldName, errors) {
      for (final error in errors) {
        addFieldError(fieldName, error);
      }
    });
  }

  /// 获取会员显示名称
  String get memberDisplayName => memberInfo.value?.displayName ?? '未知用户';

  /// 是否有头像
  bool get hasAvatar => memberInfo.value?.hasAvatar == true;

  /// 是否正在执行任何更新操作
  bool get isUpdating => isUpdatingNickName.value || isUpdatingAvatar.value;

  /// 获取最后更新时间的友好显示
  String get lastUpdateTimeDisplay {
    final time = lastUpdateTime.value;
    if (time == null) return '未知';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else {
      return '${difference.inDays}天前';
    }
  }
}
