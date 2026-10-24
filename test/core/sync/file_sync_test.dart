import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/sync/file_sync_service.dart';
import 'package:self_finance/core/sync/sync_mappers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Minimal fake SupabaseClient for testing FileSyncService
class FakeSupabaseClient extends Fake implements SupabaseClient {}

void main() {
  group('FileSyncService tests', () {
    late FileSyncService service;
    late Directory tempDir;

    setUp(() async {
      service = FileSyncService(client: FakeSupabaseClient());
      tempDir = await Directory.systemTemp.createTemp('file_sync_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Remote path builders format storage paths correctly', () {
      const userId = 'user-uuid-123';
      const entityId = 'entity-uuid-456';

      expect(
        service.getCustomerPhotoRemotePath(userId, entityId),
        'user-uuid-123/customers/entity-uuid-456/photo.jpg',
      );
      expect(
        service.getCustomerProofRemotePath(userId, entityId),
        'user-uuid-123/customers/entity-uuid-456/proof.jpg',
      );
      expect(
        service.getItemPhotoRemotePath(userId, entityId),
        'user-uuid-123/items/entity-uuid-456/photo.jpg',
      );
      expect(
        service.getTransactionSignatureRemotePath(userId, entityId),
        'user-uuid-123/transactions/entity-uuid-456/signature.png',
      );
    });

    test('uploadFile returns null when local file does not exist', () async {
      final result = await service.uploadFile(
        localRelativePath: 'non_existent_image.jpg',
        remotePath: 'user/customers/1/photo.jpg',
        appDirPath: tempDir.path,
      );

      expect(result, isNull);
    });

    test('uploadFile returns null when local file is empty', () async {
      final emptyFile = File(p.join(tempDir.path, 'empty.jpg'));
      await emptyFile.writeAsBytes([]);

      final result = await service.uploadFile(
        localRelativePath: 'empty.jpg',
        remotePath: 'user/customers/1/photo.jpg',
        appDirPath: tempDir.path,
      );

      expect(result, isNull);
    });

    test('uploadFile returns null when localRelativePath is empty', () async {
      final result = await service.uploadFile(
        localRelativePath: '',
        remotePath: 'user/customers/1/photo.jpg',
        appDirPath: tempDir.path,
      );

      expect(result, isNull);
    });

    test('downloadFile returns null when remotePath or localRelativeDestPath is empty', () async {
      expect(
        await service.downloadFile(
          remotePath: '',
          localRelativeDestPath: 'Images/customers/1.jpg',
          appDirPath: tempDir.path,
        ),
        isNull,
      );

      expect(
        await service.downloadFile(
          remotePath: 'user/customers/1/photo.jpg',
          localRelativeDestPath: '',
          appDirPath: tempDir.path,
        ),
        isNull,
      );
    });

    test('downloadFile returns cached path if file already exists locally', () async {
      final destRelPath = p.join('Images', 'customers', 'cached_photo.jpg');
      final fullPath = p.join(tempDir.path, destRelPath);
      final destFile = File(fullPath);
      await destFile.parent.create(recursive: true);
      await destFile.writeAsBytes([1, 2, 3, 4]); // Non-empty file

      final result = await service.downloadFile(
        remotePath: 'user/customers/1/photo.jpg',
        localRelativeDestPath: destRelPath,
        appDirPath: tempDir.path,
      );

      // Should return destination path directly without calling Supabase Storage
      expect(result, destRelPath);
    });

    test('isRemoteStoragePath correctly classifies remote vs local paths', () {
      expect(FileSyncService.isRemoteStoragePath('user-1/customers/1/photo.jpg'), isTrue);
      expect(FileSyncService.isRemoteStoragePath('user-1/items/1/photo.jpg'), isTrue);
      expect(FileSyncService.isRemoteStoragePath('user-1/transactions/1/signature.png'), isTrue);

      // Local Android / iOS / relative paths must return false
      expect(FileSyncService.isRemoteStoragePath('/data/user/0/com.app/app_flutter/Images/photo.jpg'), isFalse);
      expect(FileSyncService.isRemoteStoragePath('Images/customers/photo.jpg'), isFalse);
      expect(FileSyncService.isRemoteStoragePath(''), isFalse);
    });

    test('downloadFile recognizes existing local file and avoids remote storage call', () async {
      final localFile = File(p.join(tempDir.path, 'Images', 'customers', 'existing.jpg'));
      await localFile.parent.create(recursive: true);
      await localFile.writeAsBytes([1, 2, 3]);

      final result = await service.downloadFile(
        remotePath: localFile.path,
        localRelativeDestPath: 'Images/customers/dest.jpg',
        appDirPath: tempDir.path,
      );

      expect(result, p.join('Images', 'customers', 'existing.jpg'));
    });

    test('downloadFile skips downloading for missing local paths without error', () async {
      final result = await service.downloadFile(
        remotePath: '/data/user/0/com.app/nonexistent.jpg',
        localRelativeDestPath: 'Images/customers/dest.jpg',
        appDirPath: tempDir.path,
      );

      expect(result, isNull);
    });

    test('SyncMappers customerToSupabase uses remotePhotoPath when provided', () {
      final now = DateTime.utc(2026, 10, 24, 12);
      final customer = CustomerRow(
        userId: 1,
        customerId: 1,
        customerName: 'Alice',
        gaurdianName: 'Bob',
        contactNumber: '1234567890',
        customerAddress: 'City',
        customerPhoto: 'Images/customers/local_photo.jpg',
        proofPhoto: 'Images/proof/local_proof.jpg',
        createdDate: now,
        syncId: 'cust-uuid-1',
        updatedAt: now,
      );

      final map = SyncMappers.customerToSupabase(
        customer,
        'user-uuid',
        remotePhotoPath: 'user-uuid/customers/cust-uuid-1/photo.jpg',
        remoteProofPath: 'user-uuid/customers/cust-uuid-1/proof.jpg',
      );

      expect(map['photo_path'], 'user-uuid/customers/cust-uuid-1/photo.jpg');
      expect(map['proof_path'], 'user-uuid/customers/cust-uuid-1/proof.jpg');
    });

    test('SyncMappers itemToSupabase uses remotePhotoPath when provided', () {
      final now = DateTime.utc(2026, 10, 24, 12);
      final item = ItemRow(
        itemId: 1,
        customerId: 1,
        itemName: 'Ring',
        itemDescription: 'Gold',
        pawnedDate: now,
        expiryDate: now,
        pawnAmount: 1000,
        itemStatus: 'Active',
        itemPhoto: 'Images/items/local_item.jpg',
        createdDate: now,
        syncId: 'item-uuid-1',
        updatedAt: now,
      );

      final map = SyncMappers.itemToSupabase(
        item,
        'cust-uuid-1',
        'user-uuid',
        remotePhotoPath: 'user-uuid/items/item-uuid-1/photo.jpg',
      );

      expect(map['photo_path'], 'user-uuid/items/item-uuid-1/photo.jpg');
    });

    test('SyncMappers transactionToSupabase uses remoteSignaturePath when provided', () {
      final now = DateTime.utc(2026, 10, 24, 12);
      final txn = TransactionRow(
        transactionId: 1,
        customerId: 1,
        itemId: 1,
        transactionDate: now,
        transactionType: 'Active',
        amount: 1000,
        interestRate: 2.0,
        interestAmount: 20,
        remainingAmount: 1000,
        signature: 'Images/signatures/local_sig.png',
        createdDate: now,
        syncId: 'txn-uuid-1',
        updatedAt: now,
      );

      final map = SyncMappers.transactionToSupabase(
        txn,
        'cust-uuid-1',
        'item-uuid-1',
        'user-uuid',
        remoteSignaturePath: 'user-uuid/transactions/txn-uuid-1/signature.png',
      );

      expect(map['signature_path'], 'user-uuid/transactions/txn-uuid-1/signature.png');
    });
  });
}
