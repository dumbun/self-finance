import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/providers/app_dir_provider.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/views/auth_view.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
    _initApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initApp() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      await Utility.appInit();

      // Pre-warm user state and appDir while splash screen is active so that
      // AuthView and PinAuthView can render immediately without flashing a circular loading screen.
      await Future.wait([
        ref.read(userProvider.future).timeout(
              const Duration(seconds: 2),
              onTimeout: () => null,
            ),
        ref.read(appDirProvider.future).timeout(
              const Duration(seconds: 2),
              onTimeout: () => '',
            ),
      ]);
    } catch (e) {
      debugPrint('Initialization error: $e');
    }

    // Ensure splash is visible for at least 1200ms so animation is smooth and not a flash
    final int elapsed = stopwatch.elapsedMilliseconds;
    const int minDuration = 1200;
    if (elapsed < minDuration) {
      await Future.delayed(Duration(milliseconds: minDuration - elapsed));
    }

    if (!mounted) return;

    Utility.backgroundServicesInit();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthView(),
        transitionDuration: const Duration(milliseconds: 550),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: scaffoldBg,
          gradient: RadialGradient(
            radius: 0.9,
            colors: isDark
                ? [
                    AppColors.getPrimaryColor.withValues(alpha: 0.12),
                    scaffoldBg,
                  ]
                : [
                    AppColors.getPrimaryColor.withValues(alpha: 0.06),
                    scaffoldBg,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: AppColors.getPrimaryColor.withValues(
                              alpha: 0.18,
                            ),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.getPrimaryColor.withValues(
                                alpha: isDark ? 0.28 : 0.15,
                              ),
                              blurRadius: 40,
                              spreadRadius: 4,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/icon/icon_only.png',
                          height: 84,
                          width: 84,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        Constant.appTitle,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: isDark
                              ? Colors.white
                              : AppColors.getPrimaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Personal Lending & Finance",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                          color: AppColors.getLigthGreyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 140,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          minHeight: 3.5,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : AppColors.getPrimaryColor.withValues(
                                  alpha: 0.12,
                                ),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.getPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 13,
                          color: AppColors.getLigthGreyColor,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "100% Offline & Secure",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                            color: AppColors.getLigthGreyColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
