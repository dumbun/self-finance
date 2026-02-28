import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/chart_model.dart';

part 'chart_tab_providers.g.dart';

// =============================================================================
// ACTIVE TAB
// =============================================================================

enum ChartTab { yearly, monthly, weekly, today }

@riverpod
class ActiveChartTab extends _$ActiveChartTab {
  @override
  ChartTab build() => ChartTab.monthly;

  void setTab(ChartTab tab) => state = tab;
}

@riverpod
class YearlyChart extends _$YearlyChart {
  @override
  Stream<MonthlyChartState> build() {
    ref.keepAlive();
    return BackEnd.watchYearlyChartData().transform(
      StreamTransformer<
        List<Map<String, dynamic>>,
        MonthlyChartState
      >.fromHandlers(
        handleData: (rawData, sink) => sink.add(_toState(rawData)),
        handleError: (_, _, sink) => sink.add(MonthlyChartState.empty()),
      ),
    );
  }

  MonthlyChartState _toState(List<Map<String, dynamic>> rawData) {
    final List<ChartData> chartData = ChartData.toList(rawData);
    double totalDisbursed = 0, totalReceived = 0, maxValue = 0;
    for (final data in chartData) {
      totalDisbursed += data.disbursed;
      totalReceived += data.received;
      final localMax = data.disbursed > data.received
          ? data.disbursed
          : data.received;
      if (localMax > maxValue) maxValue = localMax;
    }
    return MonthlyChartState(
      data: chartData,
      maxValue: maxValue,
      totalDisbursed: totalDisbursed,
      totalReceived: totalReceived,
    );
  }
}

// =============================================================================
// WEEKLY
// Backend puts the day label ('Mon', 'Tue'…) in the 'month' key so
// ChartData.fromMap works without any modification.
// The raw stream is also exposed separately so the widget can read
// _txnDate / _payDate per point for the drill-down query.
// =============================================================================

@riverpod
class WeeklyChart extends _$WeeklyChart {
  @override
  Stream<MonthlyChartState> build() {
    ref.keepAlive();
    return BackEnd.watchWeeklyChartData().transform(
      StreamTransformer<
        List<Map<String, dynamic>>,
        MonthlyChartState
      >.fromHandlers(
        handleData: (rawData, sink) => sink.add(_toState(rawData)),
        handleError: (_, _, sink) => sink.add(MonthlyChartState.empty()),
      ),
    );
  }

  MonthlyChartState _toState(List<Map<String, dynamic>> rawData) {
    final List<ChartData> chartData = ChartData.toList(rawData);
    double totalDisbursed = 0, totalReceived = 0, maxValue = 0;
    for (final data in chartData) {
      totalDisbursed += data.disbursed;
      totalReceived += data.received;
      final localMax = data.disbursed > data.received
          ? data.disbursed
          : data.received;
      if (localMax > maxValue) maxValue = localMax;
    }
    return MonthlyChartState(
      data: chartData,
      maxValue: maxValue,
      totalDisbursed: totalDisbursed,
      totalReceived: totalReceived,
    );
  }
}

// Raw weekly maps — needed by the widget to get _txnDate/_payDate per point
@riverpod
class WeeklyRaw extends _$WeeklyRaw {
  @override
  Stream<List<Map<String, dynamic>>> build() {
    ref.keepAlive();
    return BackEnd.watchWeeklyChartData();
  }
}

@riverpod
class TodayChart extends _$TodayChart {
  @override
  Stream<TodayState> build() {
    ref.keepAlive();
    return BackEnd.watchTodayChartData().transform(
      StreamTransformer<Map<String, dynamic>, TodayState>.fromHandlers(
        handleData: (raw, sink) => sink.add(TodayState.fromMap(raw)),
        handleError: (_, _, sink) => sink.add(TodayState.empty()),
      ),
    );
  }
}

final drillDownProvider = FutureProvider.autoDispose
    .family<List<DrillItem>, DrillTarget>((ref, target) async {
      final raw = switch (target) {
        DrillMonth(:final month, :final year) =>
          await BackEnd.fetchDrillDownForMonth(month: month, year: year),
        DrillDay(:final txnDate, :final payDate) =>
          await BackEnd.fetchDrillDownForDay(
            txnDate: txnDate,
            payDate: payDate,
          ),
      };
      return raw.map(DrillItem.fromMap).toList();
    });
