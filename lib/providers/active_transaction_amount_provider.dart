import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/transactions_provider.dart';

final AutoDisposeFutureProvider<double> activeTransactionAmount = FutureProvider.autoDispose((ref) async {
  final AsyncValue<List<Trx>> allTransactions = ref.watch(asyncTransactionsProvider);
  double activeAmount = 0.0;
  List<Trx> activeTransactions;
  allTransactions.whenData(
    (List<Trx> value) {
      activeTransactions = value
          .where(
            (Trx element) => element.transacrtionType == Constant.active,
          )
          .toList();
      if (activeTransactions.isEmpty) {
        activeAmount = 0.0;
      } else {
        for (var element in activeTransactions) {
          activeAmount = activeAmount + element.amount;
        }
      }
    },
  );
  return activeAmount;
});
