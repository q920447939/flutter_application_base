/// 会员模块配置
///
/// 定义会员相关的常量、配置项和枚举
library;

/// 会员模块配置类
class MemberConfig {
  /// 私有构造函数，防止实例化
  MemberConfig._();

  // ========== API端点配置 ==========

  /// 会员API基础路径
  static const String apiBasePath = '/api/member';

  /// 获取会员信息端点
  static const String getMemberInfoEndpoint = '$apiBasePath/get';

  /// 更新昵称端点
  static const String updateNickNameEndpoint = '$apiBasePath/updateNickName';

  /// 更新头像端点
  static const String updateAvatarEndpoint = '$apiBasePath/updateAvatar';

  // ========== 验证规则配置 ==========

  /// 昵称最小长度
  static const int nickNameMinLength = 2;

  /// 昵称最大长度
  static const int nickNameMaxLength = 20;

  /// 头像URL最大长度
  static const int avatarUrlMaxLength = 500;

  /// 支持的图片格式
  static const List<String> supportedImageFormats = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
  ];

  /// 敏感词列表
  static const List<String> sensitiveWords = [
    'admin',
    '管理员',
    'test',
    '测试',
    'system',
    '系统',
    'root',
    'administrator',
  ];

  // ========== UI配置 ==========

  /// 头像默认尺寸
  static const double defaultAvatarSize = 80.0;

  /// 头像圆角半径
  static const double avatarBorderRadius = 40.0;

  /// 表单字段间距
  static const double formFieldSpacing = 16.0;

  /// 按钮高度
  static const double buttonHeight = 48.0;

  // ========== 缓存配置 ==========

  /// 会员信息缓存键
  static const String memberInfoCacheKey = 'member_info_cache';

  /// 缓存元数据键
  static const String memberCacheMetaKey = 'member_cache_meta';

  /// 缓存过期时间（分钟）
  static const int cacheExpirationMinutes = 30;

  /// 缓存预热时间（分钟）
  static const int cachePreloadMinutes = 5;

  /// 最大缓存大小（字节）
  static const int maxCacheSize = 1024 * 1024; // 1MB

  // ========== 错误码配置 ==========

  /// 会员不存在错误码
  static const int memberNotFoundCode = 1001;

  /// 昵称已存在错误码
  static const int nickNameExistsCode = 1002;

  /// 头像URL无效错误码
  static const int invalidAvatarUrlCode = 1003;

  /// 权限不足错误码
  static const int insufficientPermissionCode = 1004;

  // ========== 正则表达式 ==========

  /// 昵称验证正则（中文、英文、数字、下划线）
  static final RegExp nickNameRegex = RegExp(r'^[\u4e00-\u9fa5a-zA-Z0-9_]+$');

  /// URL验证正则
  static final RegExp urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  /// 特殊字符检测正则
  static final RegExp specialCharsRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  // ========== 默认值配置 ==========

  /// 默认头像URL
  static const String defaultAvatarUrl = 'https://via.placeholder.com/150';

  /// 默认昵称前缀
  static const String defaultNickNamePrefix = '用户';

  /// 最大重试次数
  static const int maxRetryAttempts = 3;

  /// 请求超时时间（秒）
  static const int requestTimeoutSeconds = 30;

  // ========== 功能开关 ==========

  /// 是否启用昵称重复检查
  static const bool enableNickNameDuplicateCheck = true;

  /// 是否启用头像URL验证
  static const bool enableAvatarUrlValidation = true;

  /// 是否启用敏感词过滤
  static const bool enableSensitiveWordFilter = true;

  /// 是否启用会员信息缓存
  static const bool enableMemberInfoCache = true;

  /// 是否启用批量更新
  static const bool enableBatchUpdate = true;

  // ========== 工具方法 ==========

  /// 检查是否为支持的图片格式
  static bool isSupportedImageFormat(String url) {
    final lowerUrl = url.toLowerCase();
    return supportedImageFormats.any((format) => lowerUrl.contains(format));
  }

  /// 检查是否包含敏感词
  static bool containsSensitiveWord(String text) {
    final lowerText = text.toLowerCase();
    return sensitiveWords.any((word) => lowerText.contains(word.toLowerCase()));
  }

  /// 生成默认昵称
  static String generateDefaultNickName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;
    return '$defaultNickNamePrefix$timestamp';
  }

  /// 获取错误消息
  static String getErrorMessage(int errorCode) {
    switch (errorCode) {
      case memberNotFoundCode:
        return '会员不存在';
      case nickNameExistsCode:
        return '昵称已存在，请选择其他昵称';
      case invalidAvatarUrlCode:
        return '头像URL无效';
      case insufficientPermissionCode:
        return '权限不足，无法执行此操作';
      default:
        return '未知错误';
    }
  }

  /// 验证昵称格式
  static bool isValidNickNameFormat(String nickName) {
    return nickNameRegex.hasMatch(nickName) &&
        nickName.length >= nickNameMinLength &&
        nickName.length <= nickNameMaxLength;
  }

  /// 验证URL格式
  static bool isValidUrlFormat(String url) {
    return urlRegex.hasMatch(url) && url.length <= avatarUrlMaxLength;
  }
}

/// 会员操作权限枚举
enum MemberPermission {
  /// 查看会员信息
  viewMemberInfo('查看会员信息'),

  /// 更新基本信息
  updateBasicInfo('更新基本信息'),

  /// 更新头像
  updateAvatar('更新头像'),

  /// 管理会员
  manageMember('管理会员');

  const MemberPermission(this.description);

  /// 权限描述
  final String description;
}

/// 会员状态枚举
enum MemberStatus {
  /// 正常
  normal('正常'),

  /// 禁用
  disabled('禁用'),

  /// 待审核
  pending('待审核'),

  /// 已删除
  deleted('已删除');

  const MemberStatus(this.description);

  /// 状态描述
  final String description;

  /// 是否为活跃状态
  bool get isActive => this == MemberStatus.normal;
}

/// 会员信息更新类型枚举
enum MemberUpdateType {
  /// 昵称更新
  nickName('昵称'),

  /// 头像更新
  avatar('头像'),

  /// 批量更新
  batch('批量更新');

  const MemberUpdateType(this.description);

  /// 更新类型描述
  final String description;
}
