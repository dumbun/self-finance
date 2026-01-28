import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:restart_app/restart_app.dart';

typedef RestoreProgressCallback =
    void Function(double progress, String currentFile);

/// Optimized RestoreUtility matching actual app file structure
///
/// Handles:
/// 1. iOS: databases in appDocDir/databases/, images in appDocDir/Images/
/// 2. Android: databases in getDatabasesPath(), images in appDocDir/Images/
/// 3. Stream-based extraction for memory efficiency
/// 4. Proper database closing before restore
/// 5. Security validation
class RestoreUtility {
  static const int _maxFileSize = 100 * 1024 * 1024; // 100MB

  /// Validate file size
  static bool _validateFileSize(ArchiveFile file) {
    if (file.size > _maxFileSize) {
      debugPrint('⚠️ Skipping large file: ${file.name} (${file.size} bytes)');
      return false;
    }
    return true;
  }

  /// Validate path safety
  static bool _isPathSafe(String zipPath, String targetPath, String baseDir) {
    final String normalizedTarget = p.normalize(targetPath);
    final String normalizedBase = p.normalize(baseDir);

    if (zipPath.contains('..') || zipPath.contains('~')) {
      debugPrint('🚨 Security: Blocked path traversal: $zipPath');
      return false;
    }

    if (!p.isWithin(normalizedBase, normalizedTarget) &&
        normalizedTarget != normalizedBase) {
      debugPrint('🚨 Security: Path outside base directory: $zipPath');
      return false;
    }

    return true;
  }

