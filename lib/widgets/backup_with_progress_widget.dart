import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/backup_utility.dart';
import 'package:self_finance/models/backup_model.dart';
import 'package:self_finance/models/eta_model.dart';

class BackupWithProgressWidget extends StatefulWidget {
  const BackupWithProgressWidget({super.key});

  @override
  State<BackupWithProgressWidget> createState() =>
      _BackupWithProgressWidgetState();
}

class _BackupWithProgressWidgetState extends State<BackupWithProgressWidget> {
  final ValueNotifier<BackupState> _state = ValueNotifier(BackupState.idle());
  final EtaEstimator _eta = EtaEstimator();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Future<void> _startBackup() async {
    if (_state.value.isRunning) return;

    _eta.reset();
    _state.value = BackupState.running(progress: 0, currentFile: '');

    try {
      final zipPath = await BackupUtility.startBackup(
        onProgress: (progress, currentFile) {
          final eta = _eta.update(progress);
          _state.value = BackupState.running(
            progress: progress.clamp(0.0, 1.0),
            currentFile: currentFile,
            eta: eta,
          );
        },
      );

      _state.value = BackupState.success(zipPath: zipPath);
    } catch (e) {
      _state.value = BackupState.error(message: e.toString());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Backup failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BackupState>(
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
                const BodyOneDefaultText(text: 'Backup', bold: true),
                SizedBox(height: 12.sp),

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
                          text: 'Backing up: ${_truncate(s.currentFile)}',
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
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 18),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: BodyTwoDefaultText(
                          text: 'Backup saved: ${_truncate(s.zipPath!)}',
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: BodyTwoDefaultText(
                          text: 'Error: ${s.errorMessage}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: 14.sp),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: Icon(
                      s.isRunning
                          ? Icons.cloud_upload
                          : Icons.cloud_upload_outlined,
                    ),
                    label: BodyTwoDefaultText(
                      text: s.isRunning
                          ? 'Backing up…'
                          : (s.isSuccess ? 'Run Again' : 'Start Backup'),
                    ),
                    onPressed: s.isRunning ? null : _startBackup,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _fmt(Duration d) {
    if (d.inHours > 0) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      return '${h}h ${m}m';
    }
    if (d.inMinutes > 0) {
      return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    }
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
  final BackupState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state.status) {
      BackupStatus.idle => AppColors.getLigthGreyColor,
      BackupStatus.running => AppColors.getPrimaryColor,
      BackupStatus.success => AppColors.getGreenColor,
      BackupStatus.error => AppColors.getErrorColor,
    };

    final text = switch (state.status) {
      BackupStatus.idle => 'Ready to create a backup.',
      BackupStatus.running =>
        'Creating backup… ${(state.progress * 100).toStringAsFixed(0)}%',
      BackupStatus.success => 'Backup completed.',
      BackupStatus.error => 'Backup failed.',
    };

    return Row(
      children: [
        Icon(
          switch (state.status) {
            BackupStatus.idle => Icons.info_outline,
            BackupStatus.running => Icons.sync,
            BackupStatus.success => Icons.check_circle_outline,
            BackupStatus.error => Icons.error_outline,
          },
          color: color,
          size: 18,
        ),
        SizedBox(width: 8.sp),
        Expanded(
          child: BodyTwoDefaultText(text: text, color: color),
        ),
      ],
    );
  }
}
