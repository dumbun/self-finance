import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/backend/account_database_manager.dart';

void main() {
  group('AccountDatabaseManager tests', () {
    test('getAccountSuffix produces deterministic 16-character hex string', () {
      const userId1 = '15599347-2511-4b2a-88c8-ccad48b675ee';
      const userId2 = '15599347-2511-4b2a-88c8-ccad48b675ee';
      const userId3 = 'different-user-uuid-9999-000000000000';

      final suffix1 = AccountDatabaseManager.getAccountSuffix(userId1);
      final suffix2 = AccountDatabaseManager.getAccountSuffix(userId2);
      final suffix3 = AccountDatabaseManager.getAccountSuffix(userId3);

      expect(suffix1.length, 16);
      expect(suffix1, equals(suffix2));
      expect(suffix1, isNot(equals(suffix3)));
    });

    test('database names are formatted correctly with suffix', () {
      const userId = 'user-abc-123';
      final suffix = AccountDatabaseManager.getAccountSuffix(userId);

      final itDataDbName = AccountDatabaseManager.getItDataDbName(userId);
      final userDbName = AccountDatabaseManager.getUserDbName(userId);

      expect(itDataDbName, equals('itdata_$suffix.db'));
      expect(userDbName, equals('user_$suffix.db'));
    });
  });
}
