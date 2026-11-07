import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/sync/sync_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/providers/auth_provider.dart';
import 'package:self_finance/views/google_sign_in_view.dart';

/// A dashboard widget for Settings that displays real-time sync status,
/// last synchronized timestamp, pending offline outbox count, and detailed metrics.
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final syncState = ref.watch(syncProvider);
    final pendingCountAsync = ref.watch(pendingOutboxCountProvider);
    final pendingCount = pendingCountAsync.value ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.getPrimaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    user != null
                        ? Icons.cloud_sync_rounded
                        : Icons.cloud_off_rounded,
                    color: AppColors.getPrimaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BodyOneDefaultText(
                        text: 'Cloud Backup & Sync',
                        bold: true,
                      ),
                      const SizedBox(height: 2),
                      BodySmallText(
                        text: user?.email ?? 'Not connected • Tap to sign in',
                        color: user != null
                            ? AppColors.getLigthGreyColor
                            : AppColors.getPrimaryColor,
                      ),
                    ],
                  ),
                ),
                if (user != null)
                  IconButton(
                    icon: syncState.status == SyncStatus.syncing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.info_outline_rounded, size: 20),
                    tooltip: 'Sync Metrics & Details',
                    onPressed: () => _showSyncMetricsSheet(context, ref),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Status & Metrics Pills ──
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Connectivity Chip
                _buildStatusPill(
                  context,
                  icon: syncState.isOnline
                      ? Icons.wifi_rounded
                      : Icons.wifi_off_rounded,
                  label: syncState.isOnline ? 'Online' : 'Offline',
                  color: syncState.isOnline
                      ? AppColors.getGreenColor
                      : Colors.amber.shade800,
                  bgColor: syncState.isOnline
                      ? AppColors.getGreenColor.withValues(alpha: 0.12)
                      : Colors.amber.withValues(alpha: 0.15),
                ),

                // Sync State Chip
                _buildSyncStatePill(context, syncState),

                // Pending Outbox Chip
                _buildStatusPill(
                  context,
                  icon: pendingCount > 0
                      ? Icons.outbox_rounded
                      : Icons.check_circle_outline_rounded,
                  label: pendingCount > 0
                      ? '$pendingCount pending'
                      : 'Queue clear',
                  color: pendingCount > 0
                      ? AppColors.getPrimaryColor
                      : AppColors.getGreenColor,
                  bgColor: pendingCount > 0
                      ? AppColors.getPrimaryColor.withValues(alpha: 0.12)
                      : AppColors.getGreenColor.withValues(alpha: 0.12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Last Sync Timestamp & Action ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: BodySmallText(
                    text: _formatLastSync(syncState.lastSyncTime),
                    color: AppColors.getLigthGreyColor,
                  ),
                ),
                if (user == null)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GoogleSignInView(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.login_rounded, size: 16),
                    label: const Text(
                      'Sign In',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )
                else
                  FilledButton.icon(
                    onPressed: syncState.status == SyncStatus.syncing
                        ? null
                        : () async {
                            HapticFeedback.selectionClick();
                            await ref
                                .read(syncProvider.notifier)
                                .syncNow(forceFullSync: true);
                            if (context.mounted) {
                              final current = ref.read(syncProvider);
                              if (current.status == SyncStatus.error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Sync failed: ${current.errorMessage}',
                                    ),
                                    backgroundColor: AppColors.getErrorColor,
                                  ),
                                );
                              }
                            }
                          },
                    icon: syncState.status == SyncStatus.syncing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.sync_rounded, size: 16),
                    label: Text(
                      syncState.status == SyncStatus.syncing
                          ? 'Syncing...'
                          : 'Sync Now',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.getPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      minimumSize: const Size(90, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatePill(BuildContext context, SyncState state) {
    final (icon, label, color, bg) = switch (state.status) {
      SyncStatus.syncing => (
        Icons.sync_rounded,
        'Syncing...',
        AppColors.getPrimaryColor,
        AppColors.getPrimaryColor.withValues(alpha: 0.12),
      ),
      SyncStatus.error => (
        Icons.error_outline_rounded,
        'Sync Failed',
        AppColors.getErrorColor,
        AppColors.getErrorColor.withValues(alpha: 0.12),
      ),
      SyncStatus.success => (
        Icons.cloud_done_rounded,
        'Up to date',
        AppColors.getGreenColor,
        AppColors.getGreenColor.withValues(alpha: 0.12),
      ),
      SyncStatus.idle => (
        Icons.cloud_queue_rounded,
        'Idle',
        AppColors.getLigthGreyColor,
        AppColors.getLigthGreyColor.withValues(alpha: 0.12),
      ),
    };

    return _buildStatusPill(
      context,
      icon: icon,
      label: label,
      color: color,
      bgColor: bg,
    );
  }

  Widget _buildStatusPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastSync(DateTime? time) {
    if (time == null) return 'Not synced yet';
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return 'Last synced: Just now';
    if (diff.inMinutes < 60) return 'Last synced: ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Last synced: ${diff.inHours}h ago';
    return 'Last synced: ${DateFormat('dd MMM, hh:mm a').format(time.toLocal())}';
  }

  void _showSyncMetricsSheet(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    final syncState = ref.read(syncProvider);
    final pendingCount = ref.read(pendingOutboxCountProvider).value ?? 0;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.getLigthGreyColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      color: AppColors.getPrimaryColor,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    BodyOneDefaultText(text: 'Cloud Sync Metrics', bold: true),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMetricTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Account',
                  value: user?.email ?? 'Anonymous',
                ),
                _buildMetricTile(
                  icon: syncState.isOnline
                      ? Icons.wifi_rounded
                      : Icons.wifi_off_rounded,
                  title: 'Network Connection',
                  value: syncState.isOnline
                      ? 'Online (Connected)'
                      : 'Offline (No internet)',
                  valueColor: syncState.isOnline
                      ? Colors.green
                      : Colors.amber.shade800,
                ),
                _buildMetricTile(
                  icon: Icons.outbox_rounded,
                  title: 'Pending Offline Mutations',
                  value: pendingCount > 0
                      ? '$pendingCount pending push'
                      : '0 (Fully synced)',
                ),
                _buildMetricTile(
                  icon: Icons.schedule_rounded,
                  title: 'Last Synchronization',
                  value: syncState.lastSyncTime != null
                      ? DateFormat(
                          'yyyy-MM-dd HH:mm:ss',
                        ).format(syncState.lastSyncTime!.toLocal())
                      : 'Never',
                ),
                if (syncState.status == SyncStatus.error &&
                    syncState.errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.getErrorColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.getErrorColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BodySmallText(text: 'Last Sync Error'),
                        const SizedBox(height: 4),
                        BodySmallText(
                          text: syncState.errorMessage!,
                          color: AppColors.getErrorColor,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ref
                          .read(syncProvider.notifier)
                          .syncNow(forceFullSync: true);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.getPrimaryColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.sync_rounded, size: 18),
                    label: const BodySmallText(text: 'Sync Now', whiteColor: true),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.getPrimaryColor),
          const SizedBox(width: 10),
          Expanded(child: BodyTwoDefaultText(text: title)),
          BodySmallText(text: value, color: valueColor),
        ],
      ),
    );
  }
}
