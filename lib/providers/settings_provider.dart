import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/settings_repository.dart';
import '../services/user_data_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository repo;
  final UserDataService _userDataService;

  String _name = '';
  Map<String, int> _goals = {};
  List<String> _selectedChallengeIds = ['water', 'steps', 'sleep', 'calories'];
  List<String> _completedQuests = []; 
  int _points = 0;
  Locale? _locale;

  // Поля онбординга
  double? _weight;
  String? _weightUnit;
  double? _height;
  String? _heightUnit;
  int? _age;
  String? _goalType;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SettingsProvider(this.repo, this._userDataService) {
    _init();
  }

  void _init() {
    _name = repo.name;
    _goals = Map.from(repo.goals.isNotEmpty ? repo.goals : {'water': 8, 'steps': 10000, 'sleep': 8, 'calories': 2000});
    _selectedChallengeIds = repo.prefs.getStringList('selectedChallenges') ?? ['water', 'steps', 'sleep', 'calories'];
    _completedQuests = repo.prefs.getStringList('completedQuests') ?? [];
    _points = repo.prefs.getInt('points') ?? 0;
    _locale = Locale(repo.prefs.getString('languageCode') ?? 'en');
    
    _weight = null;
    _height = null;
    _age = null;
    _goalType = null;
  }

  void reset() {
    _init();
    notifyListeners();
  }

  String get name => _name;
  Map<String, int> get goals => _goals;
  List<String> get selectedChallengeIds => _selectedChallengeIds;
  List<String> get completedQuests => _completedQuests;
  int get points => _points;
  Locale? get locale => _locale;

  double? get weight => _weight;
  String? get weightUnit => _weightUnit;
  double? get height => _height;
  String? get heightUnit => _heightUnit;
  int? get age => _age;
  String? get goalType => _goalType;

  bool get isProfileComplete => _goalType != null && _goalType!.isNotEmpty;

  // Метод для смены языка с сохранением в Firebase
  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners();
    
    // Сохраняем локально
    await repo.prefs.setString('languageCode', languageCode);
    
    // Сохраняем в облако
    try {
      await _userDataService.updateProfileData(languageCode: languageCode);
    } catch (e) {
      debugPrint("❌ Error syncing language to Firebase: $e");
    }
  }

  Future<void> toggleChallenge(String id) async {
    if (_selectedChallengeIds.contains(id)) {
      _selectedChallengeIds.remove(id);
    } else {
      _selectedChallengeIds.add(id);
    }
    notifyListeners();
    await repo.prefs.setStringList('selectedChallenges', _selectedChallengeIds);
    await _userDataService.updateProfileData(selectedChallenges: _selectedChallengeIds);
  }

  Future<void> updateGoal(String id, int value) async {
    _goals[id] = value;
    notifyListeners();
    await repo.setGoal(id, value);
    await _userDataService.updateProfileData(goals: _goals);
  }

  Future<void> completeQuest(String id, int pointsToAdd) async {
    if (!_completedQuests.contains(id)) {
      _completedQuests.add(id);
      _points += pointsToAdd;
      notifyListeners();
      await repo.prefs.setStringList('completedQuests', _completedQuests);
      await repo.prefs.setInt('points', _points);
      try {
        await _userDataService.updateProfileData(
          completedQuests: _completedQuests,
          points: _points,
        );
      } catch (e) {
        print("❌ Error syncing quest $id: $e");
      }
    }
  }

  Future<void> loadSettingsFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final doc = await _userDataService.getUserDocRef()?.get();
      if (doc != null && doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        _name = data['name'] ?? _name;
        
        // Загружаем язык из Firebase
        if (data['languageCode'] != null) {
          final lang = data['languageCode'] as String;
          _locale = Locale(lang);
          await repo.prefs.setString('languageCode', lang);
        }

        if (data['goals'] != null) {
          _goals = Map<String, int>.from(data['goals']);
          for (var entry in _goals.entries) {
            await repo.setGoal(entry.key, entry.value);
          }
        }

        if (data['selectedChallenges'] != null) {
          _selectedChallengeIds = List<String>.from(data['selectedChallenges']);
          await repo.prefs.setStringList('selectedChallenges', _selectedChallengeIds);
        }

        if (data['completedQuests'] != null) {
          _completedQuests = List<String>.from(data['completedQuests']);
          await repo.prefs.setStringList('completedQuests', _completedQuests);
        }
        
        if (data['points'] != null) {
          _points = data['points'] as int;
          await repo.prefs.setInt('points', _points);
        }

        _weight = (data['weight'] as num?)?.toDouble();
        _weightUnit = data['weightUnit'];
        _height = (data['height'] as num?)?.toDouble();
        _heightUnit = data['heightUnit'];
        _age = data['age'] as int?;
        _goalType = data['goalType'];
        
        notifyListeners();
      }
    } catch (e) {
      print("❌ Error loading settings from FB: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateName(String newName) async {
    _name = newName;
    notifyListeners();
    await repo.setName(newName);
    await _userDataService.updateProfileData(name: newName);
  }
}
