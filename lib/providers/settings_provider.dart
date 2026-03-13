// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/settings_repository.dart';
import '../services/user_data_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository repo;
  final UserDataService _userDataService;

  String _name = '';
  Map<String, int> _goals = {};
  Locale? _locale; // Инициализируем null, чтобы загрузить из настроек/репозитория

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  static const String _defaultName = 'Гость'; // Установил "Гость" как дефолт
  static const Map<String, int> _defaultGoals = {
    'water': 8,
    'steps': 10000, // Вернул 10000 как в репозитории
    'sleep': 8,
  };

  SettingsProvider(this.repo, this._userDataService) {
    _name = repo.name;
    _goals = Map.from(repo.goals.isNotEmpty ? repo.goals : _defaultGoals);
    _locale = Locale(repo.prefs.getString('languageCode') ?? 'en'); // Загружаем локаль из репозитория
  }

  // ─── Getters ───
  String get name => _name;
  Map<String, int> get goals => _goals;
  Locale? get locale => _locale;

  // ─── Update Language ───
  Future<void> updateLanguage(Locale newLocale) async { // Сделал Future<void>
    _locale = newLocale;
    notifyListeners();
    await repo.prefs.setString('languageCode', newLocale.languageCode); // Сохраняем локально
    await _saveAllCurrentSettingsToFirebase(); // Сохраняем в Firebase
  }

  // ─── Load settings from Firebase ───
  Future<void> loadSettingsFromFirebase() async { // Удалены @override, так как не переопределяем
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Если пользователь не авторизован, загружаем из локального репозитория
      _name = repo.name.isNotEmpty ? repo.name : _defaultName;
      _goals = Map.from(repo.goals.isNotEmpty ? repo.goals : _defaultGoals);
      _locale = Locale(repo.prefs.getString('languageCode') ?? 'en');
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userDocRef = _userDataService.getUserDocRef();
      if (userDocRef != null) {
        final docSnapshot = await userDocRef.get();
        if (docSnapshot.exists && docSnapshot.data() != null) {
          final data = docSnapshot.data()! as Map<String, dynamic>; // Явное приведение
          _name = data['name'] as String? ?? _defaultName;

          final Map<String, dynamic>? goalsData = data['goals'] as Map<String, dynamic>?;
          if (goalsData != null) {
            _goals['water'] = (goalsData['water'] as num?)?.toInt() ?? _defaultGoals['water']!;
            _goals['steps'] = (goalsData['steps'] as num?)?.toInt() ?? _defaultGoals['steps']!;
            _goals['sleep'] = (goalsData['sleep'] as num?)?.toInt() ?? _defaultGoals['sleep']!;
          } else {
            _goals = Map.from(_defaultGoals); // Если целей в Firebase нет, используем дефолтные
          }

          _locale = Locale(data['language'] as String? ?? 'en'); // Явное приведение
          await repo.prefs.setString('languageCode', _locale!.languageCode);

        } else {
          // Если документ пользователя не существует в Firebase, инициализируем его дефолтными
          _name = _defaultName;
          _goals = Map.from(_defaultGoals);
          _locale = const Locale('en');
          await repo.prefs.setString('languageCode', _locale!.languageCode);
          await _saveAllCurrentSettingsToFirebase(); // Сохраняем дефолтные настройки в Firebase
        }
      }

      // Сохраняем загруженные настройки в локальный репозиторий
      await repo.setName(_name);
      for (var entry in _goals.entries) {
        await repo.setGoal(entry.key, entry.value);
      }

    } catch (e) {
      print("Error loading settings from Firebase: $e");
      // В случае ошибки Firebase, загружаем из локального репозитория как запасной вариант
      _name = repo.name.isNotEmpty ? repo.name : _defaultName;
      _goals = Map.from(repo.goals.isNotEmpty ? repo.goals : _defaultGoals);
      _locale = Locale(repo.prefs.getString('languageCode') ?? 'en');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // ─── Update name ───
  Future<void> updateName(String newName) async { // Удалены @override
    _name = newName;
    await repo.setName(newName);
    notifyListeners();
    await _userDataService.updateProfileData(name: newName);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != newName) {
      try {
        await user.updateDisplayName(newName);
        // await user.reload(); // reload может быть не нужен, если displayName сразу обновляется
      } catch (e) {
        print("Error updating display name: $e");
      }
    }
  }

  // ─── Update a challenge goal ───
  Future<void> updateGoal(String id, int value) async { // Удалены @override
    _goals[id] = value;
    await repo.setGoal(id, value);
    notifyListeners();
    // Отправляем всю обновленную мапу целей, так как Firestore `set` с `merge: true`
    // будет только обновлять конкретные поля, а не всю мапу.
    // Если нужно обновить только одно поле, надо по-другому формировать Map.
    // Сейчас goals: _goals корректно для updateProfileData
    await _userDataService.updateProfileData(goals: _goals);
  }

  // ─── Reset all settings ───
  Future<void> resetSettingsToDefaults() async { // Удалены @override
    _name = _defaultName;
    _goals = Map.from(_defaultGoals);
    _locale = const Locale('en'); // Сбрасываем локаль на английский

    await repo.setName(_name);
    for (var entry in _goals.entries) {
      await repo.setGoal(entry.key, entry.value);
    }
    await repo.prefs.setString('languageCode', _locale!.languageCode);

    notifyListeners();
    await _saveAllCurrentSettingsToFirebase();
  }

  // ─── Save everything to Firebase ───
  Future<void> _saveAllCurrentSettingsToFirebase() async {
    await _userDataService.updateProfileData(
      name: _name,
      goals: _goals,
      languageCode: _locale?.languageCode,
    );
  }

  // ─── Reset only goals ───
  Future<void> resetGoals() async { // Удалены @override
    _goals = Map.from(_defaultGoals);
    for (var entry in _goals.entries) {
      await repo.setGoal(entry.key, entry.value);
    }
    notifyListeners();
    await _userDataService.updateProfileData(goals: _defaultGoals);
  }
}