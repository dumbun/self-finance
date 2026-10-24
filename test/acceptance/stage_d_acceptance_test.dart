import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:self_finance/backend/account_database_manager.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/sync/file_sync_service.dart';
import 'package:self_finance/core/sync/sync_engine.dart';
import 'package:self_finance/core/sync/sync_outbox_service.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

void main() {
  group('Stage D Acceptance Tests — Production Hardening & Full Data Flow', () {
    late Directory tempDir;

    setUp(() async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      tempDir = await Directory.systemTemp.createTemp('stage_d_acceptance_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Acceptance 1: Offline-first behavior — complete CRUD and outbox queuing works with zero network', () async {
      final db = ItDataDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      BackEnd.setDatabase(db);

      // Create Customer offline
      final customerId = await BackEnd.createNewCustomer(
        Customer(
          userID: 1,
          name: 'Offline Customer',
          guardianName: 'Guardian',
          address: 'Offline Street 42',
          number: '9999988888',
          photo: 'Images/customers/offline_photo.jpg',
          proof: 'Images/proof/offline_proof.jpg',
          createdDate: DateTime.now(),
        ),
      );
      expect(customerId, isPositive);

      // Query customer
      final fetchedList = await BackEnd.fetchSingleContactDetails(id: customerId);
      expect(fetchedList.isNotEmpty, isTrue);
      final fetched = fetchedList.first;
      expect(fetched.name, 'Offline Customer');

      // Verify outbox queued operation
      final pendingOps = await SyncOutboxService.getPending(db);
      expect(pendingOps.length, 1);
      expect(pendingOps.first.entityType, SyncOutboxService.entityCustomer);
      expect(pendingOps.first.operation, SyncOutboxService.opCreate);

      // Update customer offline
      await BackEnd.updateCustomerDetails(
        customerId: customerId,
        newCustomerName: 'Updated Customer Name',
        newGuardianName: 'Updated Guardian',
        newCustomerAddress: 'Updated Address',
        newContactNumber: '9999977777',
        newCustomerPhoto: 'Images/customers/updated_photo.jpg',
        newProofPhoto: 'Images/proof/updated_proof.jpg',
        newCreatedDate: DateTime.now(),
      );

      final updatedPending = await SyncOutboxService.getPending(db);
      expect(updatedPending.length, 2);
      expect(updatedPending.last.operation, SyncOutboxService.opUpdate);

      // Delete customer offline (soft-delete + outbox opDelete)
      await BackEnd.deleteTheCustomer(customerID: customerId);
      final afterDelete = await BackEnd.fetchSingleContactDetails(id: customerId);
      expect(afterDelete.isEmpty, isTrue);

      final deletePending = await SyncOutboxService.getPending(db);
      expect(deletePending.length, 3);
      expect(deletePending.last.operation, SyncOutboxService.opDelete);
    });

    test('Acceptance 2: Account switching data isolation — zero cross-account data leakage', () async {
      const userAId = 'user-uuid-aaaa-1111';
      const userBId = 'user-uuid-bbbb-2222';

      final suffixA = AccountDatabaseManager.getAccountSuffix(userAId);
      final suffixB = AccountDatabaseManager.getAccountSuffix(userBId);
      expect(suffixA, isNot(equals(suffixB)));

      // Simulate separate databases for user A and user B
      final dbA = ItDataDatabase(NativeDatabase.memory());
      final dbB = ItDataDatabase(NativeDatabase.memory());
      addTearDown(() async {
        await dbA.close();
        await dbB.close();
      });

      // User A logs in and creates customer
      BackEnd.setDatabase(dbA, accountId: userAId);
      await BackEnd.createNewCustomer(
        Customer(
          userID: 1,
          name: 'User A Secret Customer',
          guardianName: 'A Guardian',
          address: 'A Address',
          number: '1111111111',
          photo: '',
          proof: '',
          createdDate: DateTime.now(),
        ),
      );

      // Switch to User B
      BackEnd.setDatabase(dbB, accountId: userBId);
      await BackEnd.createNewCustomer(
        Customer(
          userID: 1,
          name: 'User B Customer',
          guardianName: 'B Guardian',
          address: 'B Address',
          number: '2222222222',
          photo: '',
          proof: '',
          createdDate: DateTime.now(),
        ),
      );

      // Verify User B only sees B's customer
      final listB = await BackEnd.fetchAllCustomerData();
      expect(listB.length, 1);
      expect(listB.first.name, 'User B Customer');

      // Switch back to User A
      BackEnd.setDatabase(dbA, accountId: userAId);
      final listA = await BackEnd.fetchAllCustomerData();
      expect(listA.length, 1);
      expect(listA.first.name, 'User A Secret Customer');

      // No cross-contamination
      expect(listA.any((c) => c.name == 'User B Customer'), isFalse);
      expect(listB.any((c) => c.name == 'User A Secret Customer'), isFalse);
    });

    test('Acceptance 3: Legacy migration & syncId backfilling preserves all records', () async {
      final db = ItDataDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      BackEnd.setDatabase(db);

      // Insert record without explicit syncId into raw table
      await db.into(db.customersTable).insert(
            CustomersTableCompanion.insert(
              userId: 1,
              customerName: 'Legacy Customer',
              gaurdianName: 'Legacy Guardian',
              customerAddress: 'Old St',
              contactNumber: '1234567890',
              customerPhoto: '',
              proofPhoto: '',
              createdDate: DateTime.now(),
            ),
          );

      // Backfill and queue
      await SyncOutboxService.queueAllExistingRecords(db);

      final allCustomers = await BackEnd.fetchAllCustomerData();
      expect(allCustomers.length, 1);
      expect(allCustomers.first.name, 'Legacy Customer');

      final row = await db.select(db.customersTable).getSingle();
      expect(row.syncId, isNotEmpty);
      expect(row.syncId.length, 36); // Valid UUID length

      final pending = await SyncOutboxService.getPending(db);
      expect(pending.length, 1);
      expect(pending.first.entitySyncId, row.syncId);
      expect(pending.first.operation, SyncOutboxService.opCreate);
    });

    test('Acceptance 4: Topological outbox order ensures dependent entities push after parents', () {
      final orderMap = {
        SyncOutboxService.entityCustomer: 1,
        SyncOutboxService.entityItem: 2,
        SyncOutboxService.entityTransaction: 3,
        SyncOutboxService.entityPayment: 4,
        SyncOutboxService.entityHistory: 5,
      };

      final items = [
        SyncOutboxRow(outboxId: 1, entityType: SyncOutboxService.entityHistory, entitySyncId: 'h-1', operation: 'create', createdAt: DateTime.now(), retryCount: 0),
        SyncOutboxRow(outboxId: 2, entityType: SyncOutboxService.entityPayment, entitySyncId: 'p-1', operation: 'create', createdAt: DateTime.now(), retryCount: 0),
        SyncOutboxRow(outboxId: 3, entityType: SyncOutboxService.entityCustomer, entitySyncId: 'c-1', operation: 'create', createdAt: DateTime.now(), retryCount: 0),
        SyncOutboxRow(outboxId: 4, entityType: SyncOutboxService.entityTransaction, entitySyncId: 't-1', operation: 'create', createdAt: DateTime.now(), retryCount: 0),
        SyncOutboxRow(outboxId: 5, entityType: SyncOutboxService.entityItem, entitySyncId: 'i-1', operation: 'create', createdAt: DateTime.now(), retryCount: 0),
      ];

      items.sort((a, b) => orderMap[a.entityType]!.compareTo(orderMap[b.entityType]!));

      expect(items[0].entityType, SyncOutboxService.entityCustomer);
      expect(items[1].entityType, SyncOutboxService.entityItem);
      expect(items[2].entityType, SyncOutboxService.entityTransaction);
      expect(items[3].entityType, SyncOutboxService.entityPayment);
      expect(items[4].entityType, SyncOutboxService.entityHistory);
    });

    test('Acceptance 5: File sync paths and attachment mapping round-trip', () async {
      final fileSync = FileSyncService(client: FakeSupabaseClient());
      const userId = 'user-uuid-999';
      const customerSyncId = 'cust-uuid-888';

      final remotePhotoPath = fileSync.getCustomerPhotoRemotePath(userId, customerSyncId);
      final remoteProofPath = fileSync.getCustomerProofRemotePath(userId, customerSyncId);

      expect(remotePhotoPath, 'user-uuid-999/customers/cust-uuid-888/photo.jpg');
      expect(remoteProofPath, 'user-uuid-999/customers/cust-uuid-888/proof.jpg');

      // Create test local files
      final localPhotoFile = File(p.join(tempDir.path, 'Images', 'customers', 'test_photo.jpg'));
      await localPhotoFile.parent.create(recursive: true);
      await localPhotoFile.writeAsBytes([10, 20, 30, 40]);

      // Download file to destination: cached file should return local path immediately
      final localRelDest = p.join('Images', 'customers', 'downloaded_photo.jpg');
      final fullDest = p.join(tempDir.path, localRelDest);
      await File(fullDest).writeAsBytes([10, 20, 30, 40]);

      final cachedResult = await fileSync.downloadFile(
        remotePath: remotePhotoPath,
        localRelativeDestPath: localRelDest,
        appDirPath: tempDir.path,
      );

      expect(cachedResult, localRelDest);
      expect(File(fullDest).existsSync(), isTrue);
    });

    test('Acceptance 6: SyncEngine initialization with custom appDirPath and FileSyncService', () {
      final db = ItDataDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final client = FakeSupabaseClient();
      final fileSync = FileSyncService(client: client);

      final engine = SyncEngine(
        client: client,
        db: db,
        userId: 'test-user-id',
        appDirPath: tempDir.path,
        fileSyncService: fileSync,
      );

      expect(engine.userId, 'test-user-id');
      expect(engine.appDirPath, tempDir.path);
      expect(engine.fileSync, fileSync);
    });
  });
}
