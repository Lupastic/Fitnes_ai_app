import 'package:hive/hive.dart';
import '../models/daily_summary.dart';

class LocalRepository {
  static const _boxName = 'dailyBox';
  late final Box<DailySummary> _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<DailySummary>(_boxName);
    } else {
      _box = Hive.box<DailySummary>(_boxName);
    }
  }

  DailySummary? getToday() {
    return _box.get(_dateKey(DateTime.now()));
  }

  Future<void> save(DailySummary summary) async {
    // Сохраняем всегда по ключу даты без времени
    await _box.put(_dateKey(summary.date), summary);
  }

  List<DailySummary> unsynced() =>
      _box.values.where((e) => !e.synced).toList();

  // Гарантируем формат ГГГГ-ММ-ДД (с ведущими нулями для сортировки)
  String _dateKey(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }
}