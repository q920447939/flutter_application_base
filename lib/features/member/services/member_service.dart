/// 会员信息服务
///
/// 提供会员信息的获取、更新等核心业务逻辑
/// 复用现有的NetworkService和CommonResult处理机制
/// 集成缓存策略，减少网络请求，提升用户体验
library;

import 'package:flutter/foundation.dart';
import '../../../core/network/network_service.dart';
import '../../../features/auth/models/common_result.dart';
import '../models/member_models.dart';
import 'member_cache_service.dart';

/// 会员信息服务接口
abstract class MemberServiceInterface {
  /// 获取会员信息
  /// [forceRefresh] 是否强制从网络刷新，忽略缓存
  Future<CommonResult<MemberInfo>> getMemberInfo({bool forceRefresh = false});

  /// 更新昵称
  Future<CommonResult<bool>> updateNickName(String nickName);

  /// 更新头像
  Future<CommonResult<bool>> updateAvatar(String avatarUrl);
}

/// 会员信息服务实现
class MemberService implements MemberServiceInterface {
  static MemberService? _instance;

  /// 网络服务实例
  final NetworkService _networkService = NetworkService.instance;

  /// 缓存服务实例
  final MemberCacheService _cacheService = MemberCacheService.instance;

  /// API端点常量
  static const String _baseEndpoint = '/api/member';
  static const String _getMemberEndpoint = '$_baseEndpoint/get';
  static const String _updateNickNameEndpoint = '$_baseEndpoint/updateNickName';
  static const String _updateAvatarEndpoint = '$_baseEndpoint/updateAvatar';

  MemberService._internal();

  /// 单例模式
  static MemberService get instance {
    _instance ??= MemberService._internal();
    return _instance!;
  }

  /// 获取会员信息（集成缓存策略）
  @override
  Future<CommonResult<MemberInfo>> getMemberInfo({
    bool forceRefresh = false,
  }) async {
    try {
      debugPrint('正在获取会员信息...');

      // 1. 如果不强制刷新，先尝试从缓存获取
      if (!forceRefresh) {
        final cachedMemberInfo = await _cacheService.getCachedMemberInfo();
        if (cachedMemberInfo != null) {
          debugPrint('✅ 从缓存获取会员信息成功: ${cachedMemberInfo.displayName}');
          return CommonResult.success(
            data: cachedMemberInfo,
            msg: '获取会员信息成功（缓存）',
          );
        }
      }

      // 2. 缓存未命中或强制刷新，从网络获取
      _cacheService.recordNetworkRequest();
      debugPrint('🌐 从网络获取会员信息...');

      final result = await _networkService.getCommonResult<MemberInfo>(
        _getMemberEndpoint,
        fromJson: (json) => MemberInfo.fromJson(json),
      );

      if (result.isSuccess && result.data != null) {
        // 3. 缓存网络请求的结果
        await _cacheService.cacheMemberInfo(result.data!);
        debugPrint('✅ 获取会员信息成功并已缓存: ${result.data!.displayName}');
      } else {
        debugPrint('❌ 获取会员信息失败: ${result.msg}');
      }

      return result;
    } catch (e, stackTrace) {
      debugPrint('获取会员信息异常: $e');
      debugPrint('错误堆栈: $stackTrace');

      return CommonResult.failure(code: -1, msg: '获取会员信息失败: $e');
    }
  }

  /// 更新昵称
  @override
  Future<CommonResult<bool>> updateNickName(String nickName) async {
    try {
      debugPrint('正在更新昵称: $nickName');

      // 使用GET请求，参数通过queryParameters传递（匹配后端接口）
      final result = await _networkService.getCommonResult<bool>(
        _updateNickNameEndpoint,
        queryParameters: {'nickName': nickName.trim()},
        fromJson: (json) => _parseBooleanResponse(json),
      );

      if (result.isSuccess) {
        // 更新缓存中的昵称
        await _cacheService.updateCachedMemberInfo(nickName: nickName.trim());
        debugPrint('更新昵称成功并已更新缓存');
      } else {
        debugPrint('更新昵称失败: ${result.msg}');
      }

      return result;
    } catch (e, stackTrace) {
      debugPrint('更新昵称异常: $e');
      debugPrint('错误堆栈: $stackTrace');

      return CommonResult.failure(code: -1, msg: '更新昵称失败: $e');
    }
  }

