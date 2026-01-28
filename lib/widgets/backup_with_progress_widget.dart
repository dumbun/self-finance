import 'dart:async';
import 'package:flutter/material.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/utility/backup_utility.dart';

/// Assumes backupImagesAndSqliteToDownloads is available in scope and
/// has signature:
/// Future->String backupImagesAndSqliteToDownloads({ BackupProgressCallback? onProgress })
///
/// Where BackupProgressCallback = void Function(double progress, String currentFile);

class BackupWithProgressWidget extends StatefulWidget {
  const BackupWithProgressWidget({super.key});

  @override
  State<BackupWithProgressWidget> createState() =>
      _BackupWithProgressWidgetState();
}

class _BackupWithProgressWidgetState extends State<BackupWithProgressWidget> {
  double _progress = 0.0; // 0.0 - 1.0
  String _currentFile = '';
  bool _running = false;
  DateTime? _startTime;
  String? _zipPath;
  Timer? _etaTimer;

  // For smoothing ETA we keep last few samples (time, progress)
  final List<_Sample> _samples = [];

  @override
  void dispose() {
    _etaTimer?.cancel();
    super.dispose();
  }

  Future<void> _startBackup() async {
    if (_running) return;

    setState(() {
      _running = true;
      _progress = 0.0;
      _currentFile = '';
      _zipPath = null;
      _startTime = DateTime.now();
      _samples.clear();
    });

    // Small timer to refresh ETA even if progress callbacks are sparse
    _etaTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {}); // re-draw ETA
    });

    try {
      final zipPath = await BackupUtility.startBackup(
        onProgress: (progress, currentFile) {
          if (!mounted) return;

          final now = DateTime.now();
          // Save sample for smoothing / ETA
          _samples.add(_Sample(time: now, progress: progress));
          // Keep last few samples only
          if (_samples.length > 6) _samples.removeAt(0);

          setState(() {
            _progress = progress.clamp(0.0, 1.0);
            _currentFile = currentFile;
          });
        },
      );

      if (!mounted) return;
      setState(() {
        _running = false;
        _zipPath = zipPath;
        _progress = 1.0;
      });
    } catch (e) {
      debugPrint('Backup failed: $e');
      if (!mounted) return;
      setState(() {
        _running = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Backup failed: ${e.toString()}')));
    } finally {
      _etaTimer?.cancel();
      _etaTimer = null;
    }
  }

  /// Estimate ETA using linear extrapolation on recent samples.
  /// Returns null if ETA cannot be calculated yet.
  Duration? _estimateRemaining() {
    if (_progress >= 1.0) return Duration.zero;
    // Use the earliest and latest sample to estimate speed
    if (_samples.length < 2) {
      // fallback to startTime if available and progress > 0
      if (_startTime != null && _progress > 0.0) {
        final elapsed = DateTime.now().difference(_startTime!);
        final estimatedTotal = Duration(
          milliseconds: (elapsed.inMilliseconds / _progress).round(),
        );
        final remainingMs =
            estimatedTotal.inMilliseconds - elapsed.inMilliseconds;
        return remainingMs > 0
            ? Duration(milliseconds: remainingMs)
            : Duration.zero;
      }
      return null;
    }

    final first = _samples.first;
    final last = _samples.last;

    final deltaProgress = (last.progress - first.progress);
    final deltaTimeMs = last.time.difference(first.time).inMilliseconds;

    if (deltaProgress <= 0 || deltaTimeMs <= 0) return null;

    final msPerProgress = deltaTimeMs / deltaProgress; // ms for 1.0 progress
    final remainingMs = msPerProgress * (1.0 - last.progress);
    if (remainingMs.isFinite && remainingMs > 0) {
      return Duration(milliseconds: remainingMs.round());
    }
    return null;
  }

  String _formatDurationShort(Duration d) {
    if (d.inHours > 0) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      return '${h}h ${m}m';
    } else if (d.inMinutes > 0) {
      return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    } else {
      return '${d.inSeconds}s';
    }
  }

  String _truncateFilename(String path, {int max = 50}) {
    if (path.length <= max) return path;
    final start = path.substring(0, (max / 2).floor());
    final end = path.substring(path.length - (max / 2).floor());
    return '$start…$end';
  }

  @override
  Widget build(BuildContext context) {
    final eta = _estimateRemaining();

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BodyOneDefaultText(text: 'Backup', bold: true),
            const SizedBox(height: 12),

            // Progress indicator area
            if (!_running && _progress == 0.0) ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload, size: 32),
                label: const BodyOneDefaultText(
                  text: 'Start Backup',
                  bold: true,
                ),
                onPressed: _startBackup,
              ),
            ] else ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Linear progress
                  LinearProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _running
                              ? 'Backing up: ${_truncateFilename(_currentFile)}'
                              : (_zipPath != null ? 'Backup saved' : 'Idle'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_running) ...[
                        if (eta != null)
                          Text(
                            'ETA: ${_formatDurationShort(eta)}',
                            style: const TextStyle(fontSize: 12),
                          )
                        else
                          const Text(
                            'Estimating...',
                            style: TextStyle(fontSize: 12),
                          ),
                      ] else if (_zipPath != null) ...[
                        Text(
                          'Saved',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(
                      _running ? Icons.pause_circle_filled : Icons.cloud_upload,
                    ),
                    label: Text(
                      _running
                          ? 'Backing...'
                          : (_zipPath == null ? 'Start Backup' : 'Run Again'),
                    ),
                    onPressed: _running ? null : _startBackup,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Sample {
  final DateTime time;
  final double progress;
  _Sample({required this.time, required this.progress});
}
