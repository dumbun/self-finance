import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/backend/user_database.dart';

part 'database_provider.g.dart';

/// NOTE:
/// With the new drift-based `BackEnd` (singleton), you usually don't need a
/// separate database provider.
/// This is kept for backwards compatibility. Prefer using `BackEnd` directly.
@Riverpod(keepAlive: true)
ItDataDatabase itDataDatabase(Ref ref) {
  final db = ItDataDatabase.defaults();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
UserDatabase userDatabase(Ref ref) {
  final db = UserDatabase.defaults();
  ref.onDispose(db.close);
  return db;
}
