import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/core/utility/preferences_helper.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  Future<bool> build() async => PreferencesHelper.isDarkTheme(); // reads from SharedPreferences directly

  Future<void> toggle() async {
    final current = state.value ?? false;
    state = AsyncData(!current);
    await PreferencesHelper.setDarkTheme(!current);
  }

  Future<void> set(bool value) async {
    state = AsyncData(value);
    await PreferencesHelper.setDarkTheme(value);
  }
}

@Riverpod(keepAlive: true)
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  Future<bool> build() async => PreferencesHelper.areNotificationsEnabled();

  Future<void> toggle() async {
    final current = state.value ?? true;
    state = AsyncData(!current);
    await PreferencesHelper.setNotificationsEnabled(!current);
  }

  Future<void> set(bool value) async {
    state = AsyncData(value);
    await PreferencesHelper.setNotificationsEnabled(value);
  }
}
