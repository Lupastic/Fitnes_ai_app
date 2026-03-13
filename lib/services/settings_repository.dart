// lib/services/settings_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _kNameKey = 'userName';
  static const _kGoalsKey = 'goals';           // {"water":8,"steps":10000}

  final SharedPreferences prefs;
  SettingsRepository(this.prefs);

  String get name => prefs.getString(_kNameKey) ?? 'Гость';
  Future<void> setName(String v) => prefs.setString(_kNameKey, v);

  Map<String, int> get goals {
    try {
      final String? goalsString = prefs.getString(_kGoalsKey);
      if (goalsString != null && goalsString.isNotEmpty) {
        return (json.decode(goalsString) as Map<String, dynamic>).cast<String, int>();
      }
    } catch (e) {
      print("Error decoding goals from SharedPreferences: $e");
    }
    return {}; // Возвращаем пустую мапу по умолчанию при ошибке или отсутствии данных
  }

  Future<void> setGoal(String id, int val) {
    final Map<String, int> currentGoals = Map.from(goals); // Получаем текущие цели
    currentGoals[id] = val; // Обновляем или добавляем новую
    return prefs.setString(_kGoalsKey, json.encode(currentGoals));
  }
}