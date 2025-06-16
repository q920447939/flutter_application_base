/// 会员信息管理演示页面
///
/// 展示会员模块的使用方法和功能
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_base/features/member/index.dart';
import 'package:flutter_application_base/core/validation/validated_text_field.dart';

/// 会员信息管理演示页面
class MemberDemoPage extends StatelessWidget {
  const MemberDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MemberController>(
      init: MemberController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('会员信息管理'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.refreshMemberInfo,
                tooltip: '刷新',
              ),
            ],
          ),
          body: Obx(() {
            if (controller.isLoadingMemberInfo.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 会员信息卡片
                    _buildMemberInfoCard(controller),

                    const SizedBox(height: 24),

                    // 编辑表单
                    if (controller.isEditMode.value) ...[
                      _buildEditForm(controller),
                      const SizedBox(height: 24),
                      _buildActionButtons(controller),
                    ] else ...[
                      _buildViewModeButtons(controller),
                    ],

                    const SizedBox(height: 24),

                    // 操作历史
                    _buildOperationHistory(controller),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  /// 构建会员信息卡片
  Widget _buildMemberInfoCard(MemberController controller) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final memberInfo = controller.memberInfo.value;

          if (memberInfo == null) {
            return const Center(child: Text('暂无会员信息'));
          }

          return Column(
            children: [
              // 头像
              CircleAvatar(
                radius: MemberConfig.defaultAvatarSize / 2,
                backgroundImage:
                    controller.hasAvatar
                        ? NetworkImage(memberInfo.avatarUrl!)
                        : null,
                child:
                    !controller.hasAvatar
                        ? const Icon(Icons.person, size: 40)
                        : null,
              ),

              const SizedBox(height: 16),

              // 基本信息
              _buildInfoRow('昵称', controller.memberDisplayName),
              _buildInfoRow('会员编码', memberInfo.memberCode ?? '未知'),
              _buildInfoRow('会员ID', memberInfo.simpleId?.toString() ?? '未知'),
              if (memberInfo.createTime != null)
                _buildInfoRow('注册时间', memberInfo.createTime!),

              // 最后更新时间
              if (controller.lastUpdateTime.value != null)
                _buildInfoRow('最后更新', controller.lastUpdateTimeDisplay),
            ],
          );
        }),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建编辑表单
  Widget _buildEditForm(MemberController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '编辑会员信息',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // 昵称输入框
        ValidatedTextField(
          controller: controller,
          fieldName: 'nickName',
          textController: controller.nickNameController,
          decoration: const InputDecoration(
            labelText: '昵称',
            hintText: '请输入昵称（2-20个字符）',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),

        const SizedBox(height: 16),

        // 头像URL输入框
        ValidatedTextField(
          controller: controller,
          fieldName: 'avatarUrl',
          textController: controller.avatarUrlController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: '头像URL',
            hintText: '请输入头像图片链接',
            prefixIcon: Icon(Icons.image_outlined),
          ),
        ),
      ],
    );
  }

  /// 构建操作按钮（编辑模式）
  Widget _buildActionButtons(MemberController controller) {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: controller.isUpdating ? null : controller.cancelEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, MemberConfig.buttonHeight),
              ),
              child: const Text('取消'),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: ElevatedButton(
              onPressed:
                  controller.isUpdating
                      ? null
                      : controller.batchUpdateMemberInfo,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, MemberConfig.buttonHeight),
              ),
              child:
                  controller.isUpdating
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('保存'),
            ),
          ),
        ],
      );
    });
  }

  /// 构建查看模式按钮
  Widget _buildViewModeButtons(MemberController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: controller.toggleEditMode,
          icon: const Icon(Icons.edit),
          label: const Text('编辑会员信息'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, MemberConfig.buttonHeight),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.updateNickName(),
                icon: const Icon(Icons.person_outline),
                label: const Text('快速更新昵称'),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.updateAvatar(),
                icon: const Icon(Icons.image_outlined),
                label: const Text('快速更新头像'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建操作历史
  Widget _buildOperationHistory(MemberController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '操作说明',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const Text(
              '• 点击"编辑会员信息"进入编辑模式\n'
              '• 在编辑模式下可以同时修改昵称和头像\n'
              '• 支持单独快速更新昵称或头像\n'
              '• 所有操作都会进行数据验证\n'
              '• 更新成功后会自动刷新显示',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 12),

            Obx(() {
              return Text(
                '当前状态: ${controller.isEditMode.value ? "编辑模式" : "查看模式"}',
                style: TextStyle(
                  color:
                      controller.isEditMode.value
                          ? Colors.orange
                          : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