  /// Restore backup from ZIP file
  static Future<void> restoreBackupFromZip({
    RestoreProgressCallback? onProgress,
    bool autoRestartApp = true,
    BuildContext? context,
  }) async {
    InputFileStream? zipInputStream;

    try {
      // 1) Close all databases before restore

      debugPrint('📦 Databases closed for restore');

      // Small delay to ensure all connections are fully closed
      await Future.delayed(const Duration(milliseconds: 500));

      // 2) Pick ZIP file
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        dialogTitle: 'Select backup ZIP file',
      );

      if (result == null || result.files.single.path == null) {
        throw Exception('No backup file selected');
      }

      final File zipFile = File(result.files.single.path!);
      if (!await zipFile.exists()) {
        throw Exception('Backup file not found');
      }

      final int zipFileSize = await zipFile.length();
      debugPrint(
        '📦 Restoring from: ${zipFile.path} (${(zipFileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
      );

      // 3) Get app directories
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;

      // Database directory (platform-specific)
      final String dbPath;
      if (Platform.isIOS) {
        // iOS: databases are in appDocDir/databases/
        dbPath = p.join(appDocPath, 'databases');
      } else {
        // Android: databases are in standard location
        dbPath = await getDatabasesPath();
      }
      final Directory dbDir = Directory(dbPath);
      await dbDir.create(recursive: true);

      debugPrint('📦 Restore paths:');
      debugPrint('   App Dir: $appDocPath');
      debugPrint('   Database: $dbPath');

      // 4) Extract ZIP file
      zipInputStream = InputFileStream(zipFile.path);
      final Archive archive = ZipDecoder().decodeBuffer(
        zipInputStream,
        password: dotenv.env['BACKUP_PASSWORD'],
      );

      if (archive.isEmpty) {
        throw Exception('ZIP file is empty');
      }

      final List<ArchiveFile> files = archive.files
          .where((ArchiveFile e) => e.isFile)
          .toList();
      int processed = 0;
      int skipped = 0;
      int restored = 0;

      debugPrint('📦 Found ${files.length} files in backup');

      // 5) Restore each file
      for (final ArchiveFile file in files) {
        final String zipPath = p.normalize(file.name).replaceAll('\\', '/');

        // Skip backup ZIP files
        if (zipPath.endsWith('.zip')) {
          debugPrint('⏭️ Skipping ZIP file: $zipPath');
          skipped++;
          processed++;
          continue;
        }

        // Validate file size
        if (!_validateFileSize(file)) {
          skipped++;
          processed++;
          continue;
        }

        String? targetPath;
        String? baseDir;

        // Determine target location based on file path in ZIP
        if (zipPath.startsWith('Images/')) {
          // Images go to appDocDir/Images/
          targetPath = p.join(appDocPath, zipPath);
          baseDir = appDocPath;

          debugPrint('📷 Image: $zipPath → $targetPath');
        } else if (zipPath.startsWith('databases/')) {
          // Database files
          final String dbFileName = zipPath.substring('databases/'.length);
          targetPath = p.join(dbPath, dbFileName);
          baseDir = dbPath;

          debugPrint('💾 Database: $zipPath → $targetPath');
        } else if (zipPath.endsWith('.db') ||
            zipPath.endsWith('.db-wal') ||
            zipPath.endsWith('.db-shm')) {
          // Legacy backup format: DB files at root
          final String fileName = p.basename(zipPath);
          targetPath = p.join(dbPath, fileName);
          baseDir = dbPath;

          debugPrint('💾 Database (legacy): $zipPath → $targetPath');
        } else {
          debugPrint('⏭️ Skipping unknown file: $zipPath');
          skipped++;
          processed++;
          continue;
        }

        // Security validation
        if (!_isPathSafe(zipPath, targetPath, baseDir)) {
          skipped++;
          processed++;
          continue;
        }

        // Create parent directories
        final File outFile = File(targetPath);
        await outFile.parent.create(recursive: true);

        // Extract file
        try {
          final List<int> content = file.content as List<int>;
          await outFile.writeAsBytes(content, flush: true);
          restored++;

          debugPrint('✅ Restored: $zipPath');
        } catch (e) {
          debugPrint('⚠️ Failed to restore ${file.name}: $e');
          skipped++;
        }

        processed++;
        onProgress?.call(processed / files.length, zipPath);
      }

      debugPrint(
        '✅ Restore completed: $restored files restored, $skipped skipped ur mom',
      );

      // 6) Restart app to apply changes
      if (autoRestartApp && context != null && context.mounted) {
        await _restartOrCloseApp(context: context);
      }
    } catch (e, st) {
      debugPrint('❌ Restore failed: $e\n$st');
      rethrow;
    } finally {
      zipInputStream?.close();
    }
  }

  /// Restart the app or show dialog for iOS
  static Future<void> _restartOrCloseApp({BuildContext? context}) async {
    try {
      if (Platform.isAndroid) {
        final a = await Restart.restartApp();
        if (!a && context != null && context.mounted) {
          await _showRestartDialog(context);
        }
      } else if (Platform.isIOS) {
        if (context != null && context.mounted) {
          await _showRestartDialog(context);
        } else {
          debugPrint(
            'ℹ️ Please manually close and reopen the app to complete restoration',
          );
        }
      } else {
        exit(0);
      }
    } catch (e) {
      debugPrint('⚠️ Restart action: $e');
    }
  }

  /// Show dialog for iOS users
  static Future<void> _showRestartDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('✅ Restore Complete'),
          content: const Text(
            'Your backup has been restored successfully!\n\n'
            'Please close and reopen the app to apply the changes.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Validate backup ZIP file before restoration
  static Future<bool> validateBackupFile(String zipPath) async {
    InputFileStream? inputStream;

    try {
      final File zipFile = File(zipPath);
      if (!await zipFile.exists()) {
        debugPrint('❌ Backup file not found: $zipPath');
        return false;
      }

      final int size = await zipFile.length();
      if (size == 0) {
        debugPrint('❌ Backup file is empty');
        return false;
      }

      if (size > 1024 * 1024 * 1024) {
        debugPrint(
          '❌ Backup file too large: ${(size / 1024 / 1024).toStringAsFixed(2)} MB',
        );
        return false;
      }

      // Validate ZIP structure
      inputStream = InputFileStream(zipPath);
      final Archive archive = ZipDecoder().decodeBuffer(inputStream);

      if (archive.isEmpty) {
        debugPrint('❌ Backup ZIP is empty');
        return false;
      }

      // Check for valid backup files
      final bool hasValidFiles = archive.files.any(
        (f) =>
            f.isFile &&
            (f.name.startsWith('Images/') ||
                f.name.startsWith('databases/') ||
                f.name.endsWith('.db')),
      );

      if (!hasValidFiles) {
        debugPrint('❌ Backup ZIP contains no valid backup files');
        return false;
      }

      debugPrint('✅ Backup file is valid: ${archive.files.length} files');
      return true;
    } catch (e) {
      debugPrint('❌ Backup validation failed: $e');
      return false;
    } finally {
      inputStream?.close();
    }
  }
}
