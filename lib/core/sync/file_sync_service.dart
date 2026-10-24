import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service responsible for uploading and downloading binary attachments
/// (customer photos, proof photos, item photos, transaction signatures)
/// to and from Supabase Storage private bucket `finance-files`.
class FileSyncService {
  FileSyncService({required this.client});

  final SupabaseClient client;

  static const String bucketName = 'finance-files';

  static bool _warnedMissingBucket = false;

  static void _logMissingBucketOnce() {
    if (!_warnedMissingBucket) {
      _warnedMissingBucket = true;
      debugPrint(
        '⚠️ FileSyncService: Storage bucket "$bucketName" not found in Supabase. '
        'Please run "supabase/migrations/20261024_create_storage_bucket.sql" in your Supabase SQL editor.',
      );
    }
  }

  static Future<void> deleteLocalFileIfExists(
    String? path, {
    required String appDirPath,
  }) async {
    if (path == null || path.trim().isEmpty) return;

    final String candidate = p.isAbsolute(path)
        ? path
        : p.join(appDirPath, path);

    final file = File(candidate);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (e) {
        debugPrint(
          'FileSyncService: failed deleting local file $candidate: $e',
        );
      }
    }
  }

  Future<void> deleteRemoteFileIfExists(String? remotePath) async {
    if (remotePath == null || remotePath.trim().isEmpty) return;
    if (!isRemoteStoragePath(remotePath)) return;

    try {
      await client.storage.from(bucketName).remove([remotePath]);
      debugPrint('FileSyncService: Deleted remote file $remotePath');
    } catch (e) {
      if (e is StorageException &&
          (e.error == 'NoSuchBucket' ||
              e.message.toLowerCase().contains('bucket not found') ||
              e.message.contains('NoSuchBucket'))) {
        _logMissingBucketOnce();
      } else {
        debugPrint('FileSyncService: Delete remote error for $remotePath: $e');
      }
    }
  }

  /// Determines whether a string is a valid remote storage path
  /// (e.g. `<userId>/customers/<syncId>/photo.jpg`) or a legacy/local device path.
  static bool isRemoteStoragePath(String path) {
    if (path.isEmpty) return false;
    if (path.startsWith('/') ||
        path.startsWith('\\') ||
        path.contains('app_flutter') ||
        path.contains('data/user') ||
        path.contains('Images/') ||
        path.contains('Images\\') ||
        path.contains(':')) {
      return false;
    }
    return path.contains('/');
  }

  // ── Remote Path Builders ──

  /// Customer photo remote path: `<userId>/customers/<customerSyncId>/photo.jpg`
  String getCustomerPhotoRemotePath(String userId, String customerSyncId) {
    return '$userId/customers/$customerSyncId/photo.jpg';
  }

  /// Customer proof remote path: `<userId>/customers/<customerSyncId>/proof.jpg`
  String getCustomerProofRemotePath(String userId, String customerSyncId) {
    return '$userId/customers/$customerSyncId/proof.jpg';
  }

  /// Item photo remote path: `<userId>/items/<itemSyncId>/photo.jpg`
  String getItemPhotoRemotePath(String userId, String itemSyncId) {
    return '$userId/items/$itemSyncId/photo.jpg';
  }

  /// Transaction signature remote path: `<userId>/transactions/<transactionSyncId>/signature.png`
  String getTransactionSignatureRemotePath(
    String userId,
    String transactionSyncId,
  ) {
    return '$userId/transactions/$transactionSyncId/signature.png';
  }

  // ── File Operations ──

  /// Uploads a local file to Supabase Storage at [remotePath].
  ///
  /// [localRelativePath] is relative to [appDirPath] (or absolute).
  /// Returns the [remotePath] on success, or null if the local file does not exist or upload fails.
  Future<String?> uploadFile({
    required String localRelativePath,
    required String remotePath,
    required String appDirPath,
  }) async {
    if (localRelativePath.isEmpty) return null;

    try {
      final String fullPath = p.isAbsolute(localRelativePath)
          ? localRelativePath
          : p.join(appDirPath, localRelativePath);

      final file = File(fullPath);
      if (!await file.exists()) {
        return null;
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        return null;
      }

      final String extension = p.extension(fullPath).toLowerCase();
      final String contentType = extension == '.png'
          ? 'image/png'
          : extension == '.webp'
          ? 'image/webp'
          : 'image/jpeg';

      await client.storage
          .from(bucketName)
          .uploadBinary(
            remotePath,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: contentType),
          );

      debugPrint('FileSyncService: Uploaded $remotePath successfully');
      return remotePath;
    } catch (e) {
      if (e is StorageException &&
          (e.error == 'NoSuchBucket' ||
              e.message.toLowerCase().contains('bucket not found') ||
              e.message.contains('NoSuchBucket'))) {
        _logMissingBucketOnce();
      } else {
        debugPrint('FileSyncService: Upload error for $remotePath: $e');
      }
      return null;
    }
  }

  /// Downloads a remote file from Supabase Storage and writes it to [localRelativeDestPath]
  /// inside [appDirPath].
  ///
  /// If [remotePath] is a local path that already exists on device, returns that path without downloading.
  /// If the destination file already exists and has size > 0, skips download and returns [localRelativeDestPath].
  /// Returns the [localRelativeDestPath] on success, or null on error.
  Future<String?> downloadFile({
    required String remotePath,
    required String localRelativeDestPath,
    required String appDirPath,
  }) async {
    if (remotePath.isEmpty || localRelativeDestPath.isEmpty) return null;

    // Check if remotePath is actually a local device path (legacy or same-device record)
    if (!isRemoteStoragePath(remotePath)) {
      final localCandidate = p.isAbsolute(remotePath)
          ? remotePath
          : p.join(appDirPath, remotePath);

      if (await File(localCandidate).exists()) {
        if (p.isAbsolute(localCandidate) &&
            localCandidate.startsWith(appDirPath)) {
          return p.relative(localCandidate, from: appDirPath);
        }
        return remotePath;
      }
      // Not a valid storage path and does not exist locally; skip remote download
      return null;
    }

    try {
      final String fullDestPath = p.isAbsolute(localRelativeDestPath)
          ? localRelativeDestPath
          : p.join(appDirPath, localRelativeDestPath);

      final destFile = File(fullDestPath);
      if (await destFile.exists() && (await destFile.length()) > 0) {
        // Already cached locally
        return localRelativeDestPath;
      }

      final parentDir = destFile.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      final Uint8List bytes = await client.storage
          .from(bucketName)
          .download(remotePath);

      if (bytes.isEmpty) {
        return null;
      }

      await destFile.writeAsBytes(bytes, flush: true);
      debugPrint(
        'FileSyncService: Downloaded $remotePath -> $localRelativeDestPath',
      );
      return localRelativeDestPath;
    } catch (e) {
      if (e is StorageException &&
          (e.error == 'NoSuchBucket' ||
              e.message.toLowerCase().contains('bucket not found') ||
              e.message.contains('NoSuchBucket'))) {
        _logMissingBucketOnce();
      } else {
        debugPrint('FileSyncService: Download error for $remotePath: $e');
      }
      return null;
    }
  }
}
