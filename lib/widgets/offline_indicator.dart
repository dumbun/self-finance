import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/sync/sync_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';

/// A lightweight, non-intrusive badge that appears in the AppBar when connectivity is lost.
///
/// When online, this widget takes up zero space ([SizedBox.shrink]).
/// When offline, it displays an animated warning pill indicating that the app is operating
/// in offline-first mode and all changes are safely preserved locally.
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({
    super.key,
    this.margin = const EdgeInsets.only(right: 6),
  });

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: isOnline
          ? const SizedBox.shrink(key: ValueKey('online'))
          : Padding(
              key: const ValueKey('offline'),
              padding: margin,
              child: Tooltip(
                message: 'No internet connection. Changes will sync automatically when online.',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: const Row(
                            children: [
                              Icon(Icons.cloud_off_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Offline mode active. All data is saved safely and will sync when reconnected.',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          duration: const Duration(seconds: 3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.getErrorColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.getErrorColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 13,
                            color: AppColors.getErrorColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Offline',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.getErrorColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
