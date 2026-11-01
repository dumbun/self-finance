import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/sync/sync_mappers.dart';
import 'package:self_finance/core/sync/sync_outbox_service.dart';

void main() {
  group('SyncEngine & Schema Resilience Tests', () {
    late ItDataDatabase db;

    setUp(() {
      db = ItDataDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('historyToSupabase safely maps 0 or empty foreign keys to null', () {
      final now = DateTime.utc(2026, 10, 25, 12);
      final history = HistoryRow(
        historyId: '0192e2fb-8c31-7e77-9492-7fca7c59501a',
        userId: 1,
        customerId: '0192e2fb-8c31-7e77-9492-7fca7c59501b',
        customerName: 'Test Customer',
        contactNumber: '9999999999',
        itemId: '0',
        transactionId: '0',
        amount: 2500.0,
        eventDate: now,
        eventType: 'Cash Payment',
        syncId: '0192e2fb-8c31-7e77-9492-7fca7c59501a',
        updatedAt: now,
      );

      final map = SyncMappers.historyToSupabase(
        history,
        history.customerId,
        history.itemId,
        history.transactionId,
        'test-owner-id',
      );

      expect(map['id'], history.historyId);
      expect(map['customer_sync_id'], history.customerId);
      expect(map['item_sync_id'], isNull, reason: "'0' should be mapped to null for Postgres UUID");
      expect(map['transaction_sync_id'], isNull, reason: "'0' should be mapped to null for Postgres UUID");
      expect(map['amount'], 2500.0);
    });

    test('SyncOutboxService coalescing logic removes redundant offline updates', () async {
      const entityId = '0192e2fb-8c31-7e77-9492-7fca7c59502a';

      // 1. Queue a create
      await SyncOutboxService.recordOperation(
        db: db,
        entityType: SyncOutboxService.entityCustomer,
        entitySyncId: entityId,
        operation: SyncOutboxService.opCreate,
      );

      // 2. Queue multiple subsequent updates
      await SyncOutboxService.recordOperation(
        db: db,
        entityType: SyncOutboxService.entityCustomer,
        entitySyncId: entityId,
        operation: SyncOutboxService.opUpdate,
      );
      await SyncOutboxService.recordOperation(
        db: db,
        entityType: SyncOutboxService.entityCustomer,
        entitySyncId: entityId,
        operation: SyncOutboxService.opUpdate,
      );

      final pending = await SyncOutboxService.getPending(db);
      expect(pending.length, 3);

      // Grouping and coalescing simulation as implemented in SyncEngine.push
      final grouped = <String, List<SyncOutboxRow>>{};
      for (final op in pending) {
        final key = '${op.entityType}:${op.entitySyncId}';
        grouped.putIfAbsent(key, () => []).add(op);
      }

      final coalescedOps = <SyncOutboxRow>[];
      final immediateDiscardIds = <int>[];

      for (final entry in grouped.entries) {
        final ops = entry.value;
        final ids = ops.map((o) => o.outboxId).toList();
        final hasCreate = ops.any((o) => o.operation == SyncOutboxService.opCreate);
        final latestOp = ops.last;

        if (hasCreate && latestOp.operation == SyncOutboxService.opDelete) {
          immediateDiscardIds.addAll(ids);
        } else {
          final effectiveOperation = hasCreate ? SyncOutboxService.opCreate : latestOp.operation;
          coalescedOps.add(latestOp.copyWith(operation: effectiveOperation));
        }
      }

      expect(immediateDiscardIds, isEmpty);
      expect(coalescedOps.length, 1);
      expect(coalescedOps.first.operation, SyncOutboxService.opCreate);
    });

    test('SyncOutboxService coalescing discards offline create + delete without pushing', () async {
      const entityId = '0192e2fb-8c31-7e77-9492-7fca7c59503a';

      await SyncOutboxService.recordOperation(
        db: db,
        entityType: SyncOutboxService.entityCustomer,
        entitySyncId: entityId,
        operation: SyncOutboxService.opCreate,
      );
      await SyncOutboxService.recordOperation(
        db: db,
        entityType: SyncOutboxService.entityCustomer,
        entitySyncId: entityId,
        operation: SyncOutboxService.opDelete,
      );

      final pending = await SyncOutboxService.getPending(db);
      expect(pending.length, 2);

      final grouped = <String, List<SyncOutboxRow>>{};
      for (final op in pending) {
        final key = '${op.entityType}:${op.entitySyncId}';
        grouped.putIfAbsent(key, () => []).add(op);
      }

      final coalescedOps = <SyncOutboxRow>[];
      final immediateDiscardIds = <int>[];

      for (final entry in grouped.entries) {
        final ops = entry.value;
        final ids = ops.map((o) => o.outboxId).toList();
        final hasCreate = ops.any((o) => o.operation == SyncOutboxService.opCreate);
        final latestOp = ops.last;

        if (hasCreate && latestOp.operation == SyncOutboxService.opDelete) {
          immediateDiscardIds.addAll(ids);
        } else {
          final effectiveOperation = hasCreate ? SyncOutboxService.opCreate : latestOp.operation;
          coalescedOps.add(latestOp.copyWith(operation: effectiveOperation));
        }
      }

      expect(immediateDiscardIds.length, 2);
      expect(coalescedOps, isEmpty);

      // Clean them up directly
      await SyncOutboxService.removeEntries(db, immediateDiscardIds);
      final remaining = await SyncOutboxService.getPending(db);
      expect(remaining, isEmpty);
    });
  });
}
