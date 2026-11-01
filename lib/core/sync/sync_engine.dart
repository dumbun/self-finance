import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' hide Query;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/sync/file_sync_service.dart';
import 'package:self_finance/core/sync/sync_mappers.dart';
import 'package:self_finance/core/sync/sync_outbox_service.dart';

/// Bidirectional sync engine coordinating local Drift SQLite, Cloud Firestore,
/// and Firebase Storage file attachments.
class SyncEngine {
  SyncEngine({
    FirebaseFirestore? firestore,
    dynamic client,
    required this.db,
    required this.userId,
    this.appDirPath,
    FileSyncService? fileSyncService,
  })  : firestore = firestore ??
            (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null),
        fileSync = fileSyncService ?? FileSyncService();

  final FirebaseFirestore? firestore;
  final ItDataDatabase db;
  final String userId;
  final String? appDirPath;
  final FileSyncService fileSync;

  CollectionReference<Map<String, dynamic>>? _collection(String name) {
    final fs = firestore;
    if (fs == null) return null;
    return fs.collection('users').doc(userId).collection(name);
  }

  static const String _prefLastSyncPrefix = 'last_sync_timestamp_';

  String get _prefKey => '$_prefLastSyncPrefix$userId';

  static DateTime? _safeParseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.trim().isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<String> _resolveAppDir() async {
    if (appDirPath != null && appDirPath!.isNotEmpty) {
      return appDirPath!;
    }
    try {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    } catch (_) {
      return '';
    }
  }

  /// Performs a full bidirectional sync: pushes local mutations, then pulls remote changes.
  Future<void> sync() async {
    debugPrint('🔄 Starting sync for user: $userId');
    final resolvedAppDir = await _resolveAppDir();
    await push(resolvedAppDir);
    await pull(resolvedAppDir);
    debugPrint('✅ Sync completed successfully.');
  }

  // ===========================================================================
  // PUSH PHASE
  // ===========================================================================

  /// Pushes pending outbox mutations to Supabase in foreign-key dependency order.
  Future<void> push([String? appDir]) async {
    final resolvedAppDir = appDir ?? await _resolveAppDir();

    while (true) {
      final pending = await SyncOutboxService.getPending(db);
      if (pending.isEmpty) {
        debugPrint('Sync Push: Outbox is clear.');
        break;
      }

      debugPrint(
        'Sync Push: Processing batch of ${pending.length} operations.',
      );

      // Group pending operations by entityType and entitySyncId to coalesce redundant mutations
      final grouped = <String, List<SyncOutboxRow>>{};
      for (final op in pending) {
        final key = '${op.entityType}:${op.entitySyncId}';
        grouped.putIfAbsent(key, () => []).add(op);
      }

      final coalescedOps = <SyncOutboxRow>[];
      final immediateDiscardIds = <int>[];
      final allOutboxIdsByGroupKey = <String, List<int>>{};

      for (final entry in grouped.entries) {
        final ops = entry.value;
        final key = entry.key;
        final ids = ops.map((o) => o.outboxId).toList();
        allOutboxIdsByGroupKey[key] = ids;

        final hasCreate =
            ops.any((o) => o.operation == SyncOutboxService.opCreate);
        final latestOp = ops.last;

        if (hasCreate && latestOp.operation == SyncOutboxService.opDelete) {
          // Created and deleted offline before ever reaching cloud: discard directly
          immediateDiscardIds.addAll(ids);
        } else {
          final effectiveOperation =
              hasCreate ? SyncOutboxService.opCreate : latestOp.operation;
          coalescedOps.add(
            latestOp.copyWith(operation: effectiveOperation),
          );
        }
      }

      if (immediateDiscardIds.isNotEmpty) {
        await SyncOutboxService.removeEntries(db, immediateDiscardIds);
        debugPrint(
          'Sync Push: Discarded ${immediateDiscardIds.length} ephemeral offline create+delete operations.',
        );
      }

      if (coalescedOps.isEmpty) {
        continue;
      }

      // Sort operations to respect foreign keys:
      // customers -> items -> transactions -> payments -> history
      final order = {
        SyncOutboxService.entityCustomer: 1,
        SyncOutboxService.entityItem: 2,
        SyncOutboxService.entityTransaction: 3,
        SyncOutboxService.entityPayment: 4,
        SyncOutboxService.entityHistory: 5,
      };

      final sorted = List<SyncOutboxRow>.from(coalescedOps)
        ..sort((a, b) {
          final ordA = order[a.entityType] ?? 99;
          final ordB = order[b.entityType] ?? 99;
          return ordA.compareTo(ordB);
        });

      final successfulIds = <int>[];

      for (final op in sorted) {
        final groupKey = '${op.entityType}:${op.entitySyncId}';
        final groupIds = allOutboxIdsByGroupKey[groupKey] ?? [op.outboxId];
        try {
          await _processOutboxOperation(op, resolvedAppDir);
          successfulIds.addAll(groupIds);
        } catch (e) {
          debugPrint(
            'Sync Push failed for ${op.entityType} ${op.entitySyncId}: $e',
          );
          for (final outboxId in groupIds) {
            await SyncOutboxService.markFailed(db, outboxId, e.toString());
          }
        }
      }

      if (successfulIds.isNotEmpty) {
        await SyncOutboxService.removeEntries(db, successfulIds);
        debugPrint(
          'Sync Push: Cleared ${successfulIds.length} outbox operations.',
        );
      } else {
        debugPrint(
          'Sync Push: All remaining items in batch failed; stopping push loop.',
        );
        break;
      }
    }
  }

