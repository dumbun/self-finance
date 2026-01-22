import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:sqflite/sqflite.dart';
import 'package:restart_app/restart_app.dart'; // Add this to pubspec.yaml

typedef RestoreProgressCallback =
    void Function(double progress, String currentFile);

class RestoreUtility {
  static Future<void> restoreBackupFromZip({
    RestoreProgressCallback? onProgress,
    bool autoRestartApp = true, // Option to control app restart
  }) async {
    try {
      /// 1️⃣ Close database before restore
      await BackEnd.close();

      /// 2️⃣ Pick ZIP file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        dialogTitle: 'Select backup ZIP file',
      );

      if (result == null || result.files.single.path == null) {
        throw Exception('No backup file selected');
      }

      final zipFile = File(result.files.single.path!);
      if (!await zipFile.exists()) {
        throw Exception('Backup file not found');
      }

      /// 3️⃣ Resolve target directories
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = await getDatabasesPath();
      final dbDir = Directory(dbPath);

      await dbDir.create(recursive: true);

      /// 4️⃣ Decode ZIP
      final archive = ZipDecoder().decodeBytes(await zipFile.readAsBytes());

      if (archive.isEmpty) {
        throw Exception('ZIP file is empty');
      }

      final files = archive.files.where((e) => e.isFile).toList();
      int processed = 0;

      /// 5️⃣ Restore files
      for (final file in files) {
        final zipPath = p.normalize(file.name).replaceAll('\\', '/');
        String? targetPath;

        /// 🖼️ Images → App Documents / Images
        /// ZIP contains: Images/customers/, Images/proofs/, etc.
        if (zipPath.startsWith('Images/')) {
          targetPath = p.join(
            appDocDir.path,
            zipPath, // Keep full path: Images/customers/...
          );
        }
        /// 🗄️ Databases → DB location
        else if (zipPath.startsWith('databases/')) {
          targetPath = p.join(
            dbDir.path,
            zipPath.substring('databases/'.length),
          );
        }
        /// ❌ Unknown → Skip
        else {
          debugPrint('Skipping unknown file: $zipPath');
          continue;
        }

        final outFile = File(targetPath);
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>, flush: true);

        processed++;
        onProgress?.call(processed / files.length, zipPath);
      }

      debugPrint('✅ Restore completed successfully');

      /// 6️⃣ Restart or close app to apply changes
      if (autoRestartApp) {
        await _restartOrCloseApp();
      }
    } catch (e, st) {
      debugPrint('❌ Restore failed: $e\n$st');
      rethrow;
    }
  }

  /// Restart the app or close it depending on platform
  static Future<void> _restartOrCloseApp() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (Platform.isAndroid) {
        await Restart.restartApp();
      } else if (Platform.isIOS) {
        // iOS doesn't allow programmatic restart
        // Show dialog asking user to manually restart
        throw Exception(
          'Please manually close and reopen the app to complete restoration',
        );
      } else {
        exit(0);
      }
    } catch (e) {
      debugPrint('⚠️ Restart action: $e');
      rethrow; // Let caller handle this
    }
  }
}
