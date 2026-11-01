import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/backend/db_paths.dart';
import 'package:self_finance/backend/user_database.dart';
import 'package:self_finance/core/sync/sync_outbox_service.dart';
import 'package:self_finance/core/utility/invoice_generator_utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages per-account database lifecycles and legacy data migration.
///
/// Ensures each authenticated Google user has an isolated SQLite database,
/// preventing cross-account data leakage on shared devices.
class AccountDatabaseManager {
  static String? _activeUserId;

  /// The currently active Supabase user ID, or `null` if unauthenticated/offline.
  static String? get activeUserId => _activeUserId;

  /// Derives a deterministic 16-character hexadecimal suffix from the user ID.
  static String getAccountSuffix(String userId) {
    return sha256
        .convert(utf8.encode(userId.trim()))
        .toString()
        .substring(0, 16);
  }

  /// Returns the account-scoped database filename for financial data.
  static String getItDataDbName(String userId) {
    return 'itdata_${getAccountSuffix(userId)}.db';
  }

  /// Returns the account-scoped database filename for user profile data.
  static String getUserDbName(String userId) {
    return 'user_${getAccountSuffix(userId)}.db';
  }

  /// Checks if legacy unmigrated data (`itdata.db`) exists on the device.
  static Future<bool> hasUnmigratedLegacyData() async {
    try {
      final legacyFile = await legacySqfliteDbFile('itdata.db');
      if (!await legacyFile.exists()) return false;
      final size = await legacyFile.length();
      return size > 0;
    } catch (e) {
      debugPrint('Error checking legacy data: $e');
      return false;
    }
  }

  /// Migrates legacy databases (`itdata.db`, `user.db`) to the specified account.
  ///
  /// If the target account database already exists, migration is skipped.
  static Future<bool> migrateLegacyDataToAccount(String userId) async {
    final suffix = getAccountSuffix(userId);
    final targetItDataName = 'itdata_$suffix.db';
    final targetUserName = 'user_$suffix.db';

    final legacyItData = await legacySqfliteDbFile('itdata.db');
    final targetItData = await legacySqfliteDbFile(targetItDataName);

    final legacyUser = await legacySqfliteDbFile('user.db');
    final targetUser = await legacySqfliteDbFile(targetUserName);

    // 1. Migrate financial database
    if (await targetItData.exists()) {
      debugPrint(
        'Account DB $targetItDataName already exists; skipping legacy financial migration.',
      );
    } else if (await legacyItData.exists()) {
      debugPrint('Migrating legacy itdata.db to $targetItDataName...');
      try {
        await legacyItData.copy(targetItData.path);
        await legacyItData.delete();
        debugPrint(
          'Legacy financial migration completed successfully for account: $userId',
        );
      } catch (e) {
        debugPrint('Error during legacy financial migration: $e');
      }
    }

    // 2. Migrate user profile database
    if (await targetUser.exists()) {
      debugPrint(
        'Account user DB $targetUserName already exists; skipping legacy user migration.',
      );
    } else if (await legacyUser.exists()) {
      debugPrint('Migrating legacy user.db to $targetUserName...');
      try {
        await legacyUser.copy(targetUser.path);
        await legacyUser.delete();
        debugPrint(
          'Legacy user migration completed successfully for account: $userId',
        );
      } catch (e) {
        debugPrint('Error during legacy user migration: $e');
      }
    }

    return true;
  }

  /// Opens the databases for the specified Supabase user account.
  ///
  /// Automatically runs one-time legacy migration if needed, initializes
  /// account-scoped [ItDataDatabase] and [UserDatabase], and configures [BackEnd]
  /// and [UserBackEnd].
  static Future<void> openForAccount(String userId) async {
    if (_activeUserId == userId &&
        BackEnd.activeDatabase != null &&
        UserBackEnd.activeDatabase != null) {
      return;
    }

    // 1. Close any currently open databases
    await closeCurrentAccount();

    // 2. Perform legacy migration if this is an existing user's first login
    await migrateLegacyDataToAccount(userId);

    // 3. Open account-scoped financial database
    final suffix = getAccountSuffix(userId);
    final itDataDb = ItDataDatabase.forAccount(suffix);
    BackEnd.setDatabase(itDataDb, accountId: userId);

    // 4. Open account-scoped user profile database
    final userDb = UserDatabase.forAccount(suffix);
    UserBackEnd.setDatabase(userDb, accountId: userId);

    _activeUserId = userId;
    debugPrint(
      'Account databases opened for user: $userId (suffix: $suffix)',
    );

    // 5. Ensure all records have a UUID syncId and are queued in outbox for sync (gated for performance)
    try {
      final needsBackfill =
          await SyncOutboxService.hasRecordsNeedingSync(itDataDb);
      if (needsBackfill) {
        await SyncOutboxService.queueAllExistingRecords(itDataDb);
      }
    } catch (e) {
      debugPrint('⚠️ Error queueing existing records in openForAccount: $e');
    }
  }

