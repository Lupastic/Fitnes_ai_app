// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Или ThemeMode.light как дефолт

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  // Загружаем сохраненную тему
  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  // Переключаем тему
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    _saveThemeMode(_themeMode);
    notifyListeners();
  }

  // Устанавливаем конкретную тему (если это нужно)
  void setTheme(ThemeMode mode) {
    if (_themeMode == mode) return; // Нет изменений
    _themeMode = mode;
    _saveThemeMode(mode);
    notifyListeners();
  }

  // Сохраняем тему
  void _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', mode.index);
  }
}