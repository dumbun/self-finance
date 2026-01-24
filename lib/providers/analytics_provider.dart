import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/dashboard_stats_model.dart';

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
      return AnalyticsNotifier();
    });

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(AnalyticsState.empty()) {
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
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
    } catch (e) {
      // Optional: log error / show snackbar
      state = AnalyticsState.empty();
    }
  }

  /// Call this after any DB mutation
  Future<void> refresh() async {
    await loadAnalytics();
  }
}

final totalCustomersProvider = Provider<int>(
  (ref) => ref.watch(analyticsProvider.select((s) => s.totalCustomers)),
);

final activeLoansProvider = Provider<int>(
  (ref) => ref.watch(analyticsProvider.select((s) => s.activeLoans)),
);

final Provider<double> outstandingAmountProvider = Provider<double>(
  (ref) => ref.watch(analyticsProvider.select((s) => s.outstandingAmount)),
);

final interestEarnedProvider = Provider<double>(
  (ref) => ref.watch(analyticsProvider.select((s) => s.interestEarned)),
);

final totalDisbursedProvider = Provider<double>(
  (ref) => ref.watch(analyticsProvider.select((s) => s.totalDisbursed)),
);

final paymentsReceivedProvider = Provider<double>(
  (ref) => ref.watch(analyticsProvider.select((s) => s.paymentsReceived)),
);
