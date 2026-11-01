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

/// Returns a list of all directories where SQLite database files could reside
/// on the host platform.
Future<List<Directory>> allDatabaseDirectories() async {
  final List<Directory> dirs = [];
  try {
    final docs = await getApplicationDocumentsDirectory();
    if (Platform.isAndroid) {
      dirs.add(Directory(p.join(docs.parent.path, 'databases')));
    }
    dirs.add(Directory(p.join(docs.path, 'databases')));
    dirs.add(docs);

    try {
      final support = await getApplicationSupportDirectory();
      dirs.add(Directory(p.join(support.path, 'databases')));
      dirs.add(support);
    } catch (_) {}
  } catch (e) {
    // ignore
  }
  return dirs;
}
