import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/utility/image_saving_utility.dart';
import 'package:self_finance/core/utility/invoice_generator_utility.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history_model.dart';
import 'package:self_finance/providers/image_providers.dart';
import 'package:self_finance/widgets/transaction_filter_widget.dart';
import 'package:signature/signature.dart';

part 'transactions_provider.g.dart';

@riverpod
class Filter extends _$Filter {
  @override
  Set<TransactionsFilters> build() => {};

  void add(TransactionsFilters filter) {
    state = {...state, filter};
  }

  void remove(TransactionsFilters filter) {
    state = state.where((f) => f != filter).toSet();
  }

  void toggle(TransactionsFilters filter) {
    if (state.contains(filter)) {
      remove(filter);
    } else {
      add(filter);
    }
  }

  void set(Set<TransactionsFilters> filters) {
    ref.read(transactionsSearchQueryProvider.notifier).clear();
    ref.read(transactionsDateSearchQueryProvider.notifier).clear();
    state = filters;
  }

  void setFilter(TransactionsFilters filter, bool selected) {
    ref.read(transactionsSearchQueryProvider.notifier).clear();
    ref.read(transactionsDateSearchQueryProvider.notifier).clear();
    state = selected ? {filter} : {};
  }

  void clear() {
    state = {};
  }

  bool contains(TransactionsFilters filter) {
    return state.contains(filter);
  }
}

@riverpod
class TransactionsSearchQuery extends _$TransactionsSearchQuery {
  @override
  String build() => '';

  void set(String q) {
    ref.read(filterProvider.notifier).clear();
    ref.read(transactionsDateSearchQueryProvider.notifier).clear();
    state = q;
  }

  void clear() => state = '';
}

@riverpod
class TransactionsDateSearchQuery extends _$TransactionsDateSearchQuery {
  @override
  DateTime? build() => null;

  void set(DateTime? q) {
    ref.read(transactionsSearchQueryProvider.notifier).clear();
    ref.read(filterProvider.notifier).clear();
    state = q;
  }

  void clear() => state = null;
}

@riverpod
class TransactionsNotifier extends _$TransactionsNotifier {
  Stream<List<Trx>> _fetchTransactions() {
    return BackEnd.watchAllTransactions();
  }

  @override
  Stream<List<Trx>> build() {
    final Stream<List<Trx>> base = _fetchTransactions();
    final String query = ref
        .watch(transactionsSearchQueryProvider)
        .trim()
        .toLowerCase();
    final DateTime? dateQuery = ref.watch(transactionsDateSearchQueryProvider);
    final filterQuery = ref.watch(filterProvider);

    if (query.isEmpty && dateQuery == null && filterQuery.isEmpty) return base;
    if (query.isNotEmpty && dateQuery == null && filterQuery.isEmpty) {
      return base.map((List<Trx> transactions) {
        return transactions
            .where((Trx element) => element.id.toString().trim() == query)
            .toList();
      });
    } else if (query.isEmpty && dateQuery != null && filterQuery.isEmpty) {
      return BackEnd.watchTransactionsByDate(inputDate: dateQuery);
    } else if (query.isEmpty && dateQuery == null && filterQuery.isNotEmpty) {
      return BackEnd.watchTransactionsByAge(months: filterQuery.first.months);
    } else {
      return base;
    }
  }

  Future<bool> addNewTransactoion({
    required int customerId,
    required String customerName,
    required String customerNumber,
    required String discription,
    required DateTime userInputDate,
    required double pawnAmount,
    required double rateOfIntrest,
    required SignatureController signatureController,
  }) async {
    ref.keepAlive();

    final String itemImagePath = await ImageSavingUtility.saveImage(
      location: 'items',
      image: ref.read(itemFileProvider),
    );
    final int itemId = await BackEnd.createNewItem(
      Items(
        customerid: customerId,
        name: discription,
        description: discription,
        pawnedDate: userInputDate,
        expiryDate: userInputDate,
        pawnAmount: pawnAmount,
        status: Constant.active,
        photo: itemImagePath,
        createdDate: DateTime.now(),
      ),
    );
    if (itemId != 0) {
      //saving signature to the storage
      final String signaturePath = await Utility.saveSignaturesInStorage(
        signatureController: signatureController,
        imageName: itemId.toString(),
      );
      final int transacrtionId = await BackEnd.createNewTransaction(
        Trx(
          customerId: customerId,
          itemId: itemId,
          transacrtionDate: userInputDate,
          transacrtionType: Constant.active,
          amount: pawnAmount,
          intrestRate: rateOfIntrest,
          intrestAmount: 0.0,
          remainingAmount: 0.0,
          signature: signaturePath,
          createdDate: DateTime.now(),
        ),
      );
      if (transacrtionId != 0) {
        final int historyId = await BackEnd.createNewHistory(
          UserHistory(
            userID: 1,
            itemID: itemId,
            customerID: customerId,
            customerName: customerName,
            customerNumber: customerNumber,
            transactionID: transacrtionId,
            eventDate: DateTime.now(),
            eventType: Constant.debited,
            amount: pawnAmount,
          ),
        );

        return historyId != 0 ? true : false;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<Map<String, int>> deleteTransaction({
    required int transactionId,
  }) async {
    return await BackEnd.deleteTransaction(transactionId: transactionId);
  }
}

@Riverpod(keepAlive: false)
class TransactionByID extends _$TransactionByID {
  @override
  Stream<Trx?> build(int transactionId) {
    return _fetchTransaction(transactionId);
  }

  Stream<Trx?> _fetchTransaction(int transactionId) {
    return BackEnd.watchRequriedTransaction(transactionId: transactionId);
  }

  Future<void> markAsPaid({
    required double amountpaid,
    required double intrestAmount,
  }) async {
    final Trx? trx = state.value;
    if (trx != null) {
      final List<Customer> customers = await BackEnd.fetchSingleContactDetails(
        id: trx.customerId,
      );
      if (customers.isEmpty) {
        throw Exception('Customer not found');
      }
      final Customer customer = customers.first;
      final Payment payment = Payment(
        transactionId: trx.id!,
        paymentDate: DateTime.now(),
        amountpaid: amountpaid,
        type: 'cash',
        createdDate: Utility.presentDate(),
      );
      await BackEnd.addPayment(payment: payment);
      await BackEnd.updateTransactionAsPaid(
        id: transactionId,
        intrestAmount: intrestAmount,
      );
      await BackEnd.createNewHistory(
        UserHistory(
          userID: 1,
          customerID: customer.id!,
          itemID: trx.itemId,
          customerNumber: customer.number,
          customerName: customer.name,
          transactionID: transactionId,
          eventDate: Utility.presentDate(),
          eventType: Constant.credit,
          amount: amountpaid,
        ),
      );
    }
  }

  Future<void> shareTransaction() async {
    final List<Trx> t = await BackEnd.fetchRequriedTransaction(
      transacrtionId: transactionId,
    );
    await InvoiceGenerator.shareInvoice(transaction: t.first);
  }
}

final requriedCustomerTransactionsProvider = StreamProvider.family
    .autoDispose<List<Trx>, int>((ref, customerId) {
      return BackEnd.watchRequriedCustomerTransactions(customerId: customerId);
    });
