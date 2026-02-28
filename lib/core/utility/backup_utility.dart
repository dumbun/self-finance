import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

typedef BackupProgressCallback =
    void Function(double progress, String currentFile);

/// Optimized BackupUtility matching actual app file structure
///
/// Handles:
/// 1. iOS: databases in appDocDir/databases/, images in appDocDir/Images/
/// 2. Android: databases in getDatabasesPath(), images in appDocDir/Images/
/// 3. Stream-based ZIP creation for memory efficiency
/// 4. Proper validation and security
class BackupUtility {
  static const int _maxFileSize = 100 * 1024 * 1024; // 100MB per file

  /// Request storage permissions
  static Future<bool> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final PermissionStatus status = await Permission.storage.request();
        if (status.isGranted) return true;

        final PermissionStatus manageStatus = await Permission
            .manageExternalStorage
            .request();
        return manageStatus.isGranted;
      } else if (Platform.isIOS) {
        return true;
      } else {
        return true;
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
      return false;
    }
  }

  /// Recursively list files under directory
  static Future<List<File>> _listFilesRecursive(Directory dir) async {
    final List<File> out = [];
    try {
      if (!await dir.exists()) return out;

      await for (final FileSystemEntity entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          final String normalizedPath = p.normalize(entity.path);
          final String normalizedBase = p.normalize(dir.path);
          if (p.isWithin(normalizedBase, normalizedPath)) {
            out.add(entity);
          }
        }
      }
    } catch (e) {
      debugPrint('Error listing files in ${dir.path}: $e');
    }
    return out;
  }

  /// Validate file size
  static Future<bool> _validateFileSize(File file) async {
    try {
      final int size = await file.length();
      if (size > _maxFileSize) {
        debugPrint(
          'Warning: File ${file.path} exceeds size limit ($size bytes)',
        );
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('Error checking file size: $e');
      return false;
    }
  }

  /// Create backup with proper file structure
  static Future<String> startBackup({
    BackupProgressCallback? onProgress,
  }) async {
    Directory? tempDir;

    try {
      // 1) Request storage permission
      final bool granted = await _requestStoragePermission();
      if (!granted) {
        throw Exception('Storage permission not granted.');
      }

      // 2) Get app directories
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;

      // Images directory (always in appDocDir/Images on both platforms)
      final Directory imagesDir = Directory(p.join(appDocPath, 'Images'));

      // Database directory (platform-specific)
      final String dbPath;
      if (Platform.isIOS) {
        // iOS: databases are in appDocDir/databases/
        dbPath = p.join(appDocPath, 'databases');
      } else {
        // Android: databases are in standard location
        final a = await getApplicationDocumentsDirectory();
        final dbDir = p.join(a.parent.path, 'databases');
        dbPath = dbDir;
      }
      final Directory dbDir = Directory(dbPath);

      debugPrint('📦 Backup paths:');
      debugPrint('   App Dir: $appDocPath');
      debugPrint('   Images: ${imagesDir.path}');
      debugPrint('   Database: $dbPath');

      // 3) Collect all files to backup
      final List<File> filesToArchive = [];
      int totalSize = 0;

      // Add all image files
      if (await imagesDir.exists()) {
        final List<File> imageFiles = await _listFilesRecursive(imagesDir);
        debugPrint('📷 Found ${imageFiles.length} image files');

        for (final File file in imageFiles) {
          if (await _validateFileSize(file)) {
            filesToArchive.add(file);
            totalSize += await file.length();
          }
        }
      }

      // Add all database files
      if (await dbDir.exists()) {
        final List<File> dbFiles = await _listFilesRecursive(dbDir);
        debugPrint('💾 Found ${dbFiles.length} database files');

        for (final File file in dbFiles) {
          // Include .db, .db-wal, .db-shm files
          final String fileName = p.basename(file.path).toLowerCase();
          if (fileName.endsWith('.db') ||
              fileName.endsWith('.db-wal') ||
              fileName.endsWith('.db-shm')) {
            if (await _validateFileSize(file)) {
              filesToArchive.add(file);
              totalSize += await file.length();
            }
          }
        }
      }

      if (filesToArchive.isEmpty) {
        throw Exception('No files found to backup.');
      }

      debugPrint(
        '📦 Total: ${filesToArchive.length} files (${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB)',
      );

      // 4) Create ZIP file
      tempDir = await Directory.systemTemp.createTemp('backup_');
      final String timestamp = DateTime.now().toIso8601String().replaceAll(
        RegExp(r'[:.]'),
        '-',
      );
      final String zipFileName = 'app_backup_$timestamp.zip';
      final String tempZipPath = p.join(tempDir.path, zipFileName);

      // 5) Create ZIP using streaming encoder
      final ZipFileEncoder encoder = ZipFileEncoder(
        password: dotenv.env['BACKUP_PASSWORD'],
      );
      encoder.create(tempZipPath);

      int processedSize = 0;

      for (int i = 0; i < filesToArchive.length; i++) {
        final File file = filesToArchive[i];
        final String filePath = p.normalize(file.path);

        // Compute relative path for ZIP entry
        String zipEntryPath;

        if (p.isWithin(p.normalize(imagesDir.path), filePath)) {
          // Image file: preserve structure under Images/
          final String relativePath = p.relative(filePath, from: appDocPath);
          zipEntryPath = relativePath;
        } else if (p.isWithin(p.normalize(dbPath), filePath)) {
          // Database file: put under databases/
          final String dbFileName = p.relative(filePath, from: dbPath);
          zipEntryPath = p.join('databases', dbFileName);
        } else {
          // Fallback (shouldn't happen)
          zipEntryPath = p.basename(filePath);
        }

        // Normalize to forward slashes for ZIP compatibility
        zipEntryPath = zipEntryPath.replaceAll('\\', '/');

        try {
          encoder.addFile(file, zipEntryPath);

          final int fileSize = await file.length();
          processedSize += fileSize;

          if (onProgress != null) {
            final double progress = processedSize / totalSize;
            onProgress(progress, zipEntryPath);
          }

          debugPrint('✅ Added to ZIP: $zipEntryPath');
        } catch (e) {
          debugPrint('⚠️ Failed to add ${file.path}: $e');
        }
      }

      encoder.close();
      debugPrint('✅ ZIP created: $tempZipPath');

      // 6) Let user choose save location
      final String? targetDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select folder to save backup',
      );

      if (targetDir == null || targetDir.isEmpty) {
        // Clean up temp file
        await File(tempZipPath).delete();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
        return "Please select backup destination";
      }

      // 7) Copy to final destination
      String destPath = p.join(targetDir, zipFileName);

      // Avoid overwriting existing files
      if (await File(destPath).exists()) {
        final String base = p.basenameWithoutExtension(zipFileName);
        final String ext = p.extension(zipFileName);
        int counter = 1;
        do {
          destPath = p.join(targetDir, '${base}_$counter$ext');
          counter++;
        } while (await File(destPath).exists());
      }

      final File tempFile = File(tempZipPath);
      //? If we face any permisson issue with copying use share
      // ShareParams s = ShareParams(files: [XFile(tempFile.path)]);
      // SharePlus.instance.share(s);
      await tempFile.copy(destPath);
      await tempFile.delete();

      debugPrint('✅ Backup saved: $destPath');
      return destPath;
    } catch (e, st) {
      debugPrint('❌ Backup error: $e\n$st');
      rethrow;
    } finally {
      if (tempDir != null && tempDir.existsSync()) {
        try {
          await tempDir.delete(recursive: true);
        } catch (e) {
          debugPrint('⚠️ Failed to clean temp directory: $e');
        }
      }
    }
  }
}
