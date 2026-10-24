import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/sync/sync_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/providers/auth_provider.dart';
import 'package:self_finance/views/google_sign_in_view.dart';

class CloudSyncTile extends ConsumerWidget {
  const CloudSyncTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudUser = ref.watch(currentUserProvider);
    final syncState = ref.watch(syncProvider);

    const String title = 'Cloud Backup & Sync';
    final String subtitle;
    final Widget trailing;

    if (cloudUser == null) {
      subtitle = 'Not connected • Tap to sign in with Google';
      trailing = const Icon(
        Icons.login_rounded,
        color: AppColors.getPrimaryColor,
      );
    } else {
      final email = cloudUser.email ?? 'Connected';
      final statusDesc = switch (syncState.status) {
        SyncStatus.syncing => 'Syncing now...',
        SyncStatus.error =>
          'Sync error: ${syncState.errorMessage ?? "Tap to retry"}',
        SyncStatus.success =>
          syncState.lastSyncTime != null
              ? 'Synced at ${_formatTime(syncState.lastSyncTime!)}'
              : 'Up to date',
        SyncStatus.idle => 'Tap to sync now',
      };
      subtitle = '$email\n$statusDesc';

      if (syncState.status == SyncStatus.syncing) {
        trailing = const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        );
      } else if (syncState.status == SyncStatus.error) {
        trailing = const Icon(
          Icons.sync_problem_rounded,
          color: AppColors.getErrorColor,
        );
      } else {
        trailing = const Icon(
          Icons.sync_rounded,
          color: AppColors.getPrimaryColor,
        );
      }
    }

    return Card(
      child: ListTile(
        leading: Icon(
          cloudUser != null
              ? Icons.cloud_done_rounded
              : Icons.cloud_off_rounded,
          color: cloudUser != null
              ? (syncState.status == SyncStatus.error
                    ? AppColors.getErrorColor
                    : AppColors.getPrimaryColor)
              : AppColors.getLigthGreyColor,
          size: 32,
        ),
        title: const BodyOneDefaultText(text: title, bold: true),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: BodyTwoDefaultText(
            text: subtitle,
            color: syncState.status == SyncStatus.error
                ? AppColors.getErrorColor
                : null,
          ),
        ),
        trailing: trailing,
        isThreeLine: cloudUser != null,
        onTap: () async {
          HapticFeedback.selectionClick();
          if (cloudUser == null) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const GoogleSignInView()));
          } else {
            if (syncState.status == SyncStatus.syncing) return;
            await ref.read(syncProvider.notifier).syncNow();
            if (context.mounted) {
              final nextState = ref.read(syncProvider);
              if (nextState.status == SyncStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sync failed: ${nextState.errorMessage}'),
                    backgroundColor: AppColors.getErrorColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cloud sync completed successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          }
        },
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
