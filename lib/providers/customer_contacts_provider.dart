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

  Future<void> deleteCustomer({required int customerID}) async {
    await BackEnd.deleteTheCustomer(customerID: customerID);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      return _fetchAllCustomersContactsData();
    });
  }

  Future<void> updateCustomer({
    required int customerId,
    required String newCustomerName,
    required String newGuardianName,
    required String newCustomerAddress,
    required String newContactNumber,
    required String newCustomerPhoto,
    required String newProofPhoto,
    required String newCreatedDate,
  }) async {
    state = const AsyncValue.loading();
    await BackEnd.updateCustomerDetails(
      customerId: customerId,
      newContactNumber: newContactNumber,
      newCustomerAddress: newCustomerAddress,
      newCreatedDate: newCreatedDate,
      newCustomerName: newCustomerName,
      newCustomerPhoto: newCustomerPhoto,
      newGuardianName: newGuardianName,
      newProofPhoto: newProofPhoto,
    );
    state = await AsyncValue.guard(() async {
      return _fetchAllCustomersContactsData();
    });
  }
}
