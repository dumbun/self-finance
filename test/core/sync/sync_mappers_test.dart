import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/sync/sync_mappers.dart';

void main() {
  group('SyncMappers tests', () {
    const ownerId = 'test-owner-uuid-1234';
    final now = DateTime.utc(2026, 10, 24, 12);

    test('customerToSupabase maps all fields correctly', () {
      final customer = CustomerRow(
        userId: 1,
        customerId: 1,
        customerName: 'John Doe',
        gaurdianName: 'Jane Doe',
        contactNumber: '9876543210',
        customerAddress: '123 Street',
        customerPhoto: 'photo_base64_or_path',
        proofPhoto: 'proof_path',
        createdDate: now,
        syncId: 'cust-uuid-1',
        updatedAt: now,
      );

      final map = SyncMappers.customerToSupabase(customer, ownerId);

      expect(map['id'], 'cust-uuid-1');
      expect(map['owner_id'], ownerId);
      expect(map['name'], 'John Doe');
      expect(map['guardian_name'], 'Jane Doe');
      expect(map['contact_number'], '9876543210');
      expect(map['address'], '123 Street');
      expect(map['photo_path'], 'photo_base64_or_path');
      expect(map['created_at'], now.toIso8601String());
      expect(map['updated_at'], now.toIso8601String());
      expect(map['deleted_at'], isNull);
    });

    test('itemToSupabase maps all fields correctly', () {
      final item = ItemRow(
        itemId: 10,
        customerId: 1,
        itemName: 'Gold Ring',
        itemDescription: '22k 5g',
        pawnedDate: now,
        expiryDate: now.add(const Duration(days: 30)),
        pawnAmount: 5000.0,
        itemStatus: 'Active',
        itemPhoto: '',
        createdDate: now,
        syncId: 'item-uuid-1',
        updatedAt: now,
      );

      final map = SyncMappers.itemToSupabase(item, 'cust-uuid-1', ownerId);

      expect(map['id'], 'item-uuid-1');
      expect(map['owner_id'], ownerId);
      expect(map['customer_sync_id'], 'cust-uuid-1');
      expect(map['name'], 'Gold Ring');
      expect(map['pawn_amount'], 5000.0);
      expect(map['status'], 'Active');
    });

    test('transactionToSupabase maps all fields correctly', () {
      final txn = TransactionRow(
        transactionId: 100,
        customerId: 1,
        itemId: 10,
        transactionDate: now,
        transactionType: 'Active',
        amount: 5000.0,
        interestRate: 2.0,
        interestAmount: 100.0,
        remainingAmount: 5100.0,
        signature: '',
        createdDate: now,
        updatedDate: now.toIso8601String(),
        syncId: 'txn-uuid-1',
        updatedAt: now,
      );

      final map = SyncMappers.transactionToSupabase(
        txn,
        'cust-uuid-1',
        'item-uuid-1',
        ownerId,
      );

      expect(map['id'], 'txn-uuid-1');
      expect(map['owner_id'], ownerId);
      expect(map['customer_sync_id'], 'cust-uuid-1');
      expect(map['item_sync_id'], 'item-uuid-1');
      expect(map['amount'], 5000.0);
      expect(map['interest_rate'], 2.0);
      expect(map['transaction_type'], 'Active');
    });

    test('paymentToSupabase maps all fields correctly', () {
      final payment = PaymentRow(
        paymentId: 5,
        transactionId: 100,
        paymentDate: now,
        amountPaid: 100.0,
        paymentType: 'Interest',
        createdDate: now,
        syncId: 'pay-uuid-1',
        updatedAt: now,
      );

      final map = SyncMappers.paymentToSupabase(
        payment,
        'txn-uuid-1',
        ownerId,
      );

      expect(map['id'], 'pay-uuid-1');
      expect(map['owner_id'], ownerId);
      expect(map['transaction_sync_id'], 'txn-uuid-1');
      expect(map['amount_paid'], 100.0);
      expect(map['payment_type'], 'Interest');
    });

    test('historyToSupabase maps all fields correctly', () {
      final history = HistoryRow(
        historyId: 20,
        userId: 1,
        customerId: 1,
        customerName: 'John Doe',
        contactNumber: '9876543210',
        itemId: 10,
        transactionId: 100,
        amount: 5000.0,
        eventDate: now,
        eventType: 'Created',
        syncId: 'hist-uuid-1',
        updatedAt: now,
      );

      final map = SyncMappers.historyToSupabase(
        history,
        'cust-uuid-1',
        'item-uuid-1',
        'txn-uuid-1',
        ownerId,
      );

      expect(map['id'], 'hist-uuid-1');
      expect(map['owner_id'], ownerId);
      expect(map['customer_sync_id'], 'cust-uuid-1');
      expect(map['item_sync_id'], 'item-uuid-1');
      expect(map['transaction_sync_id'], 'txn-uuid-1');
      expect(map['amount'], 5000.0);
    });
  });
}
