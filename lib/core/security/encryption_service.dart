/// 加密服务
///
/// 提供数据加密和解密功能，包括：
/// - AES 对称加密
/// - RSA 非对称加密
/// - 哈希算法
/// - 密钥管理
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// 加密算法类型
enum EncryptionType { aes256, sha256, md5, base64 }

/// 加密服务类
class EncryptionService {
  static EncryptionService? _instance;

  EncryptionService._internal();

  /// 单例模式
  static EncryptionService get instance {
    _instance ??= EncryptionService._internal();
    return _instance!;
  }

  /// 生成随机密钥
  String generateRandomKey(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// 生成随机盐值
  String generateSalt([int length = 16]) {
    return generateRandomKey(length);
  }

  /// SHA256 哈希
  String sha256Hash(String input, [String? salt]) {
    final data = salt != null ? '$input$salt' : input;
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// MD5 哈希
  String md5Hash(String input, [String? salt]) {
    final data = salt != null ? '$input$salt' : input;
    final bytes = utf8.encode(data);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Base64 编码
  String base64Encode(String input) {
    final bytes = utf8.encode(input);
    return base64.encode(bytes);
  }

  /// Base64 解码
  String base64Decode(String encoded) {
    final bytes = base64.decode(encoded);
    return utf8.decode(bytes);
  }

  /// HMAC-SHA256 签名
  String hmacSha256(String message, String key) {
    final keyBytes = utf8.encode(key);
    final messageBytes = utf8.encode(message);
    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(messageBytes);
    return digest.toString();
  }

  /// 验证 HMAC-SHA256 签名
  bool verifyHmacSha256(String message, String key, String signature) {
    final expectedSignature = hmacSha256(message, key);
    return expectedSignature == signature;
  }

  /// 简单的字符串加密（基于异或运算）
  String simpleEncrypt(String input, String key) {
    final inputBytes = utf8.encode(input);
    final keyBytes = utf8.encode(key);
    final encrypted = <int>[];

    for (int i = 0; i < inputBytes.length; i++) {
      encrypted.add(inputBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64.encode(encrypted);
  }

  /// 简单的字符串解密（基于异或运算）
  String simpleDecrypt(String encrypted, String key) {
    try {
      final encryptedBytes = base64.decode(encrypted);
      final keyBytes = utf8.encode(key);
      final decrypted = <int>[];

      for (int i = 0; i < encryptedBytes.length; i++) {
        decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(decrypted);
    } catch (e) {
      throw Exception('解密失败: $e');
    }
  }

  /// 密码哈希（带盐值）
  PasswordHash hashPassword(String password, [String? salt]) {
    salt ??= generateSalt();
    final hash = sha256Hash(password, salt);
    return PasswordHash(hash: hash, salt: salt);
  }

  /// 验证密码
  bool verifyPassword(String password, String hash, String salt) {
    final computedHash = sha256Hash(password, salt);
    return computedHash == hash;
  }

  /// 生成API签名
  String generateApiSignature({
    required String method,
    required String path,
    required Map<String, dynamic> params,
    required String secretKey,
    int? timestamp,
  }) {
    timestamp ??= DateTime.now().millisecondsSinceEpoch;

    // 构建签名字符串
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    final paramString = sortedParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final signString = '$method$path$paramString$timestamp';

    return hmacSha256(signString, secretKey);
  }

  /// 验证API签名
  bool verifyApiSignature({
    required String method,
    required String path,
    required Map<String, dynamic> params,
    required String secretKey,
    required String signature,
    required int timestamp,
    int toleranceSeconds = 300, // 5分钟容差
  }) {
    // 检查时间戳是否在容差范围内
    final now = DateTime.now().millisecondsSinceEpoch;
    if ((now - timestamp).abs() > toleranceSeconds * 1000) {
      return false;
    }

    // 验证签名
    final expectedSignature = generateApiSignature(
      method: method,
      path: path,
      params: params,
      secretKey: secretKey,
      timestamp: timestamp,
    );

    return expectedSignature == signature;
  }

  /// 生成UUID
  String generateUuid() {
    final random = Random.secure();
    final bytes = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      bytes[i] = random.nextInt(256);
    }

    // 设置版本号和变体
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // 版本4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // 变体

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  /// 生成随机Token
  String generateToken([int length = 32]) {
    return generateRandomKey(length);
  }

  /// 数据完整性校验
  String calculateChecksum(String data) {
    return sha256Hash(data);
  }

  /// 验证数据完整性
  bool verifyChecksum(String data, String checksum) {
    return calculateChecksum(data) == checksum;
  }

  /// 敏感信息脱敏
  String maskSensitiveInfo(
    String input, {
    int prefixLength = 3,
    int suffixLength = 4,
    String maskChar = '*',
  }) {
    if (input.length <= prefixLength + suffixLength) {
      return maskChar * input.length;
    }

    final prefix = input.substring(0, prefixLength);
    final suffix = input.substring(input.length - suffixLength);
    final maskLength = input.length - prefixLength - suffixLength;
    final mask = maskChar * maskLength;

    return '$prefix$mask$suffix';
  }

  /// 手机号脱敏
  String maskPhoneNumber(String phoneNumber) {
    return maskSensitiveInfo(phoneNumber, prefixLength: 3, suffixLength: 4);
  }

  /// 身份证号脱敏
  String maskIdCard(String idCard) {
    return maskSensitiveInfo(idCard, prefixLength: 6, suffixLength: 4);
  }

  /// 银行卡号脱敏
  String maskBankCard(String bankCard) {
    return maskSensitiveInfo(bankCard, prefixLength: 4, suffixLength: 4);
  }

  /// 邮箱脱敏
  String maskEmail(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex == -1) return email;

    final username = email.substring(0, atIndex);
    final domain = email.substring(atIndex);

    if (username.length <= 2) {
      //return '${maskChar * username.length}$domain';
      return '';
    }

    final maskedUsername = maskSensitiveInfo(
      username,
      prefixLength: 1,
      suffixLength: 1,
    );
    return '$maskedUsername$domain';
  }
}

/// 密码哈希结果
class PasswordHash {
  final String hash;
  final String salt;

  const PasswordHash({required this.hash, required this.salt});

  @override
  String toString() => 'PasswordHash(hash: $hash, salt: $salt)';

  Map<String, dynamic> toJson() => {'hash': hash, 'salt': salt};

  factory PasswordHash.fromJson(Map<String, dynamic> json) =>
      PasswordHash(hash: json['hash'] as String, salt: json['salt'] as String);
}
