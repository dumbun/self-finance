enum BackupStatus { idle, running, success, error }

class BackupState {
  final BackupStatus status;
  final double progress;
  final String currentFile;
  final Duration? eta;
  final String? zipPath;
  final String? errorMessage;

  const BackupState._({
    required this.status,
    this.progress = 0,
    this.currentFile = '',
    this.eta,
    this.zipPath,
    this.errorMessage,
  });

  factory BackupState.idle() => const BackupState._(status: BackupStatus.idle);

  factory BackupState.running({
    required double progress,
    required String currentFile,
    Duration? eta,
  }) => BackupState._(
    status: BackupStatus.running,
    progress: progress,
    currentFile: currentFile,
    eta: eta,
  );

  factory BackupState.success({required String zipPath}) => BackupState._(
    status: BackupStatus.success,
    zipPath: zipPath,
    progress: 1,
  );

  factory BackupState.error({required String message}) =>
      BackupState._(status: BackupStatus.error, errorMessage: message);

  bool get isRunning => status == BackupStatus.running;
  bool get isSuccess => status == BackupStatus.success;
  bool get isError => status == BackupStatus.error;
}
