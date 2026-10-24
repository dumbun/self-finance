import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:uuid/uuid.dart';

/// Service responsible for queueing mutations to the local [SyncOutboxTable].
///
/// Every local create, update, and delete operation writes an entry here so that
/// mutations are never lost while offline and are pushed reliably once online.
class SyncOutboxService {
  static const String entityCustomer = 'customer';
  static const String entityItem = 'item';
  static const String entityTransaction = 'transaction';
  static const String entityPayment = 'payment';
  static const String entityHistory = 'history';

  static const String opCreate = 'create';
  static const String opUpdate = 'update';
  static const String opDelete = 'delete';

  /// Records an operation to the sync outbox.
  static Future<void> recordOperation({
    required ItDataDatabase db,
    required String entityType,
    required String entitySyncId,
    required String operation,
  }) async {
    if (entitySyncId.isEmpty) return;

    try {
      await db
          .into(db.syncOutboxTable)
          .insert(
            SyncOutboxTableCompanion.insert(
              entityType: entityType,
              entitySyncId: entitySyncId,
              operation: operation,
              createdAt: DateTime.now(),
            ),
          );
      debugPrint(
        'Outbox: queued $operation on $entityType (syncId: $entitySyncId)',
      );
    } catch (e) {
      debugPrint('Outbox error queueing $operation on $entityType: $e');
    }
  }

