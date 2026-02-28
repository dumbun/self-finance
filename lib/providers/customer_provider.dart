import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/customer_model.dart';
part 'customer_provider.g.dart';

@riverpod
class CustomerNotifier extends _$CustomerNotifier {
  @override
  Stream<Customer?> build(int id) => BackEnd.watchSingleCustomer(id: id);

  Future<void> deleteCustomer(int customerID) async {
    await BackEnd.deleteTheCustomer(customerID: customerID);
  }

  Future<int> updateCustomer({required Customer customer}) async {
    return await BackEnd.updateCustomerDetails(
      customerId: customer.id!,
      newCustomerName: customer.name,
      newGuardianName: customer.guardianName,
      newCustomerAddress: customer.address,
      newContactNumber: customer.number,
      newCustomerPhoto: customer.photo,
      newProofPhoto: customer.proof,
      newCreatedDate: DateTime.now(),
    );
  }
}
