import 'package:drift/drift.dart' hide Constant;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/sync/sync_outbox_service.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/models/user_history_model.dart';

void main() {
  group('Phase 3: History UUID Migration Tests', () {
    setUp(() {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    });

    test('createNewHistory and atomic operations generate UUIDv7 historyId', () async {
      final db = ItDataDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      BackEnd.setDatabase(db);

      // Create customer
      final customerId = await BackEnd.createNewCustomer(
        Customer(
          userID: 1,
          name: 'History Test Customer',
          guardianName: 'Guardian',
          address: 'Test Address',
          number: '9876543210',
          photo: '',
          proof: '',
          createdDate: DateTime.now(),
        ),
      );

      final now = DateTime.now();

      // Create standalone history
      final historyId = await BackEnd.createNewHistory(
        UserHistory(
          userID: 1,
          customerID: customerId,
          itemID: 'item-1',
          customerName: 'History Test Customer',
          customerNumber: '9876543210',
          transactionID: 'txn-1',
          eventDate: now,
          eventType: Constant.debited,
          amount: 5000.0,
        ),
      );

      expect(historyId, isNotEmpty);
      expect(historyId.length, greaterThanOrEqualTo(32));

      // Verify row in database
      final historyRows = await db.customSelect(
        'SELECT * FROM History WHERE History_ID = ?',
        variables: [Variable<String>(historyId)],
      ).get();
      expect(historyRows.length, 1);
      final row = historyRows.first;
      expect(row.read<String>('History_ID'), equals(historyId));
      expect(row.read<String>('Sync_ID'), equals(historyId));
      expect(row.read<double>('Amount'), equals(5000.0));

      // Test atomic transaction creation history entry
      final txnId = await BackEnd.createNewTransactionAtomic(
        item: Items(
          customerid: customerId,
          name: 'Watch',
          description: 'Silver Watch',
          pawnedDate: now,
          expiryDate: now.add(const Duration(days: 90)),
          pawnAmount: 8000.0,
          status: Constant.active,
          photo: '',
          createdDate: now,
        ),
        transactionBuilder: (itemId) => Trx(
          customerId: customerId,
          itemId: itemId,
          transacrtionDate: now,
          transacrtionType: Constant.active,
          amount: 8000.0,
          intrestRate: 2.0,
          intrestAmount: 160.0,
          remainingAmount: 8000.0,
          signature: '',
          createdDate: now,
        ),
        historyBuilder: (itemId, transactionId) => UserHistory(
          userID: 1,
          customerID: customerId,
          itemID: itemId,
          customerName: 'History Test Customer',
          customerNumber: '9876543210',
          transactionID: transactionId,
          eventDate: now,
          eventType: Constant.debited,
          amount: 8000.0,
        ),
      );

      // Verify atomic history record
      final atomicHistoryRows = await db.customSelect(
        'SELECT * FROM History WHERE Transaction_ID = ?',
        variables: [Variable<String>(txnId)],
      ).get();
      expect(atomicHistoryRows.length, 1);
      final atomicRow = atomicHistoryRows.first;
      final atomicHistoryId = atomicRow.read<String>('History_ID');
      expect(atomicHistoryId, isNotEmpty);
      expect(atomicHistoryId.length, greaterThanOrEqualTo(32));
      expect(atomicRow.read<String>('Sync_ID'), equals(atomicHistoryId));

      // Test watchAllUserHistory stream
      final historyStreamList = await BackEnd.watchAllUserHistory().first;
      expect(historyStreamList.length, 2);
      expect(historyStreamList.any((h) => h.id == historyId), isTrue);
      expect(historyStreamList.any((h) => h.id == atomicHistoryId), isTrue);
    });

    test('queueAllExistingRecords backfills missing Sync_ID for History and enqueues outbox', () async {
      final db = ItDataDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      BackEnd.setDatabase(db);

      final now = DateTime.now();
      final customerId = await BackEnd.createNewCustomer(
        Customer(
          userID: 1,
          name: 'Backfill Customer',
          guardianName: 'Guardian',
          address: 'Address',
          number: '1234567890',
          photo: '',
          proof: '',
          createdDate: now,
        ),
      );

      // Insert history directly without syncId
      await db.into(db.historyTable).insert(
            HistoryTableCompanion.insert(
              userId: 1,
              customerId: customerId,
              customerName: 'Backfill Customer',
              contactNumber: '1234567890',
              itemId: 'test-item',
              transactionId: 'test-txn',
              amount: 1000.0,
              eventDate: now,
              eventType: 'Debited',
            ),
          );

      // Check hasRecordsNeedingSync is true
      final needsSync = await SyncOutboxService.hasRecordsNeedingSync(db);
      expect(needsSync, isTrue);

      // Run backfill
      final queued = await SyncOutboxService.queueAllExistingRecords(db);
      expect(queued, greaterThanOrEqualTo(1));

      // Verify row now has valid 36-char UUID Sync_ID
      final histRow = await db.select(db.historyTable).getSingle();
      expect(histRow.syncId, isNotEmpty);
      expect(histRow.syncId.length, 36);

      // Verify outbox queued
      final outbox = await SyncOutboxService.getPending(db);
      expect(outbox.any((e) => e.entityType == SyncOutboxService.entityHistory), isTrue);

      final needsSyncAfter = await SyncOutboxService.hasRecordsNeedingSync(db);
      expect(needsSyncAfter, isFalse);
    });
  });
}
