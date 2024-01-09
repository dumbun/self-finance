import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/transaction_model.dart';
part 'transactions_history_provider.g.dart';

@Riverpod(keepAlive: true)
class AsyncTransactionsHistory extends _$AsyncTransactionsHistory {
  Future<List<TransactionsHistory>> _fetchAllTransactions() async {
    final data = await BackEnd.fetchLatestTransactions();
    return data;
  }

  @override
  FutureOr<List<TransactionsHistory>> build() {
    // Load initial todo list from the remote repository
    return _fetchAllTransactions();
  }

  // void doPlaceSearch({required String place}) async {
  //   //if the user clear the search feild then the data will update to normal
  //   if (place == "") {
  //     build();
  //   }
  //   // Set the state to loading
  //   state = const AsyncValue.loading();
  //   //doing search
  //   state = await AsyncValue.guard(() async {
  //     var sd = await _fetchAllTransactions();
  //     final List<TransactionsHistory> result = sd.where((e) => e.address.contains(place)).toList();
  //     return result;
  //   });
  // }

  // void doMobileSearch({required String mobileNumber}) async {
  //   //if the user clear the search feild then the data will update to normal
  //   if (mobileNumber == "") {
  //     build();
  //   }
  //   // Set the state to loading
  //   state = const AsyncValue.loading();
  //   //doing search
  //   state = await AsyncValue.guard(() async {
  //     var sd = await _fetchAllTransactions();
  //     var result = sd.where((e) => e.mobileNumber.contains(mobileNumber)).toList();
  //     return result;
  //   });
  // }

  // void doNameSearch({required String customerName}) async {
  //   //if the user clear the search feild then the data will update to normal
  //   if (customerName == "") {
  //     build();
  //   }
  //   // Set the state to loading
  //   state = const AsyncValue.loading();
  //   //doing search
  //   state = await AsyncValue.guard(() async {
  //     var sd = await _fetchAllTransactions();
  //     List<TransactionsHistory> result = sd.where((e) => e.customerName.contains(customerName)).toList();
  //     return result;
  //   });
  // }

  Future<int> addTrasaction({required TransactionsHistory transaction}) async {
    int result = 0;
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      result = await BackEnd.createNewTransaction(transaction);
      return _fetchAllTransactions();
    });
    return result;
  }
}
