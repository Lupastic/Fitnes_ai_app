import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finallapp/generated/l10n/app_localizations.dart';

import '../providers/settings_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../services/user_data_service.dart';
import '../widgets/notification_settings_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _nameController.text = settings.name;
    _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
  }

  Future<void> _updateAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    final settings = context.read<SettingsProvider>();
    final userDataService = context.read<UserDataService>();
    final loc = AppLocalizations.of(context)!;

    try {
      if (_nameController.text != settings.name) {
        await settings.updateName(_nameController.text);
      }

      if (_pinController.text.isNotEmpty) {
        final newPin = _pinController.text.trim();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pin_code', newPin);
        await userDataService.updateProfileData(pinCode: newPin);
      }

      bool sensitiveDataChanged = (_emailController.text != user.email) || (_passwordController.text.isNotEmpty);

      if (sensitiveDataChanged) {
        try {
          if (_emailController.text != user.email) {
            await user.updateEmail(_emailController.text);
          }
          if (_passwordController.text.isNotEmpty) {
            await user.updatePassword(_passwordController.text);
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') {
            _showReauthDialog();
            return;
          }
          rethrow;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.accountUpdatedSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showReauthDialog() {
    final loc = AppLocalizations.of(context)!;
    final TextEditingController passwordCheck = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.recentLoginRequired),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.reauthPrompt),
            TextField(controller: passwordCheck, obscureText: true, decoration: InputDecoration(labelText: loc.currentPassword)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.cancel)),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              final cred = EmailAuthProvider.credential(email: user!.email!, password: passwordCheck.text);
              try {
                await user.reauthenticateWithCredential(cred);
                Navigator.pop(context);
                _updateAccount();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.wrongPassword), backgroundColor: Colors.red));
              }
            },
            child: Text(loc.confirm),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final localeProvider = context.read<LocaleProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption("English", const Locale('en'), localeProvider, settingsProvider),
            _buildLanguageOption("Русский", const Locale('ru'), localeProvider, settingsProvider),
            _buildLanguageOption("Қазақша", const Locale('kk'), localeProvider, settingsProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String label, Locale locale, LocaleProvider localeProvider, SettingsProvider settingsProvider) {
    return ListTile(
      title: Text(label),
      trailing: localeProvider.locale == locale ? const Icon(Icons.check, color: Colors.tealAccent) : null,
      onTap: () async {
        await localeProvider.setLocale(locale);
        await settingsProvider.setLocale(locale.languageCode);
        if (mounted) Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    String currentLangName = "English";
    if (localeProvider.locale.languageCode == 'ru') currentLangName = "Русский";
    if (localeProvider.locale.languageCode == 'kk') currentLangName = "Қазақша";

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.tealAccent.withOpacity(0.1),
              child: ListTile(
                leading: const Icon(Icons.history, color: Colors.tealAccent),
                title: Text(loc.history, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(loc.checkPastActivity),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.pushNamed(context, '/history'),
              ),
            ),
            const SizedBox(height: 24),

            Text(loc.accountSettings, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(controller: _nameController, decoration: InputDecoration(labelText: loc.displayName, prefixIcon: const Icon(Icons.person))),
                    TextField(controller: _emailController, decoration: InputDecoration(labelText: loc.email, prefixIcon: const Icon(Icons.email))),
                    TextField(controller: _passwordController, decoration: InputDecoration(labelText: loc.newPasswordOptional, prefixIcon: const Icon(Icons.lock)), obscureText: true),
                    TextField(controller: _pinController, decoration: InputDecoration(labelText: loc.newPinCode, prefixIcon: const Icon(Icons.pin_outlined)), keyboardType: TextInputType.number, obscureText: true),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _updateAccount,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent.shade700, foregroundColor: Colors.white),
                      child: Text(loc.updateAccount),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(loc.notifications, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            const NotificationSettingsCard(),
            const SizedBox(height: 24),

            Text(loc.preferences, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.brightness_6),
                    title: Text(loc.theme),
                    subtitle: Text(themeProvider.themeMode == ThemeMode.dark ? loc.darkMode : loc.lightMode),
                    trailing: Switch(
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (v) => themeProvider.toggleTheme(),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(loc.language),
                    subtitle: Text(currentLangName),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showLanguageDialog,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}