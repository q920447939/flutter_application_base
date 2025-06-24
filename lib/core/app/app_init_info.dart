import 'package:flutter/widgets.dart';

import '../permissions/platform_detector.dart';

class AppInitInfo {
  final ScreenRatio screenRatio;
  final Widget child;
  final bool openDevicePreview;

  AppInitInfo({
    required this.child,
    ScreenRatio? screenRatio,
    this.openDevicePreview = false,
  }) : screenRatio = screenRatio ?? ScreenRatio();
}

class ScreenRatio {
  final double aspectRatio;

  ScreenRatio({double? aspectRatio})
    : aspectRatio = aspectRatio ?? _getDefaultAspectRatio();

  /// 根据平台获取默认宽高比
  static double _getDefaultAspectRatio() {
    final platformDetector = PlatformDetector.instance;

    if (platformDetector.isMobile) {
      // 手机默认 16:9
      return 16.0 / 9.0;
    } else {
      //  默认不设置 (-1)
      return -1.0;
    }
  }
}
