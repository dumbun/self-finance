import 'package:drift/drift.dart' hide Constant;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/sync/sync_outbox_service.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history_model.dart';

void main() {
  group('Phase 2: Transaction & Payment UUID Migration Tests', () {
    setUp(() {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    });

    test('createNewTransactionAtomic generates UUIDv7 for item, txn, and links history', () async {
      final db = ItDataDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      BackEnd.setDatabase(db);

      // Create parent customer
      final customerId = await BackEnd.createNewCustomer(
        Customer(
          userID: 1,
          name: 'Jane Doe',
          guardianName: 'Father Doe',
          address: '42 Main St',
          number: '9876543210',
          photo: '',
          proof: '',
          createdDate: DateTime.now(),
        ),
      );
      expect(customerId, isNotEmpty);

      final now = DateTime.now();
      final txnId = await BackEnd.createNewTransactionAtomic(
        item: Items(
          customerid: customerId,
          name: 'Gold Ring',
          description: '22k Gold Ring',
          pawnedDate: now,
          expiryDate: now.add(const Duration(days: 90)),
          pawnAmount: 10000.0,
          status: Constant.active,
          photo: '',
          createdDate: now,
        ),
        transactionBuilder: (itemId) => Trx(
          customerId: customerId,
          itemId: itemId,
          transacrtionDate: now,
          transacrtionType: Constant.active,
          amount: 10000.0,
          intrestRate: 2.0,
          intrestAmount: 200.0,
          remainingAmount: 10000.0,
          signature: '',
          createdDate: now,
        ),
        historyBuilder: (itemId, transactionId) => UserHistory(
          userID: 1,
          customerID: customerId,
          itemID: itemId,
          customerName: 'Jane Doe',
          customerNumber: '9876543210',
          transactionID: transactionId,
          eventDate: now,
          eventType: Constant.debited,
          amount: 10000.0,
        ),
      );

      // Verify transaction ID is a non-empty UUID string
      expect(txnId, isNotEmpty);
      expect(txnId.length, greaterThanOrEqualTo(32));

      // Fetch transaction
      final txns = await BackEnd.fetchRequriedTransaction(transacrtionId: txnId);
      expect(txns.length, 1);
      final fetchedTxn = txns.first;
      expect(fetchedTxn.id, equals(txnId));
      expect(fetchedTxn.customerId, equals(customerId));
      expect(fetchedTxn.amount, equals(10000.0));
      expect(fetchedTxn.itemId, isNotEmpty);

      // Fetch history linked to this transaction
      final historyRows = await db.customSelect(
        'SELECT * FROM History WHERE Transaction_ID = ?',
        variables: [Variable<String>(txnId)],
      ).get();
      expect(historyRows.length, 1);
      expect(historyRows.first.read<String>('Transaction_ID'), equals(txnId));
      expect(historyRows.first.read<String>('Item_ID'), equals(fetchedTxn.itemId));

      // Add payment
      final paymentId = await BackEnd.addPayment(
        payment: Payment(
          transactionId: txnId,
          paymentDate: now,
          amountpaid: 2000.0,
          type: 'Cash',
          createdDate: now,
        ),
      );
      expect(paymentId, isNotEmpty);
      expect(paymentId.length, greaterThanOrEqualTo(32));

      // Fetch payments for this transaction
      final payments = await BackEnd.fetchRequriedPaymentsOfTransaction(
        transactionId: txnId,
      );
      expect(payments.length, 1);
      expect(payments.first.id, equals(paymentId));
      expect(payments.first.transactionId, equals(txnId));
      expect(payments.first.amountpaid, equals(2000.0));

      // Check outbox entries
      final outbox = await SyncOutboxService.getPending(db);
      final entityTypes = outbox.map((e) => e.entityType).toSet();
      expect(entityTypes.contains(SyncOutboxService.entityCustomer), isTrue);
      expect(entityTypes.contains(SyncOutboxService.entityItem), isTrue);
      expect(entityTypes.contains(SyncOutboxService.entityTransaction), isTrue);
      expect(entityTypes.contains(SyncOutboxService.entityPayment), isTrue);
    });

    test('queueAllExistingRecords backfills missing Sync_ID for Transactions and Payments and enqueues them', () async {
      final db = ItDataDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      BackEnd.setDatabase(db);

      final now = DateTime.now();
      // Insert customer with syncId
      final custId = await BackEnd.createNewCustomer(
        Customer(
          userID: 1,
          name: 'Sync Test Customer',
          guardianName: 'Guardian',
          address: 'Address',
          number: '1234567890',
          photo: '',
          proof: '',
          createdDate: now,
        ),
      );

      // Insert item with valid customerId
      final itemId = await BackEnd.createNewItem(
        Items(
          customerid: custId,
          name: 'Ring',
          description: 'Gold Ring',
          pawnedDate: now,
          expiryDate: now.add(const Duration(days: 90)),
          pawnAmount: 5000.0,
          status: 'Active',
          photo: '',
          createdDate: now,
        ),
      );

      // Insert transaction directly without syncId
      await db.into(db.transactionsTable).insert(
            TransactionsTableCompanion.insert(
              customerId: custId,
              itemId: itemId,
              transactionDate: now,
              transactionType: 'Active',
              amount: 5000.0,
              interestRate: 2.0,
              interestAmount: 100.0,
              remainingAmount: 5000.0,
              signature: '',
              createdDate: now,
            ),
          );

      final createdTxn = await db.select(db.transactionsTable).getSingle();
      expect(createdTxn.transactionId, isNotEmpty);

      // Insert payment without syncId
      await db.into(db.paymentsTable).insert(
            PaymentsTableCompanion.insert(
              transactionId: createdTxn.transactionId,
              paymentDate: now,
              amountPaid: 500.0,
              paymentType: 'Cash',
              createdDate: now,
            ),
          );

      // Before backfill, check hasRecordsNeedingSync returns true
      final needsSync = await SyncOutboxService.hasRecordsNeedingSync(db);
      expect(needsSync, isTrue);

      // Execute backfill
      final queuedCount = await SyncOutboxService.queueAllExistingRecords(db);
      expect(queuedCount, greaterThanOrEqualTo(2));

      // Check transaction now has valid Sync_ID
      final txnAfter = await db.select(db.transactionsTable).getSingle();
      expect(txnAfter.syncId, isNotEmpty);
      expect(txnAfter.syncId.length, 36);

      // Check payment now has valid Sync_ID
      final payAfter = await db.select(db.paymentsTable).getSingle();
      expect(payAfter.syncId, isNotEmpty);
      expect(payAfter.syncId.length, 36);

      // Verify hasRecordsNeedingSync is now false
      final needsSyncAfter = await SyncOutboxService.hasRecordsNeedingSync(db);
      expect(needsSyncAfter, isFalse);
    });

    test('deleteTransaction deletes transaction, item, payment and cancels reminder', () async {
      final db = ItDataDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      BackEnd.setDatabase(db);

      final customerId = await BackEnd.createNewCustomer(
        Customer(
          userID: 1,
          name: 'Delete Test',
          guardianName: 'Guardian',
          address: 'Address',
          number: '1111122222',
          photo: '',
          proof: '',
          createdDate: DateTime.now(),
        ),
      );

      final now = DateTime.now();
      final txnId = await BackEnd.createNewTransactionAtomic(
        item: Items(
          customerid: customerId,
          name: 'Item to delete',
          description: 'Desc',
          pawnedDate: now,
          expiryDate: now.add(const Duration(days: 90)),
          pawnAmount: 3000.0,
          status: Constant.active,
          photo: '',
          createdDate: now,
        ),
        transactionBuilder: (itemId) => Trx(
          customerId: customerId,
          itemId: itemId,
          transacrtionDate: now,
          transacrtionType: Constant.active,
          amount: 3000.0,
          intrestRate: 1.5,
          intrestAmount: 45.0,
          remainingAmount: 3000.0,
          signature: '',
          createdDate: now,
        ),
        historyBuilder: (itemId, transactionId) => UserHistory(
          userID: 1,
          customerID: customerId,
          itemID: itemId,
          customerName: 'Delete Test',
          customerNumber: '1111122222',
          transactionID: transactionId,
          eventDate: now,
          eventType: Constant.debited,
          amount: 3000.0,
        ),
      );

      // Add a payment
      await BackEnd.addPayment(
        payment: Payment(
          transactionId: txnId,
          paymentDate: now,
          amountpaid: 500.0,
          type: 'Cash',
          createdDate: now,
        ),
      );

      // Delete the transaction
      final result = await BackEnd.deleteTransaction(transactionId: txnId);
      expect(result['transactionDeleted'], equals(1));
      expect(result['itemDeleted'], equals(1));
      expect(result['paymentsDeleted'], equals(1));

      // Verify transaction is gone
      final txnsAfter = await BackEnd.fetchRequriedTransaction(transacrtionId: txnId);
      expect(txnsAfter, isEmpty);

      // Verify payments are gone
      final paymentsAfter = await BackEnd.fetchRequriedPaymentsOfTransaction(
        transactionId: txnId,
      );
      expect(paymentsAfter, isEmpty);
    });
  });
}
