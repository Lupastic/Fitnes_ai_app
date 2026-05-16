import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationIds {
  static const int water = 1;
  static const int steps = 2;
  static const int sleep = 3;
  static const int calories = 4;
  static const int dailySummary = 5;
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    bool? a = await android?.requestNotificationsPermission();
    bool? i = await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return (a ?? true) || (i ?? true);
  }

  NotificationDetails _details(String channelId, String channelName) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId, channelName,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true, presentSound: true, presentBadge: true,
      ),
    );
  }

  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();
    await _plugin.show(id, title, body,
        _details('instant_channel', 'Instant Notifications'), payload: payload);
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    await init();
    await _plugin.zonedSchedule(
      id, title, body,
      _nextInstanceOfTime(hour, minute),
      _details('reminder_channel', 'Daily Reminders'),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> cancel(int id) async => _plugin.cancel(id);
  Future<void> cancelAll() async => _plugin.cancelAll();

  Future<void> scheduleWaterReminder(int h, int m) => scheduleDailyReminder(
      id: NotificationIds.water,
      title: '💧 Time to hydrate!',
      body: 'Have you had your water today?',
      hour: h, minute: m, payload: 'water');

  Future<void> scheduleStepsReminder(int h, int m) => scheduleDailyReminder(
      id: NotificationIds.steps,
      title: '🏃 Move it!',
      body: 'Check your step count and keep moving!',
      hour: h, minute: m, payload: 'steps');

  Future<void> scheduleSleepReminder(int h, int m) => scheduleDailyReminder(
      id: NotificationIds.sleep,
      title: '😴 Bedtime reminder',
      body: 'Time to wind down. Good sleep is key!',
      hour: h, minute: m, payload: 'sleep');

  Future<void> scheduleCaloriesReminder(int h, int m) => scheduleDailyReminder(
      id: NotificationIds.calories,
      title: '🍎 Log your meals!',
      body: "Don't forget to track your calories for today.",
      hour: h, minute: m, payload: 'calories');

  Future<void> scheduleDailySummary(int h, int m) => scheduleDailyReminder(
      id: NotificationIds.dailySummary,
      title: '📊 Daily Summary',
      body: 'Check your activity summary for today!',
      hour: h, minute: m, payload: 'summary');
}

class NotificationSettings {
  final bool waterEnabled;
  final TimeOfDay waterTime;
  final bool stepsEnabled;
  final TimeOfDay stepsTime;
  final bool sleepEnabled;
  final TimeOfDay sleepTime;
  final bool caloriesEnabled;
  final TimeOfDay caloriesTime;
  final bool summaryEnabled;
  final TimeOfDay summaryTime;

  const NotificationSettings({
    this.waterEnabled = false,
    this.waterTime = const TimeOfDay(hour: 9, minute: 0),
    this.stepsEnabled = false,
    this.stepsTime = const TimeOfDay(hour: 12, minute: 0),
    this.sleepEnabled = false,
    this.sleepTime = const TimeOfDay(hour: 22, minute: 0),
    this.caloriesEnabled = false,
    this.caloriesTime = const TimeOfDay(hour: 13, minute: 0),
    this.summaryEnabled = false,
    this.summaryTime = const TimeOfDay(hour: 21, minute: 0),
  });

  NotificationSettings copyWith({
    bool? waterEnabled, TimeOfDay? waterTime,
    bool? stepsEnabled, TimeOfDay? stepsTime,
    bool? sleepEnabled, TimeOfDay? sleepTime,
    bool? caloriesEnabled, TimeOfDay? caloriesTime,
    bool? summaryEnabled, TimeOfDay? summaryTime,
  }) => NotificationSettings(
    waterEnabled: waterEnabled ?? this.waterEnabled,
    waterTime: waterTime ?? this.waterTime,
    stepsEnabled: stepsEnabled ?? this.stepsEnabled,
    stepsTime: stepsTime ?? this.stepsTime,
    sleepEnabled: sleepEnabled ?? this.sleepEnabled,
    sleepTime: sleepTime ?? this.sleepTime,
    caloriesEnabled: caloriesEnabled ?? this.caloriesEnabled,
    caloriesTime: caloriesTime ?? this.caloriesTime,
    summaryEnabled: summaryEnabled ?? this.summaryEnabled,
    summaryTime: summaryTime ?? this.summaryTime,
  );

  static Future<NotificationSettings> load() async {
    final p = await SharedPreferences.getInstance();
    return NotificationSettings(
      waterEnabled: p.getBool('notif_water_enabled') ?? false,
      waterTime: _t(p, 'notif_water', 9, 0),
      stepsEnabled: p.getBool('notif_steps_enabled') ?? false,
      stepsTime: _t(p, 'notif_steps', 12, 0),
      sleepEnabled: p.getBool('notif_sleep_enabled') ?? false,
      sleepTime: _t(p, 'notif_sleep', 22, 0),
      caloriesEnabled: p.getBool('notif_calories_enabled') ?? false,
      caloriesTime: _t(p, 'notif_calories', 13, 0),
      summaryEnabled: p.getBool('notif_summary_enabled') ?? false,
      summaryTime: _t(p, 'notif_summary', 21, 0),
    );
  }

  static TimeOfDay _t(SharedPreferences p, String k, int dh, int dm) =>
      TimeOfDay(hour: p.getInt('${k}_hour') ?? dh, minute: p.getInt('${k}_minute') ?? dm);

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('notif_water_enabled', waterEnabled);
    await _st(p, 'notif_water', waterTime);
    await p.setBool('notif_steps_enabled', stepsEnabled);
    await _st(p, 'notif_steps', stepsTime);
    await p.setBool('notif_sleep_enabled', sleepEnabled);
    await _st(p, 'notif_sleep', sleepTime);
    await p.setBool('notif_calories_enabled', caloriesEnabled);
    await _st(p, 'notif_calories', caloriesTime);
    await p.setBool('notif_summary_enabled', summaryEnabled);
    await _st(p, 'notif_summary', summaryTime);
  }

  static Future<void> _st(SharedPreferences p, String k, TimeOfDay t) async {
    await p.setInt('${k}_hour', t.hour);
    await p.setInt('${k}_minute', t.minute);
  }
}