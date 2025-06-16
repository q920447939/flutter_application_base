/// 会员信息相关数据模型
/// 
/// 包含会员信息、更新请求等数据结构
library;

import 'package:json_annotation/json_annotation.dart';

part 'member_models.g.dart';

/// 会员信息响应模型
/// 对应后端MemberRespVO
@JsonSerializable()
class MemberInfo {
  /// 会员ID
  final int? id;

  /// 会员编码
  @JsonKey(name: 'memberCode')
  final String? memberCode;

  /// 会员昵称
  @JsonKey(name: 'memberNickName')
  final String? nickName;

  /// 会员简单ID
  @JsonKey(name: 'memberSimpleId')
  final int? simpleId;

  /// 邀请人简单ID
  @JsonKey(name: 'inviteMemberSimpleId')
  final int? inviterSimpleId;

  /// 头像URL
  @JsonKey(name: 'avatar')
  final String? avatarUrl;

  /// 创建时间
  @JsonKey(name: 'createTime')
  final String? createTime;

  const MemberInfo({
    this.id,
    this.memberCode,
    this.nickName,
    this.simpleId,
    this.inviterSimpleId,
    this.avatarUrl,
    this.createTime,
  });

  /// 是否有头像
  bool get hasAvatar => avatarUrl?.isNotEmpty == true;

  /// 显示名称（优先使用昵称，否则使用会员编码）
  String get displayName => nickName?.isNotEmpty == true 
      ? nickName! 
      : memberCode ?? '未知用户';

  /// 从JSON创建
  factory MemberInfo.fromJson(Map<String, dynamic> json) => 
      _$MemberInfoFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$MemberInfoToJson(this);

  /// 复制并更新部分字段
  MemberInfo copyWith({
    int? id,
    String? memberCode,
    String? nickName,
    int? simpleId,
    int? inviterSimpleId,
    String? avatarUrl,
    String? createTime,
  }) {
    return MemberInfo(
      id: id ?? this.id,
      memberCode: memberCode ?? this.memberCode,
      nickName: nickName ?? this.nickName,
      simpleId: simpleId ?? this.simpleId,
      inviterSimpleId: inviterSimpleId ?? this.inviterSimpleId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createTime: createTime ?? this.createTime,
    );
  }

  @override
  String toString() {
    return 'MemberInfo(id: $id, nickName: $nickName, memberCode: $memberCode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemberInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 更新昵称请求模型
@JsonSerializable()
class UpdateNickNameRequest {
  /// 新昵称
  @JsonKey(name: 'nickName')
  final String nickName;

  const UpdateNickNameRequest({
    required this.nickName,
  });

  /// 从JSON创建
  factory UpdateNickNameRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdateNickNameRequestFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$UpdateNickNameRequestToJson(this);
}

/// 更新头像请求模型
@JsonSerializable()
class UpdateAvatarRequest {
  /// 头像URL
  @JsonKey(name: 'avatarUrl')
  final String avatarUrl;

  const UpdateAvatarRequest({
    required this.avatarUrl,
  });

  /// 从JSON创建
  factory UpdateAvatarRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdateAvatarRequestFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$UpdateAvatarRequestToJson(this);
}

/// 会员操作类型枚举
enum MemberOperationType {
  /// 获取会员信息
  getMemberInfo('获取会员信息'),
  
  /// 更新昵称
  updateNickName('更新昵称'),
  
  /// 更新头像
  updateAvatar('更新头像');

  const MemberOperationType(this.description);

  /// 操作描述
  final String description;
}

/// 会员信息更新结果
@JsonSerializable()
class MemberUpdateResult {
  /// 是否成功
  final bool success;

  /// 更新的字段类型
  final MemberOperationType operationType;

  /// 更新时间
  final DateTime updateTime;

  /// 附加信息
  final String? message;

  const MemberUpdateResult({
    required this.success,
    required this.operationType,
    required this.updateTime,
    this.message,
  });

  /// 从JSON创建
  factory MemberUpdateResult.fromJson(Map<String, dynamic> json) => 
      _$MemberUpdateResultFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$MemberUpdateResultToJson(this);

  /// 创建成功结果
  factory MemberUpdateResult.success({
    required MemberOperationType operationType,
    String? message,
  }) {
    return MemberUpdateResult(
      success: true,
      operationType: operationType,
      updateTime: DateTime.now(),
      message: message,
    );
  }

  /// 创建失败结果
  factory MemberUpdateResult.failure({
    required MemberOperationType operationType,
    String? message,
  }) {
    return MemberUpdateResult(
      success: false,
      operationType: operationType,
      updateTime: DateTime.now(),
      message: message,
    );
  }
}
