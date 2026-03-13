// lib/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/settings_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart'; // Добавил импорт ThemeProvider

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key}); // Корректный const конструктор

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameController;
  final TextEditingController _waterGoalController = TextEditingController();
  final TextEditingController _stepsGoalController = TextEditingController();
  final TextEditingController _sleepGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Инициализируем контроллеры после BuildContext, чтобы получить доступ к SettingsProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      _nameController = TextEditingController(text: settings.name);
      _waterGoalController.text = (settings.goals['water'] ?? 8).toString();
      _stepsGoalController.text = (settings.goals['steps'] ?? 10000).toString();
      _sleepGoalController.text = (settings.goals['sleep'] ?? 8).toString();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _waterGoalController.dispose();
    _stepsGoalController.dispose();
    _sleepGoalController.dispose();
    super.dispose();
  }

  void _saveGoals() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    final waterGoal = int.tryParse(_waterGoalController.text);
    final stepsGoal = int.tryParse(_stepsGoalController.text);
    final sleepGoal = int.tryParse(_sleepGoalController.text);

    if (waterGoal != null) settings.updateGoal('water', waterGoal);
    if (stepsGoal != null) settings.updateGoal('steps', stepsGoal);
    if (sleepGoal != null) settings.updateGoal('sleep', sleepGoal);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.goalsSaved)), // Нужен ключ goalsSaved
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context); // Используем ThemeProvider

    final currentLangCode = localeProvider.locale.languageCode;
    String currentLangText;
    switch (currentLangCode) {
      case 'en':
        currentLangText = 'English';
        break;
      case 'ru':
        currentLangText = 'Русский';
        break;
      case 'kk':
        currentLangText = 'Қазақша';
        break;
      default:
        currentLangText = 'English';
    }

    final currentThemeText = themeProvider.themeMode == ThemeMode.dark ? loc.dark : loc.light;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Раздел "Общие настройки"
            Text(loc.generalSettings, style: Theme.of(context).textTheme.headlineSmall), // Нужен ключ generalSettings
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(loc.language),
                      subtitle: Text(currentLangText),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(loc.selectLanguage),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: AppLocalizations.supportedLocales.map((l) {
                                return ListTile(
                                  title: Text(
                                    l.languageCode == 'ru' ? 'Русский' :
                                    l.languageCode == 'kk' ? 'Қазақша' : 'English',
                                  ),
                                  onTap: () {
                                    localeProvider.setLocale(l); // Изменил на setLocale
                                    settingsProvider.updateLanguage(l); // Обновляем в settingsProvider
                                    Navigator.of(ctx).pop();
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.brightness_6),
                      title: Text(loc.theme),
                      subtitle: Text(currentThemeText),
                      onTap: () {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Раздел "Цели и вызовы"
            Text(loc.goalsAndChallenges, style: Theme.of(context).textTheme.headlineSmall), // Нужен ключ goalsAndChallenges
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _waterGoalController,
                      decoration: InputDecoration(
                        labelText: loc.waterCupsGoal, // Нужен ключ waterCupsGoal
                        hintText: '8',
                        prefixIcon: const Icon(Icons.water),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _stepsGoalController,
                      decoration: InputDecoration(
                        labelText: loc.stepsGoal, // Нужен ключ stepsGoal
                        hintText: '10000',
                        prefixIcon: const Icon(Icons.directions_walk),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _sleepGoalController,
                      decoration: InputDecoration(
                        labelText: loc.sleepHoursGoal, // Нужен ключ sleepHoursGoal
                        hintText: '8',
                        prefixIcon: const Icon(Icons.bed),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveGoals,
                      child: Text(loc.saveGoals), // Нужен ключ saveGoals
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {
                        settingsProvider.resetGoals();
                        // Обновляем контроллеры после сброса
                        _waterGoalController.text = (settingsProvider.goals['water'] ?? 8).toString();
                        _stepsGoalController.text = (settingsProvider.goals['steps'] ?? 10000).toString();
                        _sleepGoalController.text = (settingsProvider.goals['sleep'] ?? 8).toString();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.goalsReset)), // Нужен ключ goalsReset
                        );
                      },
                      child: Text(loc.resetGoals), // Нужен ключ resetGoals
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Раздел "Прочее"
            Text(loc.otherSettings, style: Theme.of(context).textTheme.headlineSmall), // Нужен ключ otherSettings
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_reset),
                      title: Text(loc.resetAllSettings), // Нужен ключ resetAllSettings
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(loc.confirmReset), // Нужен ключ confirmReset
                            content: Text(loc.resetSettingsWarning), // Нужен ключ resetSettingsWarning
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(loc.cancel)), // Нужен ключ cancel
                              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(loc.reset)), // Нужен ключ reset
                            ],
                          ),
                        );
                        if (confirm == true) {
                          settingsProvider.resetSettingsToDefaults();
                          // Обновляем контроллеры после полного сброса
                          _nameController.text = settingsProvider.name;
                          _waterGoalController.text = (settingsProvider.goals['water'] ?? 8).toString();
                          _stepsGoalController.text = (settingsProvider.goals['steps'] ?? 10000).toString();
                          _sleepGoalController.text = (settingsProvider.goals['sleep'] ?? 8).toString();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(loc.allSettingsReset)), // Нужен ключ allSettingsReset
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}