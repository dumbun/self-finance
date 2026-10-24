import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/backend/user_database.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pushes dashboard numbers to the iOS / Android home-screen widget.
///
/// Call [HomeWidgetService.start] once after the app has initialised.
/// It listens to the existing drift analytics stream, so the widget updates
/// whenever a loan or payment changes.
class HomeWidgetService {
  HomeWidgetService._();

  // Must match the App Group you enable in Xcode (Runner + HomeWidgetExtension).
  static const String appGroupId = 'group.com.dumbun.selffinance';

  // iOS: the `kind` string in HomeWidget.swift
  static const String iOSWidgetName = 'HomeWidget';

  // Android: class name of SelfFinanceWidgetProvider (package = applicationId)
  static const String androidWidgetName = 'SelfFinanceWidgetProvider';

  static const String _hideAmountsKey = 'widget_hide_amounts';

  static StreamSubscription<Map<String, num>>? _sub;
  static Timer? _debounce;

  static Future<void> start() async {
    if (_sub != null) return;
    await HomeWidget.setAppGroupId(appGroupId);
    unawaited(refresh());

    _sub = BackEnd.watchAnalyticsData().listen((Map<String, num> analytics) {
      // Debounce: a single DB write can fire several stream events.
      _debounce?.cancel();
      _debounce = Timer(
        const Duration(milliseconds: 600),
        () => refresh(analytics: analytics),
      );
    }, onError: (Object e) => debugPrint('HomeWidgetService stream error: $e'));
  }

  static Future<void> stop() async {
    _debounce?.cancel();
    await _sub?.cancel();
    _sub = null;
  }

  /// Privacy switch: the widget is visible without the app PIN, so let the
  /// user hide the amounts (shows •••• instead). Wire this to a settings tile.
  static Future<void> setHideAmounts(bool hide) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hideAmountsKey, hide);
    await refresh();
  }

  static Future<bool> isHidingAmounts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hideAmountsKey) ?? false;
  }

  static Future<void> refresh({Map<String, num>? analytics}) async {
    try {
      final Map<String, num> a =
          analytics ?? await BackEnd.watchAnalyticsData().first;
      final Map<String, dynamic> today = await BackEnd.fetchTodayChartData();
      final List<Map<String, dynamic>> weekly =
          await BackEnd.fetchWeeklyChartData();
      final User user = await UserBackEnd.fetchUserData();
      final bool hide = await isHidingAmounts();

      final num recVal = (today['received'] as num?) ?? 0;
      final num disbVal = (today['disbursed'] as num?) ?? 0;

      final String weeklyReceived =
          weekly.map((d) => (d['received'] as num?) ?? 0).join(',');
      final String weeklyDisbursed =
          weekly.map((d) => (d['disbursed'] as num?) ?? 0).join(',');
      final String weeklyDays = weekly.map((d) {
        final String m = d['month'] as String? ?? '';
        return m.isNotEmpty ? m[0] : '';
      }).join(',');

      String money(num v) =>
          hide ? '••••' : Utility.compactNumber(v.toDouble());

      final DateTime now = DateTime.now();

      // Everything is saved as String so Android and iOS read it the same way.
      await Future.wait<bool?>([
        HomeWidget.saveWidgetData<String>('currency', user.userCurrency),
        HomeWidget.saveWidgetData<String>(
          'date',
          DateFormat('yyyy-MM-dd').format(now),
        ),
        HomeWidget.saveWidgetData<String>(
          'updated',
          DateFormat('HH:mm').format(now),
        ),
        HomeWidget.saveWidgetData<String>('today_received', money(recVal)),
        HomeWidget.saveWidgetData<String>('today_disbursed', money(disbVal)),
        HomeWidget.saveWidgetData<String>(
          'today_received_raw',
          recVal.toString(),
        ),
        HomeWidget.saveWidgetData<String>(
          'today_disbursed_raw',
          disbVal.toString(),
        ),
        HomeWidget.saveWidgetData<String>(
          'weekly_received',
          hide ? '' : weeklyReceived,
        ),
        HomeWidget.saveWidgetData<String>(
          'weekly_disbursed',
          hide ? '' : weeklyDisbursed,
        ),
        HomeWidget.saveWidgetData<String>(
          'weekly_days',
          hide ? '' : weeklyDays,
        ),
        HomeWidget.saveWidgetData<String>(
          'outstanding',
          money(a['outstandingAmount'] ?? 0),
        ),
        HomeWidget.saveWidgetData<String>(
          'active_loans',
          (a['activeLoans'] ?? 0).toInt().toString(),
        ),
      ]);

      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );
    } catch (e, st) {
      debugPrint('HomeWidgetService.refresh failed: $e\n$st');
    }
  }
}
