/// 启动页面
/// 
/// 应用启动时的加载页面
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ui/index.dart';
import '../../core/localization/app_localizations.dart';
import '../../features/auth/services/auth_service.dart';

/// 启动页面
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 初始化动画
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  /// 初始化应用
  Future<void> _initializeApp() async {
    // 等待动画完成
    await Future.delayed(const Duration(seconds: 3));

    // 检查用户登录状态
    final isAuthenticated = AuthService.instance.isAuthenticated;

    if (isAuthenticated) {
      // 已登录，跳转到主页
      Get.offAllNamed('/home');
    } else {
      // 未登录，跳转到登录页
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppBorders.borderRadiusXl,
                        boxShadow: AppShadows.xl,
                      ),
                      child: const Icon(
                        Icons.flutter_dash,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),

                    AppSpacing.verticalSpace32,

                    // 应用名称
                    Text(
                      S.appName,
                      style: AppTypography.headlineLargeStyle.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    AppSpacing.verticalSpace16,

                    // 版本信息
                    Text(
                      'v1.0.0',
                      style: AppTypography.bodyMediumStyle.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),

                    AppSpacing.verticalSpace48,

                    // 加载指示器
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white.withOpacity(0.8),
                        ),
                        strokeWidth: 3,
                      ),
                    ),

                    AppSpacing.verticalSpace16,

                    // 加载文本
                    Text(
                      S.loading,
                      style: AppTypography.bodyMediumStyle.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
