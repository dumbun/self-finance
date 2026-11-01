import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' hide Constant;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/sync/sync_engine.dart';
import 'package:self_finance/core/sync/sync_outbox_service.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/providers/analytics_provider.dart';
import 'package:self_finance/providers/app_dir_provider.dart';
import 'package:self_finance/providers/auth_provider.dart';
import 'package:self_finance/providers/contacts_provider.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';

enum SyncStatus { idle, syncing, success, error }

class SyncState {
  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncTime,
    this.errorMessage,
    this.isOnline = true,
  });

  final SyncStatus status;
  final DateTime? lastSyncTime;
  final String? errorMessage;
  final bool isOnline;

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncTime,
    String? errorMessage,
    bool? isOnline,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class SyncNotifier extends Notifier<SyncState> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _debounceTimer;
  Timer? _outboxDebounceTimer;
  bool _hasPendingSync = false;

  @override
  SyncState build() {
    _listenToConnectivity();
    _listenToAuth();
    _listenToOutbox();
    Connectivity()
        .checkConnectivity()
        .then((List<ConnectivityResult> results) {
          final bool hasConnection = results.any(
            (ConnectivityResult r) => r != ConnectivityResult.none,
          );
          state = state.copyWith(isOnline: hasConnection);
          if (hasConnection && _hasPendingSync) {
            _hasPendingSync = false;
            _scheduleOutboxSync();
          }
        })
        .catchError((_) {});

    ref.onDispose(() {
      _debounceTimer?.cancel();
      _outboxDebounceTimer?.cancel();
      _connectivitySub?.cancel();
    });
    return const SyncState();
  }

  /// Public method to request an automatic debounced sync after local mutations
  /// (such as creating, updating, or deleting transactions, contacts, or customers).
  void triggerAutoSync() {
    _scheduleOutboxSync();
  }

  /// Watches the outbox for pending entries and auto-triggers sync
  /// when mutations are detected.
  void _listenToOutbox() {
    ref.listen<AsyncValue<int>>(pendingOutboxCountProvider, (previous, next) {
      final int currentCount = next.asData?.value ?? 0;
      if (currentCount > 0) {
        debugPrint(
          'Outbox: $currentCount pending entries detected. Scheduling auto-sync.',
        );
        _scheduleOutboxSync();
      }
    });
  }

  /// Debounces rapid mutations (e.g. creating a transaction writes 3 outbox
  /// entries: item + transaction + history) into a single sync pass.
  void _scheduleOutboxSync() {
    if (!state.isOnline) {
      debugPrint('Outbox: offline — queued sync for when connectivity returns.');
      _hasPendingSync = true;
      return;
    }

    _outboxDebounceTimer?.cancel();
    _outboxDebounceTimer = Timer(const Duration(milliseconds: 1500), () {
      if (state.status == SyncStatus.syncing) {
        debugPrint('Outbox: sync in progress — queuing follow-up pass.');
        _hasPendingSync = true;
        return;
      }
      debugPrint('Outbox: auto-triggering syncNow().');
      syncNow();
    });
  }

  void _listenToAuth() {
    ref.listen(authStateProvider, (previous, next) {
      final prevUser = previous?.asData?.value;
      final currentUser = next.asData?.value;

      if (currentUser != null && prevUser?.id != currentUser.id) {
        // User logged in or restored session — trigger full sync
        Future.delayed(const Duration(milliseconds: 600), syncNow);
      }
    });
  }

  void _listenToConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any(
        (ConnectivityResult r) => r != ConnectivityResult.none,
      );
      state = state.copyWith(isOnline: hasConnection);
      if (hasConnection && (_hasPendingSync || state.status != SyncStatus.syncing)) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
          if (state.status != SyncStatus.syncing) {
            _hasPendingSync = false;
            syncNow();
          }
        });
      }
    });
  }

  /// Invalidates data providers so the UI immediately reflects updates pulled from the cloud.
  void _invalidateDataProviders() {
    try {
      ref.invalidate(transactionsProvider);
      ref.invalidate(contactsProvider);
      ref.invalidate(historyProvider);
      ref.invalidate(totalCustomersProvider);
      ref.invalidate(activeLoansProvider);
      ref.invalidate(outstandingAmountProvider);
      ref.invalidate(interestEarnedProvider);
      ref.invalidate(totalDisbursedProvider);
      ref.invalidate(paymentsReceivedProvider);
    } catch (e) {
      debugPrint('Error invalidating data providers after sync: $e');
    }
  }

  /// Triggers a bidirectional sync.
  Future<void> syncNow() async {
    final user = ref.read(currentUserProvider);

    if (user == null) {
      debugPrint('Sync skipped: user not active.');
      return;
    }

    if (state.status == SyncStatus.syncing) {
      debugPrint('Sync already in progress; queuing follow-up.');
      _hasPendingSync = true;
      return;
    }

    final ItDataDatabase? db = BackEnd.activeDatabase;
    if (db == null) {
      debugPrint('Sync skipped: database not active.');
      return;
    }

    if (!Utility.isFirebaseInitialized) {
      debugPrint('Sync skipped: Cloud backend not initialized.');
      return;
    }

    state = state.copyWith(status: SyncStatus.syncing);

    try {
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

      final SyncEngine engine = SyncEngine(
        db: db,
        userId: user.id,
        appDirPath: appDirPath,
      );

      await engine.sync();

      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncTime: DateTime.now(),
      );

      _invalidateDataProviders();
    } catch (e) {
      debugPrint('Sync failed: $e');
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
    } finally {
      if (_hasPendingSync) {
        _hasPendingSync = false;
        Future.microtask(_scheduleOutboxSync);
      }
    }
  }
}

final NotifierProvider<SyncNotifier, SyncState> syncProvider =
    NotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);

final Provider<bool> isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(syncProvider.select((s) => s.isOnline));
});

final StreamProvider<int> pendingOutboxCountProvider = StreamProvider<int>((
  ref,
) async* {
  ref.watch(currentUserProvider);
  ItDataDatabase? db = BackEnd.activeDatabase;
  while (db == null) {
    yield 0;
    await Future.delayed(const Duration(milliseconds: 500));
    db = BackEnd.activeDatabase;
  }
  final Expression<int> countExpr = db.syncOutboxTable.outboxId.count();
  yield* (db.selectOnly(db.syncOutboxTable)
        ..where(
          db.syncOutboxTable.status.equals(SyncOutboxService.statusPending),
        )
        ..addColumns([countExpr]))
      .map((TypedResult row) => row.read(countExpr) ?? 0)
      .watchSingle();
});