  /// 更新头像
  @override
  Future<CommonResult<bool>> updateAvatar(String avatarUrl) async {
    try {
      debugPrint('正在更新头像: $avatarUrl');

      // 使用GET请求，参数通过queryParameters传递（匹配后端接口）
      final result = await _networkService.getCommonResult<bool>(
        _updateAvatarEndpoint,
        queryParameters: {'avatarUrl': avatarUrl.trim()},
        fromJson: (json) => _parseBooleanResponse(json),
      );

      if (result.isSuccess) {
        // 更新缓存中的头像
        await _cacheService.updateCachedMemberInfo(avatarUrl: avatarUrl.trim());
        debugPrint('更新头像成功并已更新缓存');
      } else {
        debugPrint('更新头像失败: ${result.msg}');
      }

      return result;
    } catch (e, stackTrace) {
      debugPrint('更新头像异常: $e');
      debugPrint('错误堆栈: $stackTrace');

      return CommonResult.failure(code: -1, msg: '更新头像失败: $e');
    }
  }

  /// 批量更新会员信息（扩展方法）
  Future<CommonResult<List<MemberUpdateResult>>> batchUpdateMemberInfo({
    String? nickName,
    String? avatarUrl,
  }) async {
    final results = <MemberUpdateResult>[];

    try {
      // 更新昵称
      if (nickName?.isNotEmpty == true) {
        final nickNameResult = await updateNickName(nickName!);
        results.add(
          MemberUpdateResult(
            success: nickNameResult.isSuccess,
            operationType: MemberOperationType.updateNickName,
            updateTime: DateTime.now(),
            message: nickNameResult.msg,
          ),
        );
      }

      // 更新头像
      if (avatarUrl?.isNotEmpty == true) {
        final avatarResult = await updateAvatar(avatarUrl!);
        results.add(
          MemberUpdateResult(
            success: avatarResult.isSuccess,
            operationType: MemberOperationType.updateAvatar,
            updateTime: DateTime.now(),
            message: avatarResult.msg,
          ),
        );
      }

      // 检查是否所有操作都成功
      final allSuccess = results.every((result) => result.success);

      return CommonResult.success(
        data: results,
        msg: allSuccess ? '批量更新成功' : '部分更新失败',
      );
    } catch (e) {
      debugPrint('批量更新会员信息异常: $e');

      return CommonResult.failure(code: -1, msg: '批量更新失败: $e', data: results);
    }
  }

  /// 刷新会员信息缓存
  Future<void> refreshMemberInfoCache() async {
    try {
      // 强制从网络获取最新数据并更新缓存
      final result = await getMemberInfo(forceRefresh: true);
      if (result.isSuccess) {
        debugPrint('会员信息缓存刷新成功');
      } else {
        debugPrint('会员信息缓存刷新失败: ${result.msg}');
      }
    } catch (e) {
      debugPrint('刷新会员信息缓存异常: $e');
    }
  }

  /// 检查会员信息是否需要更新
  Future<bool> needsUpdate(MemberInfo currentInfo) async {
    try {
      final latestResult = await getMemberInfo(forceRefresh: true);
      if (latestResult.isSuccess && latestResult.data != null) {
        // 比较关键字段是否有变化
        final latest = latestResult.data!;
        return currentInfo.nickName != latest.nickName ||
            currentInfo.avatarUrl != latest.avatarUrl;
      }
      return false;
    } catch (e) {
      debugPrint('检查会员信息更新状态异常: $e');
      return false;
    }
  }

  /// 解析后端返回的Boolean响应
  bool _parseBooleanResponse(dynamic json) {
    if (json is bool) return json;
    if (json is String) return json.toLowerCase() == 'true';
    if (json is int) return json == 1;
    return false;
  }

  /// 清除会员信息缓存
  Future<void> clearMemberInfoCache() async {
    await _cacheService.clearMemberInfoCache();
    debugPrint('会员信息缓存已清除');
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    return _cacheService.getCacheStats();
  }

  /// 预热缓存
  Future<void> preloadCache() async {
    await _cacheService.preloadCache();
  }

  /// 初始化缓存服务
  Future<void> initializeCacheService() async {
    await _cacheService.initialize();
  }
}
