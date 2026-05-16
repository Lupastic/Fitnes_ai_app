import 'package:flutter/material.dart';
import '../services/notification_service.dart' as ns;

class NotificationProvider extends ChangeNotifier {
  ns.NotificationSettings _settings = const ns.NotificationSettings();
  bool _isLoading = true;

  ns.NotificationSettings get settings => _settings;
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
    await ns.NotificationService().requestPermissions();
    notifyListeners();
  }

  Future<void> updateSettings(ns.NotificationSettings newSettings) async {
    _settings = newSettings;
    await _settings.save();
    await _rescheduleAll();
    notifyListeners();
  }

  Future<void> _rescheduleAll() async {
    final svc = ns.NotificationService();

    if (_settings.waterEnabled) {
      await svc.scheduleWaterReminder(_settings.waterTime.hour, _settings.waterTime.minute);
    } else {
      await svc.cancel(ns.NotificationIds.water);
    }

    if (_settings.stepsEnabled) {
      await svc.scheduleStepsReminder(_settings.stepsTime.hour, _settings.stepsTime.minute);
    } else {
      await svc.cancel(ns.NotificationIds.steps);
    }

    if (_settings.sleepEnabled) {
      await svc.scheduleSleepReminder(_settings.sleepTime.hour, _settings.sleepTime.minute);
    } else {
      await svc.cancel(ns.NotificationIds.sleep);
    }

    if (_settings.caloriesEnabled) {
      await svc.scheduleCaloriesReminder(_settings.caloriesTime.hour, _settings.caloriesTime.minute);
    } else {
      await svc.cancel(ns.NotificationIds.calories);
    }

    if (_settings.summaryEnabled) {
      await svc.scheduleDailySummary(_settings.summaryTime.hour, _settings.summaryTime.minute);
    } else {
      await svc.cancel(ns.NotificationIds.dailySummary);
    }
  }

  Future<void> showGoalAchieved(String name) async {
    await ns.NotificationService().showInstant(
      id: 100,
      title: '🏆 Goal reached!',
      body: "You've completed your $name goal for today. Amazing!",
    );
  }
}