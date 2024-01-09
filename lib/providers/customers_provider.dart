import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/customer_model.dart';
part 'customers_history_provider.g.dart';

@Riverpod(keepAlive: true)
class AsyncCustomers extends _$AsyncCustomers {
  Future<List<Customer>> _fetchAllTransactions() async {
    final data = await BackEnd.fetchAllCustomersData();
    // print(data);
    return data;
  }

  @override
  FutureOr<List<Customer>> build() {
    // Load initial todo list from the remote repository
    return _fetchAllTransactions();
  }

  Future<int> addCustomer({required Customer customer}) async {
    late int result = 0;
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      result = await BackEnd.createNewCustomer(customer);
      return _fetchAllTransactions();
    });

    return (result);
  }
}
