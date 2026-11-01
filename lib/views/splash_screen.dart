import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/backend/account_database_manager.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/views/account_gate.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final bool autoInit;

  const SplashScreen({super.key, this.autoInit = true});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;
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

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    if (widget.autoInit) {
      _initApp();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _initApp() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      await Utility.appInit();

      // Pre-warm the active account database during splash so the app can route
      // straight into the appropriate gate without an intermediate loading screen.
      if (Utility.isFirebaseInitialized) {
        final currentFirebaseUser = FirebaseAuth.instance.currentUser;
        if (currentFirebaseUser != null) {
          await AccountDatabaseManager.openForAccount(currentFirebaseUser.uid);
        }
      }

      await ref
          .read(userProvider.future)
          .timeout(const Duration(seconds: 2), onTimeout: () => null);
    } catch (e) {
      debugPrint('Initialization error: $e');
    }

    // Ensure splash is visible for at least 1200ms so animation is smooth and not a flash
    final int elapsed = stopwatch.elapsedMilliseconds;
    const int minDuration = 1200;
    if (elapsed < minDuration) {
      await Future.delayed(Duration(milliseconds: minDuration - elapsed));
    }

    await Utility.backgroundServicesInit();

    if (!mounted) return;

    // Route directly to AccountGate (Login / Session restore)
    const Widget destination = AccountGate();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionDuration: const Duration(milliseconds: 1200),
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
    return Scaffold(
      body: Stack(
        children: [
          // 1. Subtle, elegant ambient top gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.getPrimaryColor.withValues(alpha: 0.10),
                    AppColors.getTransparentColor,
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),

          // 2. Center ambient radial glow (animated breathing halo)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, _) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.15),
                      radius: 0.65 + (_glowAnimation.value * 0.15),
                      colors: [
                        AppColors.getPrimaryColor.withValues(
                          alpha: 0.12 + (_glowAnimation.value * 0.05),
                        ),
                        AppColors.getTransparentColor,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. Foreground Content
          SafeArea(
            child: SizedBox.expand(
              child: Column(
                children: [
                  const Spacer(flex: 5),

                  // Animated Logo & Branding
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Clean floating brand icon with diffused drop shadow
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.getPrimaryColor.withValues(
                                    alpha: 0.22,
                                  ),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.asset(
                                'assets/icon/icon_only.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            context.l10n.appTitle,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.l10n.appSubtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                              color: AppColors.getLigthGreyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 4),

                  // Subtle, elegant loading indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.getPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
