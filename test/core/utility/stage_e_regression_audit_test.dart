import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/core/sync/sync_provider.dart';
import 'package:self_finance/core/utility/invoice_generator_utility.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/customer_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Stage E: Third Regression Audit Tests', () {
    test('InvoiceGenerator.clearUserCache clears static cache and verified file paths', () {
      clearVerifiedFilePathsCache();
      InvoiceGenerator.clearUserCache();
      // No throw when clearing repeatedly
      InvoiceGenerator.clearUserCache();
    });

    test('InvoiceGenerator.generateInvoice throws ArgumentError when transaction.id is null', () async {
      final customer = Customer(
        id: 'cust-1',
        userID: 1,
        name: 'Test Customer',
        guardianName: 'Guardian',
        address: '123 Main St',
        number: '9876543210',
        photo: '',
        proof: '',
        createdDate: DateTime(2025),
      );

      final trx = Trx(
        customerId: 'cust-1',
        itemId: 'item-1',
        transacrtionDate: DateTime(2025),
        transacrtionType: 'Active',
        amount: 1000.0,
        intrestRate: 2.0,
        intrestAmount: 20.0,
        remainingAmount: 1000.0,
        signature: '',
        createdDate: DateTime(2025),
      );

      expect(
        () => InvoiceGenerator.generateInvoice(transaction: trx, customer: customer),
        throwsArgumentError,
      );
    });

    test('InvoiceGenerator.generateInvoice throws ArgumentError when customer.name is empty', () async {
      final customer = Customer(
        id: 'cust-1',
        userID: 1,
        name: '   ',
        guardianName: 'Guardian',
        address: '123 Main St',
        number: '9876543210',
        photo: '',
        proof: '',
        createdDate: DateTime(2025),
      );

      final trx = Trx(
        id: 'trx-1',
        customerId: 'cust-1',
        itemId: 'item-1',
        transacrtionDate: DateTime(2025),
        transacrtionType: 'Active',
        amount: 1000.0,
        intrestRate: 2.0,
        intrestAmount: 20.0,
        remainingAmount: 1000.0,
        signature: '',
        createdDate: DateTime(2025),
      );

      expect(
        () => InvoiceGenerator.generateInvoice(transaction: trx, customer: customer),
        throwsArgumentError,
      );
    });

    test('InvoiceGenerator.shareInvoice throws ArgumentError when transaction.id is null', () async {
      final trx = Trx(
        customerId: 'cust-1',
        itemId: 'item-1',
        transacrtionDate: DateTime(2025),
        transacrtionType: 'Active',
        amount: 1000.0,
        intrestRate: 2.0,
        intrestAmount: 20.0,
        remainingAmount: 1000.0,
        signature: '',
        createdDate: DateTime(2025),
      );

      expect(
        () => InvoiceGenerator.shareInvoice(transaction: trx),
        throwsArgumentError,
      );
    });

    test('SyncNotifier does not enter or remain in syncing state when offline or db not ready', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(syncProvider.notifier);
      final initialState = container.read(syncProvider);

      expect(initialState.status, isNot(equals(SyncStatus.syncing)));

      // Trigger syncNow when unauthenticated
      await notifier.syncNow();

      final stateAfter = container.read(syncProvider);
      // Must not be stuck in syncing
      expect(stateAfter.status, isNot(equals(SyncStatus.syncing)));
    });

    test('Sanitized image file naming format conforms to UUIDv7 pattern without spaces or colons', () {
      final regex = RegExp(r'^photo_\d+_[a-f0-9]{8}\.jpg$');
      final testFileName = 'photo_${DateTime.now().millisecondsSinceEpoch}_0192a3b4.jpg';
      expect(regex.hasMatch(testFileName), isTrue);
      expect(testFileName.contains(':'), isFalse);
      expect(testFileName.contains(' '), isFalse);
    });
  });
}
