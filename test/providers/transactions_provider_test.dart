import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/models/trx_with_customer_model.dart';
import 'package:self_finance/providers/transactions_provider.dart';

void main() {
  group('TransactionsPaginationState', () {
    test('default state has correct initial values', () {
      const state = TransactionsPaginationState();
      expect(state.transactions, isEmpty);
      expect(state.hasMore, isTrue);
      expect(state.isLoadingMore, isFalse);
      expect(state.loadMoreError, isNull);
    });

    test('copyWith updates fields correctly', () {
      final txn = TrxWithCustomer(
        id: 1,
        customerId: 10,
        itemId: 100,
        transactionDate: DateTime(2026),
        transactionType: 'Active',
        amount: 5000.0,
        interestRate: 2.0,
        interestAmount: 100.0,
        remainingAmount: 5100.0,
        signature: '',
        createdDate: DateTime(2026),
        customerName: 'Alice',
        customerPhoto: '',
      );

      final state = const TransactionsPaginationState().copyWith(
        transactions: [txn],
        hasMore: false,
        isLoadingMore: true,
      );

      expect(state.transactions.length, 1);
      expect(state.transactions.first.id, 1);
      expect(state.hasMore, isFalse);
      expect(state.isLoadingMore, isTrue);
      expect(state.loadMoreError, isNull);
    });

    test('copyWith clearLoadMoreError works as expected', () {
      final stateWithError = const TransactionsPaginationState().copyWith(
        loadMoreError: 'Network failure',
      );
      expect(stateWithError.loadMoreError, equals('Network failure'));

      final stateCleared = stateWithError.copyWith(clearLoadMoreError: true);
      expect(stateCleared.loadMoreError, isNull);
    });

    test('value equality works based on properties', () {
      const state1 = TransactionsPaginationState(
        hasMore: false,
        isLoadingMore: true,
      );
      const state2 = TransactionsPaginationState(
        hasMore: false,
        isLoadingMore: true,
      );
      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
    });
  });
}
