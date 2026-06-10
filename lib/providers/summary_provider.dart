import 'package:flutter/foundation.dart';
import '../services/local_repository.dart';
import '../services/user_data_service.dart';
import '../models/daily_summary.dart';
import 'dart:developer' as developer;

class SummaryProvider with ChangeNotifier {
  final LocalRepository _repo;
  final UserDataService _userDataService = UserDataService();
  late DailySummary _today;

  SummaryProvider(this._repo) {
    _loadToday();
  }

  void _loadToday() {
    _today = _repo.getToday() ??
        DailySummary(
          date: DateTime.now(),
          waterCups: 0,
          sleepHours: 0,
          calories: 0,
          steps: 0,
        );
  }

  DailySummary get today {
    final now = DateTime.now();
    if (_today.date.year != now.year || 
        _today.date.month != now.month || 
        _today.date.day != now.day) {
      _loadToday();
      Future.microtask(() => notifyListeners());
    }
    return _today;
  }

  void reset() {
    _loadToday();
    notifyListeners();
  }

  Future<void> syncFromFirebase() async {
    try {
      final remoteSummary = await _userDataService.getDailySummary(DateTime.now());
      if (remoteSummary != null) {
        _today = remoteSummary;
        await _repo.save(_today);
        notifyListeners();
        debugPrint("Successfully synced today's data from Firebase");
      }
    } catch (e) {
      debugPrint("Error syncing from Firebase: $e");
    }
  }

  void update({
    int? water,
    double? sleep,
    int? cal,
    int? steps,
    int? yoga,
    double? running,
    bool add = false,
  }) async {
    // Ensure we are working with the freshest data
    final currentToday = today;

    int newSteps = add ? (currentToday.steps + (steps ?? 0)) : (steps ?? currentToday.steps);
    
    // Safety check: steps shouldn't decrease during the same day unless explicit reset
    if (!add && steps != null && steps < currentToday.steps && steps != 0) {
       developer.log("⚠️ Warning: Attempted to set steps to $steps which is less than current ${currentToday.steps}", name: "SummaryProvider");
    }

    _today = DailySummary(
      date: currentToday.date,
      waterCups: add ? (currentToday.waterCups + (water ?? 0)) : (water ?? currentToday.waterCups),
      sleepHours: add ? (currentToday.sleepHours + (sleep ?? 0.0)) : (sleep ?? currentToday.sleepHours),
      calories: add ? (currentToday.calories + (cal ?? 0)) : (cal ?? currentToday.calories),
      steps: newSteps,
      yogaSessions: add ? (currentToday.yogaSessions + (yoga ?? 0)) : (yoga ?? currentToday.yogaSessions),
      runningKm: add ? (currentToday.runningKm + (running ?? 0.0)) : (running ?? currentToday.runningKm),
      synced: false,
    );
    
    await _repo.save(_today);
    notifyListeners();

    try {
      await _userDataService.saveDailySummary(_today);
      _today.synced = true;
      await _repo.save(_today);
    } catch (e) {
      debugPrint("Auto-sync failed: $e");
    }
  }
}
