import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
 
/// IDs для каждого типа уведомлений
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
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);
 
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('📩 Notification tapped: ${details.payload}');
      },
    );
 
    _initialized = true;
    debugPrint('✅ NotificationService initialized');
  }
 
  Future<bool> requestPermissions() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
 
    bool? androidGranted = await androidPlugin?.requestNotificationsPermission();
    bool? iosGranted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
 
    return (androidGranted ?? true) || (iosGranted ?? true);
  }
 
  // ─── Детали канала (Android) ──────────────────────────────────────────────
 
  NotificationDetails _details({
    required String channelId,
    required String channelName,
    required String channelDesc,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) {
    final android = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: importance,
      priority: priority,
      icon: '@mipmap/ic_launcher',
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );
    return NotificationDetails(android: android, iOS: ios);
  }
 
  // ─── Немедленное уведомление (например, достижение цели) ─────────────────
 
  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();
    await _plugin.show(
      id,
      title,
      body,
      _details(
        channelId: 'instant_channel',
        channelName: 'Instant Notifications',
        channelDesc: 'Immediate alerts and achievements',
      ),
      payload: payload,
    );
  }
 
  // ─── Запланированное ежедневное уведомление ───────────────────────────────
 
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
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      _details(
        channelId: 'reminder_channel',
        channelName: 'Daily Reminders',
        channelDesc: 'Daily fitness reminders',
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
    debugPrint('🔔 Scheduled daily reminder "$title" at $hour:$minute');
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
 
  // ─── Отмена уведомлений ───────────────────────────────────────────────────
 
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
    debugPrint('🚫 Cancelled notification id=$id');
  }
 
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('🚫 All notifications cancelled');
  }
 
  // ─── Удобные методы для фитнес-напоминаний ────────────────────────────────
 
  Future<void> scheduleWaterReminder(int hour, int minute) =>
      scheduleDailyReminder(
        id: NotificationIds.water,
        title: '💧 Time to hydrate!',
        body: 'Have you had your water today? Stay on track with your goal!',
        hour: hour,
        minute: minute,
        payload: 'water',
      );
 
  Future<void> scheduleStepsReminder(int hour, int minute) =>
      scheduleDailyReminder(
        id: NotificationIds.steps,
        title: '🏃 Move it!',
        body: 'Check your step count and keep moving towards your daily goal!',
        hour: hour,
        minute: minute,
        payload: 'steps',
      );
 
  Future<void> scheduleSleepReminder(int hour, int minute) =>
      scheduleDailyReminder(
        id: NotificationIds.sleep,
        title: '😴 Bedtime reminder',
        body: 'Time to wind down. Good sleep is key to your fitness goals!',
        hour: hour,
        minute: minute,
        payload: 'sleep',
      );
 
  Future<void> scheduleCaloriesReminder(int hour, int minute) =>
      scheduleDailyReminder(
        id: NotificationIds.calories,
        title: '🍎 Log your meals!',
        body: 'Don\'t forget to track your calories for today.',
        hour: hour,
        minute: minute,
        payload: 'calories',
      );
 
  Future<void> scheduleDailySummary(int hour, int minute) =>
      scheduleDailyReminder(
        id: NotificationIds.dailySummary,
        title: '📊 Daily Summary',
        body: 'Check your activity summary for today. Great job staying active!',
        hour: hour,
        minute: minute,
        payload: 'summary',
      );
}
 
// ─── Настройки уведомлений (сохранение/загрузка) ─────────────────────────────
 
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
    bool? waterEnabled,
    TimeOfDay? waterTime,
    bool? stepsEnabled,
    TimeOfDay? stepsTime,
    bool? sleepEnabled,
    TimeOfDay? sleepTime,
    bool? caloriesEnabled,
    TimeOfDay? caloriesTime,
    bool? summaryEnabled,
    TimeOfDay? summaryTime,
  }) {
    return NotificationSettings(
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
  }
 
  static Future<NotificationSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationSettings(
      waterEnabled: prefs.getBool('notif_water_enabled') ?? false,
      waterTime: _loadTime(prefs, 'notif_water', 9, 0),
      stepsEnabled: prefs.getBool('notif_steps_enabled') ?? false,
      stepsTime: _loadTime(prefs, 'notif_steps', 12, 0),
      sleepEnabled: prefs.getBool('notif_sleep_enabled') ?? false,
      sleepTime: _loadTime(prefs, 'notif_sleep', 22, 0),
      caloriesEnabled: prefs.getBool('notif_calories_enabled') ?? false,
      caloriesTime: _loadTime(prefs, 'notif_calories', 13, 0),
      summaryEnabled: prefs.getBool('notif_summary_enabled') ?? false,
      summaryTime: _loadTime(prefs, 'notif_summary', 21, 0),
    );
  }
 
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_water_enabled', waterEnabled);
    await _saveTime(prefs, 'notif_water', waterTime);
    await prefs.setBool('notif_steps_enabled', stepsEnabled);
    await _saveTime(prefs, 'notif_steps', stepsTime);
    await prefs.setBool('notif_sleep_enabled', sleepEnabled);
    await _saveTime(prefs, 'notif_sleep', sleepTime);
    await prefs.setBool('notif_calories_enabled', caloriesEnabled);
    await _saveTime(prefs, 'notif_calories', caloriesTime);
    await prefs.setBool('notif_summary_enabled', summaryEnabled);
    await _saveTime(prefs, 'notif_summary', summaryTime);
  }
 
  static TimeOfDay _loadTime(
      SharedPreferences prefs, String key, int defH, int defM) {
    return TimeOfDay(
      hour: prefs.getInt('${key}_hour') ?? defH,
      minute: prefs.getInt('${key}_minute') ?? defM,
    );
  }
 
  static Future<void> _saveTime(
      SharedPreferences prefs, String key, TimeOfDay time) async {
    await prefs.setInt('${key}_hour', time.hour);
    await prefs.setInt('${key}_minute', time.minute);
  }
}
 