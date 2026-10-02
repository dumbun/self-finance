import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/contacts_model.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';

class Threads {
  static List<Customer> computeAllCustomersDetails(List<CustomerRow> rows) {
    return rows
        .map(
          (CustomerRow r) => Customer(
            id: r.customerId,
            userID: r.userId,
            name: r.customerName,
            guardianName: r.gaurdianName,
            address: r.customerAddress,
            number: r.contactNumber,
            photo: r.customerPhoto,
            proof: r.proofPhoto,
            createdDate: r.createdDate,
          ),
        )
        .toList();
  }

  static List<Contact> mapRowsToContacts(List<(int, String, String)> rows) {
    return rows
        .map((r) => Contact(id: r.$1, name: r.$2, number: r.$3))
        .toList();
  }

  static List<Trx> computeAllTransactions(List<TransactionRow> rows) {
    return rows
        .map(
          (TransactionRow r) => Trx(
            id: r.transactionId,
            customerId: r.customerId,
            itemId: r.itemId,
            transacrtionDate: r.transactionDate,
            transacrtionType: r.transactionType,
            amount: r.amount,
            intrestRate: r.interestRate,
            intrestAmount: r.interestAmount,
            remainingAmount: r.remainingAmount,
            signature: r.signature,
            createdDate: r.createdDate,
          ),
        )
        .toList();
  }
}
