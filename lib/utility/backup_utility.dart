import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

typedef BackupProgressCallback =
    void Function(double progress, String currentFile);

/// High-level function to create a ZIP backup with:
/// - all files under appDocuments/customers/
/// - all files inside getDatabasesPath()
///
/// Returns the path to the created ZIP on success, throws Exception on failure.
/// Optionally receives progress updates (0.0 - 1.0).
///
///
///
///
class BackupUtility {
  /// Request storage permissions (best-effort). Handles common Android cases.
  /// Returns true if we have permission to write into external storage.
  static Future<bool> _requestStoragePermission() async {
    // On Android R+ (API 30+), some apps need MANAGE_EXTERNAL_STORAGE for broad access.
    // permission_handler exposes Permission.manageExternalStorage.
    try {
      if (Platform.isAndroid) {
        // Try to request typical storage permission first
        final status = await Permission.storage.request();
        if (status.isGranted) return true;

        // If not granted and device supports manage external storage, request it
        final manageStatus = await Permission.manageExternalStorage.request();
        return manageStatus.isGranted;
      } else if (Platform.isIOS) {
        // iOS doesn't expose a global Downloads folder; we still proceed and will
        // place the backup into app documents or raise an error.
        // No runtime permission required for app documents.
        return true;
      } else {
        // Other platforms: assume permission allowed
        return true;
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
      return false;
    }
  }

  /// Best-effort: find Downloads directory.
  ///
  /// Uses:
  ///  - path_provider's getExternalStorageDirectories(StorageDirectory.downloads)
  ///  - fallback to common Android path /storage/emulated/0/Download
  ///  - on iOS returns application documents directory (no system Downloads exposed)
  static Future<Directory?> _getDownloadsDirectory() async {
    try {
      if (Platform.isAndroid) {
        // path_provider has getExternalStorageDirectories which can take StorageDirectory.downloads
        try {
          final extDirs = await getExternalStorageDirectories(
            type: StorageDirectory.downloads,
          );
          if (extDirs != null && extDirs.isNotEmpty) {
            // Usually returns a list — pick the first writable one.
            final candidate = extDirs.first;
            return Directory(candidate.path);
          }
        } catch (_) {
          // ignore and fallback
        }

        // fallback common Android public Download folder
        final fallback = Directory('/storage/emulated/0/Download');
        if (await fallback.exists()) return fallback;

        // final fallback: app-specific external storage
        final appExt = await getExternalStorageDirectory();
        if (appExt != null) {
          // Try to create a 'Download' folder in app external dir (still accessible)
          final maybe = Directory(p.join(appExt.path, 'Download'));
          if (!await maybe.exists()) {
            await maybe.create(recursive: true);
          }
          return maybe;
        }

        return null;
      } else if (Platform.isIOS) {
        // iOS does not provide a public Downloads directory accessible to apps.
        // Use applicationDocumentsDirectory as a fallback (user can retrieve via Files app if needed).
        return await getApplicationDocumentsDirectory();
      } else {
        // Desktop / other: use application documents directory
        return await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      debugPrint('getDownloadsDirectory error: $e');
      return null;
    }
  }

  /// Recursively list files under directory (not including directories themselves).
  static Future<List<File>> _listFilesRecursive(Directory dir) async {
    final List<File> out = [];
    await for (final entity in dir.list(recursive: true, followLinks: true)) {
      if (entity is File) out.add(entity);
    }
    return out;
  }

  /// Compute a nice relative path for the file inside the ZIP archive.
  ///
  /// - Files under the app documents (e.g. <appDoc>/Images/... ) keep their folder structure.
  /// - Optionally remaps the top-level Images/ -> customers/ inside the ZIP (so ZIP contains customers/...).
  /// - DB files are stored under databases/...
  static String _computeRelativePathForArchive(
    File file,
    String appDocPath,
    String dbPath,
  ) {
    final absolute = p.normalize(file.path);
    final appDocNorm = p.normalize(appDocPath);
    final dbPathNorm = p.normalize(dbPath);

    // 1) If file is inside app documents, preserve its relative structure.
    if (p.isWithin(appDocNorm, absolute) || absolute == appDocNorm) {
      // Example: relative might be "Images/user/photo.jpg"
      final rel = p.relative(absolute, from: appDocNorm);

      // If you want to keep 'Images' as-is inside the zip, return rel.
      // If you'd rather have 'customers' as the top-level folder in the zip, remap here:
      final imagesRoot = p.join(
        'Images',
      ); // change to 'Images' because that's your folder name
      if (rel == imagesRoot) {
        return 'Images'; // unlikely for a file, but safe
      } else if (rel.startsWith('$imagesRoot${p.separator}')) {
        final afterImages = p.relative(
          absolute,
          from: p.join(appDocNorm, 'Images'),
        );
        return p.join('Images', afterImages); // -> Images/user/photo.jpg
      }

      // Otherwise return the relative path as-is (e.g., Documents/someOtherFolder/...)
      return rel;
    }

    // 2) If file is inside the DB folder, put it under 'databases/...' in the zip.
    if (p.isWithin(dbPathNorm, absolute) || absolute == dbPathNorm) {
      return p.join('databases', p.relative(absolute, from: dbPathNorm));
    }

    // 3) Fallback: keep parent folder name + basename to reduce collisions
    final parentName = p.basename(p.dirname(absolute));
    return p.join(parentName, p.basename(absolute));
  }

  static Future<String> backupImagesAndSqliteToDownloads({
    BackupProgressCallback? onProgress,
  }) async {
    try {
      // 1) Request storage permission(s)
      final granted = await _requestStoragePermission();
      if (!granted) {
        throw Exception('Storage permission not granted.');
      }

      // 2) Resolve folder paths
      final appDocDir = await getApplicationDocumentsDirectory();
      final customersDir = Directory(p.join(appDocDir.path, 'Images'));

      // Downloads directory (best-effort)
      final downloadsDir = await _getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception(
          'Unable to locate a Downloads directory on this device.',
        );
      }

      // 3) Collect files to include
      final List<File> filesToArchive = [];

      if (await customersDir.exists()) {
        filesToArchive.addAll(await _listFilesRecursive(customersDir));
      }

      final dbPath = await getDatabasesPath();
      final dbDir = Directory(dbPath);
      if (await dbDir.exists()) {
        filesToArchive.addAll(await _listFilesRecursive(dbDir));
      }

      if (filesToArchive.isEmpty) {
        throw Exception('No files found to backup.');
      }

      // 4) Build Archive in memory (Archive -> ZipEncoder)
      final archive = Archive();
      final total = filesToArchive.length;
      for (var i = 0; i < total; i++) {
        final f = filesToArchive[i];
        // compute relative path for zip entry
        var relativePath = _computeRelativePathForArchive(
          f,
          appDocDir.path,
          dbPath,
        );
        // normalize zip entry to use forward slashes
        relativePath = relativePath.replaceAll('\\', '/');

        // read file bytes
        final bytes = await f.readAsBytes();

        // create archive file entry
        final archiveFile = ArchiveFile(relativePath, bytes.length, bytes);
        archive.addFile(archiveFile);

        // progress callback
        if (onProgress != null) {
          final progress = (i + 1) / total;
          onProgress(progress, relativePath);
        }
      }

      // 5) Encode archive to zip bytes and write to a temporary zip file in downloadsDir
      final timestamp = DateTime.now().toIso8601String().replaceAll(
        RegExp(r'[:.]'),
        '-',
      );
      final zipFileName = 'app_backup_$timestamp.zip';
      final zipFilePath = p.join(downloadsDir.path, zipFileName);

      final encoder = ZipEncoder();
      final zipBytes = encoder.encode(archive);
      if (zipBytes == null) {
        throw Exception('Failed to encode ZIP archive.');
      }

      final srcFile = File(zipFilePath);
      await srcFile.writeAsBytes(zipBytes, flush: true);

      // 6) Ask user to pick a directory to save the backup (optional)
      final String? targetDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select folder to save backup (e.g., Downloads)',
      );

      // If user cancels the picker, return the path where we wrote the zip (app/downloads fallback)
      if (targetDir == null) {
        return srcFile.path;
      }

      // 7) Compute a safe destination path (avoid overwrite)
      final String fileName = p.basename(srcFile.path);
      String destPath = p.join(targetDir, fileName);

      if (await File(destPath).exists()) {
        final String base = p.basenameWithoutExtension(fileName);
        final String ext = p.extension(fileName);
        int counter = 1;
        String candidate;
        do {
          candidate = p.join(targetDir, '${base}_$counter$ext');
          counter++;
        } while (await File(candidate).exists());
        destPath = candidate;
      }

      // 8) Copy final zip to the chosen directory
      await srcFile.copy(destPath);

      return destPath;
    } catch (e, st) {
      debugPrint('backupImagesAndSqliteToDownloads error: $e\n$st');
      rethrow;
    }
  }
}
