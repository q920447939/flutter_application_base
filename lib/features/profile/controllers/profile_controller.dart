/// 用户资料控制器
/// 
/// 管理用户资料相关的UI状态和业务逻辑
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/state/base_controller.dart';
import '../../../core/localization/app_localizations.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/models/user_model.dart';

/// 用户资料控制器
class ProfileController extends BaseController {
  /// 当前用户
  UserModel? get currentUser => AuthService.instance.currentUser;

  /// 用户信息是否已加载
  final RxBool isUserLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    if (currentUser != null) {
      isUserLoaded.value = true;
    }
  }

  /// 刷新用户信息
  Future<void> refreshUserInfo() async {
    await executeAsync(() async {
      // 这里可以调用API刷新用户信息
      await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求
      isUserLoaded.value = true;
    });
  }

  /// 退出登录
  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(S.logout),
        content: Text(S.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(S.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(S.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await executeAsync(() async {
        await AuthService.instance.logout();
        Get.offAllNamed('/login');
      });
    }
  }

  /// 编辑资料
  void editProfile() {
    Get.toNamed('/profile/edit');
  }

  /// 修改密码
  void changePassword() {
    Get.toNamed('/profile/change-password');
  }

  /// 设置
  void openSettings() {
    Get.toNamed('/settings');
  }

  /// 关于
  void openAbout() {
    Get.toNamed('/about');
  }

  /// 帮助与反馈
  void openHelp() {
    Get.toNamed('/help');
  }
}

/// 编辑资料控制器
class EditProfileController extends BaseController {
  /// 表单Key
  final formKey = GlobalKey<FormState>();

  /// 昵称控制器
  final nicknameController = TextEditingController();

  /// 邮箱控制器
  final emailController = TextEditingController();

  /// 手机号控制器
  final phoneController = TextEditingController();

  /// 地址控制器
  final addressController = TextEditingController();

  /// 个人简介控制器
  final bioController = TextEditingController();

  /// 选中的性别
  final Rx<Gender?> selectedGender = Rx<Gender?>(null);

  /// 选中的生日
  final Rx<DateTime?> selectedBirthday = Rx<DateTime?>(null);

  /// 头像URL
  final RxString avatarUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  @override
  void onClose() {
    nicknameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    bioController.dispose();
    super.onClose();
  }

  /// 初始化数据
  void _initializeData() {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      nicknameController.text = user.nickname ?? '';
      emailController.text = user.email ?? '';
      phoneController.text = user.phone ?? '';
      addressController.text = user.address ?? '';
      bioController.text = user.bio ?? '';
      selectedGender.value = user.gender;
      selectedBirthday.value = user.birthday;
      avatarUrl.value = user.avatar ?? '';
    }
  }

  /// 选择性别
  void selectGender(Gender? gender) {
    selectedGender.value = gender;
  }

  /// 选择生日
  Future<void> selectBirthday() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedBirthday.value ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedBirthday.value = picked;
    }
  }

  /// 选择头像
  Future<void> selectAvatar() async {
    // 这里可以实现头像选择逻辑
    // 可以从相册选择或拍照
    showModalBottomSheet(
      context: Get.context!,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('拍照'),
              onTap: () {
                Get.back();
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Get.back();
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('取消'),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  /// 拍照
  Future<void> _takePhoto() async {
    // 实现拍照逻辑
    showInfo('拍照功能待实现');
  }

  /// 从相册选择
  Future<void> _pickFromGallery() async {
    // 实现从相册选择逻辑
    showInfo('相册选择功能待实现');
  }

  /// 保存资料
  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final userInfo = {
      'nickname': nicknameController.text.trim(),
      'email': emailController.text.trim().isEmpty ? null : emailController.text.trim(),
      'phone': phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
      'address': addressController.text.trim().isEmpty ? null : addressController.text.trim(),
      'bio': bioController.text.trim().isEmpty ? null : bioController.text.trim(),
      'gender': selectedGender.value?.name,
      'birthday': selectedBirthday.value?.toIso8601String(),
      'avatar': avatarUrl.value.isEmpty ? null : avatarUrl.value,
    };

    await executeAsync(
      () async {
        final success = await AuthService.instance.updateUserInfo(userInfo);
        if (success) {
          showSuccess(S.updateSuccess);
          Get.back();
        } else {
          throw Exception(S.updateFailed);
        }
      },
      errorMessage: S.updateFailed,
    );
  }

  /// 验证昵称
  String? validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return S.required;
    }
    if (value.trim().length > 20) {
      return '昵称最多20个字符';
    }
    return null;
  }

  /// 验证邮箱
  String? validateEmail(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (!GetUtils.isEmail(value.trim())) {
        return S.invalidEmail;
      }
    }
    return null;
  }

  /// 验证手机号
  String? validatePhone(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (!GetUtils.isPhoneNumber(value.trim())) {
        return S.invalidPhone;
      }
    }
    return null;
  }

  /// 验证个人简介
  String? validateBio(String? value) {
    if (value != null && value.trim().length > 200) {
      return '个人简介最多200个字符';
    }
    return null;
  }

  /// 获取性别显示文本
  String getGenderText(Gender? gender) {
    switch (gender) {
      case Gender.male:
        return S.male;
      case Gender.female:
        return S.female;
      case Gender.other:
        return S.other;
      default:
        return '请选择';
    }
  }

  /// 获取生日显示文本
  String getBirthdayText(DateTime? birthday) {
    if (birthday == null) return '请选择';
    return '${birthday.year}年${birthday.month}月${birthday.day}日';
  }
}