  /// Fetches pending outbox operations up to [limit].
  static Future<List<SyncOutboxRow>> getPending(
    ItDataDatabase db, {
    int limit = 100,
  }) async {
    return (db.select(db.syncOutboxTable)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Removes successfully synchronized outbox entries by their IDs.
  static Future<void> removeEntries(
    ItDataDatabase db,
    List<int> outboxIds,
  ) async {
    if (outboxIds.isEmpty) return;
    await (db.delete(
      db.syncOutboxTable,
    )..where((t) => t.outboxId.isIn(outboxIds))).go();
  }

  /// Increments the retry count and records the last error on an outbox entry.
  static Future<void> markFailed(
    ItDataDatabase db,
    int outboxId,
    String error,
  ) async {
    final entry = await (db.select(
      db.syncOutboxTable,
    )..where((t) => t.outboxId.equals(outboxId))).getSingleOrNull();

    if (entry != null) {
      await (db.update(
        db.syncOutboxTable,
      )..where((t) => t.outboxId.equals(outboxId))).write(
        SyncOutboxTableCompanion(
          retryCount: Value(entry.retryCount + 1),
          lastError: Value(error),
        ),
      );
    }
  }

  /// Returns true when any local row is still missing a sync ID and needs
  /// migration/backfill before the next cloud sync.
  static Future<bool> hasRecordsNeedingSync(ItDataDatabase db) async {
    try {
      final tables = <String, String>{
        'Customers':
            'SELECT COUNT(*) AS cnt FROM Customers WHERE Sync_ID IS NULL OR Sync_ID = \'\'',
        'Items':
            'SELECT COUNT(*) AS cnt FROM Items WHERE Sync_ID IS NULL OR Sync_ID = \'\'',
        'Transactions':
            'SELECT COUNT(*) AS cnt FROM Transactions WHERE Sync_ID IS NULL OR Sync_ID = \'\'',
        'Payments':
            'SELECT COUNT(*) AS cnt FROM Payments WHERE Sync_ID IS NULL OR Sync_ID = \'\'',
        'History':
            'SELECT COUNT(*) AS cnt FROM History WHERE Sync_ID IS NULL OR Sync_ID = \'\'',
      };

      for (final entry in tables.entries) {
        final result = await db.customSelect(entry.value).getSingle();
        final count = result.read<int>('cnt');
        if (count > 0) {
          debugPrint(
            'Outbox: ${entry.key} still needs Sync_ID backfill ($count rows).',
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Outbox: failed to check for legacy sync IDs: $e');
      return false;
    }
  }

  /// Ensures all local records have a valid UUID syncId and queues any un-synced
  /// records into the outbox so that existing/restored records are pushed to Supabase.
  ///
  /// This is intentionally kept as a migration/backfill path; it should not run on
  /// every sync cycle because it does a full table scan and creates outbox items for
  /// every row. Callers should guard with [hasRecordsNeedingSync] first.
  static Future<int> queueAllExistingRecords(ItDataDatabase db) async {
    const uuid = Uuid();
    final now = DateTime.now();
    int queuedCount = 0;

    // Pre-fetch all pending outbox entries to avoid thousands of individual queries
    final existingOutboxEntries = await db.select(db.syncOutboxTable).get();
    final queuedKeys = existingOutboxEntries
        .map((e) => '${e.entityType}:${e.entitySyncId}')
        .toSet();

    await db.transaction(() async {
      // 1. Customers
      final custs = await db
          .customSelect(
            "SELECT Customer_ID, Sync_ID FROM Customers WHERE Sync_ID IS NULL OR Sync_ID = ''",
          )
          .get();
      for (final row in custs) {
        final id = row.read<int>('Customer_ID');
        String syncId = row.read<String?>('Sync_ID') ?? '';
        if (syncId.isEmpty || syncId.length < 30) {
          syncId = uuid.v4();
          await db.customUpdate(
            'UPDATE Customers SET Sync_ID = ?, Updated_At = ? WHERE Customer_ID = ?',
            variables: [
              Variable<String>(syncId),
              Variable<DateTime>(now),
              Variable<int>(id),
            ],
          );
        }
        final key = '$entityCustomer:$syncId';
        if (!queuedKeys.contains(key)) {
          await recordOperation(
            db: db,
            entityType: entityCustomer,
            entitySyncId: syncId,
            operation: opCreate,
          );
          queuedKeys.add(key);
          queuedCount++;
        }
      }

      // 2. Items
      final items = await db
          .customSelect(
            "SELECT Item_ID, Sync_ID FROM Items WHERE Sync_ID IS NULL OR Sync_ID = ''",
          )
          .get();
      for (final row in items) {
        final id = row.read<int>('Item_ID');
        String syncId = row.read<String?>('Sync_ID') ?? '';
        if (syncId.isEmpty || syncId.length < 30) {
          syncId = uuid.v4();
          await db.customUpdate(
            'UPDATE Items SET Sync_ID = ?, Updated_At = ? WHERE Item_ID = ?',
            variables: [
              Variable<String>(syncId),
              Variable<DateTime>(now),
              Variable<int>(id),
            ],
          );
        }
        final key = '$entityItem:$syncId';
        if (!queuedKeys.contains(key)) {
          await recordOperation(
            db: db,
            entityType: entityItem,
            entitySyncId: syncId,
            operation: opCreate,
          );
          queuedKeys.add(key);
          queuedCount++;
        }
      }

      // 3. Transactions
      final txns = await db
          .customSelect(
            "SELECT Transaction_ID, Sync_ID FROM Transactions WHERE Sync_ID IS NULL OR Sync_ID = ''",
          )
          .get();
      for (final row in txns) {
        final id = row.read<int>('Transaction_ID');
        String syncId = row.read<String?>('Sync_ID') ?? '';
        if (syncId.isEmpty || syncId.length < 30) {
          syncId = uuid.v4();
          await db.customUpdate(
            'UPDATE Transactions SET Sync_ID = ?, Updated_At = ? WHERE Transaction_ID = ?',
            variables: [
              Variable<String>(syncId),
              Variable<DateTime>(now),
              Variable<int>(id),
            ],
          );
        }
        final key = '$entityTransaction:$syncId';
        if (!queuedKeys.contains(key)) {
          await recordOperation(
            db: db,
            entityType: entityTransaction,
            entitySyncId: syncId,
            operation: opCreate,
          );
          queuedKeys.add(key);
          queuedCount++;
        }
      }

      // 4. Payments
      final pays = await db
          .customSelect(
            "SELECT Payment_ID, Sync_ID FROM Payments WHERE Sync_ID IS NULL OR Sync_ID = ''",
          )
          .get();
      for (final row in pays) {
        final id = row.read<int>('Payment_ID');
        String syncId = row.read<String?>('Sync_ID') ?? '';
        if (syncId.isEmpty || syncId.length < 30) {
          syncId = uuid.v4();
          await db.customUpdate(
            'UPDATE Payments SET Sync_ID = ?, Updated_At = ? WHERE Payment_ID = ?',
            variables: [
              Variable<String>(syncId),
              Variable<DateTime>(now),
              Variable<int>(id),
            ],
          );
        }
        final key = '$entityPayment:$syncId';
        if (!queuedKeys.contains(key)) {
          await recordOperation(
            db: db,
            entityType: entityPayment,
            entitySyncId: syncId,
            operation: opCreate,
          );
          queuedKeys.add(key);
          queuedCount++;
        }
      }

      // 5. History
      final hists = await db
          .customSelect(
            "SELECT History_ID, Sync_ID FROM History WHERE Sync_ID IS NULL OR Sync_ID = ''",
          )
          .get();
      for (final row in hists) {
        final id = row.read<int>('History_ID');
        String syncId = row.read<String?>('Sync_ID') ?? '';
        if (syncId.isEmpty || syncId.length < 30) {
          syncId = uuid.v4();
          await db.customUpdate(
            'UPDATE History SET Sync_ID = ?, Updated_At = ? WHERE History_ID = ?',
            variables: [
              Variable<String>(syncId),
              Variable<DateTime>(now),
              Variable<int>(id),
            ],
          );
        }
        final key = '$entityHistory:$syncId';
        if (!queuedKeys.contains(key)) {
          await recordOperation(
            db: db,
            entityType: entityHistory,
            entitySyncId: syncId,
            operation: opCreate,
          );
          queuedKeys.add(key);
          queuedCount++;
        }
      }
    });

    if (queuedCount > 0) {
      debugPrint(
        'Outbox: Finished queueing $queuedCount existing records for sync.',
      );
    }
    return queuedCount;
  }
}
