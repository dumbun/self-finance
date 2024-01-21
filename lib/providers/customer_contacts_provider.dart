import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/contacts_model.dart';
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

  Future<void> searchCustomer({required String givenInput}) async {
    final List<Contact> data = await BackEnd.fetchAllCustomerNumbersWithNames();
    if (givenInput.isEmpty || givenInput == "" || givenInput == " ") {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        return data;
      });
    } else {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        if (data.isNotEmpty) {
          return data.where((element) {
            return "${element.number} ${element.name.toLowerCase()}".contains(givenInput.toLowerCase());
          }).toList();
        } else {
          return [];
        }
      });
    }
  }
}
