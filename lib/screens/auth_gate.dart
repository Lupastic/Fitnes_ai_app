import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/summary_provider.dart';
import 'start_page.dart';
import 'navigation_wrapper.dart';
import 'pin_code_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  User? _lastUser;

  // ✅ Храним future чтобы не пересоздавать при каждом build()
  Future<bool>? _pinFuture;
  String? _pinFutureUid; // для какого uid был создан future

  @override
  void dispose() {
    _lastUser = null;
    super.dispose();
  }

  Future<void> _handleInitialLogic(User user) async {
    if (_lastUser?.uid == user.uid) return;
    _lastUser = user;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      developer.log("📦 Загрузка данных: ${user.email}", name: "AuthGate");
      await context.read<SettingsProvider>().loadSettingsFromFirebase();
      await context.read<SummaryProvider>().syncFromFirebase();
    });
  }

  // ✅ Получаем future только когда меняется uid
  Future<bool> _getPinFuture(AppAuthProvider authProvider, String uid) {
    if (_pinFuture == null || _pinFutureUid != uid) {
      _pinFutureUid = uid;
      _pinFuture = authProvider.shouldShowPin();
    }
    return _pinFuture!;
  }

  // ✅ Сброс при выходе
  void _resetState() {
    _lastUser = null;
    _pinFuture = null;
    _pinFutureUid = null;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(), // Используем userChanges для отслеживания emailVerified
      builder: (context, snapshot) {
        developer.log(
          "🔄 Auth: ${snapshot.connectionState}, user: ${snapshot.data?.email}, verified: ${snapshot.data?.emailVerified}",
          name: "AuthGate",
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        final user = snapshot.data;

        if (user == null) {
          _resetState();
          return const StartPage();
        }

        // Проверка email
        if (!user.emailVerified &&
            user.providerData.any((p) => p.providerId == 'password')) {
          return _buildEmailVerificationScreen(user);
        }

        // Загружаем данные пользователя
        _handleInitialLogic(user);

        // ✅ Если ПИН уже был введен в этой сессии, пропускаем его
        if (authProvider.isPinVerified) {
          return const NavigationWrapper();
        }

        return FutureBuilder<bool>(
          future: _getPinFuture(authProvider, user.uid),
          builder: (context, pinSnapshot) {
            if (pinSnapshot.connectionState != ConnectionState.done) {
              return _buildLoading();
            }

            if (pinSnapshot.hasError) {
              developer.log("❌ Ошибка shouldShowPin: ${pinSnapshot.error}", name: "AuthGate");
              return const NavigationWrapper(); 
            }

            final bool hasPin = pinSnapshot.data ?? false;
            return hasPin ? const PinCodeScreen() : const NavigationWrapper();
          },
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F8FA),
      body: Center(
        child: CircularProgressIndicator(color: Colors.teal),
      ),
    );
  }

  Widget _buildEmailVerificationScreen(User user) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 80, color: Colors.teal),
            const SizedBox(height: 24),
            const Text(
              "Подтвердите Email",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              "Мы отправили письмо на ${user.email}. Пожалуйста, подтвердите его, затем нажмите кнопку ниже.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                await user.reload(); // Перезагружаем пользователя, чтобы обновить emailVerified
                setState(() {}); // Обновляем UI
              },
              child: const Text("Я подтвердил почту", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.teal),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                await user.sendEmailVerification();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Письмо отправлено повторно")),
                  );
                }
              },
              child: const Text("Отправить письмо еще раз", style: TextStyle(color: Colors.teal)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<AppAuthProvider>().signOut(context),
              child: const Text("Выйти", style: TextStyle(color: Colors.teal)),
            ),
          ],
        ),
      ),
    );
  }
}
