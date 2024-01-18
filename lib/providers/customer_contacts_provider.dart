import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
part 'customer_contacts_provider.g.dart';

@Riverpod(keepAlive: false)
class AsyncCustomersContacts extends _$AsyncCustomersContacts {
  Future<List<Map<String, String>>> _fetchAllCustomersContactsData() async {
    return BackEnd.fetchAllCustomerNumbersWithNames();
  }

  @override
  Future<List<Map<String, String>>> build() {
    // Load initial todo list from the remote repository
    return _fetchAllCustomersContactsData();
  }

  Future searchCustomer({required String givenInput}) async {
    if (givenInput.isEmpty || givenInput == "" || givenInput == " ") {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        return _fetchAllCustomersContactsData();
      });
    } else {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        return await BackEnd.fetchAllCustomerNumbersWithNames().then((value) {
          if (value.isNotEmpty) {
            return value.where((element) {
              try {
                return "${element["Contact_Number"]} ${element["Customer_Name"]!.toLowerCase()}"
                    .contains(givenInput.toLowerCase());
              } catch (e) {
                return false;
              }
            }).toList();
          } else {
            return [];
          }
        });
      });
    }
  }

  // Future<int> addCustomer({required Customer customer}) async {
  //   int result = 0;
  //   // Set the state to loading
  //   state = const AsyncValue.loading();
  //   // Add the new todo and reload the todo list from the remote repository
  //   state = await AsyncValue.guard(() async {
  //     result = await BackEnd.createNewCustomer(customer);
  //     return _fetchAllCustomersData();
  //   });
  //   return result;
  // }

  // Future<List<String>> fetchAllCustomersNumbers() async {
  //   List<String> data = [];
  //   // Set the state to loading
  //   state = const AsyncValue.loading();
  //   // Add the new todo and reload the todo list from the remote repository
  //   state = await AsyncValue.guard(() async {
  //     data = await BackEnd.fetchAllCustomerNumbers();
  //     return _fetchAllCustomersData();
  //   });
  //   return data;
  // }

  // Future<List<Map<String, Object?>>> fetchAllCustomerNumbersWithNames() async {
  //   List<Map<String, Object?>> data = [];
  //   // Set the state to loading
  //   state = const AsyncValue.loading();
  //   // Add the new todo and reload the todo list from the remote repository
  //   state = await AsyncValue.guard(() async {
  //     data = await BackEnd.fetchAllCustomerNumbersWithNames();
  //     return _fetchAllCustomersData();
  //   });
  //   return data;
  // }
}
