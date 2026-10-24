import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, debugPrintStack;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/backend/user_database.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/core/utility/image_saving_utility.dart';
import 'package:self_finance/core/utility/invoice_generator_utility.dart';
import 'package:self_finance/core/utility/notification_service.dart';
import 'package:self_finance/core/utility/preferences_helper.dart';
import 'package:self_finance/core/utility/review_helper.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/trx_with_customer_model.dart';
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

class TransactionsPaginationState {
  final List<TrxWithCustomer> transactions;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? loadMoreError;

  const TransactionsPaginationState({
    this.transactions = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  TransactionsPaginationState copyWith({
    List<TrxWithCustomer>? transactions,
    bool? hasMore,
    bool? isLoadingMore,
    Object? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return TransactionsPaginationState(
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError:
          clearLoadMoreError ? null : (loadMoreError ?? this.loadMoreError),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionsPaginationState &&
        other.transactions == transactions &&
        other.hasMore == hasMore &&
        other.isLoadingMore == isLoadingMore &&
        other.loadMoreError == loadMoreError;
  }

  @override
  int get hashCode => Object.hash(
    transactions,
    hasMore,
    isLoadingMore,
    loadMoreError,
  );
}

@riverpod
class TransactionsNotifier extends _$TransactionsNotifier {
  static const int _pageSize = 30;

  String _searchQuery = '';
  DateTime? _dateQuery;
  int? _ageMonths;

  /// Incremented on every rebuild. Async results that finish after the
  /// filters changed compare against this and are discarded.
  int _generation = 0;

  bool get hasMore => state.value?.hasMore ?? false;
  bool get isLoadingMore => state.value?.isLoadingMore ?? false;

  @override
  Future<TransactionsPaginationState> build() async {
    final int gen = ++_generation;

    final String query = ref
        .watch(transactionsSearchQueryProvider)
        .trim()
        .toLowerCase();
    final DateTime? dateQuery = ref.watch(transactionsDateSearchQueryProvider);
    final Set<TransactionsFilters> filterQuery = ref.watch(filterProvider);
    final int? ageMonths = filterQuery.isEmpty
        ? null
        : filterQuery.first.months;

    _searchQuery = query;
    _dateQuery = dateQuery;
    _ageMonths = ageMonths;

    final List<TrxWithCustomer> firstPage = await BackEnd.fetchTransactionsPage(
      searchQuery: query,
      dateQuery: dateQuery,
      ageMonths: ageMonths,
    );

    // A newer build started while we were waiting: discard stale results.
    if (gen != _generation) {
      return state.value ??
          const TransactionsPaginationState(
            hasMore: false,
          );
    }

    return TransactionsPaginationState(
      transactions: List<TrxWithCustomer>.unmodifiable(firstPage),
      hasMore: firstPage.length >= _pageSize,
    );
  }

  // ---------------------------------------------------------------------------
  // Pagination
  // ---------------------------------------------------------------------------

  Future<void> loadMore({bool isRetry = false}) async {
    final TransactionsPaginationState? currentState = state.value;
    if (currentState == null ||
        state.isLoading ||
        state.isRefreshing ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    if (!isRetry && currentState.loadMoreError != null) {
      return;
    }

    final int gen = _generation;

    // Immediately emit loading state so UI updates and displays footer spinner.
    state = AsyncData(
      currentState.copyWith(
        isLoadingMore: true,
        clearLoadMoreError: true,
      ),
    );

    try {
      final int? lastId = currentState.transactions.isNotEmpty
          ? currentState.transactions.last.id
          : null;

      final List<TrxWithCustomer> nextPage =
          await BackEnd.fetchTransactionsPage(
            beforeTransactionId: lastId,
            searchQuery: _searchQuery,
            dateQuery: _dateQuery,
            ageMonths: _ageMonths,
          );

      if (gen != _generation) return; // filters or search changed, discard

      final List<TrxWithCustomer> updatedList = [
        ...currentState.transactions,
        ...nextPage,
      ];

      state = AsyncData(
        currentState.copyWith(
          transactions: List<TrxWithCustomer>.unmodifiable(updatedList),
          hasMore: nextPage.length >= _pageSize,
          isLoadingMore: false,
          clearLoadMoreError: true,
        ),
      );
    } catch (e, st) {
      if (gen != _generation) return;
      debugPrint('Failed to load more transactions: $e');
      debugPrintStack(stackTrace: st);
      state = AsyncData(
        currentState.copyWith(
          isLoadingMore: false,
          loadMoreError: e,
        ),
      );
    }
  }

  /// Reloads from page 1. The old list stays visible while loading.
  void refreshTransactions() => ref.invalidateSelf();

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

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
    final keepAlive = ref.keepAlive();

    String itemImagePath = '';
    String signaturePath = '';

    try {
      itemImagePath = await ImageSavingUtility.saveImage(
        location: 'items',
        image: ref.read(itemFileProvider),
      );

      signaturePath = await Utility.saveSignaturesInStorage(
        signatureController: signatureController,
        imageName: '${customerId}_${DateTime.now().millisecondsSinceEpoch}',
      );

      final User user = await UserBackEnd.fetchUserData();
      final int activeUserId = (user.id != null && user.id! > 0) ? user.id! : 1;

      final int transacrtionId = await BackEnd.createNewTransactionAtomic(
        item: Items(
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
        transactionBuilder: (itemId) => Trx(
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
        historyBuilder: (itemId, txnId) => UserHistory(
          userID: activeUserId,
          itemID: itemId,
          customerID: customerId,
          customerName: customerName,
          customerNumber: customerNumber,
          transactionID: txnId,
          eventDate: DateTime.now(),
          eventType: Constant.debited,
          amount: pawnAmount,
        ),
      );

      if (transacrtionId != 0) {
        final bool notificationsEnabled =
            await PreferencesHelper.areNotificationsEnabled();

        if (notificationsEnabled) {
          await NotificationService().scheduleTransactionDueReminder(
            transactionId: transacrtionId,
            customerName: customerName,
            dueDate: userInputDate.add(const Duration(days: 6 * 30)),
          );
        }

        // Show the new transaction at the top of the list.
        refreshTransactions();
        return true;
      }
      return false;
    } catch (e) {
      if (itemImagePath.isNotEmpty) {
        try {
          final dir = await getApplicationDocumentsDirectory();
          final file = File(p.join(dir.path, itemImagePath));
          if (await file.exists()) await file.delete();
        } catch (_) {}
      }
      if (signaturePath.isNotEmpty) {
        try {
          final dir = await getApplicationDocumentsDirectory();
          final file = File(p.join(dir.path, signaturePath));
          if (await file.exists()) await file.delete();
        } catch (_) {}
      }
      rethrow;
    } finally {
      keepAlive.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<Map<String, int>> deleteTransaction({
    required int transactionId,
  }) async {
    await NotificationService().cancelTransactionReminder(
      transactionId: transactionId,
    );
    final Map<String, int> result = await BackEnd.deleteTransaction(
      transactionId: transactionId,
    );
    if (ref.mounted) {
      refreshTransactions();
    }
    return result;
  }
}

@Riverpod()
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
      await NotificationService().cancelTransactionReminder(
        transactionId: trx.id!,
      );
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

      final User user = await UserBackEnd.fetchUserData();
      final int activeUserId = (user.id != null && user.id! > 0) ? user.id! : 1;

      await BackEnd.markTransactionAsPaidAtomic(
        payment: payment,
        transactionId: transactionId,
        interestAmount: intrestAmount,
        history: UserHistory(
          userID: activeUserId,
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

      // The list is no longer a live stream, so refresh it manually
      // so the Active/Inactive chip updates.
      ref.invalidate(transactionsProvider);

      await ReviewHelper.requestAppReview();
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
