import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/transaction_model.dart';
part 'transactions_provider.g.dart';

@Riverpod(keepAlive: false)
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
      return _fetchAllTransactionsData();
    });
    return result;
  }

  Future<List<Trx>> fetchRequriedCustomerTransactions({required int customerID}) async {
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      return await BackEnd.fetchRequriedCustomerTransactions(customerId: customerID);
    });

    return await BackEnd.fetchRequriedCustomerTransactions(customerId: customerID);
  }
}
