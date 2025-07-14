import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/contacts_model.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/home_screen_graph_value_provider.dart';

part 'customer_contacts_provider.g.dart';

@Riverpod(keepAlive: false)
class AsyncCustomersContacts extends _$AsyncCustomersContacts {
  Future<List<Contact>> _fetchAllCustomersContactsData() async {
    return await ref
        .watch(asyncCustomersProvider.notifier)
        .fetchAllCustomersNameAndNumber();
  }

  @override
  Future<List<Contact>> build() {
    // Load initial todo list from the remote repository
    return _fetchAllCustomersContactsData();
  }

  Future<int> addCustomer({required Customer customer}) async {
    int result = 0;
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      result = await ref
          .read(asyncCustomersProvider.notifier)
          .addCustomer(customer: customer);
      // creating new item becacuse every new transaction will have a proof item
      return await _fetchAllCustomersContactsData();
    });
    return result;
  }

  Future<void> searchCustomer({required String givenInput}) async {
    final List<Contact> data = await BackEnd.fetchAllCustomerNumbersWithNames();

    if (givenInput.trim().isEmpty) {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async => data);
      return;
    }

    // Create a HashMap for quick lookup
    final Map<String, Contact> customerMap = {
      for (Contact contact in data)
        "${contact.number} ${contact.name.toLowerCase()}": contact,
    };

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return customerMap.entries
          .where(
            (MapEntry<String, Contact> entry) =>
                entry.key.contains(givenInput.toLowerCase()),
          )
          .map((MapEntry<String, Contact> entry) => entry.value)
          .toList();
    });
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
    response = await ref
        .read(asyncCustomersProvider.notifier)
        .updateCustomer(
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
