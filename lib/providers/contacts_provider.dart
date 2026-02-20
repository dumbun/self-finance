import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/utility/image_saving_utility.dart';
import 'package:self_finance/models/contacts_model.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/providers/date_provider.dart';
import 'package:self_finance/providers/image_providers.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:signature/signature.dart';

part 'contacts_provider.g.dart';

@riverpod
class ContactsSearchQuery extends _$ContactsSearchQuery {
  @override
  String build() => '';

  void set(String q) => state = q;

  void clear() => state = '';
}

@riverpod
class ContactsNotifier extends _$ContactsNotifier {
  Stream<List<Contact>> _fetchAllContacts() {
    return BackEnd.watchAllCustomerNumbersWithNames();
  }

  @override
  Stream<List<Contact>> build() {
    final String query = ref
        .watch(contactsSearchQueryProvider)
        .trim()
        .toLowerCase();
    final Stream<List<Contact>> base = _fetchAllContacts();

    if (query.isEmpty) return base;

    return base.map((List<Contact> contacts) {
      return contacts.where((Contact c) {
        final String name = c.name.toLowerCase();
        final String number = c.number.toLowerCase();
        final String id = c.id.toString();
        return name.contains(query) ||
            number.contains(query) ||
            id.contains(query);
      }).toList();
    });
  }

  void doSearch(String input) {
    ref.read(contactsSearchQueryProvider.notifier).set(input);
  }

  void clearSearch() {
    ref.read(contactsSearchQueryProvider.notifier).clear();
  }

  Future<List<String>> fetchContactsNumber() async {
    return await BackEnd.fetchAllCustomerNumbers();
  }

  Future<bool> createNewCustomer({
    required String discription,
    required double takenAmount,
    required double rateOfIntrest,
    required SignatureController signatureController,
    required String customerName,
    required String guardianName,
    required String address,
    required String number,
  }) async {
    ref.keepAlive();

    //saving images
    final DateTime? userPickedDate = ref.read(dateProvider);
    if (userPickedDate != null) {
      // saving image to storage
      final String imagePath = await ImageSavingUtility.saveImage(
        location: 'customers',
        image: ref.read(imageFileProvider),
      );

      final String proofPath = await ImageSavingUtility.saveImage(
        location: 'proofs',
        image: ref.read(proofFileProvider),
      );

      final Customer c = Customer(
        userID: 1,
        name: customerName,
        guardianName: guardianName,
        address: address,
        number: number,
        photo: imagePath,
        proof: proofPath,
        createdDate: DateTime.now(),
      );

      final int customerCreatedResponse = await BackEnd.createNewCustomer(c);

      if (customerCreatedResponse != 0) {
        final bool createNewTransaction = await ref
            .read(transactionsProvider.notifier)
            .addNewTransactoion(
              customerName: customerName,
              customerNumber: number,
              customerId: customerCreatedResponse,
              discription: discription,
              userInputDate: userPickedDate,
              pawnAmount: takenAmount,
              rateOfIntrest: rateOfIntrest,
              signatureController: signatureController,
            );
        return createNewTransaction;
      }
    }
    return false;
  }
}
