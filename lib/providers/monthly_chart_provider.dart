import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/chart_model.dart';

part 'monthly_chart_provider.g.dart';

@riverpod
class MonthlyChart extends _$MonthlyChart {
  @override
  Future<MonthlyChartState> build() async {
    // 🔒 Keep provider alive (optional but recommended for dashboard)
    ref.keepAlive();

    return _loadChartData();
  }

  Future<MonthlyChartState> _loadChartData() async {
    try {
      final List<Map<String, dynamic>> rawData =
          await BackEnd.fetchMonthlyChartData();
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
    } catch (_) {
      return MonthlyChartState.empty();
    }
  }

  /// Manual refresh (call after insert / update if needed)
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadChartData);
  }
}
