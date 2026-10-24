import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/backend/db_paths.dart';
import 'package:self_finance/core/sync/sync_outbox_service.dart';

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
    return sha256.convert(utf8.encode(userId.trim())).toString().substring(0, 16);
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

  /// Migrates legacy financial database (`itdata.db`) to the specified account.
  ///
  /// If the target account database already exists, migration is skipped.
  /// Creates backups (`itdata_legacy_backup.db`) and renames the legacy file to
  /// `itdata_migrated.db` so it cannot be claimed by another account.
  static Future<bool> migrateLegacyDataToAccount(String userId) async {
    final suffix = getAccountSuffix(userId);
    final targetItDataName = 'itdata_$suffix.db';

    final legacyItData = await legacySqfliteDbFile('itdata.db');
    final targetItData = await legacySqfliteDbFile(targetItDataName);

    // If target already exists, do not overwrite (user has an existing account DB)
    if (await targetItData.exists()) {
      debugPrint('Account DB $targetItDataName already exists; skipping legacy migration.');
      return false;
    }

    if (await legacyItData.exists()) {
      debugPrint('Migrating legacy itdata.db to $targetItDataName...');
      // 1. Create a safety backup
      final backupFile = await legacySqfliteDbFile('itdata_legacy_backup.db');
      await legacyItData.copy(backupFile.path);

      // 2. Copy to target account db
      await legacyItData.copy(targetItData.path);

      // 3. Rename legacy file to itdata_migrated.db so it's not claimed again
      final migratedMarker = await legacySqfliteDbFile('itdata_migrated.db');
      await legacyItData.rename(migratedMarker.path);

      debugPrint('Legacy data migration completed successfully for account: $userId');
      return true;
    }

    return false;
  }

  /// Opens the financial database for the specified Supabase user account.
  ///
  /// Automatically runs one-time legacy migration if needed, initializes
  /// the account-scoped [ItDataDatabase], and configures [BackEnd].
  /// Note: [UserBackEnd] (local device PIN, currency, profile) remains stable
  /// and open on the device to avoid closing active isolate stream channels.
  static Future<void> openForAccount(String userId) async {
    if (_activeUserId == userId && BackEnd.activeDatabase != null) {
      return;
    }

    // 1. Close any currently open financial database
    await closeCurrentAccount();

    // 2. Perform legacy migration if this is an existing user's first login
    await migrateLegacyDataToAccount(userId);

    // 3. Open account-scoped financial database
    final suffix = getAccountSuffix(userId);
    final itDataDb = ItDataDatabase.forAccount(suffix);

    // 4. Assign it to BackEnd singleton
    BackEnd.setDatabase(itDataDb, accountId: userId);

    _activeUserId = userId;
    debugPrint('Account financial database opened for user: $userId (suffix: $suffix)');

    // 5. Ensure all records have a UUID syncId and are queued in outbox for sync
    try {
      await SyncOutboxService.queueAllExistingRecords(itDataDb);
    } catch (e) {
      debugPrint('⚠️ Error queueing existing records in openForAccount: $e');
    }
  }

  /// Closes the currently active account financial database.
  static Future<void> closeCurrentAccount() async {
    await BackEnd.close();
    _activeUserId = null;
    debugPrint('Current account financial database closed.');
  }
}
