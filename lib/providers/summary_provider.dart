import 'package:flutter/foundation.dart';
import '../services/local_repository.dart';
import '../services/user_data_service.dart';
import '../models/daily_summary.dart';

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
    // Проверка на смену дня: если дата в _today не совпадает с текущей, загружаем новый день
    final now = DateTime.now();
    if (_today.date.year != now.year || 
        _today.date.month != now.month || 
        _today.date.day != now.day) {
      _loadToday();
      // Уведомляем слушателей о сбросе данных в интерфейсе
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
    // Используем геттер today для актуализации даты перед обновлением
    final currentToday = today;

    _today = DailySummary(
      date: currentToday.date,
      waterCups: add ? (currentToday.waterCups + (water ?? 0)) : (water ?? currentToday.waterCups),
      sleepHours: add ? (currentToday.sleepHours + (sleep ?? 0.0)) : (sleep ?? currentToday.sleepHours),
      calories: add ? (currentToday.calories + (cal ?? 0)) : (cal ?? currentToday.calories),
      steps: add ? (currentToday.steps + (steps ?? 0)) : (steps ?? currentToday.steps),
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
