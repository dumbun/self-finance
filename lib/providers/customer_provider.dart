import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/customer_model.dart';
part 'customer_provider.g.dart';

@Riverpod(keepAlive: false)
class AsyncCustomers extends _$AsyncCustomers {
  Future<List<Customer>> _fetchAllCustomersData() async {
    return BackEnd.fetchAllCustomerData();
  }

  @override
  FutureOr<List<Customer>> build() {
    // Load initial todo list from the remote repository
    return _fetchAllCustomersData();
  }

  Future<int> addCustomer({required Customer customer}) async {
    int result = 0;
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      result = await BackEnd.createNewCustomer(customer);
      return _fetchAllCustomersData();
    });
    return result;
  }

  Future<List<String>> fetchAllCustomersNumbers() async {
    List<String> data = [];
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      data = await BackEnd.fetchAllCustomerNumbers();
      return _fetchAllCustomersData();
    });
    return data;
  }
}
