import 'package:flutter/material.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/csv_export_utility.dart';
import 'package:self_finance/models/csv_model.dart';
import 'package:self_finance/widgets/csv_export_status_banner_widget.dart';
import 'package:self_finance/widgets/csv_type_selection_tile_widget.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

class CsvExportWidget extends StatefulWidget {
  const CsvExportWidget({super.key});

  /// Show the export bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const CsvExportWidget(),
    );
  }

  @override
  State<CsvExportWidget> createState() => _CsvExportWidgetState();
}

class _CsvExportWidgetState extends State<CsvExportWidget> {
  final Set<CsvExportType> _selectedTypes = {CsvExportType.allTransactions};
  final ValueNotifier<ExportState> _state = ValueNotifier(
    const ExportState.idle(),
  );

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Future<void> _startExport() async {
    if (_selectedTypes.isEmpty) {
      Navigator.pop(context);
      SnackBarWidget.snackBarWidget(
        context: context,
        message: 'Please select at least one data type.',
      );
    }

    _state.value = const ExportState.running(
      progress: 0,
      message: 'Starting export…',
    );

    final CsvExportResult result = await CsvExportUtility.export(
      types: _selectedTypes,
      onProgress: (progress, message) {
        _state.value = ExportState.running(
          progress: progress,
          message: message,
        );
      },
    );

    if (result.success) {
      _state.value = const ExportState.success();
    } else {
      _state.value = ExportState.error(result.errorMessage ?? 'Unknown error');
    }
  }

  void _reset() {
    _state.value = const ExportState.idle();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.getPrimaryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.file_download_outlined,
                  color: AppColors.getPrimaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const BodyOneDefaultText(text: 'Export to CSV', bold: true),
            ],
          ),

          const SizedBox(height: 20),

          // Data type selection
          const BodyTwoDefaultText(text: 'Select data to export', bold: true),
          const SizedBox(height: 10),
          ...Constant.typeInfo.entries.map((entry) {
            final CsvExportType type = entry.key;
            final (icon, label, desc) = entry.value;
            final bool selected = _selectedTypes.contains(type);

            return CsvTypeSelectionTileWidget(
              icon: icon,
              label: label,
              description: desc,
              selected: selected,
              onTap: () => setState(() {
                selected
                    ? _selectedTypes.remove(type)
                    : _selectedTypes.add(type);
              }),
            );
          }),

          const SizedBox(height: 16),

          // Progress / status area
          ValueListenableBuilder<ExportState>(
            valueListenable: _state,
            builder: (_, state, _) {
              if (state.isRunning) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.getPrimaryColor.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.getPrimaryColor.withAlpha(60),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.getPrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: BodySmallText(
                              text: state.message,
                              color: AppColors.getPrimaryColor,
                              bold: true,
                            ),
                          ),
                          BodySmallText(
                            text:
                                '${(state.progress * 100).toStringAsFixed(0)}%',
                            color: AppColors.getPrimaryColor,
                            bold: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: state.progress,
                          backgroundColor: AppColors.getPrimaryColor.withAlpha(
                            20,
                          ),
                          color: AppColors.getPrimaryColor,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (state.isSuccess) {
                return const StatusBanner(
                  icon: Icons.check_circle_rounded,
                  color: AppColors.getGreenColor,
                  message: 'Export completed successfully!',
                );
              }
              if (state.isError) {
                return StatusBanner(
                  icon: Icons.error_rounded,
                  color: AppColors.getErrorColor,
                  message: state.errorMessage ?? 'Export failed.',
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Action buttons
          ValueListenableBuilder<ExportState>(
            valueListenable: _state,
            builder: (_, state, _) {
              if (state.isRunning) {
                return const SizedBox.shrink();
              }

              if (state.isSuccess || state.isError) {
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Export Again'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.getPrimaryColor,
                        ),
                        icon: const Icon(Icons.done_rounded),
                        label: const Text('Done'),
                      ),
                    ),
                  ],
                );
              }

              // Idle state
              return SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _startExport,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.getPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.download_rounded),
                  label: Text(
                    'Export ${_selectedTypes.length} file${_selectedTypes.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
