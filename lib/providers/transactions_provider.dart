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
      return _fetchAllTransactionsData();
    });
    ref.refresh(homeScreenGraphValuesProvider.future).ignore();
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

  Future<double> fetchSumOfTakenAmount() async {
    return await BackEnd.fetchSumOfTakenAmount();
  }
}
