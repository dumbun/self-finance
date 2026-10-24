import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/sync/sync_engine.dart';
import 'package:self_finance/core/sync/sync_outbox_service.dart';
import 'package:self_finance/providers/app_dir_provider.dart';
import 'package:self_finance/providers/auth_provider.dart';

enum SyncStatus { idle, syncing, success, error }

class SyncState {
  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncTime,
    this.errorMessage,
  });

  final SyncStatus status;
  final DateTime? lastSyncTime;
  final String? errorMessage;

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncTime,
    String? errorMessage,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage,
    );
  }
}

class SyncNotifier extends Notifier<SyncState> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _debounceTimer;

  @override
  SyncState build() {
    _listenToConnectivity();
    ref.onDispose(() {
      _debounceTimer?.cancel();
      _connectivitySub?.cancel();
    });
    return const SyncState();
  }

  void _listenToConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection && state.status != SyncStatus.syncing) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
          if (state.status != SyncStatus.syncing) {
            syncNow();
          }
        });
      }
    });
  }

  /// Triggers a bidirectional sync.
  Future<void> syncNow() async {
    final user = ref.read(currentUserProvider);

    if (user == null) {
      debugPrint('Sync skipped: user not active.');
      return;
    }

    if (state.status == SyncStatus.syncing) {
      debugPrint('Sync already in progress; skipping trigger.');
      return;
    }

    state = state.copyWith(status: SyncStatus.syncing);

    try {
      final db = BackEnd.activeDatabase;
      if (db == null) {
        debugPrint('Sync skipped: database not active.');
        return;
      }

      // Only backfill legacy rows when they genuinely need migration.
      // This avoids a full-table scan on every sync and keeps normal syncs fast.
      final needsBackfill = await SyncOutboxService.hasRecordsNeedingSync(db);
      if (needsBackfill) {
        await SyncOutboxService.queueAllExistingRecords(db);
      }

      String? appDirPath;
      try {
        appDirPath = ref.read(appDirProvider);
      } catch (_) {
        // Fallback if appDirProvider is not overridden in test environments
      }

      final engine = SyncEngine(
        client: Supabase.instance.client,
        db: db,
        userId: user.id,
        appDirPath: appDirPath,
      );

      await engine.sync();

      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Sync failed: $e');
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);
