import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'date_provider.g.dart';

@Riverpod(keepAlive: false)
class DateNotifier extends _$DateNotifier {
  @override
  DateTime? build() => null;

  void set(DateTime input) {
    state = input;
  }

  void clear() => state = null;
}
