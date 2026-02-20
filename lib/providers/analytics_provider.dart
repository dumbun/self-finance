import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/dashboard_stats_model.dart';

part 'analytics_provider.g.dart';

/// Live dashboard analytics driven by drift streams.
/// No manual refresh needed - this updates automatically on DB changes.
@riverpod
Stream<AnalyticsState> analytics(Ref ref) {
  return BackEnd.watchAnalyticsData().map((Map<String, num> data) {
    return AnalyticsState(
      totalCustomers: data['totalCustomers']?.toInt() ?? 0,
      activeLoans: data['activeLoans']?.toInt() ?? 0,
      outstandingAmount: data['outstandingAmount']?.toDouble() ?? 0.0,
      interestEarned: data['interestEarned']?.toDouble() ?? 0.0,
      totalDisbursed: data['totalDisbursed']?.toDouble() ?? 0.0,
      paymentsReceived: data['paymentsReceived']?.toDouble() ?? 0.0,
    );
  });
}

// ---------------------------------------------------------------------------
// Derived providers (stable defaults while loading / error)
// ---------------------------------------------------------------------------

@riverpod
int totalCustomers(Ref ref) {
  return ref
      .watch(analyticsProvider)
      .maybeWhen(data: (a) => a.totalCustomers, orElse: () => 0);
}

@riverpod
int activeLoans(Ref ref) {
  return ref
      .watch(analyticsProvider)
      .maybeWhen(data: (a) => a.activeLoans, orElse: () => 0);
}

@riverpod
double outstandingAmount(Ref ref) {
  return ref
      .watch(analyticsProvider)
      .maybeWhen(data: (a) => a.outstandingAmount, orElse: () => 0.0);
}

@riverpod
double interestEarned(Ref ref) {
  return ref
      .watch(analyticsProvider)
      .maybeWhen(data: (a) => a.interestEarned, orElse: () => 0.0);
}

@riverpod
double totalDisbursed(Ref ref) {
  return ref
      .watch(analyticsProvider)
      .maybeWhen(data: (a) => a.totalDisbursed, orElse: () => 0.0);
}

@riverpod
double paymentsReceived(Ref ref) {
  return ref
      .watch(analyticsProvider)
      .maybeWhen(data: (a) => a.paymentsReceived, orElse: () => 0.0);
}
