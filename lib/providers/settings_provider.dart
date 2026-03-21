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
  Locale? _locale;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SettingsProvider(this.repo, this._userDataService) {
    _name = repo.name;
    _goals = Map.from(repo.goals.isNotEmpty ? repo.goals : {'water': 8, 'steps': 10000, 'sleep': 8, 'calories': 2000});
    _selectedChallengeIds = repo.prefs.getStringList('selectedChallenges') ?? ['water', 'steps', 'sleep', 'calories'];
    _locale = Locale(repo.prefs.getString('languageCode') ?? 'en');
  }

  String get name => _name;
  Map<String, int> get goals => _goals;
  List<String> get selectedChallengeIds => _selectedChallengeIds;
  Locale? get locale => _locale;

  Future<void> toggleChallenge(String id) async {
    if (_selectedChallengeIds.contains(id)) {
      _selectedChallengeIds.remove(id);
    } else {
      _selectedChallengeIds.add(id);
    }
    notifyListeners();
    // Сохраняем ЛОКАЛЬНО
    await repo.prefs.setStringList('selectedChallenges', _selectedChallengeIds);
    // Синхронизируем с FIREBASE
    await _userDataService.updateProfileData(selectedChallenges: _selectedChallengeIds);
  }

  Future<void> updateName(String newName) async {
    _name = newName;
    notifyListeners();
    await repo.setName(newName);
    await _userDataService.updateProfileData(name: newName);
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
        
        // Загружаем имя
        _name = data['name'] ?? _name;
        
        // Загружаем выбранные челленджи
        if (data['selectedChallenges'] != null) {
          _selectedChallengeIds = List<String>.from(data['selectedChallenges']);
          await repo.prefs.setStringList('selectedChallenges', _selectedChallengeIds);
        }
        
        notifyListeners();
      }
    } catch (e) {
      print("Error loading settings from FB: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}