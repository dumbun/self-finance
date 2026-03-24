enum ExportStatus { idle, running, success, error }

enum CsvExportType {
  allTransactions,
  activeLoans,
  completedLoans,
  paymentHistory,
}

typedef CsvProgressCallback = void Function(double progress, String message);

class CsvExportResult {
  final bool success;
  final List<String> filePaths;
  final String? errorMessage;

  const CsvExportResult._({
    required this.success,
    this.filePaths = const [],
    this.errorMessage,
  });

  factory CsvExportResult.success(List<String> paths) =>
      CsvExportResult._(success: true, filePaths: paths);

  factory CsvExportResult.failure(String message) =>
      CsvExportResult._(success: false, errorMessage: message);
}

class ExportState {
  final ExportStatus status;
  final double progress;
  final String message;
  final String? errorMessage;

  const ExportState._({
    required this.status,
    this.progress = 0,
    this.message = '',
    this.errorMessage,
  });

  const ExportState.idle() : this._(status: ExportStatus.idle);

  const ExportState.running({required double progress, required String message})
    : this._(
        status: ExportStatus.running,
        progress: progress,
        message: message,
      );

  const ExportState.success()
    : this._(
        status: ExportStatus.success,
        progress: 1,
        message: 'Export complete!',
      );

  const ExportState.error(String msg)
    : this._(status: ExportStatus.error, errorMessage: msg);

  bool get isRunning => status == ExportStatus.running;
  bool get isSuccess => status == ExportStatus.success;
  bool get isError => status == ExportStatus.error;
}
