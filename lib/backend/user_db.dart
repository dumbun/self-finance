import 'package:self_finance/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

/// An abstract class to handle database operations related to the User model.
/// Provides methods for creating the database table, performing CRUD operations,
/// and fetching user data.
abstract class UserBackEnd {
  /// [database] - The database instance where the table will be created.
  static Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE USER(
      ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      USER_NAME TEXT NOT NULL,
      USER_PIN TEXT NOT NULL,
      USER_CURRENCY TEXT NOT NULL,
      USER_PROFILE_PICTURE TEXT NOT NULL
    )""");
  }

  /// Opens or creates the database and returns a [Database] instance.
  /// The database file will be stored at a path that ensures persistence
  /// across app reinstalls.
  ///
  /// Returns a [Database] instance.

  static Future<Database> db() async {
    final String databasePath = await getDatabasesPath();
    final path = '$databasePath/user.db';
    return openDatabase(path, version: 1, onCreate: (Database database, int version) async {
      await createTable(database);
    });
  }

  /// Inserts a new user into the USER table.
  ///
  /// [user] - The user object to be inserted.
  ///
  /// Returns `true` if the user was successfully created, otherwise `false`.

  static Future<bool> createNewUser(User user) async {
    final db = await UserBackEnd.db();
    try {
      final Map<String, Object?> data = {
        "ID": user.id,
        "USER_NAME": user.userName,
        "USER_PIN": user.userPin,
        "USER_CURRENCY": user.userCurrency,
        "USER_PROFILE_PICTURE": user.profilePicture,
      };
      final id = await db.insert('USER', data, conflictAlgorithm: ConflictAlgorithm.replace);
      return id != 0 ? true : false;
    } catch (e) {
      return false;
    }
  }

  // get called first  app lunches or reload app

  static Future<List<Map<String, dynamic>>> fetchAllData() async {
    final db = await UserBackEnd.db();
    return db.query('USER', orderBy: 'ID');
  }

  // fetch the user data

  static Future<List<User>> fetchUserData() async {
    final db = await UserBackEnd.db();

    List<Map<String, Object?>> result = await db.rawQuery("""
      SELECT * FROM USER WHERE ID = 1
    """);

    return User.toList(result);
  }

  static Future<List<User>> fetchIDOneUser() async {
    final db = await UserBackEnd.db();
    List<Map<String, Object?>> result = await db.rawQuery("""
      SELECT * FROM USER WHERE ID = 1
    """);
    return result.isNotEmpty ? User.toList(result) : [];
  }

  // fetch user pin

  static Future<String> fetchUserPIN() async {
    final db = await UserBackEnd.db();
    List<Map<String, Object?>> result = await db.rawQuery("""
  SELECT USER_PIN FROM USER WHERE ID = 1
""");
    return result[0]["USER_PIN"].toString();
  }

  // fetch user currency

  static Future<String> fetchUserCurrency() async {
    final db = await UserBackEnd.db();
    List<Map<String, Object?>> result = await db.rawQuery("""
  SELECT USER_CURRENCY FROM USER WHERE ID = 1 
    """);
    return result[0]["USER_CURRENCY"].toString();
  }

  // Update the USER_NAME

  static Future<int> updateUserName(int id, String name) async {
    final db = await UserBackEnd.db();
    final data = {'USER_NAME': name};
    final result = await db.update('USER', data, where: "id = ?", whereArgs: [id]);
    return result;
  }
  // Update the USER_PIN

  static Future<int> updateUserPin(int id, String pin) async {
    final db = await UserBackEnd.db();
    final data = {'USER_PIN': pin};
    final result = await db.update('USER', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Update the USER_PIN

  static Future<int> updateUserCurrency(int id, String currency) async {
    final db = await UserBackEnd.db();
    final data = {'USER_CURRENCY': currency};
    final result = await db.update('USER', data, where: "id = ?", whereArgs: [id]);
    return result;
  }
  // Update the USER_PROFILE_PIC

  static Future<int> updateProfilePic(int id, String imageString) async {
    final db = await UserBackEnd.db();
    final data = {'USER_PROFILE_PICTURE': imageString};
    final result = await db.update('USER', data, where: "id = ?", whereArgs: [id]);
    return result;
  }
  // Update the USER

  static Future<int> updateUser(User user) async {
    final db = await UserBackEnd.db();
    final data = {
      'ID': user.id!,
      'USER_NAME': user.userName,
      'USER_PIN': user.userPin,
      'USER_CURRENCY': user.userCurrency,
      'USER_PROFILE_PICTURE': user.profilePicture,
    };
    final result = await db.update('USER', data, where: "id = ?", whereArgs: [user.id]);
    return result;
  }

  // fetch the security PIN transactions of a requried number

  static Future<List<User>> fetchPin(String pin) async {
    final db = await UserBackEnd.db();
    List<User> data = User.toList(
      await db.query(
        "USER",
        where: "USER_PIN = ?",
        whereArgs: [pin],
      ),
    );
    return data;
  }

  // close a data base

  Future<bool> close() async {
    final db = await UserBackEnd.db();
    await db.close();
    return true;
  }
}
