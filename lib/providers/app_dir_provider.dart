import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_dir_provider.g.dart';

@Riverpod(keepAlive: true)
Future<String> appDir(Ref ref) async {
  final Directory a = await getApplicationDocumentsDirectory();
  return a.path;
}
