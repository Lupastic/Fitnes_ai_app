// lib/screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../models/history_entry.dart';
import '../providers/settings_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../services/user_data_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currentEmailController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();

  bool _isSaving = false;
  List<Map<String, dynamic>> _history = []; // Список для отображения истории

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadUserHistory();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentEmailController.dispose();
    _newEmailController.dispose();
    _passwordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Имя берем из SettingsProvider, почту из Firebase
      _nameController.text = settings.name;
      _currentEmailController.text = user.email ?? '';
    }
  }

  Future<void> _loadUserHistory() async {
    final userDataService = Provider.of<UserDataService>(context, listen: false);
    List<HistoryEntry> allHistoryEntries = [];

    // Загружаем историю из Firebase
    try {
      final firebaseHistory = await userDataService.getUserHistory();
      allHistoryEntries.addAll(firebaseHistory);
    } catch (e) {
      print("Error loading history from Firebase: $e");
    }

    // Загружаем историю из Hive
    final box = await Hive.openBox<HistoryEntry>('history');
    final localHistory = box.values.toList();
    allHistoryEntries.addAll(localHistory);

    // Сортируем все записи по убыванию даты и берем последние 3
    allHistoryEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    setState(() {
      _history = allHistoryEntries.take(3).map((entry) => {
        'title': entry.title,
        'timestamp': entry.timestamp,
      }).toList();
    });
  }

  Future<void> _saveChanges() async {
    if (_currentPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите ваш текущий пароль для применения изменений.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final userDataService = Provider.of<UserDataService>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    final newName = _nameController.text.trim();
    final currentEmail = _currentEmailController.text.trim();
    final newEmail = _newEmailController.text.trim();
    final newPassword = _passwordController.text.trim();
    final currentPassword = _currentPasswordController.text.trim();

    print('🟡 Starting saveChanges...');
    print('➡️ currentEmail: $currentEmail');
    print('➡️ newEmail: $newEmail');
    print('➡️ currentPassword: ${'*' * currentPassword.length}');

    try {
      if (user == null) {
        print('❌ No Firebase user found.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пользователь не авторизован'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      // Обновление имени через SettingsProvider, который позаботится о Firebase и локальном хранилище
      if (newName.isNotEmpty && newName != settings.name) {
        print('🔄 Updating display name...');
        await settings.updateName(newName);
      }

      // Reauthentication требуется для изменения чувствительных данных (email, password)
      print('🔐 Attempting reauthentication...');
      final cred = EmailAuthProvider.credential(email: currentEmail, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
      print('✅ Reauthenticated as ${user.email}');

      await user.reload(); // Убедитесь, что информация о пользователе обновлена
      final reloadedUser = FirebaseAuth.instance.currentUser;

      // Обновление почты
      if (newEmail.isNotEmpty && newEmail != (reloadedUser?.email ?? '')) {
        print('✉️ Validating new email format...');
        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
        if (!emailRegex.hasMatch(newEmail)) {
          throw FirebaseAuthException(code: 'invalid-email', message: 'Неверный формат электронной почты.');
        }

        print('📧 Sending verification link for new email...');
        await reloadedUser!.verifyBeforeUpdateEmail(newEmail);
        print('✅ Verification email sent to $newEmail. Awaiting user confirmation.');

        if (mounted) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Подтвердите новую почту'),
              content: Text('Письмо с подтверждением отправлено на $newEmail. Пожалуйста, перейдите по ссылке, чтобы завершить обновление.'),
              actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('ОК'))],
            ),
          );
        }
        return; // Не продолжаем; ждем подтверждения пользователя
      }

      // Обновление пароля
      if (newPassword.isNotEmpty) {
        print('🔄 Updating password...');
        await reloadedUser!.updatePassword(newPassword);
        print('✅ Password updated.');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пароль успешно обновлен. Пожалуйста, войдите снова.')),
          );
        }
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/auth_page', (route) => false);
        }
        return;
      }

      print('🗃️ Storing update history...');
      // Добавляем запись в историю через UserDataService
      final HistoryEntry newHistoryEntry = HistoryEntry(title: 'Профиль обновлен', timestamp: DateTime.now());
      await userDataService.addHistoryEntry(newHistoryEntry);

      final historyBox = await Hive.openBox<HistoryEntry>('history');
      await historyBox.add(newHistoryEntry); // Сохраняем и в локальный Hive

      await _loadUserHistory(); // Перезагружаем историю для отображения

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.changesSaved)),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('❗ FirebaseAuthException: ${e.code} - ${e.message}');
      String errorMessage = 'Что-то пошло не так.';
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Текущий пароль неверный.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Этот адрес электронной почты уже используется.';
          break;
        case 'weak-password':
          errorMessage = 'Пароль слишком слабый (минимум 6 символов).';
          break;
        case 'invalid-email':
          errorMessage = 'Неверный формат электронной почты.';
          break;
        case 'requires-recent-login':
          errorMessage = 'Пожалуйста, войдите снова, чтобы изменить конфиденциальную информацию.';
          break;
        default:
          errorMessage = 'Ошибка Firebase: ${e.message}';
          break;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('❗ Unexpected error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Неожиданная ошибка: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      print('✅ Finished _saveChanges');
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context); // Используется для отображения текущих настроек
    final localeProvider = Provider.of<LocaleProvider>(context);
    final langCode = localeProvider.locale.languageCode;
    final langText = langCode == 'ru' ? 'Русский' : langCode == 'kk' ? 'Қазақша' : 'English';
    final themeText = Theme.of(context).brightness == Brightness.dark ? loc.dark : loc.light;
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text(loc.profile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        labelText: loc.name,
                      ),
                    ),
                    TextField(
                      controller: _currentEmailController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        labelText: 'Текущая почта',
                      ),
                      readOnly: true, // Почту можно только просмотреть, не менять напрямую
                    ),
                    TextField(
                      controller: _newEmailController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        labelText: 'Новая почта',
                      ),
                    ),
                    TextField(
                      controller: _currentPasswordController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: 'Текущий пароль',
                      ),
                      obscureText: true,
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelText: loc.newPassword,
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_outlined),
                      onPressed: _isSaving ? null : _saveChanges,
                      label: _isSaving
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Text(loc.saveChanges),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(loc.language),
                    subtitle: Text(langText),
                    onTap: () {
                      // Пример: показать диалог выбора языка
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(loc.selectLanguage),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: AppLocalizations.supportedLocales.map((l) {
                              return ListTile(
                                title: Text(l.languageCode == 'ru' ? 'Русский' : l.languageCode == 'kk' ? 'Қазақша' : 'English'),
                                onTap: () {
                                  context.read<LocaleProvider>().setLocale(l);
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
                    subtitle: Text(themeText),
                    onTap: () {
                      context.read<ThemeProvider>().toggleTheme();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(loc.history, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Проверяем, что _history не пуст, прежде чем отображать
            if (_history.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(loc.noHistoryYet), // Используйте локализованный текст "Нет истории"
              )
            else
              ..._history.map((entry) {
                final date = entry['timestamp'];
                final formattedDate = date is DateTime ? dateFormatter.format(date) : 'Unknown';
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.history, color: Colors.blueAccent),
                    title: Text(entry['title'] ?? loc.noTitle),
                    subtitle: Text(formattedDate),
                  ),
                );
              }).toList(),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: Text(loc.viewAllHistory),
                onPressed: () => Navigator.pushNamed(context, '/history'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}