import 'package:hive/hive.dart';
import '../models/daily_summary.dart';

class LocalRepository {
  static const _boxName = 'dailyBox';
  late final Box<DailySummary> _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<DailySummary>(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
  }

  DailySummary? getToday() {
    return _box.get(_dateKey(DateTime.now()));
  }

  List<DailySummary> getLastDays(int days) {
    final now = DateTime.now();
    List<DailySummary> history = [];
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final summary = _box.get(_dateKey(date));
      if (summary != null) {
        history.add(summary);
      }
    }
    return history;
  }

  Future<void> save(DailySummary summary) async {
    await _box.put(_dateKey(summary.date), summary);
  }

  Future<void> clearAll() async {
    // Очищаем основную коробку
    await _box.clear();
    
    // Безопасно очищаем коробку истории, если она открыта
    try {
      if (Hive.isBoxOpen('history')) {
        await Hive.box('history').clear();
      } else {
        // Если не открыта, просто удаляем с диска (на всякий случай)
        await Hive.deleteBoxFromDisk('history');
      }
    } catch (e) {
      print("Error clearing history box: $e");
      // Если не получилось очистить через Box, пробуем удалить файл
      await Hive.deleteBoxFromDisk('history').catchError((_){});
    }
  }

  List<DailySummary> unsynced() =>
      _box.values.where((e) => !e.synced).toList();

  String _dateKey(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }
}
