import 'dart:async';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:self_finance/models/user_model.dart';

import 'db_paths.dart';

part 'user_database.g.dart';

@DataClassName('UserRow')
class UserTable extends Table {
  @override
  String get tableName => 'USER';

  IntColumn get id => integer().named('ID').autoIncrement()();

  TextColumn get userName => text().named('USER_NAME')();

  TextColumn get userPin => text().named('USER_PIN')();

  TextColumn get userCurrency => text().named('USER_CURRENCY')();

  TextColumn get profilePicture => text().named('USER_PROFILE_PICTURE')();
}

@DriftDatabase(tables: [UserTable])
class UserDatabase extends _$UserDatabase {
  UserDatabase(super.e);

  factory UserDatabase.defaults() {
    return UserDatabase(
      driftDatabase(
        name: 'user',
        native: DriftNativeOptions(
          databasePath: () async => (await legacySqfliteDbFile('user.db')).path,
          shareAcrossIsolates: true,
        ),
      ),
    );
  }

  @override
  int get schemaVersion => 1;
}

class UserBackEnd {
  static UserDatabase? _db;

  static Future<UserDatabase> db() async {
    _db ??= UserDatabase.defaults();
    return _db!;
  }

  static Future<bool> createNewUser(User user) async {
    try {
      final d = await db();
      await d
          .into(d.userTable)
          .insert(
            UserTableCompanion.insert(
              userName: user.userName,
              userPin: user.userPin,
              userCurrency: user.userCurrency,
              profilePicture: user.profilePicture,
            ),
            mode: InsertMode.insertOrReplace,
          );

      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAllData() async {
    final d = await db();
    final rows = await d.select(d.userTable).get();
    return rows
        .map(
          (r) => {
            'ID': r.id,
            'USER_NAME': r.userName,
            'USER_PIN': r.userPin,
            'USER_CURRENCY': r.userCurrency,
            'USER_PROFILE_PICTURE': r.profilePicture,
          },
        )
        .toList();
  }

  static Future<User> fetchUserData() async {
    final d = await db();
    final row = await (d.select(d.userTable)..limit(1)).getSingleOrNull();
    if (row == null) {
      return User(
        id: 0,
        userName: '',
        userPin: '',
        userCurrency: '',
        profilePicture: '',
      );
    }

    return User(
      id: row.id,
      userName: row.userName,
      userPin: row.userPin,
      userCurrency: row.userCurrency,
      profilePicture: row.profilePicture,
    );
  }

  static Future<int> fetchIDOneUser() async {
    final d = await db();
    final TypedResult? row =
        await (d.selectOnly(d.userTable)
              ..addColumns([d.userTable.id])
              ..where(d.userTable.id.equals(1))
              ..limit(1))
            .getSingleOrNull();
    if (row != null) {}
    return row?.read(d.userTable.id) ?? 0;
  }

  static Future<bool> fetchUserPIN(int id) async {
    final d = await db();
    final row =
        await (d.select(d.userTable)
              ..where((t) => t.id.equals(id))
              ..limit(1))
            .getSingleOrNull();

    if (row == null) return false;
    return row.userPin.isNotEmpty;
  }

  static Future<int> updateUserName({
    required int id,
    required String newUserName,
  }) async {
    final d = await db();
    return (d.update(d.userTable)..where((t) => t.id.equals(id))).write(
      UserTableCompanion(userName: Value(newUserName)),
    );
  }

  static Future<int> updateUserPin({
    required int id,
    required String newPin,
  }) async {
    final d = await db();
    return (d.update(d.userTable)..where((t) => t.id.equals(id))).write(
      UserTableCompanion(userPin: Value(newPin)),
    );
  }

  static Future<int> updateUserCurrency({
    required int id,
    required String currency,
  }) async {
    final d = await db();
    return (d.update(d.userTable)..where((t) => t.id.equals(id))).write(
      UserTableCompanion(userCurrency: Value(currency)),
    );
  }

  static Future<int> updateProfilePicture({
    required int id,
    required String photoPath,
  }) async {
    final d = await db();
    return (d.update(d.userTable)..where((t) => t.id.equals(id))).write(
      UserTableCompanion(profilePicture: Value(photoPath)),
    );
  }

  static Future<int> updateUser({required User user}) async {
    final d = await db();
    return (d.update(d.userTable)..where((t) => t.id.equals(user.id!))).write(
      UserTableCompanion(
        userName: Value(user.userName),
        userPin: Value(user.userPin),
        userCurrency: Value(user.userCurrency),
        profilePicture: Value(user.profilePicture),
      ),
    );
  }

  static Future<String> fetchPin() async {
    final d = await db();
    final row =
        await (d.selectOnly(d.userTable)
              ..addColumns([d.userTable.userPin])
              ..limit(1))
            .getSingleOrNull();

    return row?.read(d.userTable.userPin) ?? '';
  }

  // ---------------------------------------------------------------------------
  // STREAMS (reactive reads)
  // ---------------------------------------------------------------------------

  static Stream<List<User>> watchAllData() {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final q = (d.select(
        d.userTable,
      )..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();

      return q.map(
        (rows) => rows
            .map(
              (r) => User(
                id: r.id,
                userName: r.userName,
                userPin: r.userPin,
                userCurrency: r.userCurrency,
                profilePicture: r.profilePicture,
              ),
            )
            .toList(),
      );
    });
  }

  /// Watches the first (or only) user row.
  static Stream<User?> watchUserData() {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final q = (d.select(d.userTable)..limit(1)).watch();
      return q.map((rows) {
        if (rows.isEmpty) {
          return null;
        }
        final r = rows.first;
        return User(
          id: r.id,
          userName: r.userName,
          userPin: r.userPin,
          userCurrency: r.userCurrency,
          profilePicture: r.profilePicture,
        );
      });
    });
  }

  static Stream<String> watchPin({int id = 1}) {
    return Stream.fromFuture(db()).asyncExpand((d) {
      final q =
          (d.selectOnly(d.userTable)
                ..addColumns([d.userTable.userPin])
                ..where(d.userTable.id.equals(id))
                ..limit(1))
              .watch();

      return q.map(
        (rows) =>
            rows.isEmpty ? '' : (rows.first.read(d.userTable.userPin) ?? ''),
      );
    });
  }

  static Future<void> close() async {
    final d = _db;
    if (d == null) return;
    await d.close();
    _db = null;
  }
}
