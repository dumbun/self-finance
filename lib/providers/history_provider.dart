import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/providers/analytics_provider.dart';

part 'history_provider.g.dart';

@Riverpod(keepAlive: true)
class AsyncHistory extends _$AsyncHistory {
  Future<List<UserHistory>> _fetchAllHistoryData() async {
    final data = await BackEnd.fetchAllUserHistory();
    return data;
  }

  @override
  FutureOr<List<UserHistory>> build() {
    // Load initial todo list from the remote repository
    return _fetchAllHistoryData();
  }

  Future<int> addHistory({required UserHistory history}) async {
    int result = 0;
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      result = await BackEnd.createNewHistory(history);
      return _fetchAllHistoryData();
    });
    await ref.read(analyticsProvider.notifier).refresh();
    return result;
  }

  Future<void> doSearch({required String givenInput}) async {
    final List<UserHistory> historyData = await BackEnd.fetchAllUserHistory();
    if (historyData.isNotEmpty) {
      state = const AsyncValue.loading(); // Set loading state once

      if (historyData.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      if (givenInput.isEmpty) {
        state = AsyncValue.data(historyData);
        return;
      }

      final inputLower = givenInput.trim().toLowerCase();
      state = await AsyncValue.guard(() async {
        return historyData.where((UserHistory element) {
          return element.customerNumber.contains(inputLower) ||
              element.customerName.toLowerCase().contains(inputLower) ||
              't_${element.transactionID.toString()}'.contains(inputLower);
        }).toList();
      }, (err) => err is! FormatException);
    }
  }

  Future<List<UserHistory>> fetchAllUserHistory() async {
    return await _fetchAllHistoryData();
  }
}
