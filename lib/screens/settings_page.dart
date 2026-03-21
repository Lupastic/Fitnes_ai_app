import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/settings_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../services/user_data_service.dart';

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

  final TextEditingController _waterGoalController = TextEditingController();
  final TextEditingController _stepsGoalController = TextEditingController();
  final TextEditingController _sleepGoalController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _nameController.text = settings.name;
    _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
    
    _waterGoalController.text = (settings.goals['water'] ?? 8).toString();
    _stepsGoalController.text = (settings.goals['steps'] ?? 10000).toString();
    _sleepGoalController.text = (settings.goals['sleep'] ?? 8).toString();
  }

  Future<void> _updateAccount() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    final settings = context.read<SettingsProvider>();
    final userDataService = context.read<UserDataService>();

    try {
      if (_nameController.text != settings.name) await settings.updateName(_nameController.text);
      if (_pinController.text.isNotEmpty) {
        final newPin = _pinController.text.trim();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pin_code', newPin);
        await userDataService.updateProfileData(pinCode: newPin);
      }
      if (user != null) {
        if (_emailController.text != user.email) await user.updateEmail(_emailController.text);
        if (_passwordController.text.isNotEmpty) await user.updatePassword(_passwordController.text);
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account & PIN updated")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ИСТОРИЯ (НОВОЕ МЕСТО)
                Card(
                  color: Colors.tealAccent.withOpacity(0.1),
                  child: ListTile(
                    leading: const Icon(Icons.history, color: Colors.tealAccent),
                    title: const Text("View Activity History", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Check your past logs and logins"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.pushNamed(context, '/history'),
                  ),
                ),
                const SizedBox(height: 24),

                Text("Account Settings", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Display Name", prefixIcon: Icon(Icons.person))),
                        TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email))),
                        TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "New Password", prefixIcon: Icon(Icons.lock)), obscureText: true),
                        TextField(controller: _pinController, decoration: const InputDecoration(labelText: "New PIN Code", prefixIcon: Icon(Icons.pin_outlined)), keyboardType: TextInputType.number, obscureText: true),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _updateAccount, child: const Text("Update Account")),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text("Daily Goals", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(controller: _waterGoalController, decoration: const InputDecoration(labelText: "Water (cups)"), keyboardType: TextInputType.number),
                        TextField(controller: _stepsGoalController, decoration: const InputDecoration(labelText: "Steps"), keyboardType: TextInputType.number),
                        TextField(controller: _sleepGoalController, decoration: const InputDecoration(labelText: "Sleep (hours)"), keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: Text(loc.theme),
                  trailing: Switch(
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (v) => themeProvider.toggleTheme(),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}