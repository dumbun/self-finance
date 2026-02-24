import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_dir_provider.g.dart';

@riverpod
Future<String> appDir(Ref ref) async {
  final a = await getApplicationDocumentsDirectory();
  return a.path;
}
