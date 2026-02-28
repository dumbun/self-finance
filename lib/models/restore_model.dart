// ------------ UI state + header ------------

enum RestoreStatus { idle, running, success, error }

class RestoreUiState {
  final RestoreStatus status;
  final double progress;
  final String currentFile;
  final Duration? eta;
  final String? errorMessage;

  const RestoreUiState._({
    required this.status,
    this.progress = 0,
    this.currentFile = '',
    this.eta,
    this.errorMessage,
  });

  const RestoreUiState.idle() : this._(status: RestoreStatus.idle);

  const RestoreUiState.running({
    required double progress,
    required String currentFile,
    Duration? eta,
  }) : this._(
         status: RestoreStatus.running,
         progress: progress,
         currentFile: currentFile,
         eta: eta,
       );

  const RestoreUiState.success()
    : this._(status: RestoreStatus.success, progress: 1);

  const RestoreUiState.error(String message)
    : this._(status: RestoreStatus.error, errorMessage: message);

  bool get isRunning => status == RestoreStatus.running;
  bool get isSuccess => status == RestoreStatus.success;
  bool get isError => status == RestoreStatus.error;
}
