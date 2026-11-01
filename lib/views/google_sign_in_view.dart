import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(googleSignInProvider.notifier).handleAppResumed();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signInState = ref.watch(googleSignInProvider);
    final bool isLoading = signInState.isLoading;
    final String? errorMessage = signInState.errorMessage;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 0.9,
            colors: [
              AppColors.getPrimaryColor.withValues(alpha: 0.1),
              AppColors.getTransparentColor,
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
                      color: AppColors.getPrimaryColor.withValues(alpha: 0.08),
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
                            alpha: 0.2,
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
                    context.l10n.appTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.appSubtitle,
                    style: const TextStyle(
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
                          context.l10n.signInToSyncData,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color: AppColors.getLigthGreyColor,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Google sign-in button ──
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.getPrimaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            onPressed: isLoading
                                ? null
                                : () => ref
                                      .read(googleSignInProvider.notifier)
                                      .signInWithGoogle(),
                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.g_mobiledata_rounded,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              isLoading
                                  ? context.l10n.signingIn
                                  : context.l10n.continueWithGoogle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),

                        // ── Error message ──
                        if (errorMessage != null) ...[
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
                                    errorMessage,
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

                        const SizedBox(height: 18),

                        //// after implementing the phone number auth
                        // // ── Divider ──
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: Divider(
                        //         color: AppColors.getLigthGreyColor.withValues(
                        //           alpha: 0.25,
                        //         ),
                        //       ),
                        //     ),
                        //     const Padding(
                        //       padding: EdgeInsets.symmetric(horizontal: 12),
                        //       child: Text(
                        //         'OR',
                        //         style: TextStyle(
                        //           fontSize: 11,
                        //           fontWeight: FontWeight.bold,
                        //           color: AppColors.getLigthGreyColor,
                        //         ),
                        //       ),
                        //     ),
                        //     Expanded(
                        //       child: Divider(
                        //         color: AppColors.getLigthGreyColor.withValues(
                        //           alpha: 0.25,
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(height: 18),

                        // // ── Customer / Borrower Portal Button ──
                        // SizedBox(
                        //   width: double.infinity,
                        //   height: 52,
                        //   child: OutlinedButton.icon(
                        //     style: OutlinedButton.styleFrom(
                        //       foregroundColor: AppColors.getPrimaryColor,
                        //       side: const BorderSide(
                        //         color: AppColors.getPrimaryColor,
                        //         width: 1.5,
                        //       ),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(16),
                        //       ),
                        //     ),
                        //     onPressed: () {
                        //       Navigator.of(context).push(
                        //         MaterialPageRoute<void>(
                        //           builder: (_) => const CustomerLoginView(),
                        //         ),
                        //       );
                        //     },
                        //     icon: const Icon(
                        //       Icons.phone_android_rounded,
                        //       size: 20,
                        //     ),
                        //     label: Text(
                        //       context.l10n.customerLogin,
                        //       style: const TextStyle(
                        //         fontSize: 15,
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Trust indicators ──
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 13,
                        color: AppColors.getLigthGreyColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.yourDataStaysOnDevice,
                        style: const TextStyle(
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
