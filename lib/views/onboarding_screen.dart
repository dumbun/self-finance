import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/fonts/title_widget.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/preferences_helper.dart';
import 'package:self_finance/models/onboarding_model.dart';
import 'package:self_finance/views/auth_view.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

/// First-launch onboarding.
/// Content of a single onboarding page.
///
/// Three swipeable pages that follow the same visual language as the splash
/// screen (primary colour, soft radial background, rounded icon card).
/// Completion is persisted through [PreferencesHelper.setOnboardingComplete].
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<OnboardingItem> _items = <OnboardingItem>[
    OnboardingItem(
      icon: Icons.lock_outline_rounded,
      title: 'Secure & Offline',
      subtitle: '100% private on your device',
      description:
          'Your ledger never leaves your phone. Protect it with a PIN or '
          'biometrics, and keep it safe with encrypted backups.',
    ),
    OnboardingItem(
      icon: Icons.auto_graph_rounded,
      title: 'Smart Interest',
      subtitle: 'Monthly rate, daily precision',
      description:
          'Interest, due time and total payable are calculated '
          'automatically, so you always know exactly what to collect.',
    ),
    OnboardingItem(
      icon: Icons.receipt_long_outlined,
      title: 'Manage Every Loan',
      subtitle: 'Built for shopkeepers & lenders',
      description:
          'Track customers, signatures and payments, share PDF receipts '
          'and export your records to CSV whenever you need.',
    ),
  ];

  static const Duration _pageDuration = Duration(milliseconds: 400);

  final PageController _controller = PageController();
  final ValueNotifier<int> _page = ValueNotifier<int>(0);
  bool _finishing = false;

  @override
  void dispose() {
    _controller.dispose();
    _page.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    HapticFeedback.lightImpact();
    if (_page.value < _items.length - 1) {
      await _controller.nextPage(
        duration: _pageDuration,
        curve: Curves.easeInOutCubic,
      );
    } else {
      await _finish();
    }
  }

  Future<void> _previous() {
    return _controller.previousPage(
      duration: _pageDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    HapticFeedback.mediumImpact();

    try {
      await PreferencesHelper.setOnboardingComplete(true);
    } catch (_) {
      // Non-critical: worst case onboarding is shown once more.
    }

    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const AuthView(),
        transitionDuration: const Duration(milliseconds: 550),
        transitionsBuilder: (_, Animation<double> animation, _, Widget child) {
          final CurvedAnimation curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
              child: child,
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

    return ValueListenableBuilder<int>(
      valueListenable: _page,
      builder: (BuildContext context, int page, _) {
        final bool isLast = page == _items.length - 1;

        return PopScope(
          // Back goes to the previous page; only the first page exits.
          canPop: page == 0,
          onPopInvokedWithResult: (bool didPop, _) {
            if (!didPop) _previous();
          },
          child: Scaffold(
            backgroundColor: scaffoldBg,
            body: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.9,
                  colors: <Color>[
                    AppColors.getPrimaryColor.withValues(
                      alpha: isDark ? 0.12 : 0.06,
                    ),
                    scaffoldBg,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    _Header(visibleSkip: !isLast, onSkip: _finish),
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: _items.length,
                        onPageChanged: (int i) => _page.value = i,
                        itemBuilder: (_, int i) => _OnboardingPage(
                          item: _items[i],
                          index: i,
                          controller: _controller,
                        ),
                      ),
                    ),
                    _Footer(
                      page: page,
                      count: _items.length,
                      isLast: isLast,
                      enabled: !_finishing,
                      onPressed: _next,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// HEADER
// =============================================================================

class _Header extends StatelessWidget {
  const _Header({required this.visibleSkip, required this.onSkip});

  final bool visibleSkip;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
      child: Row(
        children: <Widget>[
          Image.asset('assets/icon/icon_only.png', height: 36, width: 36),
          const SizedBox(width: 10),
          const BodyTwoDefaultText(text: Constant.appTitle, bold: true),
          const Spacer(),
          // Keeps layout stable while fading out on the last page.
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: visibleSkip ? 1 : 0,
            child: IgnorePointer(
              ignoring: !visibleSkip,
              child: TextButton(
                onPressed: onSkip,
                child: const BodyTwoDefaultText(
                  text: 'Skip',
                  bold: true,
                  color: AppColors.getLigthGreyColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAGE
// =============================================================================

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.item,
    required this.index,
    required this.controller,
  });

  final OnboardingItem item;
  final int index;
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    // Content is built once; only the fade/parallax wrapper rebuilds per frame.
    return AnimatedBuilder(
      animation: controller,
      child: _PageContent(item: item),
      builder: (BuildContext context, Widget? child) {
        double offset = 0;
        if (controller.hasClients && controller.position.haveDimensions) {
          offset = (controller.page ?? index.toDouble()) - index;
        }
        final double t = offset.abs().clamp(0.0, 1.0);

        return Opacity(
          opacity: 1 - t,
          child: Transform.translate(
            offset: Offset(-offset * 48, 0),
            child: child,
          ),
        );
      },
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.item});

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    // Scrolls on small screens / large font scale instead of overflowing.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _IconCard(icon: item.icon),
                const SizedBox(height: 40),
                TitleWidget(
                  text: item.title,
                  textAlign: TextAlign.center,
                  bold: true,
                ),
                const SizedBox(height: 12),
                _SubtitleChip(text: item.subtitle),
                const SizedBox(height: 20),
                BodyTwoDefaultText(
                  text: item.description,
                  textAlign: TextAlign.center,
                  color: AppColors.getLigthGreyColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Same look as the icon card on the splash screen.
class _IconCard extends StatelessWidget {
  const _IconCard({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ExcludeSemantics(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: AppColors.getPrimaryColor.withValues(alpha: 0.18),
            width: 1.5,
          ),
          boxShadow: <BoxShadow>[
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
        child: Icon(icon, size: 56, color: AppColors.getPrimaryColor),
      ),
    );
  }
}

class _SubtitleChip extends StatelessWidget {
  const _SubtitleChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.getPrimaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: BodySmallText(
        text: text,
        bold: true,
        color: AppColors.getPrimaryColor,
      ),
    );
  }
}

// =============================================================================
// FOOTER
// =============================================================================

class _Footer extends StatelessWidget {
  const _Footer({
    required this.page,
    required this.count,
    required this.isLast,
    required this.enabled,
    required this.onPressed,
  });

  final int page;
  final int count;
  final bool isLast;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: <Widget>[
          Semantics(
            label: 'Page ${page + 1} of $count',
            child: ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  count,
                  (int i) => _Dot(active: i == page),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          RoundedCornerButton(
            text: isLast ? 'Get Started' : 'Continue',
            onPressed: enabled ? onPressed : null,
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.shield_outlined,
                size: 13,
                color: AppColors.getLigthGreyColor,
              ),
              SizedBox(width: 6),
              BodySmallText(
                text: '100% Offline & Secure',
                color: AppColors.getLigthGreyColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: active
            ? AppColors.getPrimaryColor
            : AppColors.getPrimaryColor.withValues(alpha: 0.18),
      ),
    );
  }
}
