import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/dashboard_stats_model.dart';

part 'analytics_provider.g.dart'; // Add this for code generation

@riverpod
class Analytics extends _$Analytics {
  @override
  AnalyticsState build() {
    _loadAnalytics();
    return AnalyticsState.empty();
  }

  Future<void> _loadAnalytics() async {
    try {
      final Map<String, num> data = await BackEnd.fetchAnalyticsData();

      state = AnalyticsState(
        totalCustomers: data['totalCustomers']!.toInt(),
        activeLoans: data['activeLoans']!.toInt(),
        outstandingAmount: data['outstandingAmount']!.toDouble(),
        interestEarned: data['interestEarned']!.toDouble(),
        totalDisbursed: data['totalDisbursed']!.toDouble(),
        paymentsReceived: data['paymentsReceived']!.toDouble(),
      );
    } catch (_) {
      state = AnalyticsState.empty();
    }
  }

  Future<void> refresh() async {
    await _loadAnalytics();
  }
}

// Derived providers using selectors
@riverpod
int totalCustomers(Ref ref) {
  return ref.watch(analyticsProvider.select((s) => s.totalCustomers));
}

@riverpod
int activeLoans(Ref ref) {
  return ref.watch(analyticsProvider.select((s) => s.activeLoans));
}

@riverpod
double outstandingAmount(Ref ref) {
  return ref.watch(analyticsProvider.select((s) => s.outstandingAmount));
}

@riverpod
double interestEarned(Ref ref) {
  return ref.watch(analyticsProvider.select((s) => s.interestEarned));
}

@riverpod
double totalDisbursed(Ref ref) {
  return ref.watch(analyticsProvider.select((s) => s.totalDisbursed));
}

@riverpod
double paymentsReceived(Ref ref) {
  return ref.watch(analyticsProvider.select((s) => s.paymentsReceived));
}
