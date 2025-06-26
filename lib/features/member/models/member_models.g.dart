// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberInfo _$MemberInfoFromJson(Map<String, dynamic> json) => MemberInfo(
  id: (json['id'] as num?)?.toInt(),
  memberCode: json['memberCode'] as String?,
  nickName: json['memberNickName'] as String?,
  simpleId: (json['memberSimpleId'] as num?)?.toInt(),
  inviterSimpleId: (json['inviteMemberSimpleId'] as num?)?.toInt(),
  avatarUrl: json['avatar'] as String?,
  createTime: json['createTime'] as String?,
);

Map<String, dynamic> _$MemberInfoToJson(MemberInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberCode': instance.memberCode,
      'memberNickName': instance.nickName,
      'memberSimpleId': instance.simpleId,
      'inviteMemberSimpleId': instance.inviterSimpleId,
      'avatar': instance.avatarUrl,
      'createTime': instance.createTime,
    };

UpdateNickNameRequest _$UpdateNickNameRequestFromJson(
  Map<String, dynamic> json,
) => UpdateNickNameRequest(nickName: json['nickName'] as String);

Map<String, dynamic> _$UpdateNickNameRequestToJson(
  UpdateNickNameRequest instance,
) => <String, dynamic>{'nickName': instance.nickName};

UpdateAvatarRequest _$UpdateAvatarRequestFromJson(Map<String, dynamic> json) =>
    UpdateAvatarRequest(avatarUrl: json['avatarUrl'] as String);

Map<String, dynamic> _$UpdateAvatarRequestToJson(
  UpdateAvatarRequest instance,
) => <String, dynamic>{'avatarUrl': instance.avatarUrl};

MemberUpdateResult _$MemberUpdateResultFromJson(Map<String, dynamic> json) =>
    MemberUpdateResult(
      success: json['success'] as bool,
      operationType: $enumDecode(
        _$MemberOperationTypeEnumMap,
        json['operationType'],
      ),
      updateTime: DateTime.parse(json['updateTime'] as String),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$MemberUpdateResultToJson(MemberUpdateResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'operationType': _$MemberOperationTypeEnumMap[instance.operationType]!,
      'updateTime': instance.updateTime.toIso8601String(),
      'message': instance.message,
    };

const _$MemberOperationTypeEnumMap = {
  MemberOperationType.getMemberInfo: 'getMemberInfo',
  MemberOperationType.updateNickName: 'updateNickName',
  MemberOperationType.updateAvatar: 'updateAvatar',
};
