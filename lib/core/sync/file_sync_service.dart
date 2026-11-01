import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Service responsible for uploading and downloading binary attachments
/// (customer photos, proof photos, item photos, transaction signatures)
/// to and from Firebase Cloud Storage.
class FileSyncService {
  FileSyncService({
    FirebaseStorage? storage,
    dynamic client,
  }) : _storage = storage ??
            (Firebase.apps.isNotEmpty ? FirebaseStorage.instance : null);

  final FirebaseStorage? _storage;

  static Future<void> deleteLocalFileIfExists(
    String? path, {
    required String appDirPath,
  }) async {
    if (path == null || path.trim().isEmpty) return;

    final String candidate =
        p.isAbsolute(path) ? path : p.join(appDirPath, path);

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

    final storage = _storage;
    if (storage == null) return;

    try {
      await storage.ref(remotePath).delete();
      debugPrint('FileSyncService: Deleted remote file $remotePath');
    } catch (e) {
      debugPrint('FileSyncService: Delete remote error for $remotePath: $e');
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

  /// Uploads a local file to Firebase Cloud Storage at [remotePath].
  ///
  /// [localRelativePath] is relative to [appDirPath] (or absolute).
  /// Returns the [remotePath] on success, or null if the local file does not exist or upload fails.
  Future<String?> uploadFile({
    required String localRelativePath,
    required String remotePath,
    required String appDirPath,
  }) async {
    if (localRelativePath.isEmpty) return null;

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

    final storage = _storage;
    if (storage == null) {
      debugPrint(
        'FileSyncService: upload skipped, FirebaseStorage unavailable.',
      );
      return null;
    }

    try {
      final String extension = p.extension(fullPath).toLowerCase();
      final String contentType = extension == '.png'
          ? 'image/png'
          : extension == '.webp'
              ? 'image/webp'
              : 'image/jpeg';

      final ref = storage.ref(remotePath);
      await ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );

      debugPrint('FileSyncService: Uploaded $remotePath successfully');
      return remotePath;
    } catch (e) {
      debugPrint('FileSyncService: Upload error for $remotePath: $e');
      return null;
    }
  }

  /// Downloads a remote file from Firebase Storage and writes it to [localRelativeDestPath]
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

    final String fullDestPath = p.isAbsolute(localRelativeDestPath)
        ? localRelativeDestPath
        : p.join(appDirPath, localRelativeDestPath);

    final destFile = File(fullDestPath);
    if (await destFile.exists() && (await destFile.length()) > 0) {
      // Already cached locally
      return localRelativeDestPath;
    }

    final storage = _storage;
    if (storage == null) return null;

    try {
      final parentDir = destFile.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      final ref = storage.ref(remotePath);
      final Uint8List? bytes = await ref.getData();

      if (bytes == null || bytes.isEmpty) {
        return null;
      }

      await destFile.writeAsBytes(bytes, flush: true);
      debugPrint(
        'FileSyncService: Downloaded $remotePath -> $localRelativeDestPath',
      );
      return localRelativeDestPath;
    } catch (e) {
      debugPrint('FileSyncService: Download error for $remotePath: $e');
      return null;
    }
  }
}