  String _tableNameForEntity(String entity) {
    switch (entity) {
      case SyncOutboxService.entityCustomer:
        return 'customers';
      case SyncOutboxService.entityItem:
        return 'items';
      case SyncOutboxService.entityTransaction:
        return 'transactions';
      case SyncOutboxService.entityPayment:
        return 'payments';
      case SyncOutboxService.entityHistory:
        return 'history';
      default:
        throw ArgumentError('Unknown entity: $entity');
    }
  }

  Future<void> _processOutboxOperation(
    SyncOutboxRow op,
    String resolvedAppDir,
  ) async {
    final syncId = op.entitySyncId;

    if (op.operation == SyncOutboxService.opDelete) {
      final table = _tableNameForEntity(op.entityType);
      final payload = <String, dynamic>{
        'deleted_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      if (op.entityType == SyncOutboxService.entityCustomer) {
        payload['photo_path'] = null;
        payload['proof_path'] = null;
      }
      if (op.entityType == SyncOutboxService.entityItem) {
        payload['photo_path'] = null;
      }
      if (op.entityType == SyncOutboxService.entityTransaction) {
        payload['signature_path'] = null;
      }

      await _collection(table)?.doc(syncId).set(
            payload,
            SetOptions(merge: true),
          );

      return;
    }

    // Create or Update
    switch (op.entityType) {
      case SyncOutboxService.entityCustomer:
        final row = await (db.select(
          db.customersTable,
        )..where((t) => t.syncId.equals(syncId) | t.customerId.equals(syncId))).getSingleOrNull();
        if (row != null) {
          String? remotePhoto;
          String? remoteProof;
          final effectiveSyncId =
              row.syncId.isNotEmpty ? row.syncId : row.customerId;
          if (resolvedAppDir.isNotEmpty) {
            if (row.customerPhoto.isNotEmpty) {
              final remote = fileSync.getCustomerPhotoRemotePath(
                userId,
                effectiveSyncId,
              );
              final uploaded = await fileSync.uploadFile(
                localRelativePath: row.customerPhoto,
                remotePath: remote,
                appDirPath: resolvedAppDir,
              );
              if (uploaded != null) remotePhoto = uploaded;
            }
            if (row.proofPhoto.isNotEmpty) {
              final remote = fileSync.getCustomerProofRemotePath(
                userId,
                effectiveSyncId,
              );
              final uploaded = await fileSync.uploadFile(
                localRelativePath: row.proofPhoto,
                remotePath: remote,
                appDirPath: resolvedAppDir,
              );
              if (uploaded != null) remoteProof = uploaded;
            }
          }

          final payload = SyncMappers.customerToSupabase(
            row,
            userId,
            remotePhotoPath: remotePhoto,
            remoteProofPath: remoteProof,
          );
          await _collection('customers')?.doc(effectiveSyncId).set(
                payload,
                SetOptions(merge: true),
              );
        }
        break;

      case SyncOutboxService.entityItem:
        final row = await (db.select(
          db.itemsTable,
        )..where((t) => t.syncId.equals(syncId) | t.itemId.equals(syncId))).getSingleOrNull();
        if (row != null) {
          final cust =
              await (db.select(db.customersTable)
                    ..where((t) => t.customerId.equals(row.customerId) | t.syncId.equals(row.customerId)))
                  .getSingleOrNull();
          if (cust != null) {
            String? remotePhoto;
            final effectiveSyncId =
                row.syncId.isNotEmpty ? row.syncId : row.itemId;
            if (resolvedAppDir.isNotEmpty && row.itemPhoto.isNotEmpty) {
              final remote = fileSync.getItemPhotoRemotePath(
                userId,
                effectiveSyncId,
              );
              final uploaded = await fileSync.uploadFile(
                localRelativePath: row.itemPhoto,
                remotePath: remote,
                appDirPath: resolvedAppDir,
              );
              if (uploaded != null) remotePhoto = uploaded;
            }

            final custSyncId =
                cust.syncId.isNotEmpty ? cust.syncId : cust.customerId;
            final payload = SyncMappers.itemToSupabase(
              row,
              custSyncId,
              userId,
              remotePhotoPath: remotePhoto,
            );
            await _collection('items')?.doc(effectiveSyncId).set(
                  payload,
                  SetOptions(merge: true),
                );
          }
        }
        break;

      case SyncOutboxService.entityTransaction:
        final row = await (db.select(
          db.transactionsTable,
        )..where((t) => t.syncId.equals(syncId) | t.transactionId.equals(syncId))).getSingleOrNull();
        if (row != null) {
          final cust =
              await (db.select(db.customersTable)
                    ..where((t) => t.customerId.equals(row.customerId) | t.syncId.equals(row.customerId)))
                  .getSingleOrNull();
          final item = await (db.select(
            db.itemsTable,
          )..where((t) => t.itemId.equals(row.itemId) | t.syncId.equals(row.itemId))).getSingleOrNull();
          if (cust != null && item != null) {
            String? remoteSig;
            final effectiveSyncId =
                row.syncId.isNotEmpty ? row.syncId : row.transactionId;
            if (resolvedAppDir.isNotEmpty && row.signature.isNotEmpty) {
              final remote = fileSync.getTransactionSignatureRemotePath(
                userId,
                effectiveSyncId,
              );
              final uploaded = await fileSync.uploadFile(
                localRelativePath: row.signature,
                remotePath: remote,
                appDirPath: resolvedAppDir,
              );
              if (uploaded != null) remoteSig = uploaded;
            }

            final custSyncId =
                cust.syncId.isNotEmpty ? cust.syncId : cust.customerId;
            final itemSyncId =
                item.syncId.isNotEmpty ? item.syncId : item.itemId;
            final payload = SyncMappers.transactionToSupabase(
              row,
              custSyncId,
              itemSyncId,
              userId,
              remoteSignaturePath: remoteSig,
            );
            await _collection('transactions')?.doc(effectiveSyncId).set(
                  payload,
                  SetOptions(merge: true),
                );
          }
        }
        break;

      case SyncOutboxService.entityPayment:
        final row = await (db.select(
          db.paymentsTable,
        )..where((t) => t.syncId.equals(syncId) | t.paymentId.equals(syncId))).getSingleOrNull();
        if (row != null) {
          final txn =
              await (db.select(db.transactionsTable)
                    ..where((t) => t.transactionId.equals(row.transactionId) | t.syncId.equals(row.transactionId)))
                  .getSingleOrNull();
          if (txn != null) {
            final effectiveSyncId =
                row.syncId.isNotEmpty ? row.syncId : row.paymentId;
            final txnSyncId =
                txn.syncId.isNotEmpty ? txn.syncId : txn.transactionId;
            final payload = SyncMappers.paymentToSupabase(
              row,
              txnSyncId,
              userId,
            );
            await _collection('payments')?.doc(effectiveSyncId).set(
                  payload,
                  SetOptions(merge: true),
                );
          }
        }
        break;

      case SyncOutboxService.entityHistory:
        final row = await (db.select(
          db.historyTable,
        )..where((t) => t.syncId.equals(syncId) | t.historyId.equals(syncId))).getSingleOrNull();
        if (row != null) {
          final cust =
              await (db.select(db.customersTable)
                    ..where((t) => t.customerId.equals(row.customerId) | t.syncId.equals(row.customerId)))
                  .getSingleOrNull();
          if (cust != null) {
            final effectiveSyncId =
                row.syncId.isNotEmpty ? row.syncId : row.historyId;
            String? itemSync;
            String? txnSync;
            if (row.itemId.isNotEmpty && row.itemId != '0') {
              final item = await (db.select(
                db.itemsTable,
              )..where((t) => t.itemId.equals(row.itemId) | t.syncId.equals(row.itemId))).getSingleOrNull();
              if (item != null) {
                itemSync = item.syncId.isNotEmpty ? item.syncId : item.itemId;
              }
            }
            if (row.transactionId.isNotEmpty && row.transactionId != '0') {
              final txn =
                  await (db.select(db.transactionsTable)..where(
                        (t) => t.transactionId.equals(row.transactionId) | t.syncId.equals(row.transactionId),
                      ))
                      .getSingleOrNull();
              if (txn != null) {
                txnSync =
                    txn.syncId.isNotEmpty ? txn.syncId : txn.transactionId;
              }
            }

            final custSyncId =
                cust.syncId.isNotEmpty ? cust.syncId : cust.customerId;
            final payload = SyncMappers.historyToSupabase(
              row,
              custSyncId,
              itemSync,
              txnSync,
              userId,
            );
            await _collection('history')?.doc(effectiveSyncId).set(
                  payload,
                  SetOptions(merge: true),
                );
          }
        }
        break;
    }
  }

