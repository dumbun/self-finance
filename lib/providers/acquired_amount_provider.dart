import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/transactions_provider.dart';

final acquiredAmountProvider = Provider.autoDispose((ref) {
  final AsyncValue<List<Trx>> allTransactions = ref.watch(asyncTransactionsProvider);
});
