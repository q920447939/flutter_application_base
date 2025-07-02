/// 验证码服务测试页面
///
/// 提供验证码服务的可视化测试功能，包括：
/// - 图形验证码获取和显示
/// - 验证码刷新功能
/// - 验证码验证功能
/// - 短信验证码获取
/// - 邮箱验证码获取
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_base/features/auth/services/captcha_service.dart';
import 'package:flutter_application_base/features/auth/models/captcha_model.dart';
import 'package:flutter_application_base/features/auth/models/auth_enums.dart';

/// 验证码测试页面
class CaptchaTestPage extends StatefulWidget {
  const CaptchaTestPage({super.key});

  @override
  State<CaptchaTestPage> createState() => _CaptchaTestPageState();
}

class _CaptchaTestPageState extends State<CaptchaTestPage> {
  // 控制器
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // 状态变量
  CaptchaInfo? _currentCaptcha;
  bool _isLoading = false;
  String _statusMessage = '';
  String _lastResult = '';

  // 验证码服务
  late CaptchaService _captchaService;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// 初始化服务
  void _initializeService() {
    try {
      _captchaService = CaptchaService.instance;
      _setStatus('验证码服务已初始化');
    } catch (e) {
      _setStatus('验证码服务初始化失败: $e');
    }
  }