  /// Downloads a remote attachment without holding a database lock.
  /// Falls back to the existing local path when the download fails.
  Future<String> _resolvePulledFile({
    required String remotePath,
    required String destRelativePath,
    required String resolvedAppDir,
    String? existingLocalPath,
  }) async {
    if (remotePath.isEmpty) {
      return existingLocalPath ?? '';
    }
    if (resolvedAppDir.isEmpty) {
      return (existingLocalPath != null && existingLocalPath.isNotEmpty)
          ? existingLocalPath
          : remotePath;
    }

    final downloaded = await fileSync.downloadFile(
      remotePath: remotePath,
      localRelativeDestPath: destRelativePath,
      appDirPath: resolvedAppDir,
    );
    if (downloaded != null) return downloaded;
    if (existingLocalPath != null && existingLocalPath.isNotEmpty) {
      return existingLocalPath;
    }
    return remotePath;
  }

  // ===========================================================================
  // PULL PHASE
  // ===========================================================================

  /// Pulls changes updated in Supabase since last sync and merges them into Drift.
  Future<void> pull([String? appDir]) async {
    final resolvedAppDir = appDir ?? await _resolveAppDir();
    final prefs = await SharedPreferences.getInstance();
    final lastSyncEpoch = prefs.getInt(_prefKey) ?? 0;
    final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(
      lastSyncEpoch,
      isUtc: true,
    );
    final syncStartTime = DateTime.now().toUtc();

    debugPrint(
      'Sync Pull: Fetching changes since ${lastSyncTime.toIso8601String()}',
    );

    try {
      // Pull in topological order
      await _pullCustomers(lastSyncTime, resolvedAppDir);
      await _pullItems(lastSyncTime, resolvedAppDir);
      await _pullTransactions(lastSyncTime, resolvedAppDir);
      await _pullPayments(lastSyncTime);
      await _pullHistory(lastSyncTime);

      await prefs.setInt(_prefKey, syncStartTime.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Sync Pull failed: $e');
      rethrow;
    }
  }

  Future<void> _pullCustomers(DateTime since, String resolvedAppDir) async {
    final remoteRows = await _fetchPage('customers', since);
    if (remoteRows.isEmpty) return;

    final syncIds = remoteRows
        .map((map) => map['id'] as String?)
        .whereType<String>()
        .toList();
    final existingBySyncId = await _existingRowsBySyncId(
      SyncOutboxService.entityCustomer,
      syncIds,
    );

    final localPhotoBySyncId = <String, String>{};
    final localProofBySyncId = <String, String>{};
    for (final map in remoteRows) {
      if (_safeParseDateTime(map['updated_at']) == null ||
          _safeParseDateTime(map['created_at']) == null) {
        continue;
      }
      if (_safeParseDateTime(map['deleted_at']) != null) continue;

      final syncId = map['id'] as String;
      final existing = existingBySyncId[syncId];

      localPhotoBySyncId[syncId] = await _resolvePulledFile(
        remotePath: map['photo_path'] as String? ?? '',
        destRelativePath: 'Images/customers/${syncId}_photo.jpg',
        resolvedAppDir: resolvedAppDir,
        existingLocalPath: existing is CustomerRow
            ? existing.customerPhoto
            : null,
      );
      localProofBySyncId[syncId] = await _resolvePulledFile(
        remotePath: map['proof_path'] as String? ?? '',
        destRelativePath: 'Images/proof/${syncId}_proof.jpg',
        resolvedAppDir: resolvedAppDir,
        existingLocalPath: existing is CustomerRow ? existing.proofPhoto : null,
      );
    }

    await db.transaction(() async {
      for (final Map<String, dynamic> map in remoteRows) {
        final currentUpdatedAt = _safeParseDateTime(map['updated_at']);
        final currentCreatedAt = _safeParseDateTime(map['created_at']);
        if (currentUpdatedAt == null || currentCreatedAt == null) {
          continue;
        }

        final syncId = map['id'] as String;
        final deletedAt = _safeParseDateTime(map['deleted_at']);
        final existing = existingBySyncId[syncId];

        if (deletedAt != null) {
          if (existing is CustomerRow) {
            await (db.delete(
              db.customersTable,
            )..where((t) => t.customerId.equals(existing.customerId))).go();
          }
          continue;
        }

        final localPhoto = localPhotoBySyncId[syncId] ?? '';
        final localProof = localProofBySyncId[syncId] ?? '';

        if (existing == null) {
          await db
              .into(db.customersTable)
              .insert(
                CustomersTableCompanion.insert(
                  customerId: Value(syncId),
                  userId: 1,
                  customerName: map['name'] as String? ?? '',
                  gaurdianName: map['guardian_name'] as String? ?? '',
                  customerAddress: map['address'] as String? ?? '',
                  contactNumber: map['contact_number'] as String? ?? '',
                  customerPhoto: localPhoto,
                  proofPhoto: localProof,
                  createdDate: currentCreatedAt,
                  syncId: Value(syncId),
                  updatedAt: Value(currentUpdatedAt),
                ),
              );
        } else if (existing is CustomerRow) {
          final localUpdated = existing.updatedAt ?? existing.createdDate;
          if (currentUpdatedAt.isAfter(localUpdated)) {
            await (db.update(
              db.customersTable,
            )..where((t) => t.customerId.equals(existing.customerId))).write(
              CustomersTableCompanion(
                customerName: Value(map['name'] as String? ?? ''),
                gaurdianName: Value(map['guardian_name'] as String? ?? ''),
                customerAddress: Value(map['address'] as String? ?? ''),
                contactNumber: Value(map['contact_number'] as String? ?? ''),
                customerPhoto: Value(localPhoto),
                proofPhoto: Value(localProof),
                updatedAt: Value(currentUpdatedAt),
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _pullItems(DateTime since, String resolvedAppDir) async {
    final remoteRows = await _fetchPage('items', since);
    if (remoteRows.isEmpty) return;

    final syncIds = remoteRows
        .map((map) => map['id'] as String?)
        .whereType<String>()
        .toList();
    final existingBySyncId = await _existingRowsBySyncId(
      SyncOutboxService.entityItem,
      syncIds,
    );

    final localPhotoBySyncId = <String, String>{};
    for (final map in remoteRows) {
      final updatedAt = _safeParseDateTime(map['updated_at']);
      final createdDate = _safeParseDateTime(map['created_at']);
      final pawnedDate = _safeParseDateTime(map['pawned_date']);
      final expiryDate = _safeParseDateTime(map['expiry_date']);
      if (updatedAt == null ||
          createdDate == null ||
          pawnedDate == null ||
          expiryDate == null) {
        continue;
      }
      if (_safeParseDateTime(map['deleted_at']) != null) continue;

      final syncId = map['id'] as String;
      final existing = existingBySyncId[syncId];

      localPhotoBySyncId[syncId] = await _resolvePulledFile(
        remotePath: map['photo_path'] as String? ?? '',
        destRelativePath: 'Images/items/${syncId}_photo.jpg',
        resolvedAppDir: resolvedAppDir,
        existingLocalPath: existing is ItemRow ? existing.itemPhoto : null,
      );
    }

    final customerIdCache = <String, String>{};

    await db.transaction(() async {
      for (final map in remoteRows) {
        final syncId = map['id'] as String;
        final custSyncId = map['customer_sync_id'] as String;
        final deletedAt = _safeParseDateTime(map['deleted_at']);
        final updatedAt = _safeParseDateTime(map['updated_at']);
        final createdDate = _safeParseDateTime(map['created_at']);
        final pawnedDate = _safeParseDateTime(map['pawned_date']);
        final expiryDate = _safeParseDateTime(map['expiry_date']);
        if (updatedAt == null ||
            createdDate == null ||
            pawnedDate == null ||
            expiryDate == null) {
          continue;
        }

        String? parentCustomerId = customerIdCache[custSyncId];
        if (parentCustomerId == null) {
          final parentCustomer = await (db.select(
            db.customersTable,
          )..where((t) => t.syncId.equals(custSyncId) | t.customerId.equals(custSyncId))).getSingleOrNull();
          if (parentCustomer == null) continue;
          parentCustomerId = parentCustomer.customerId;
          customerIdCache[custSyncId] = parentCustomerId;
        }

        final existing = existingBySyncId[syncId];

        if (deletedAt != null) {
          if (existing is ItemRow) {
            await (db.delete(
              db.itemsTable,
            )..where((t) => t.itemId.equals(existing.itemId))).go();
          }
          continue;
        }

        final pawnAmount = (map['pawn_amount'] as num).toDouble();
        final localPhoto = localPhotoBySyncId[syncId] ?? '';

        if (existing == null) {
          await db
              .into(db.itemsTable)
              .insert(
                ItemsTableCompanion.insert(
                  itemId: Value(syncId),
                  customerId: parentCustomerId,
                  itemName: map['name'] as String? ?? '',
                  itemDescription: map['description'] as String? ?? '',
                  pawnedDate: pawnedDate,
                  expiryDate: expiryDate,
                  pawnAmount: pawnAmount,
                  itemStatus: map['status'] as String? ?? 'Active',
                  itemPhoto: localPhoto,
                  createdDate: createdDate,
                  syncId: Value(syncId),
                  updatedAt: Value(updatedAt),
                ),
              );
        } else if (existing is ItemRow) {
          final localUpdated = existing.updatedAt ?? existing.createdDate;
          if (updatedAt.isAfter(localUpdated)) {
            await (db.update(
              db.itemsTable,
            )..where((t) => t.itemId.equals(existing.itemId))).write(
              ItemsTableCompanion(
                itemName: Value(map['name'] as String? ?? ''),
                itemDescription: Value(map['description'] as String? ?? ''),
                pawnedDate: Value(pawnedDate),
                expiryDate: Value(expiryDate),
                pawnAmount: Value(pawnAmount),
                itemStatus: Value(map['status'] as String? ?? 'Active'),
                itemPhoto: Value(localPhoto),
                updatedAt: Value(updatedAt),
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _pullTransactions(DateTime since, String resolvedAppDir) async {
    final remoteRows = await _fetchPage('transactions', since);
    if (remoteRows.isEmpty) return;

    final syncIds = remoteRows
        .map((map) => map['id'] as String?)
        .whereType<String>()
        .toList();
    final existingBySyncId = await _existingRowsBySyncId(
      SyncOutboxService.entityTransaction,
      syncIds,
    );

    final localSigBySyncId = <String, String>{};
    for (final map in remoteRows) {
      final updatedAt = _safeParseDateTime(map['updated_at']);
      final createdDate = _safeParseDateTime(map['created_at']);
      final txnDate = _safeParseDateTime(map['transaction_date']);
      if (updatedAt == null || createdDate == null || txnDate == null) {
        continue;
      }
      if (_safeParseDateTime(map['deleted_at']) != null) continue;

      final syncId = map['id'] as String;
      final existing = existingBySyncId[syncId];

      localSigBySyncId[syncId] = await _resolvePulledFile(
        remotePath: map['signature_path'] as String? ?? '',
        destRelativePath: 'Images/signatures/${syncId}_signature.png',
        resolvedAppDir: resolvedAppDir,
        existingLocalPath: existing is TransactionRow
            ? existing.signature
            : null,
      );
    }

    final customerIdCache = <String, String>{};
    final itemIdCache = <String, String>{};

    await db.transaction(() async {
      for (final map in remoteRows) {
        final syncId = map['id'] as String;
        final custSyncId = map['customer_sync_id'] as String;
        final itemSyncId = map['item_sync_id'] as String;
        final deletedAt = _safeParseDateTime(map['deleted_at']);
        final updatedAt = _safeParseDateTime(map['updated_at']);
        final createdDate = _safeParseDateTime(map['created_at']);
        final txnDate = _safeParseDateTime(map['transaction_date']);
        if (updatedAt == null || createdDate == null || txnDate == null) {
          continue;
        }

        String? parentCustomerId = customerIdCache[custSyncId];
        if (parentCustomerId == null) {
          final parentCustomer = await (db.select(
            db.customersTable,
          )..where((t) => t.syncId.equals(custSyncId) | t.customerId.equals(custSyncId))).getSingleOrNull();
          if (parentCustomer == null) continue;
          parentCustomerId = parentCustomer.customerId;
          customerIdCache[custSyncId] = parentCustomerId;
        }

        String? parentItemId = itemIdCache[itemSyncId];
        if (parentItemId == null) {
          final parentItem = await (db.select(
            db.itemsTable,
          )..where((t) => t.syncId.equals(itemSyncId) | t.itemId.equals(itemSyncId))).getSingleOrNull();
          if (parentItem == null) continue;
          parentItemId = parentItem.itemId;
          itemIdCache[itemSyncId] = parentItemId;
        }

        final existing = existingBySyncId[syncId];

        if (deletedAt != null) {
          if (existing is TransactionRow) {
            await (db.delete(
                  db.transactionsTable,
                )..where((t) => t.transactionId.equals(existing.transactionId)))
                .go();
          }
          continue;
        }

        final amount = (map['amount'] as num).toDouble();
        final interestRate = (map['interest_rate'] as num).toDouble();
        final interestAmount = (map['interest_amount'] as num).toDouble();
        final remainingAmount = (map['remaining_amount'] as num).toDouble();
        final localSig = localSigBySyncId[syncId] ?? '';

        if (existing == null) {
          await db
              .into(db.transactionsTable)
              .insert(
                TransactionsTableCompanion.insert(
                  transactionId: Value(syncId),
                  customerId: parentCustomerId,
                  itemId: parentItemId,
                  transactionDate: txnDate,
                  transactionType:
                      map['transaction_type'] as String? ?? 'Active',
                  amount: amount,
                  interestRate: interestRate,
                  interestAmount: interestAmount,
                  remainingAmount: remainingAmount,
                  signature: localSig,
                  createdDate: createdDate,
                  syncId: Value(syncId),
                  updatedAt: Value(updatedAt),
                ),
              );
        } else if (existing is TransactionRow) {
          final localUpdated = existing.updatedAt ?? existing.createdDate;
          if (updatedAt.isAfter(localUpdated)) {
            await (db.update(
                  db.transactionsTable,
                )..where((t) => t.transactionId.equals(existing.transactionId)))
                .write(
                  TransactionsTableCompanion(
                    transactionType: Value(
                      map['transaction_type'] as String? ?? 'Active',
                    ),
                    amount: Value(amount),
                    interestRate: Value(interestRate),
                    interestAmount: Value(interestAmount),
                    remainingAmount: Value(remainingAmount),
                    signature: Value(localSig),
                    updatedAt: Value(updatedAt),
                  ),
                );
          }
        }
      }
    });
  }

  Future<void> _pullPayments(DateTime since) async {
    final remoteRows = await _fetchPage('payments', since);
    if (remoteRows.isEmpty) return;

    final syncIds = remoteRows
        .map((map) => map['id'] as String?)
        .whereType<String>()
        .toList();
    final existingBySyncId = await _existingRowsBySyncId(
      SyncOutboxService.entityPayment,
      syncIds,
    );

    final txnIdCache = <String, String>{};

    await db.transaction(() async {
      for (final json in remoteRows) {
        final map = json;
        final syncId = map['id'] as String;
        final txnSyncId = map['transaction_sync_id'] as String;
        final deletedAt = _safeParseDateTime(map['deleted_at']);
        final updatedAt = _safeParseDateTime(map['updated_at']);
        final createdDate = _safeParseDateTime(map['created_at']);
        final paymentDate = _safeParseDateTime(map['payment_date']);
        if (updatedAt == null || createdDate == null || paymentDate == null) {
          continue;
        }

        String? parentTxnId = txnIdCache[txnSyncId];
        if (parentTxnId == null) {
          final parentTxn = await (db.select(
            db.transactionsTable,
          )..where((t) => t.syncId.equals(txnSyncId) | t.transactionId.equals(txnSyncId))).getSingleOrNull();
          if (parentTxn == null) continue;
          parentTxnId = parentTxn.transactionId;
          txnIdCache[txnSyncId] = parentTxnId;
        }

        final existing = existingBySyncId[syncId];

        if (deletedAt != null) {
          if (existing is PaymentRow) {
            await (db.delete(
              db.paymentsTable,
            )..where((t) => t.paymentId.equals(existing.paymentId))).go();
          }
          continue;
        }

        final amountPaid = (map['amount_paid'] as num).toDouble();

        if (existing == null) {
          await db
              .into(db.paymentsTable)
              .insert(
                PaymentsTableCompanion.insert(
                  paymentId: Value(syncId),
                  transactionId: parentTxnId,
                  paymentDate: paymentDate,
                  amountPaid: amountPaid,
                  paymentType: map['payment_type'] as String? ?? 'Cash',
                  createdDate: createdDate,
                  syncId: Value(syncId),
                  updatedAt: Value(updatedAt),
                ),
              );
        } else if (existing is PaymentRow) {
          final localUpdated = existing.updatedAt ?? existing.createdDate;
          if (updatedAt.isAfter(localUpdated)) {
            await (db.update(
              db.paymentsTable,
            )..where((t) => t.paymentId.equals(existing.paymentId))).write(
              PaymentsTableCompanion(
                paymentDate: Value(paymentDate),
                amountPaid: Value(amountPaid),
                paymentType: Value(map['payment_type'] as String? ?? 'Cash'),
                updatedAt: Value(updatedAt),
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _pullHistory(DateTime since) async {
    final remoteRows = await _fetchPage('history', since);
    if (remoteRows.isEmpty) return;

    final syncIds = remoteRows
        .map((map) => map['id'] as String?)
        .whereType<String>()
        .toList();
    final existingBySyncId = await _existingRowsBySyncId(
      SyncOutboxService.entityHistory,
      syncIds,
    );

    final custIdCache = <String, String>{};

    await db.transaction(() async {
      for (final json in remoteRows) {
        final map = json;
        final syncId = map['id'] as String;
        final custSyncId = map['customer_sync_id'] as String;
        final deletedAt = _safeParseDateTime(map['deleted_at']);
        final updatedAt = _safeParseDateTime(map['updated_at']);
        final eventDate = _safeParseDateTime(map['event_date']);
        if (updatedAt == null || eventDate == null) {
          continue;
        }

        String? parentCustId = custIdCache[custSyncId];
        if (parentCustId == null) {
          final parentCust = await (db.select(
            db.customersTable,
          )..where((t) => t.syncId.equals(custSyncId) | t.customerId.equals(custSyncId))).getSingleOrNull();
          if (parentCust == null) continue;
          parentCustId = parentCust.customerId;
          custIdCache[custSyncId] = parentCustId;
        }

        final existing = existingBySyncId[syncId];

        if (deletedAt != null) {
          if (existing is HistoryRow) {
            await (db.delete(
              db.historyTable,
            )..where((t) => t.historyId.equals(existing.historyId))).go();
          }
          continue;
        }

        final amount = (map['amount'] as num).toDouble();
        final txnSyncId = map['transaction_sync_id'] as String?;
        String resolvedTxnId = '';
        if (txnSyncId != null && txnSyncId.isNotEmpty && txnSyncId != '0') {
          final txn = await (db.select(
            db.transactionsTable,
          )..where((t) => t.syncId.equals(txnSyncId) | t.transactionId.equals(txnSyncId))).getSingleOrNull();
          if (txn != null) {
            resolvedTxnId = txn.transactionId;
          }
        }

        final itemSyncId = map['item_sync_id'] as String?;
        String resolvedItemId = '';
        if (itemSyncId != null && itemSyncId.isNotEmpty && itemSyncId != '0') {
          final item = await (db.select(
            db.itemsTable,
          )..where((t) => t.syncId.equals(itemSyncId) | t.itemId.equals(itemSyncId))).getSingleOrNull();
          if (item != null) {
            resolvedItemId = item.itemId;
          }
        }

        if (existing == null) {
          await db
              .into(db.historyTable)
              .insert(
                HistoryTableCompanion.insert(
                  historyId: Value(syncId),
                  userId: 1,
                  customerId: parentCustId,
                  customerName: map['customer_name'] as String? ?? '',
                  contactNumber: map['contact_number'] as String? ?? '',
                  itemId: resolvedItemId,
                  transactionId: resolvedTxnId,
                  amount: amount,
                  eventDate: eventDate,
                  eventType: map['event_type'] as String? ?? 'Default',
                  syncId: Value(syncId),
                  updatedAt: Value(updatedAt),
                ),
              );
        } else if (existing is HistoryRow) {
          final localUpdated = existing.updatedAt ?? existing.eventDate;
          if (updatedAt.isAfter(localUpdated)) {
            await (db.update(
              db.historyTable,
            )..where((t) => t.historyId.equals(existing.historyId))).write(
              HistoryTableCompanion(
                customerName: Value(map['customer_name'] as String? ?? ''),
                contactNumber: Value(map['contact_number'] as String? ?? ''),
                amount: Value(amount),
                eventDate: Value(eventDate),
                eventType: Value(map['event_type'] as String? ?? 'Default'),
                itemId: resolvedItemId.isNotEmpty
                    ? Value(resolvedItemId)
                    : const Value.absent(),
                transactionId: resolvedTxnId.isNotEmpty
                    ? Value(resolvedTxnId)
                    : const Value.absent(),
                updatedAt: Value(updatedAt),
              ),
            );
          }
        }
      }
    });
  }

  Future<Map<String, dynamic>> _existingRowsBySyncId(
    String entityType,
    Iterable<String> syncIds,
  ) async {
    final ids = syncIds.where((id) => id.isNotEmpty).toList();
    if (ids.isEmpty) return {};

    final map = <String, dynamic>{};
    const chunkSize = 200;

    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(
        i,
        (i + chunkSize > ids.length) ? ids.length : i + chunkSize,
      );

      switch (entityType) {
        case SyncOutboxService.entityCustomer:
          final rows = await (db.select(
            db.customersTable,
          )..where((t) => t.syncId.isIn(chunk) | t.customerId.isIn(chunk))).get();
          for (final row in rows) {
            if (row.syncId.isNotEmpty) map[row.syncId] = row;
            map[row.customerId] = row;
          }
          break;
        case SyncOutboxService.entityItem:
          final rows = await (db.select(
            db.itemsTable,
          )..where((t) => t.syncId.isIn(chunk) | t.itemId.isIn(chunk))).get();
          for (final row in rows) {
            if (row.syncId.isNotEmpty) map[row.syncId] = row;
            map[row.itemId] = row;
          }
          break;
        case SyncOutboxService.entityTransaction:
          final rows = await (db.select(
            db.transactionsTable,
          )..where((t) => t.syncId.isIn(chunk) | t.transactionId.isIn(chunk))).get();
          for (final row in rows) {
            if (row.syncId.isNotEmpty) map[row.syncId] = row;
            map[row.transactionId] = row;
          }
          break;
        case SyncOutboxService.entityPayment:
          final rows = await (db.select(
            db.paymentsTable,
          )..where((t) => t.syncId.isIn(chunk) | t.paymentId.isIn(chunk))).get();
          for (final row in rows) {
            if (row.syncId.isNotEmpty) map[row.syncId] = row;
            map[row.paymentId] = row;
          }
          break;
        case SyncOutboxService.entityHistory:
          final rows = await (db.select(
            db.historyTable,
          )..where((t) => t.syncId.isIn(chunk) | t.historyId.isIn(chunk))).get();
          for (final row in rows) {
            if (row.syncId.isNotEmpty) map[row.syncId] = row;
            map[row.historyId] = row;
          }
          break;
        default:
          return {};
      }
    }

    return map;
  }

  // ===========================================================================
  // PULL PHASE
  // ===========================================================================
  Future<List<Map<String, dynamic>>> _fetchPage(
    String table,
    DateTime since, {
    int pageSize = 500,
  }) async {
    final col = _collection(table);
    if (col == null) return [];

    final all = <Map<String, dynamic>>[];
    final sinceIso = since.toUtc().toIso8601String();

    Query<Map<String, dynamic>> query;
    if (since.millisecondsSinceEpoch > 0) {
      query = col
          .where('updated_at', isGreaterThan: sinceIso)
          .orderBy('updated_at');
    } else {
      query = col.orderBy('updated_at');
    }

    DocumentSnapshot<Map<String, dynamic>>? lastDoc;

    while (true) {
      Query<Map<String, dynamic>> pagedQuery = query.limit(pageSize);
      if (lastDoc != null) {
        pagedQuery = pagedQuery.startAfterDocument(lastDoc);
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await pagedQuery.get().timeout(const Duration(seconds: 30));

      if (snapshot.docs.isEmpty) break;

      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = data['id'] ?? doc.id;
        all.add(data);
      }

      if (snapshot.docs.length < pageSize) break;
      lastDoc = snapshot.docs.last;
    }

    return all;
  }
}
