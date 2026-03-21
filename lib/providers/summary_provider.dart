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
    // Сначала берем локально
    _today = _repo.getToday() ??
        DailySummary(
          date: DateTime.now(),
          waterCups: 0,
          sleepHours: 0,
          calories: 0,
          steps: 0,
        );
  }

  DailySummary get today => _today;

  // НОВЫЙ МЕТОД: Синхронизация с облаком при запуске
  Future<void> syncFromFirebase() async {
    try {
      final remoteSummary = await _userDataService.getDailySummary(DateTime.now());
      if (remoteSummary != null) {
        // Если в облаке данных больше (или они новее), обновляем локально
        _today = remoteSummary;
        await _repo.save(_today);
        notifyListeners();
        debugPrint("Successfully synced today's data from Firebase");
      }
    } catch (e) {
      debugPrint("Error syncing from Firebase: $e");
    }
  }

  void update({int? water, double? sleep, int? cal, int? steps, bool add = false}) async {
    _today = DailySummary(
      date: _today.date,
      waterCups: add ? (_today.waterCups + (water ?? 0)) : (water ?? _today.waterCups),
      sleepHours: add ? (_today.sleepHours + (sleep ?? 0)) : (sleep ?? _today.sleepHours),
      calories: add ? (_today.calories + (cal ?? 0)) : (cal ?? _today.calories),
      steps: add ? (_today.steps + (steps ?? 0)) : (steps ?? _today.steps),
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