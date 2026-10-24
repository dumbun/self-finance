import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/sync/sync_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';

class SyncIndicatorIconButton extends ConsumerStatefulWidget {
  const SyncIndicatorIconButton({
    super.key,
    this.padding = const EdgeInsets.all(10),
  });

  final EdgeInsetsGeometry padding;

  @override
  ConsumerState<SyncIndicatorIconButton> createState() =>
      _SyncIndicatorIconButtonState();
}

class _SyncIndicatorIconButtonState extends ConsumerState<SyncIndicatorIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncProvider);

    if (syncState.status == SyncStatus.syncing) {
      if (!_animController.isAnimating) {
        _animController.repeat();
      }
    } else {
      if (_animController.isAnimating) {
        _animController.stop();
        _animController.reset();
      }
    }

    final String tooltip = switch (syncState.status) {
      SyncStatus.syncing => 'Syncing with cloud...',
      SyncStatus.error =>
        'Sync failed: ${syncState.errorMessage ?? "Tap to retry"}',
      SyncStatus.success => syncState.lastSyncTime != null
          ? 'Synced at ${_formatTime(syncState.lastSyncTime!)}'
          : 'Cloud sync up to date',
      SyncStatus.idle => 'Tap to sync with cloud',
    };

    return Semantics(
      button: true,
      label: tooltip,
      child: IconButton(
        tooltip: tooltip,
        padding: widget.padding,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        splashRadius: 24,
        onPressed: syncState.status == SyncStatus.syncing
            ? null
            : () async {
                HapticFeedback.selectionClick();
                await ref.read(syncProvider.notifier).syncNow();
                if (context.mounted && ref.read(syncProvider).status == SyncStatus.error) {
                  final err = ref.read(syncProvider).errorMessage;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sync error: $err'),
                      backgroundColor: AppColors.getErrorColor,
                    ),
                  );
                }
              },
        icon: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            if (syncState.status == SyncStatus.syncing) {
              return Transform.rotate(
                angle: _animController.value * 2 * 3.1415926535,
                child: const Icon(
                  Icons.sync_rounded,
                  color: AppColors.getPrimaryColor,
                ),
              );
            }
            if (syncState.status == SyncStatus.error) {
              return const Icon(
                Icons.sync_problem_rounded,
                color: AppColors.getErrorColor,
              );
            }
            return const Icon(
              Icons.cloud_done_outlined,
              color: AppColors.getPrimaryColor,
            );
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
