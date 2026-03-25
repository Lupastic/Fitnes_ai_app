import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'auth_page.dart';
import 'navigation_wrapper.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Явно задаем цвета, чтобы не зависеть от контекста темы в момент инициализации
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF0A0C12) : const Color(0xFFF7F8FA);
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.health_and_safety, size: 80, color: Colors.teal),
              const SizedBox(height: 24),
              Text(
                'Health App',
                style: TextStyle(
                  color: textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ваш персональный помощник здоровья',
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 16),
              ),
              const SizedBox(height: 60),
              
              // Кнопка Email
              _buildButton(
                context,
                label: 'Войти через Email',
                icon: Icons.email,
                color: Colors.teal,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Кнопка Google
              _buildButton(
                context,
                label: 'Войти через Google',
                icon: Icons.g_mobiledata,
                color: isDark ? Colors.white10 : Colors.white,
                textColor: isDark ? Colors.white : Colors.black87,
                hasBorder: true,
                onPressed: () async {
                  try {
                    await context.read<AppAuthProvider>().signInWithGoogle();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка Google: $e')),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Кнопка Гость
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const NavigationWrapper(isGuest: true)),
                ),
                child: Text(
                  'Продолжить как гость',
                  style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    Color textColor = Colors.white,
    bool hasBorder = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: textColor),
        label: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: hasBorder ? const BorderSide(color: Colors.black12) : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
