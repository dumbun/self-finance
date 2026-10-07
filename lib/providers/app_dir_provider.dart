import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_dir_provider.g.dart';

@Riverpod(keepAlive: true)
String appDir(Ref ref) {
  throw UnimplementedError('appDirProvider must be overridden');
}
