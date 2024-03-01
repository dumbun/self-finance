import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/contacts_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/widgets/home_screen_graph_widget.dart';
part 'customer_contacts_provider.g.dart';

@Riverpod(keepAlive: false)
class AsyncCustomersContacts extends _$AsyncCustomersContacts {
  Future<List<Contact>> _fetchAllCustomersContactsData() async {
    return await ref.watch(asyncCustomersProvider.notifier).fetchAllCustomersNameAndNumber();
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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BackEnd.deleteTheCustomer(customerID: customerID);
      return _fetchAllCustomersContactsData();
    });
    ref.refresh(homeScreenGraphValuesProvider.future).ignore();
  }

  Future<int> updateCustomer({
    required int customerId,
    required String newCustomerName,
    required String newGuardianName,
    required String newCustomerAddress,
    required String newContactNumber,
    required String newCustomerPhoto,
    required String newProofPhoto,
    required String newCreatedDate,
  }) async {
    int response;
    state = const AsyncValue.loading();
    response = await ref.read(asyncCustomersProvider.notifier).updateCustomer(
          customerId: customerId,
          newCustomerName: newCustomerName,
          newGuardianName: newGuardianName,
          newCustomerAddress: newCustomerAddress,
          newContactNumber: newContactNumber,
          newCustomerPhoto: newCustomerPhoto,
          newProofPhoto: newProofPhoto,
          newCreatedDate: newCreatedDate,
        );
    state = await AsyncValue.guard(() async {
      return _fetchAllCustomersContactsData();
    });
    return response;
  }
}
