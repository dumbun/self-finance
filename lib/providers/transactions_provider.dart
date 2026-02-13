import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/analytics_provider.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/providers/monthly_chart_provider.dart';

part 'transactions_provider.g.dart';

@Riverpod(keepAlive: true)
class AsyncTransactions extends _$AsyncTransactions {
  Future<List<Trx>> _fetchAllTransactionsData() async {
    final List<Trx> data = await BackEnd.fetchAllTransactions();
    return data;
  }

  @override
  FutureOr<List<Trx>> build() {
    // Load initial todo list from the remote repository\
    ref.keepAlive();
    return _fetchAllTransactionsData();
  }

  Future<int> addTransaction({required Trx transaction}) async {
    int result = 0;
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      result = await BackEnd.createNewTransaction(transaction);
      return await _fetchAllTransactionsData();
    });
    ref.read(analyticsProvider.notifier).refresh().ignore();
    ref.refresh(monthlyChartProvider.future).ignore();
    return result;
  }

  Future<List<Trx>> fetchRequriedTransaction({
    required int transactionId,
  }) async {
    final List<Trx> responce = await BackEnd.fetchRequriedTransaction(
      transacrtionId: transactionId,
    );
    return responce;
  }

  Future<int> markAsPaidTransaction({
    required int trancationId,
    required double intrestAmount,
  }) async {
    int responce = 0;
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      responce = await BackEnd.updateTransactionAsPaid(
        id: trancationId,
        intrestAmount: intrestAmount,
      );
      return await _fetchAllTransactionsData();
    });
    return responce;
  }

  Future<void> doSearch({required String givenInput}) async {
    final List<Trx> transactionData = await BackEnd.fetchAllTransactions();
    if (transactionData.isNotEmpty) {
      state = const AsyncValue.loading(); // Set loading state once
      state = await AsyncValue.guard(() async {
        if (transactionData.isEmpty) {
          return [];
        }

        if (givenInput.isEmpty) {
          return transactionData;
        }

        final String inputLower = givenInput.trim().toLowerCase();
        return transactionData.where((Trx element) {
          return element.id.toString().trim().contains(inputLower);
        }).toList();
      }, (err) => err is! FormatException);
    }
  }

  Future fetchTransactionsByAge(int input) async {
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final List<Trx> responce = await BackEnd.fetchTransactionsByAge(
        months: input,
      );

      return responce;
    });
  }

  Future<void> fetchTransactionsByDate(String inputDate) async {
    if (inputDate.isNotEmpty) {
      state = AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final List<Trx> responce = await BackEnd.fetchTransactionsByDate(
          inputDate: inputDate,
        );
        return responce;
      });
    }
  }

  Future<void> deleteTransactionAndHistory(int id) async {
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await BackEnd.deleteTransaction(transactionId: id);
      await ref
          .read(asyncHistoryProvider.notifier)
          .deleteHistory(transactionId: id);
      ref.read(analyticsProvider.notifier).refresh().ignore();
      ref.refresh(monthlyChartProvider.future).ignore();
      return _fetchAllTransactionsData();
    });
  }
}

@riverpod
Future<List<Trx?>> transactionsByCustomerId(Ref ref, int customerId) async {
  // Watch the customer list - when it changes, this provider rebuilds
  ref.watch(asyncTransactionsProvider);
  final List<Trx?> transactions =
      await BackEnd.fetchRequriedCustomerTransactions(customerId: customerId);
  return transactions;
}

@riverpod
Future<List<Trx>> fetchRequriedTransaction(Ref ref, int transactionId) async {
  // Watch the customer list - when it changes, this provider rebuilds
  ref.watch(asyncTransactionsProvider);
  final List<Trx> transactions = await BackEnd.fetchRequriedTransaction(
    transacrtionId: transactionId,
  );
  return transactions;
}
