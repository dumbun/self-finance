import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/restore_utility.dart';
import 'package:self_finance/models/eta_model.dart';
import 'package:self_finance/models/restore_model.dart';

class RestoreWithProgressWidget extends StatefulWidget {
  const RestoreWithProgressWidget({super.key});

  @override
  State<RestoreWithProgressWidget> createState() =>
      _RestoreWithProgressWidgetState();
}

class _RestoreWithProgressWidgetState extends State<RestoreWithProgressWidget> {
  final ValueNotifier<RestoreUiState> _state = ValueNotifier(
    const RestoreUiState.idle(),
  );
  final EtaEstimator _eta = EtaEstimator();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Future<void> _startRestore() async {
    if (_state.value.isRunning) return;

    _eta.reset();
    _state.value = const RestoreUiState.running(progress: 0, currentFile: '');

    try {
      await RestoreUtility.restoreBackupFromZip(
        context: context,
        onProgress: (progress, currentFile) {
          final eta = _eta.update(progress);
          _state.value = RestoreUiState.running(
            progress: progress.clamp(0.0, 1.0),
            currentFile: currentFile,
            eta: eta,
          );
        },
      );

      // If restore triggers app restart, you may not see this state,
      // but it’s still correct for cases where restart is not immediate.
      _state.value = const RestoreUiState.success();
    } catch (e) {
      _state.value = RestoreUiState.error(e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RestoreUiState>(
      valueListenable: _state,
      builder: (context, s, _) {
        return Card(
          margin: EdgeInsets.all(12.sp),
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BodyOneDefaultText(text: 'Restore', bold: true),
                const SizedBox(height: 12),

                _HeaderLine(state: s),

                SizedBox(height: 10.sp),

                if (s.isRunning) ...[
                  LinearProgressIndicator(
                    value: s.progress == 0 ? null : s.progress,
                  ),
                  SizedBox(height: 8.sp),
                  Row(
                    children: [
                      Expanded(
                        child: BodyTwoDefaultText(
                          text: 'Restoring: ${_truncate(s.currentFile)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      BodyTwoDefaultText(
                        text: s.eta == null
                            ? 'Estimating…'
                            : 'ETA: ${_fmt(s.eta!)}',
                      ),
                    ],
                  ),
                ] else if (s.isSuccess) ...[
                  const Row(
                    children: [
                      Icon(Icons.check_circle, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: BodyTwoDefaultText(
                          text:
                              'Restore completed. Please reopen the app if prompted.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ] else if (s.isError) ...[
                  Row(
                    children: [
                      const Icon(Icons.error, size: 18),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: BodyTwoDefaultText(
                          text: 'Error: ${s.errorMessage}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const BodyTwoDefaultText(
                    text: 'Select a backup ZIP file and restore your data.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                SizedBox(height: 14.sp),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: Icon(s.isRunning ? Icons.sync : Icons.restore),
                    label: BodyTwoDefaultText(
                      text: s.isRunning
                          ? 'Restoring…'
                          : (s.isSuccess
                                ? 'Restore Again'
                                : 'Select ZIP & Restore'),
                    ),
                    onPressed: s.isRunning ? null : _startRestore,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---- helpers ----

  static String _fmt(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    return '${d.inSeconds}s';
  }

  static String _truncate(String s, {int max = 55}) {
    if (s.isEmpty) return '';
    if (s.length <= max) return s;
    final head = s.substring(0, (max * 0.55).floor());
    final tail = s.substring(s.length - (max * 0.35).floor());
    return '$head…$tail';
  }
}

class _HeaderLine extends StatelessWidget {
  const _HeaderLine({required this.state});
  final RestoreUiState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state.status) {
      RestoreStatus.idle => AppColors.getLigthGreyColor,
      RestoreStatus.running => AppColors.getPrimaryColor,
      RestoreStatus.success => AppColors.getGreenColor,
      RestoreStatus.error => AppColors.getErrorColor,
    };

    final text = switch (state.status) {
      RestoreStatus.idle => 'Ready to restore a backup.',
      RestoreStatus.running =>
        'Restoring… ${(state.progress * 100).toStringAsFixed(0)}%',
      RestoreStatus.success => 'Restore completed.',
      RestoreStatus.error => 'Restore failed.',
    };

    final icon = switch (state.status) {
      RestoreStatus.idle => Icons.info_outline,
      RestoreStatus.running => Icons.sync,
      RestoreStatus.success => Icons.check_circle_outline,
      RestoreStatus.error => Icons.error_outline,
    };

    return Row(
      children: [
        Icon(icon, color: color, size: 18.sp),
        const SizedBox(width: 8),
        Expanded(
          child: BodyTwoDefaultText(text: text, color: color),
        ),
      ],
    );
  }
}