  /// 设置状态消息
  void _setStatus(String message) {
    setState(() {
      _statusMessage = message;
    });
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  /// 更新结果显示
  void _updateResult(String result) {
    setState(() {
      _lastResult = result;
    });
  }

  /// 获取图形验证码
  Future<void> _getCaptcha() async {
    _setLoading(true);
    _setStatus('正在获取验证码...');

    try {
      final result = await _captchaService.getCaptcha();

      if (result.isSuccess && result.data != null) {
        setState(() {
          _currentCaptcha = result.data;
        });
        _setStatus('验证码获取成功');
        _updateResult('获取验证码成功: ${result.data!.sessionId}');
      } else {
        _setStatus('验证码获取失败: ${result.msg}');
        _updateResult('获取验证码失败: ${result.msg}');
      }
    } catch (e) {
      _setStatus('验证码获取异常: $e');
      _updateResult('获取验证码异常: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 刷新验证码
  Future<void> _refreshCaptcha() async {
    if (_currentCaptcha == null) {
      _setStatus('请先获取验证码');
      return;
    }

    _setLoading(true);
    _setStatus('正在刷新验证码...');

    try {
      final result = await _captchaService.refreshCaptcha(
        sessionId: _currentCaptcha!.sessionId,
      );

      if (result.isSuccess && result.data != null) {
        setState(() {
          _currentCaptcha = result.data;
        });
        _setStatus('验证码刷新成功');
        _updateResult('刷新验证码成功: ${result.data!.sessionId}');
      } else {
        _setStatus('验证码刷新失败: ${result.msg}');
        _updateResult('刷新验证码失败: ${result.msg}');
      }
    } catch (e) {
      _setStatus('验证码刷新异常: $e');
      _updateResult('刷新验证码异常: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 验证验证码
  Future<void> _verifyCaptcha() async {
    if (_currentCaptcha == null) {
      _setStatus('请先获取验证码');
      return;
    }

    if (_codeController.text.trim().isEmpty) {
      _setStatus('请输入验证码');
      return;
    }

    _setLoading(true);
    _setStatus('正在验证验证码...');

    try {
      final result = await _captchaService.verifyCaptcha(
        sessionId: _currentCaptcha!.sessionId,
        code: _codeController.text.trim(),
      );

      if (result.isSuccess) {
        final isValid = result.data ?? false;
        _setStatus(isValid ? '验证码验证成功' : '验证码验证失败');
        _updateResult('验证码验证结果: ${isValid ? "正确" : "错误"}');
      } else {
        _setStatus('验证码验证失败: ${result.msg}');
        _updateResult('验证码验证失败: ${result.msg}');
      }
    } catch (e) {
      _setStatus('验证码验证异常: $e');
      _updateResult('验证码验证异常: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 获取短信验证码
  Future<void> _getSmsCode() async {
    if (_phoneController.text.trim().isEmpty) {
      _setStatus('请输入手机号');
      return;
    }

    _setLoading(true);
    _setStatus('正在获取短信验证码...');

    try {
      final result = await _captchaService.getSmsCode(
        phone: _phoneController.text.trim(),
      );

      if (result.isSuccess && result.data != null) {
        setState(() {
          _currentCaptcha = result.data;
        });
        _setStatus('短信验证码发送成功');
        _updateResult('短信验证码发送成功: ${result.data!.sessionId}');
      } else {
        _setStatus('短信验证码发送失败: ${result.msg}');
        _updateResult('短信验证码发送失败: ${result.msg}');
      }
    } catch (e) {
      _setStatus('短信验证码发送异常: $e');
      _updateResult('短信验证码发送异常: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 获取邮箱验证码
  Future<void> _getEmailCode() async {
    if (_emailController.text.trim().isEmpty) {
      _setStatus('请输入邮箱地址');
      return;
    }

    // _setLoading(true);
    _setStatus('正在获取邮箱验证码...');

    final result = await _captchaService.getEmailCode(
      email: _emailController.text.trim(),
    );

    if (result.isSuccess && result.data != null) {
      setState(() {
        _currentCaptcha = result.data;
      });
      _setStatus('邮箱验证码发送成功');
      _updateResult('邮箱验证码发送成功: ${result.data!.sessionId}');
    } else {
      _setStatus('邮箱验证码发送失败: ${result.msg}');
      _updateResult('邮箱验证码发送失败: ${result.msg}');
    }
    throw Exception('测试异常');
  }

  /// 清除验证码
  void _clearCaptcha() {
    _captchaService.clearCurrentCaptcha();
    setState(() {
      _currentCaptcha = null;
      _codeController.clear();
    });
    _setStatus('验证码已清除');
    _updateResult('验证码已清除');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('验证码服务测试'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _getCaptcha,
            tooltip: '获取新验证码',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildImageCaptchaSection(),
            const SizedBox(height: 16),
            _buildSmsSection(),
            const SizedBox(height: 16),
            _buildEmailSection(),
            const SizedBox(height: 16),
            _buildResultSection(),
          ],
        ),
      ),
    );
  }

  /// 构建状态卡片
  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  '状态信息',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('处理中...'),
                ],
              )
            else
              Text(
                _statusMessage.isEmpty ? '准备就绪' : _statusMessage,
                style: TextStyle(
                  color:
                      _statusMessage.contains('失败') ||
                              _statusMessage.contains('异常')
                          ? Colors.red
                          : _statusMessage.contains('成功')
                          ? Colors.green
                          : null,
                ),
              ),
            if (_currentCaptcha != null) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              _buildCaptchaInfo(),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建验证码信息
  Widget _buildCaptchaInfo() {
    if (_currentCaptcha == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('当前验证码信息:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('会话ID: ${_currentCaptcha!.sessionId}'),
        Text('类型: ${_currentCaptcha!.type.description}'),
        Text('长度: ${_currentCaptcha!.length}'),
        Text('过期时间: ${_currentCaptcha!.expireSeconds}秒'),
        Text('创建时间: ${_currentCaptcha!.createdAt.toString().substring(0, 19)}'),
        Text(
          '状态: ${_currentCaptcha!.isExpired
              ? "已过期"
              : _currentCaptcha!.isExpiringSoon
              ? "即将过期"
              : "有效"}',
          style: TextStyle(
            color:
                _currentCaptcha!.isExpired
                    ? Colors.red
                    : _currentCaptcha!.isExpiringSoon
                    ? Colors.orange
                    : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 构建图形验证码区域
  Widget _buildImageCaptchaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.image, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '图形验证码',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 验证码图片显示区域
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildImageCaptcha(),
            ),
            const SizedBox(height: 16),
            // 验证码输入框
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: '请输入验证码',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.keyboard),
              ),
              maxLength: 6,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _verifyCaptcha(),
            ),
            const SizedBox(height: 16),
            // 操作按钮
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _getCaptcha,
                  icon: const Icon(Icons.refresh),
                  label: const Text('获取验证码'),
                ),
                ElevatedButton.icon(
                  onPressed:
                      _isLoading || _currentCaptcha == null
                          ? null
                          : _refreshCaptcha,
                  icon: const Icon(Icons.refresh_outlined),
                  label: const Text('刷新验证码'),
                ),
                ElevatedButton.icon(
                  onPressed:
                      _isLoading ||
                              _currentCaptcha == null ||
                              _codeController.text.trim().isEmpty
                          ? null
                          : _verifyCaptcha,
                  icon: const Icon(Icons.check),
                  label: const Text('验证验证码'),
                ),
                OutlinedButton.icon(
                  onPressed: _currentCaptcha == null ? null : _clearCaptcha,
                  icon: const Icon(Icons.clear),
                  label: const Text('清除验证码'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildImageCaptcha() {
    if (_currentCaptcha != null &&
        _currentCaptcha!.type == CaptchaTypeEnum.image) {
      var imageBase64 = _currentCaptcha!.imageBase64.substring(
        22,
        _currentCaptcha!.imageBase64.length,
      );
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          base64Decode("111" + imageBase64),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text('图片加载失败', style: TextStyle(color: Colors.red)),
            );
          },
        ),
      );
    } else {
      return const Center(
        child: Text('点击"获取验证码"按钮获取图形验证码', style: TextStyle(color: Colors.grey)),
      );
    }
  }

  /// 构建短信验证码区域
  Widget _buildSmsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sms, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  '短信验证码',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '请输入手机号',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
                hintText: '例: 13800138000',
              ),
              keyboardType: TextInputType.phone,
              maxLength: 11,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _getSmsCode(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _getSmsCode,
                icon: const Icon(Icons.send),
                label: const Text('获取短信验证码'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建邮箱验证码区域
  Widget _buildEmailSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.email, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  '邮箱验证码',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '请输入邮箱地址',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
                hintText: '例: user@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _getEmailCode(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _getEmailCode,
                icon: const Icon(Icons.send),
                label: const Text('获取邮箱验证码'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建结果显示区域
  Widget _buildResultSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  '操作结果',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _lastResult.isEmpty ? '暂无操作结果' : _lastResult,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _lastResult = '';
                      });
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('清除结果'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _lastResult.isEmpty
                            ? null
                            : () {
                              Clipboard.setData(
                                ClipboardData(text: _lastResult),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('结果已复制到剪贴板')),
                              );
                            },
                    icon: const Icon(Icons.copy),
                    label: const Text('复制结果'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
