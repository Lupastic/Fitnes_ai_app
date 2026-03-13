// lib/services/local_repository.dart
import 'package:hive/hive.dart';
import '../models/daily_summary.dart';

class LocalRepository {
  static const _boxName = 'dailyBox';
  late final Box<DailySummary> _box;

  Future<void> init() async {
    // Проверяем, открыта ли уже Box, чтобы избежать ошибки
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<DailySummary>(_boxName);
    } else {
      _box = Hive.box<DailySummary>(_boxName);
    }
  }

  DailySummary? getToday() {
    final key = _dateKey(DateTime.now());
    return _box.get(key);
  }

  Future<void> save(DailySummary summary) async =>
      _box.put(_dateKey(summary.date), summary);

  List<DailySummary> unsynced() =>
      _box.values.where((e) => !e.synced).toList();

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}