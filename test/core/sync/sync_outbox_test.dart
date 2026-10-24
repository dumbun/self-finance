import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/sync/sync_outbox_service.dart';

void main() {
  group('SyncOutboxService tests', () {
    late ItDataDatabase db;

    setUp(() {
      db = ItDataDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('recordOperation queues operations and getPending retrieves them', () async {
      await SyncOutboxService.recordOperation(
        db: db,
        entityType: SyncOutboxService.entityCustomer,
        entitySyncId: 'cust-uuid-1',
        operation: SyncOutboxService.opCreate,
      );

      await SyncOutboxService.recordOperation(
        db: db,
        entityType: SyncOutboxService.entityTransaction,
        entitySyncId: 'txn-uuid-1',
        operation: SyncOutboxService.opUpdate,
      );

      final pending = await SyncOutboxService.getPending(db);
      expect(pending.length, 2);
      expect(pending[0].entityType, SyncOutboxService.entityCustomer);
      expect(pending[0].entitySyncId, 'cust-uuid-1');
      expect(pending[0].operation, SyncOutboxService.opCreate);

      expect(pending[1].entityType, SyncOutboxService.entityTransaction);
      expect(pending[1].entitySyncId, 'txn-uuid-1');
      expect(pending[1].operation, SyncOutboxService.opUpdate);
    });

    test('removeEntries removes processed entry', () async {
      await SyncOutboxService.recordOperation(
        db: db,
        entityType: SyncOutboxService.entityCustomer,
        entitySyncId: 'cust-uuid-1',
        operation: SyncOutboxService.opCreate,
      );

      final pending = await SyncOutboxService.getPending(db);
      expect(pending.length, 1);

      await SyncOutboxService.removeEntries(db, [pending.first.outboxId]);

      final pendingAfter = await SyncOutboxService.getPending(db);
      expect(pendingAfter, isEmpty);
    });

    test('queueAllExistingRecords backfills Sync_ID and queues existing records', () async {
      // Insert customer with empty syncId
      await db.into(db.customersTable).insert(
        CustomersTableCompanion.insert(
          userId: 1,
          customerName: 'John Doe',
          gaurdianName: 'Jane Doe',
          customerAddress: '123 Test St',
          contactNumber: '1234567890',
          customerPhoto: 'photo.jpg',
          proofPhoto: 'proof.jpg',
          createdDate: DateTime.now(),
        ),
      );

      final beforeRows = await db.select(db.customersTable).get();
      expect(beforeRows.length, 1);
      expect(beforeRows.first.syncId, isEmpty);

      // Run queueAllExistingRecords
      await SyncOutboxService.queueAllExistingRecords(db);

      // Verify syncId was backfilled
      final afterRows = await db.select(db.customersTable).get();
      expect(afterRows.first.syncId, isNotEmpty);
      expect(afterRows.first.syncId.length, 36); // UUID v4 length

      // Verify outbox has the record queued
      final pending = await SyncOutboxService.getPending(db);
      expect(pending.length, 1);
      expect(pending.first.entityType, SyncOutboxService.entityCustomer);
      expect(pending.first.entitySyncId, afterRows.first.syncId);
      expect(pending.first.operation, SyncOutboxService.opCreate);

      // Calling again shouldn't duplicate outbox entries
      await SyncOutboxService.queueAllExistingRecords(db);
      final pendingSecond = await SyncOutboxService.getPending(db);
      expect(pendingSecond.length, 1);
    });
  });
}
