import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/providers/settings_provider.dart';

class ThemeToggleIconButton extends ConsumerWidget {
  const ThemeToggleIconButton({
    super.key,
    this.size = 22,
    this.padding = const EdgeInsets.all(10),
  });

  /// Icon size
  final double size;

  /// Tap target padding (keeps ~44x44+ hit area)
  final EdgeInsetsGeometry padding;

  /// Animation duration
  static final _kRotationTurns = Tween<double>(begin: 0.12, end: 0.0);
  static final _kScale = Tween<double>(begin: 0.92, end: 1.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(themeProvider)
        .when(
          data: (bool isDark) => Semantics(
            key: UniqueKey(),
            button: true,
            toggled: isDark,
            child: IconButton(
              tooltip: "Toggle themes",
              padding: padding,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              splashRadius: 24,
              onPressed: () async {
                HapticFeedback.selectionClick();
                await ref.read(themeProvider.notifier).toggle();
              },
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                layoutBuilder: (currentChild, previousChildren) {
                  // Prevent layout jumps between icons
                  return Stack(
                    alignment: Alignment.center,
                    children: <Widget>[...previousChildren, ?currentChild],
                  );
                },
                transitionBuilder: (child, anim) {
                  return RotationTransition(
                    turns: _kRotationTurns.animate(anim),
                    child: ScaleTransition(
                      scale: _kScale.animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                  );
                },
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  key: ValueKey<bool>(isDark),
                  size: size,
                  color: isDark ? null : AppColors.contentColorYellow,
                ),
              ),
            ),
          ),
          error: (_, _) => const SizedBox.shrink(),
          loading: () => const CircularProgressIndicator.adaptive(),
        );
  }
}
