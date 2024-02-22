import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/user_history.dart';

part 'history_provider.g.dart';

@Riverpod(keepAlive: false)
class AsyncHistory extends _$AsyncHistory {
  Future<List<UserHistory>> _fetchAllItemsData() async {
    final data = await BackEnd.fetchAllUserHistory();
    return data;
  }

  @override
  FutureOr<List<UserHistory>> build() {
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
    final List<UserHistory> historyData = await BackEnd.fetchAllUserHistory();
    if (givenInput.isEmpty) {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        return historyData;
      });
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (historyData.isNotEmpty) {
        return historyData.where((element) {
          return "${element.customerNumber} ${element.customerName.toLowerCase()}".contains(givenInput.toLowerCase());
        }).toList();
      } else {
        return [];
      }
    });
  }
}