  /// Closes all currently active account databases.
  static Future<void> closeCurrentAccount() async {
    try {
      await BackEnd.close();
    } catch (e) {
      debugPrint('Error closing BackEnd: $e');
    }
    try {
      await UserBackEnd.close();
    } catch (e) {
      debugPrint('Error closing UserBackEnd: $e');
    }
    InvoiceGenerator.clearUserCache();
    _activeUserId = null;
    debugPrint('Current account databases closed.');
  }

  /// Closes all active database connections and permanently deletes all local
  /// database files, sidecars (WAL/SHM/journal), cached images, and sync preferences.
  static Future<void> deleteAllLocalData({String? userId}) async {
    // 1. Close all active database connections cleanly
    await closeCurrentAccount();

    // Wait a brief moment for OS file locks / isolates to release
    await Future.delayed(const Duration(milliseconds: 150));

    // 2. Discover all candidate database directories across platforms
    final List<Directory> candidateDirs = await allDatabaseDirectories();

    // 3. Scan and delete all database files and sidecars
    final visitedPaths = <String>{};
    for (final dir in candidateDirs) {
      if (!dir.existsSync()) continue;
      final String canonicalDir;
      try {
        canonicalDir = dir.resolveSymbolicLinksSync();
      } catch (_) {
        continue;
      }
      if (visitedPaths.contains(canonicalDir)) continue;
      visitedPaths.add(canonicalDir);

      try {
        final isDatabasesDir =
            p.basename(dir.path).toLowerCase() == 'databases';
        final List<FileSystemEntity> entities = dir.listSync(
          recursive: isDatabasesDir,
          followLinks: false,
        );

        for (final entity in entities) {
          if (entity is File) {
            final fileName = p.basename(entity.path).toLowerCase();
            final isDbFile = isDatabasesDir ||
                fileName.endsWith('.db') ||
                fileName.endsWith('.db-wal') ||
                fileName.endsWith('.db-shm') ||
                fileName.endsWith('.db-journal') ||
                fileName.endsWith('.sqlite') ||
                fileName.endsWith('.sqlite-wal') ||
                fileName.endsWith('.sqlite-shm') ||
                fileName.endsWith('.sqlite-journal');

            if (isDbFile) {
              try {
                if (entity.existsSync()) {
                  entity.deleteSync();
                  debugPrint('Deleted db file: ${entity.path}');
                }
              } catch (e) {
                // If direct delete fails (e.g. transient file lock), truncate first then delete
                try {
                  entity.writeAsBytesSync([]);
                  entity.deleteSync();
                  debugPrint('Truncated and deleted: ${entity.path}');
                } catch (e2) {
                  debugPrint('Failed to delete ${entity.path}: $e2');
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error listing dir ${dir.path}: $e');
      }
    }

    // 4. Delete cached customer / user images directory
    try {
      final docs = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(docs.path, 'Images'));
      if (imagesDir.existsSync()) {
        try {
          imagesDir.deleteSync(recursive: true);
          debugPrint('Deleted Images directory.');
        } catch (e) {
          debugPrint('Failed to delete Images directory: $e');
        }
      }
    } catch (e) {
      debugPrint('Error resolving Images directory: $e');
    }

    // 5. Clear sync preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('last_sync_timestamp_')) {
          await prefs.remove(key);
        }
      }
      if (userId != null && userId.isNotEmpty) {
        await prefs.remove('last_sync_timestamp_$userId');
      }
    } catch (e) {
      debugPrint('Failed to clear sync prefs: $e');
    }

    debugPrint('All local databases and cached data successfully deleted.');
  }

  /// Permanently deletes all local data for [userId].
  ///
  /// Calls [deleteAllLocalData] to ensure all files, sidecars, images, and
  /// preferences are completely cleared.
  static Future<void> deleteAllAccountData(String userId) async {
    await deleteAllLocalData(userId: userId);
  }

  /// Permanently deletes local database files. Kept for backward compatibility.
  static Future<void> deleteAccountDatabase(String userId) async {
    await deleteAllLocalData(userId: userId);
  }
}
