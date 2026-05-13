import 'package:flutter/material.dart';
import '../services/notification_service.dart' as ns;

class NotificationProvider extends ChangeNotifier {
  ns.NotificationSettings _settings = const ns.NotificationSettings();
  bool _permissionGranted = false;
  bool _isLoading = true;

  ns.NotificationSettings get settings => _settings;
  bool get permissionGranted => _permissionGranted;
  bool get isLoading => _isLoading;

  NotificationProvider() {
    _init();
  }

  Future<void> _init() async {
    await ns.NotificationService().init();
    _settings = await ns.NotificationSettings.load();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> requestPermissions() async {
    _permissionGranted = await ns.NotificationService().requestPermissions();
    notifyListeners();
  }

  /// Обновить настройки и сразу перепланировать/отменить нужные уведомления
  Future<void> updateSettings(ns.NotificationSettings newSettings) async {
    _settings = newSettings;
    await _settings.save();
    await _rescheduleAll();
    notifyListeners();
  }

  Future<void> _rescheduleAll() async {
    final svc = ns.NotificationService();

    // Water
    if (_settings.waterEnabled) {
      await svc.scheduleWaterReminder(
          _settings.waterTime.hour, _settings.waterTime.minute);
    } else {
      await svc.cancel(ns.NotificationIds.water);
    }

    // Steps
    if (_settings.stepsEnabled) {
      await svc.scheduleStepsReminder(
          _settings.stepsTime.hour, _settings.stepsTime.minute);
    } else {
      await svc.cancel(ns.NotificationIds.steps);
    }

    // Sleep
    if (_settings.sleepEnabled) {
      await svc.scheduleSleepReminder(
          _settings.sleepTime.hour, _settings.sleepTime.minute);
    } else {
      await svc.cancel(ns.NotificationIds.sleep);
    }

    // Calories
    if (_settings.caloriesEnabled) {
      await svc.scheduleCaloriesReminder(
          _settings.caloriesTime.hour, _settings.caloriesTime.minute);
    } else {
      await svc.cancel(ns.NotificationIds.calories);
    }

    // Daily summary
    if (_settings.summaryEnabled) {
      await svc.scheduleDailySummary(
          _settings.summaryTime.hour, _settings.summaryTime.minute);
    } else {
      await svc.cancel(ns.NotificationIds.dailySummary);
    }
  }

  /// Показать мгновенное уведомление о достижении цели
  Future<void> showGoalAchieved(String challengeId, String challengeName) async {
    await ns.NotificationService().showInstant(
      id: 100,
      title: '🏆 Goal reached!',
      body: 'You\'ve completed your $challengeName goal for today. Amazing!',
      payload: challengeId,
    );
  }
}