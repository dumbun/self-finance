import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/user_history.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';

part 'history_provider.g.dart';

@riverpod
class AsyncHistory extends _$AsyncHistory {
  Future<List<UserHistory>> _fetchAllItemsData() async {
    final data = await BackEnd.fetchAllUserHistory();
    return data;
  }

  @override
  FutureOr<List<UserHistory>> build() {
    ref.watch(asyncCustomersContactsProvider);
    ref.watch(asyncCustomersProvider);
    ref.watch(asyncTransactionsProvider);
    // Load initial todo list from the remote repository
    return _fetchAllItemsData();
  }

  Future<int> addHistory({required UserHistory history}) async {
    int result = 0;
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      result = await BackEnd.createNewHistory(history);
      return _fetchAllItemsData();
    });
    return result;
  }

  Future<void> doSearch({required String givenInput}) async {
    state = const AsyncValue.loading(); // Set loading state once

    final List<UserHistory> historyData = await BackEnd.fetchAllUserHistory();
    if (historyData.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    if (givenInput.isEmpty) {
      state = AsyncValue.data(historyData);
      return;
    }

    final inputLower = givenInput.toLowerCase();
    final filteredData = historyData.where((UserHistory element) {
      return element.customerNumber.contains(inputLower) || element.customerName.toLowerCase().contains(inputLower);
    }).toList();

    state = AsyncValue.data(filteredData);
  }

  Future<List<UserHistory>> fetchAllUserHistory() async {
    return await _fetchAllItemsData();
  }
}
