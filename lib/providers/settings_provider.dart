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
  List<String> _earnedAchievements = []; 
  Locale? _locale;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SettingsProvider(this.repo, this._userDataService) {
    _name = repo.name;
    _goals = Map.from(repo.goals.isNotEmpty ? repo.goals : {'water': 8, 'steps': 10000, 'sleep': 8, 'calories': 2000});
    _selectedChallengeIds = repo.prefs.getStringList('selectedChallenges') ?? ['water', 'steps', 'sleep', 'calories'];
    _earnedAchievements = repo.prefs.getStringList('earnedAchievements') ?? [];
    _locale = Locale(repo.prefs.getString('languageCode') ?? 'en');
    print("✅ SettingsProvider initialized. Local achievements: $_earnedAchievements");
  }

  String get name => _name;
  Map<String, int> get goals => _goals;
  List<String> get selectedChallengeIds => _selectedChallengeIds;
  List<String> get earnedAchievements => _earnedAchievements;
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

  Future<void> addAchievement(String id) async {
    if (!_earnedAchievements.contains(id)) {
      _earnedAchievements.add(id);
      notifyListeners();
      
      print("🏆 New achievement earned: $id");
      
      await repo.prefs.setStringList('earnedAchievements', _earnedAchievements);
      
      try {
        await _userDataService.updateProfileData(achievements: _earnedAchievements);
        print("☁️ Achievement $id synced to Firebase");
      } catch (e) {
        print("❌ Error syncing achievement $id: $e");
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
        
        if (data['selectedChallenges'] != null) {
          _selectedChallengeIds = List<String>.from(data['selectedChallenges']);
          await repo.prefs.setStringList('selectedChallenges', _selectedChallengeIds);
        }

        if (data['achievements'] != null) {
          _earnedAchievements = List<String>.from(data['achievements']);
          await repo.prefs.setStringList('earnedAchievements', _earnedAchievements);
          print("☁️ Achievements loaded from Firebase: $_earnedAchievements");
        }
        
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
