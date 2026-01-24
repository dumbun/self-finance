import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/chart_model.dart';

part 'monthly_chart_provider.g.dart';

@riverpod
class MonthlyChart extends _$MonthlyChart {
  Future<MonthlyChartState> _loadChartData() async {
    try {
      final List<Map<String, dynamic>> rawData =
          await BackEnd.fetchMonthlyChartData();
      final List<ChartData> chartData = ChartData.toList(rawData);

      // Calculate totals and max value
      double totalDisbursed = 0;
      double totalReceived = 0;
      double maxValue = 0;

      for (var data in chartData) {
        totalDisbursed += data.disbursed;
        totalReceived += data.received;

        final max = [
          data.disbursed,
          data.received,
        ].reduce((a, b) => a > b ? a : b);
        if (max > maxValue) maxValue = max;
      }

      return MonthlyChartState(
        data: chartData,
        maxValue: maxValue,
        totalDisbursed: totalDisbursed,
        totalReceived: totalReceived,
      );
    } catch (e) {
      return MonthlyChartState.empty();
    }
  }

  @override
  FutureOr<MonthlyChartState> build() {
    return _loadChartData();
  }

  /// Call this after any transaction or payment mutation
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _loadChartData();
    });
  }
}
