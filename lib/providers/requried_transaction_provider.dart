import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/transactions_provider.dart';
part 'requried_transaction_provider.g.dart';

@riverpod
class AsyncRequriedTransactions extends _$AsyncRequriedTransactions {
  Future<List<Trx>> _fetchAllTransactionsData(id) async {
    final data = await ref.watch(asyncTransactionsProvider.notifier).fetchRequriedTransaction(
          transactionId: id,
        );

    return data;
  }

  @override
  FutureOr<List<Trx>> build(id) {
    // Load initial todo list from the remote repository
    return _fetchAllTransactionsData(id);
  }

  Future<int> markAsPaidTransaction({required int trancationId}) async {
    int responce = 0;
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      responce = await ref.read(asyncTransactionsProvider.notifier).markAsPaidTransaction(trancationId: trancationId);
      return await _fetchAllTransactionsData(trancationId);
    });

    return responce;
  }
}
