import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Returns a [File] pointing to the same on-device location your legacy sqflite
/// code used.
///
/// Legacy behavior in your project:
/// - iOS: Documents/databases/dbName
/// - Android: app data/databases/dbName (sqflite's getDatabasesPath)
Future<File> legacySqfliteDbFile(String dbName) async {
  final docs = await getApplicationDocumentsDirectory();

  if (Platform.isAndroid) {
    // docs is typically .../<package>/app_flutter
    final appRoot = docs.parent; // .../<package>
    final dbDir = Directory(p.join(appRoot.path, 'databases'));
    await dbDir.create(recursive: true);

    return File(p.join(dbDir.path, dbName));
  }

  // iOS / macOS (and a sensible fallback for other platforms)
  final dbDir = Directory(p.join(docs.path, 'databases'));
  await dbDir.create(recursive: true);
  return File(p.join(dbDir.path, dbName));
}
