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
      if (instance.id case final value?) 'id': value,
      if (instance.memberCode case final value?) 'memberCode': value,
      if (instance.nickName case final value?) 'memberNickName': value,
      if (instance.simpleId case final value?) 'memberSimpleId': value,
      if (instance.inviterSimpleId case final value?)
        'inviteMemberSimpleId': value,
      if (instance.avatarUrl case final value?) 'avatar': value,
      if (instance.createTime case final value?) 'createTime': value,
    };

UpdateNickNameRequest _$UpdateNickNameRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateNickNameRequest(
      nickName: json['nickName'] as String,
    );

Map<String, dynamic> _$UpdateNickNameRequestToJson(
        UpdateNickNameRequest instance) =>
    <String, dynamic>{
      'nickName': instance.nickName,
    };

UpdateAvatarRequest _$UpdateAvatarRequestFromJson(Map<String, dynamic> json) =>
    UpdateAvatarRequest(
      avatarUrl: json['avatarUrl'] as String,
    );

Map<String, dynamic> _$UpdateAvatarRequestToJson(
        UpdateAvatarRequest instance) =>
    <String, dynamic>{
      'avatarUrl': instance.avatarUrl,
    };

MemberUpdateResult _$MemberUpdateResultFromJson(Map<String, dynamic> json) =>
    MemberUpdateResult(
      success: json['success'] as bool,
      operationType:
          $enumDecode(_$MemberOperationTypeEnumMap, json['operation_type']),
      updateTime: DateTime.parse(json['update_time'] as String),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$MemberUpdateResultToJson(MemberUpdateResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'operation_type': _$MemberOperationTypeEnumMap[instance.operationType]!,
      'update_time': instance.updateTime.toIso8601String(),
      if (instance.message case final value?) 'message': value,
    };

const _$MemberOperationTypeEnumMap = {
  MemberOperationType.getMemberInfo: 'getMemberInfo',
  MemberOperationType.updateNickName: 'updateNickName',
  MemberOperationType.updateAvatar: 'updateAvatar',
};
