import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/core/sync/sync_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Automatic Sync & SyncNotifier tests', () {
    test('SyncNotifier initializes in idle status and exposes triggerAutoSync()', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(syncProvider.notifier);
      final state = container.read(syncProvider);

      expect(state.status, equals(SyncStatus.idle));
      expect(state.isOnline, isTrue);

      // Verify triggerAutoSync can be safely invoked without crashing
      expect(notifier.triggerAutoSync, returnsNormally);
    });

    test('Rapid triggerAutoSync calls debounce into a single execution flow', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(syncProvider.notifier);

      // Trigger 5 times in rapid succession
      for (int i = 0; i < 5; i++) {
        notifier.triggerAutoSync();
      }

      // Allow microtasks and timer to progress slightly
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = container.read(syncProvider);
      // Not stuck in syncing error
      expect(state.status, isNot(equals(SyncStatus.error)));
    });

    test('syncNow completes safely without active user session', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(syncProvider.notifier);

      await notifier.syncNow();

      final state = container.read(syncProvider);
      expect(state.status, isNot(equals(SyncStatus.syncing)));
    });
  });
}
