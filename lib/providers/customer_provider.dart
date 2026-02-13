import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/utility/image_saving_utility.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/contacts_model.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/providers/image_providers.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:signature/signature.dart';

part 'customer_provider.g.dart';

@Riverpod(keepAlive: true)
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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      result = await BackEnd.createNewCustomer(customer);
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
    return await BackEnd.fetchAllCustomerNumbers();
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

  Future<bool> createNewCustomer({
    required String customerName,
    required String guardianName,
    required String address,
    required String number,
    required double takenAmount,
    required String presentDateTime,
    required String description,
    required String takenDate,
    required SignatureController signatureController,
    required double intrestRate,
  }) async {
    bool result = false;

    state = const AsyncValue.loading();

    try {
      // ✅ Read these BEFORE any await, so you don't read after disposal.
      final customerPhoto = ref.read(imageFileProvider);
      final proofPhoto = ref.read(proofFileProvider);
      final itemPhoto = ref.read(itemFileProvider);

      final imagePath = await ImageSavingUtility.saveImage(
        location: 'customers',
        image: customerPhoto,
      );
      if (!ref.mounted) return false;

      final proofPath = await ImageSavingUtility.saveImage(
        location: 'proofs',
        image: proofPhoto,
      );
      if (!ref.mounted) return false;

      final c = Customer(
        userID: 1,
        name: customerName,
        guardianName: guardianName,
        address: address,
        number: number,
        photo: imagePath,
        proof: proofPath,
        createdDate: presentDateTime,
      );

      final customerId = await BackEnd.createNewCustomer(c);
      if (!ref.mounted) return false;

      if (customerId != 0) {
        final itemImagePath = await ImageSavingUtility.saveImage(
          location: 'items',
          image: itemPhoto,
        );
        if (!ref.mounted) return false;

        final item = Items(
          customerid: customerId,
          name: description,
          description: description,
          pawnedDate: takenDate,
          expiryDate: presentDateTime,
          pawnAmount: takenAmount,
          status: Constant.active,
          photo: itemImagePath,
          createdDate: presentDateTime,
        );

        final itemId = await BackEnd.createNewItem(item);
        if (!ref.mounted) return false;

        if (itemId != 0) {
          final signatureResponse = await Utility.saveSignaturesInStorage(
            signatureController: signatureController,
            imageName: itemId.toString(),
          );
          if (!ref.mounted) return false;

          final t = Trx(
            customerId: customerId,
            itemId: itemId,
            transacrtionDate: takenDate,
            transacrtionType: Constant.active,
            amount: takenAmount,
            intrestRate: intrestRate,
            intrestAmount: 0.0,
            remainingAmount: 0,
            signature: signatureResponse,
            createdDate: presentDateTime,
          );

          final transactionId = await BackEnd.createNewTransaction(t);
          if (!ref.mounted) return false;

          if (transactionId != 0) {
            final h = UserHistory(
              userID: 1,
              customerID: customerId,
              itemID: itemId,
              customerNumber: number,
              customerName: customerName,
              transactionID: transactionId,
              eventDate: presentDateTime,
              eventType: Constant.debited,
              amount: takenAmount,
            );

            final historyId = await BackEnd.createNewHistory(h);
            if (historyId != 0) result = true;
          }
        }
      }

      final refreshed = await _fetchAllCustomersData();
      if (ref.mounted) state = AsyncValue.data(refreshed);

      return result;
    } catch (e, st) {
      if (ref.mounted) state = AsyncValue.error(e, st);
      return false;
    }
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
