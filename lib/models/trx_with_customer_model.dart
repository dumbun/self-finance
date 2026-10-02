/// [TrxWithCustomer] is a lightweight read-only view model used exclusively
/// by the transactions list screen.
///
/// It is produced by a single SQL JOIN in [BackEnd.watchTransactionsWithCustomer],
/// so no per-row customer lookups are needed in the UI layer.
class TrxWithCustomer {
  const TrxWithCustomer({
    required this.id,
    required this.customerId,
    required this.itemId,
    required this.transactionDate,
    required this.transactionType,
    required this.amount,
    required this.interestRate,
    required this.interestAmount,
    required this.remainingAmount,
    required this.signature,
    required this.createdDate,
    required this.customerName,
    required this.customerPhoto,
  });

  final int id;
  final int customerId;
  final int itemId;
  final DateTime transactionDate;
  final String transactionType;
  final double amount;
  final double interestRate;
  final double interestAmount;
  final double remainingAmount;
  final String signature;
  final DateTime createdDate;

  /// Denormalized customer fields — populated by JOIN, never null.
  final String customerName;
  final String customerPhoto;
}
