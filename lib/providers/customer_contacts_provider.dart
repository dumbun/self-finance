import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/contacts_model.dart';
import 'package:self_finance/models/customer_model.dart';
part 'customer_contacts_provider.g.dart';

@Riverpod(keepAlive: false)
class AsyncCustomersContacts extends _$AsyncCustomersContacts {
  Future<List<Contact>> _fetchAllCustomersContactsData() async {
    return BackEnd.fetchAllCustomerNumbersWithNames();
  }

  @override
  Future<List<Contact>> build() {
    // Load initial todo list from the remote repository
    return _fetchAllCustomersContactsData();
  }

  Future<AsyncValue<List<Customer>>> fetchSingleContactDetails({required int customerID}) async {
    AsyncValue<List<Customer>> result;
    result = await AsyncValue.guard(() async {
      return await BackEnd.fetchSingleContactDetails(id: customerID);
    });
    return result;
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
                return "${element.number} ${element.name.toLowerCase()}".contains(givenInput.toLowerCase());
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
}
