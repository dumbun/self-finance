import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/chart_model.dart';

part 'monthly_chart_provider.g.dart';

@riverpod
class MonthlyChart extends _$MonthlyChart {
  @override
  Stream<MonthlyChartState> build() {
    // 🔒 Keep provider alive (optional but recommended for dashboard)
    ref.keepAlive();

    // Convert backend raw stream -> UI state stream
    return BackEnd.watchMonthlyChartData().transform(
      StreamTransformer<
        List<Map<String, dynamic>>,
        MonthlyChartState
      >.fromHandlers(
        handleData:
            (
              List<Map<String, dynamic>> rawData,
              EventSink<MonthlyChartState> sink,
            ) {
              sink.add(_toState(rawData));
            },
        handleError: (error, stackTrace, sink) {
          // If anything goes wrong, emit empty state instead of crashing UI
          sink.add(MonthlyChartState.empty());
        },
      ),
    );
  }

  MonthlyChartState _toState(List<Map<String, dynamic>> rawData) {
    final List<ChartData> chartData = ChartData.toList(rawData);

    double totalDisbursed = 0;
    double totalReceived = 0;
    double maxValue = 0;

    for (final data in chartData) {
      totalDisbursed += data.disbursed;
      totalReceived += data.received;

      final localMax = data.disbursed > data.received
          ? data.disbursed
          : data.received;

      if (localMax > maxValue) {
        maxValue = localMax;
      }
    }

    return MonthlyChartState(
      data: chartData,
      maxValue: maxValue,
      totalDisbursed: totalDisbursed,
      totalReceived: totalReceived,
    );
  }

  /// Optional: force rebuild / resubscribe (usually not needed since stream is reactive)
  void refresh() {
    ref.invalidateSelf();
  }
}
