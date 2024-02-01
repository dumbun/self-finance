import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/contacts_model.dart';
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
      final List<Contact> data = await BackEnd.fetchAllCustomerNumbersWithNames();
      if (data.isNotEmpty) {
        List<Contact> contacts = data.where((element) {
          return "${element.number} ${element.name.toLowerCase()} ".contains(givenInput.toLowerCase());
        }).toList();

        List<UserHistory> matchingUserHistoryList = [];

        for (Contact contact in contacts) {
          UserHistory matchingUserHistory = historyData.firstWhere(
            (userHistory) => userHistory.id == contact.id,
            orElse: () => UserHistory(
              id: -1,
              userID: -1,
              customerID: -1,
              transactionID: -1,
              amount: 0,
              eventDate: "",
              eventType: "",
              itemID: -1,
            ),
          );
          if (matchingUserHistory.id != -1) {
            matchingUserHistoryList.add(matchingUserHistory);
          }
        }
        return matchingUserHistoryList;
      } else {
        return [];
      }
    });
  }
}
