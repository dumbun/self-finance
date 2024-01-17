import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
part 'items_provider.g.dart';

@Riverpod(keepAlive: true)
class AsyncItems extends _$AsyncItems {
  Future<List<Customer>> _fetchAllItemsData() async {
    final data = await BackEnd.fetchAllCustomerData();
    print(data);
    return data;
  }

  @override
  FutureOr<List<Customer>> build() {
    // Load initial todo list from the remote repository
    return _fetchAllItemsData();
  }

  Future<int> addItem({required Items item}) async {
    int result = 0;
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      result = await BackEnd.createNewItem(item);
      return _fetchAllItemsData();
    });
    return result;
  }
}
