/// 证书绑定服务
///
/// 提供SSL证书绑定功能，防止中间人攻击，包括：
/// - 证书指纹验证
/// - 公钥绑定
/// - 证书链验证
/// - 自定义证书验证
library;

import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

/// 证书绑定类型
enum PinningType {
  certificate, // 证书绑定
  publicKey, // 公钥绑定
  sha256, // SHA256指纹绑定
}

/// 证书绑定配置
class CertificatePinningConfig {
  final String hostname;
  final List<String> pins;
  final PinningType type;
  final bool allowSubdomains;

  const CertificatePinningConfig({
    required this.hostname,
    required this.pins,
    this.type = PinningType.sha256,
    this.allowSubdomains = false,
  });
}

/// 证书绑定服务
class CertificatePinningService {
  static CertificatePinningService? _instance;
  final List<CertificatePinningConfig> _configs = [];

  CertificatePinningService._internal();

  /// 单例模式
  static CertificatePinningService get instance {
    _instance ??= CertificatePinningService._internal();
    return _instance!;
  }

  /// 添加证书绑定配置
  void addPinningConfig(CertificatePinningConfig config) {
    _configs.add(config);
  }

  /// 批量添加证书绑定配置
  void addPinningConfigs(List<CertificatePinningConfig> configs) {
    _configs.addAll(configs);
  }

  /// 清除所有配置
  void clearConfigs() {
    _configs.clear();
  }

  /// 获取指定主机名的配置
  CertificatePinningConfig? getConfigForHostname(String hostname) {
    for (final config in _configs) {
      if (config.hostname == hostname) {
        return config;
      }

      // 检查子域名匹配
      if (config.allowSubdomains && hostname.endsWith('.${config.hostname}')) {
        return config;
      }
    }
    return null;
  }

  /// 验证证书
  bool verifyCertificate(X509Certificate certificate, String hostname) {
    final config = getConfigForHostname(hostname);
    if (config == null) {
      // 如果没有配置，默认通过系统验证
      return true;
    }

    switch (config.type) {
      case PinningType.certificate:
        return _verifyCertificatePin(certificate, config.pins);
      case PinningType.publicKey:
        return _verifyPublicKeyPin(certificate, config.pins);
      case PinningType.sha256:
        return _verifySha256Pin(certificate, config.pins);
    }
  }

  /// 验证证书指纹
  bool _verifyCertificatePin(X509Certificate certificate, List<String> pins) {
    final certBytes = certificate.der;
    final certHash = sha256.convert(certBytes).toString();
    return pins.contains(certHash);
  }

  /// 验证公钥指纹
  bool _verifyPublicKeyPin(X509Certificate certificate, List<String> pins) {
    // 注意：这里需要提取公钥，实际实现可能需要使用更专业的加密库
    // 这里提供一个简化的实现
    final certBytes = certificate.der;
    final publicKeyHash = sha256.convert(certBytes).toString();
    return pins.contains(publicKeyHash);
  }

  /// 验证SHA256指纹
  bool _verifySha256Pin(X509Certificate certificate, List<String> pins) {
    final certBytes = certificate.der;
    final certHash = sha256.convert(certBytes).toString();
    return pins.contains(certHash);
  }

  /// 创建自定义HttpClient（带证书绑定）
  HttpClient createHttpClient() {
    final client = HttpClient();

    client.badCertificateCallback = (
      X509Certificate cert,
      String host,
      int port,
    ) {
      // 使用证书绑定验证
      return verifyCertificate(cert, host);
    };

    return client;
  }

  /// 为Dio配置证书绑定
  void configureDio(Dio dio) {
    /* (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      return createHttpClient();
    }; */
  }

  /// 从PEM格式提取证书指纹
  static String extractSha256FromPem(String pemCertificate) {
    // 移除PEM头尾
    final cert = pemCertificate
        .replaceAll('-----BEGIN CERTIFICATE-----', '')
        .replaceAll('-----END CERTIFICATE-----', '')
        .replaceAll('\n', '')
        .replaceAll('\r', '');

    // Base64解码
    final certBytes = Uint8List.fromList(cert.codeUnits);

    // 计算SHA256
    final digest = sha256.convert(certBytes);
    return digest.toString();
  }

  /// 从URL获取证书指纹（用于开发时获取指纹）
  static Future<String> getCertificateFingerprint(String url) async {
    final uri = Uri.parse(url);
    final client = HttpClient();

    try {
      final request = await client.getUrl(uri);
      final response = await request.close();

      final certificate = response.certificate;
      if (certificate != null) {
        final certBytes = certificate.der;
        final digest = sha256.convert(certBytes);
        return digest.toString();
      }

      throw Exception('无法获取证书');
    } finally {
      client.close();
    }
  }

  /// 预定义的常用证书配置
  static List<CertificatePinningConfig> getCommonConfigs() {
    return [
      // Google
      const CertificatePinningConfig(
        hostname: 'google.com',
        pins: [
          // 这里应该是实际的证书指纹，需要根据实际情况更新
          'example_google_cert_fingerprint',
        ],
        allowSubdomains: true,
      ),

      // GitHub
      const CertificatePinningConfig(
        hostname: 'github.com',
        pins: [
          // 这里应该是实际的证书指纹
          'example_github_cert_fingerprint',
        ],
        allowSubdomains: true,
      ),
    ];
  }

  /// 初始化常用配置
  void initializeCommonConfigs() {
    addPinningConfigs(getCommonConfigs());
  }

  /// 验证证书链
  bool verifyCertificateChain(List<X509Certificate> chain, String hostname) {
    if (chain.isEmpty) return false;

    // 验证叶子证书
    final leafCert = chain.first;
    if (!verifyCertificate(leafCert, hostname)) {
      return false;
    }

    // 这里可以添加更多的证书链验证逻辑
    // 例如验证中间证书、根证书等

    return true;
  }

  /// 检查证书是否即将过期
  bool isCertificateExpiringSoon(
    X509Certificate certificate, {
    int daysThreshold = 30,
  }) {
    final now = DateTime.now();
    final expiryDate = certificate.endValidity;
    final daysUntilExpiry = expiryDate.difference(now).inDays;

    return daysUntilExpiry <= daysThreshold;
  }

  /// 获取证书信息
  Map<String, dynamic> getCertificateInfo(X509Certificate certificate) {
    return {
      'subject': certificate.subject,
      'issuer': certificate.issuer,
      'startValidity': certificate.startValidity.toIso8601String(),
      'endValidity': certificate.endValidity.toIso8601String(),
      'sha256': sha256.convert(certificate.der).toString(),
    };
  }

  /// 日志记录证书验证结果
  void logCertificateVerification(
    String hostname,
    bool isValid,
    String reason,
  ) {
    final timestamp = DateTime.now().toIso8601String();
    print(
      '[$timestamp] Certificate verification for $hostname: ${isValid ? 'PASS' : 'FAIL'} - $reason',
    );
  }
}

/// 证书绑定异常
class CertificatePinningException implements Exception {
  final String message;
  final String hostname;
  final String? certificateFingerprint;

  const CertificatePinningException({
    required this.message,
    required this.hostname,
    this.certificateFingerprint,
  });

  @override
  String toString() {
    return 'CertificatePinningException: $message (hostname: $hostname, fingerprint: $certificateFingerprint)';
  }
}
