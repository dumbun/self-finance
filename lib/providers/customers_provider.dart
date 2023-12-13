import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/customer_model.dart';
part 'customers_provider.g.dart';

@Riverpod(keepAlive: true)
class AsyncCustomers extends _$AsyncCustomers {
  Future<List<Customer>> _fetchAllTransactions() async {
    final data = await BackEnd.fetchAllData();
    return data;
  }

  @override
  FutureOr<List<Customer>> build() {
    // Load initial todo list from the remote repository
    return _fetchAllTransactions();
  }

  Future<bool> addCustomer({required Customer customer}) async {
    bool result = false;
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      result = await BackEnd.createNewEntry(customer);
      return _fetchAllTransactions();
    });
    return result;
  }
}
