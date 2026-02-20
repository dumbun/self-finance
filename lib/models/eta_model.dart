class _Sample {
  final DateTime time;
  final double progress;
  _Sample(this.time, this.progress);
}

class EtaEstimator {
  final List<_Sample> _samples = [];
  DateTime? _start;

  void reset() {
    _samples.clear();
    _start = DateTime.now();
  }

  Duration? update(double progress) {
    final now = DateTime.now();
    _samples.add(_Sample(now, progress));
    if (_samples.length > 6) _samples.removeAt(0);

    if (progress <= 0) return null;
    if (progress >= 1) return Duration.zero;

    if (_samples.length < 2) {
      final start = _start;
      if (start == null) return null;
      final elapsed = now.difference(start);
      final totalMs = (elapsed.inMilliseconds / progress).round();
      final remain = totalMs - elapsed.inMilliseconds;
      return remain > 0 ? Duration(milliseconds: remain) : Duration.zero;
    }

    final first = _samples.first;
    final last = _samples.last;

    final dp = last.progress - first.progress;
    final dtMs = last.time.difference(first.time).inMilliseconds;

    if (dp <= 0 || dtMs <= 0) return null;

    final msPer1 = dtMs / dp;
    final remainingMs = msPer1 * (1.0 - last.progress);
    if (!remainingMs.isFinite || remainingMs <= 0) return Duration.zero;

    return Duration(milliseconds: remainingMs.round());
  }
}
