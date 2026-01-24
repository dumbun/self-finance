class AnalyticsState {
  final int totalCustomers;
  final int activeLoans;
  final double outstandingAmount;
  final double interestEarned;
  final double totalDisbursed;
  final double paymentsReceived;

  const AnalyticsState({
    required this.totalCustomers,
    required this.activeLoans,
    required this.outstandingAmount,
    required this.interestEarned,
    required this.totalDisbursed,
    required this.paymentsReceived,
  });

  factory AnalyticsState.empty() => const AnalyticsState(
    totalCustomers: 0,
    activeLoans: 0,
    outstandingAmount: 0,
    interestEarned: 0,
    totalDisbursed: 0,
    paymentsReceived: 0,
  );
}
