import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/contacts_model.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/providers/transactions_provider.dart';

part 'customer_provider.g.dart';

@Riverpod(keepAlive: false)
class AsyncCustomers extends _$AsyncCustomers {
  Future<List<Customer>> _fetchAllCustomersData() async {
    return BackEnd.fetchAllCustomerData();
  }

  @override
  FutureOr<List<Customer>> build() {
    // Load initial todo list from the remote repository
    return _fetchAllCustomersData();
  }

  Future<int> addCustomer({required Customer customer}) async {
    int result = 0;
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      result = await BackEnd.createNewCustomer(customer);
      // creating new item becacuse every new transaction will have a proof item
      return _fetchAllCustomersData();
    });
    return result;
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
    response = await BackEnd.updateCustomerDetails(
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
      return _fetchAllCustomersData();
    });

    return response;
  }

  Future<List<String>> fetchAllCustomersNumbers() async {
    List<String> data = [];
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      data = await BackEnd.fetchAllCustomerNumbers();
      return _fetchAllCustomersData();
    });
    return data;
  }

  Future<List<Contact>> fetchAllCustomersNameAndNumber() async {
    return await BackEnd.fetchAllCustomerNumbersWithNames();
  }

  Future<List<Customer>> fetchRequriedCustomerDetails({
    required int customerID,
  }) async {
    return await BackEnd.fetchSingleContactDetails(id: customerID);
  }

  Future<void> deleteCustomer({required int customerID}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BackEnd.deleteTheCustomer(customerID: customerID);
      // Also invalidate the specific customer provider
      return _fetchAllCustomersData();
    });

    ref.refresh(asyncTransactionsProvider.future).ignore();
  }
}

// // Separate provider for fetching a specific customer
// // This will now automatically update when the customer list changes
@riverpod
Future<Customer?> customerById(Ref ref, int customerId) async {
  // Watch the customer list - when it changes, this provider rebuilds
  ref.watch(asyncCustomersProvider);
  final List<Customer> customers = await ref
      .read(asyncCustomersProvider.notifier)
      .fetchRequriedCustomerDetails(customerID: customerId);

  return customers.first;
}
