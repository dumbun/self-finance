import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/home_screen_graph_value_provider.dart';

part 'transactions_provider.g.dart';

@Riverpod(keepAlive: true)
class AsyncTransactions extends _$AsyncTransactions {
  Future<List<Trx>> _fetchAllTransactionsData() async {
    final data = await BackEnd.fetchAllTransactions();
    return data;
  }

  @override
  FutureOr<List<Trx>> build() {
    // Load initial todo list from the remote repository
    return _fetchAllTransactionsData();
  }

  Future<int> addTransaction({required Trx transaction}) async {
    int result = 0;
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      result = await BackEnd.createNewTransaction(transaction);
      return await _fetchAllTransactionsData();
    });
    ref.refresh(homeScreenGraphValuesProvider.future).ignore();
    return result;
  }

  Future<void> fetchRequriedCustomerTransactions({
    required int customerID,
  }) async {
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      return await BackEnd.fetchRequriedCustomerTransactions(
        customerId: customerID,
      );
    });
  }

  Future<List<Trx>> fetchRequriedTransaction({
    required int transactionId,
  }) async {
    final List<Trx> responce = await BackEnd.fetchRequriedTransaction(
      transacrtionId: transactionId,
    );
    return responce;
  }

  Future<double> fetchSumOfTakenAmount() async {
    return await BackEnd.fetchSumOfTakenAmount();
  }

  Future<int> markAsPaidTransaction({required int trancationId}) async {
    int responce = 0;
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      responce = await BackEnd.updateTransactionAsPaid(id: trancationId);
      return await _fetchAllTransactionsData();
    });

    return responce;
  }
}
