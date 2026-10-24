import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/auth/supabase_auth_service.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/providers/auth_provider.dart';

/// Full-screen Google sign-in view shown when no Supabase session exists.
///
/// This screen appears **before** the existing PIN/biometric gate and
/// does not replace it. After a successful Google sign-in, the account
/// gate transitions to [AuthView] which handles the local PIN flow.
class GoogleSignInView extends ConsumerStatefulWidget {
  const GoogleSignInView({super.key});

  @override
  ConsumerState<GoogleSignInView> createState() => _GoogleSignInViewState();
}

class _GoogleSignInViewState extends ConsumerState<GoogleSignInView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _slideUp;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final SupabaseAuthService service = ref.read(supabaseAuthServiceProvider);
      await service.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Sign-in failed. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          child: FadeTransition(
            opacity: _fadeIn,
            child: AnimatedBuilder(
              animation: _slideUp,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _slideUp.value),
                child: child,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ── App branding ──
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
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

                  const Spacer(flex: 2),

                  // ── Sign-in section ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sign in to sync your data\nacross devices',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color: isDark
                                ? Colors.white70
                                : AppColors.getLigthGreyColor,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Google sign-in button ──
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              foregroundColor: isDark
                                  ? Colors.white
                                  : AppColors.getPrimaryTextColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : Colors.black.withValues(alpha: 0.12),
                                ),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _isLoading ? null : _handleGoogleSignIn,
                            icon: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: isDark
                                          ? Colors.white70
                                          : AppColors.getPrimaryColor,
                                    ),
                                  )
                                : Icon(
                                    Icons.g_mobiledata_rounded,
                                    size: 28,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.getPrimaryColor,
                                  ),
                            label: Text(
                              _isLoading
                                  ? 'Signing in...'
                                  : 'Continue with Google',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),

                        // ── Error message ──
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.getErrorColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 16,
                                  color: AppColors.getErrorColor,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.getErrorColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Trust indicators ──
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
                        "Your data stays on your device",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                          color: AppColors.getLigthGreyColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
