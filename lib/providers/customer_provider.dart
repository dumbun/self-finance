import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/providers/transactions_provider.dart';
part 'customer_provider.g.dart';

@riverpod
class CustomerNotifier extends _$CustomerNotifier {
  @override
  Stream<Customer?> build(int id) => BackEnd.watchSingleCustomer(id: id);

  Future<int> updateCustomer({required Customer customer}) async {
    final int res = await BackEnd.updateCustomerDetails(
      customerId: customer.id!,
      newCustomerName: customer.name,
      newGuardianName: customer.guardianName,
      newCustomerAddress: customer.address,
      newContactNumber: customer.number,
      newCustomerPhoto: customer.photo,
      newProofPhoto: customer.proof,
      newCreatedDate: DateTime.now(),
    );

    if (res != 0) {
      ref.invalidate(transactionsProvider);
    }
    return res;
  }

  Future<void> deleteCustomer(int customerID) async {
    await BackEnd.deleteTheCustomer(customerID: customerID);
    ref.invalidate(transactionsProvider);
  }
}
