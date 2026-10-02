import 'dart:async';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    // initializeTimeZones() MUST run on the main isolate — it populates a
    // global in-memory timezone database. Running it via compute() would
    // initialise the DB in the spawned isolate's memory, leaving the main
    // isolate with an empty DB and crashing tz.getLocation() below.
    tz.initializeTimeZones();

    try {
      final TimezoneInfo currentTimeZone =
          await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidInit = AndroidInitializationSettings(
      '@drawable/ic_launcher_foreground',
    );
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      
    );

    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    // Android 13+ permission (recommended)
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        notificationPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidPlugin?.requestNotificationsPermission();

    await notificationPlugin.initialize(settings: settings);

    _isInitialized = true;

    // Schedule daily reminders off the critical startup path — these don't
    // need to complete before the first frame is rendered.
    _scheduleDailyNotificationsInBackground();
  }

  /// Fires all daily scheduled notifications without blocking the caller.
  void _scheduleDailyNotificationsInBackground() {
    //At 6am
    unawaited(scheduleNotification(
      id: 101,
      title: "💰 Daily Finance Reminder",
      body: getTodaysQuote(),
      hr: 06,
      min: 00,
    ));

    //At 9am
    unawaited(scheduleNotification(
      id: 102,
      title: "Analatics",
      body: "Do you want to check how much you made it Yesterday 💸",
      hr: 09,
      min: 00,
    ));

    //At 2pm
    unawaited(scheduleNotification(
      id: 103,
      title: "💰 Daily Finance Reminder",
      body: getTodaysQuote(),
      hr: 14,
      min: 0,
    ));

    //At 6pm
    unawaited(scheduleNotification(
      id: 104,
      title: "💰 Daily Finance Reminder",
      body: getTodaysQuote(),
      hr: 18,
      min: 0,
    ));

    // At 8pm
    unawaited(scheduleNotification(
      id: 105,
      title: "Analatics",
      body: "Do you want to check how much you made it today 🏆",
      hr: 20,
      min: 00,
    ));
  }


  static String getTodaysQuote() {
    final DateTime now = DateTime.now();
    final int seed = now.year * 10000 + now.month * 100 + now.day;
    final int index = Random(seed).nextInt(Constant.dailyQuotes.length);
    return Constant.dailyQuotes[index];
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    await initNotification();

    await notificationPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _notificationDetails(),
    );
  }

  Future<void> scheduleNotification({
    int id = 0,
    required String title,
    required String body,
    required int hr,
    required int min,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hr,
      min,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await notificationPlugin.zonedSchedule(
      title: title,
      body: body,
      id: id,
      scheduledDate: scheduledDate,
      notificationDetails: _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // cancel all notifications
  Future<void> cancelAllNotifications() async {
    await notificationPlugin.cancelAll();
    _isInitialized = false;
  }

  Future<void> scheduleTransactionDueReminder({
    required int transactionId,
    required String customerName,
    required DateTime dueDate,
  }) async {
    if (!_isInitialized) {
      await initNotification();
    }
    // Cancel any existing reminder for this transaction first
    await cancelTransactionReminder(transactionId: transactionId);

    final now = tz.TZDateTime.now(tz.local);

    // ── On due date ────────────────────────────────────────────────
    final onDueDate = tz.TZDateTime(
      tz.local,
      dueDate.year,
      dueDate.month,
      dueDate.day,
      8,
    );

    if (onDueDate.isAfter(now)) {
      await notificationPlugin.zonedSchedule(
        id: _reminderIdBase(transactionId, 2),
        notificationDetails: _notificationDetails(),
        title: '🔴 Loan Due Today',
        body:
            '$customerName\'s loan payment is due today. Please collect payment.',
        scheduledDate: onDueDate,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  // Generates unique notification IDs per transaction
  // transactionId * 10 + slot (0, 1, 2)
  // e.g. transactionId=5 → IDs 50, 51, 52
  int _reminderIdBase(int transactionId, int slot) {
    return (transactionId * 10) + slot;
  }

  Future<void> cancelTransactionReminder({required int transactionId}) async {
    await notificationPlugin.cancel(id: _reminderIdBase(transactionId, 2));
  }
}
