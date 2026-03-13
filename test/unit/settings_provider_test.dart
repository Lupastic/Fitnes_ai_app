import 'package:flutter_test/flutter_test.dart';
import 'package:finallapp/providers/settings_provider.dart';
import 'package:finallapp/services/settings_repository.dart';
import 'package:finallapp/services/user_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Real subclass to override behavior
class MockSettingsRepo extends SettingsRepository {
  MockSettingsRepo(SharedPreferences prefs) : super(prefs);

  @override
  String get name => 'Kamilla';

  @override
  Map<String, int> get goals => {
    'water': 8,
    'steps': 10000,
    'sleep': 8,
  };
}

class MockUserDataService extends UserDataService {}

void main() {
  group('SettingsProvider Unit Test', () {
    test('Initial values are loaded correctly', () async {
      // 🧪 Provide mock shared prefs
      SharedPreferences.setMockInitialValues({}); // 💡 use built-in mock
      final prefs = await SharedPreferences.getInstance();

      final repo = MockSettingsRepo(prefs);
      final provider = SettingsProvider(repo, MockUserDataService());

      expect(provider.name, 'Kamilla');
      expect(provider.goals['water'], 8);
    });
  });
}
