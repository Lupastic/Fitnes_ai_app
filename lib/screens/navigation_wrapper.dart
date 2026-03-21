// lib/screens/navigation_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/settings_provider.dart';

import 'home_page.dart';
import 'challenges_page.dart';
import 'statistics_page.dart';

class NavigationWrapper extends StatefulWidget {
  final bool isGuest;

  const NavigationWrapper({super.key, this.isGuest = false});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.isGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && mounted) {
          context.read<SettingsProvider>().loadSettingsFromFirebase();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ТЕПЕРЬ 4 ВКЛАДКИ
    final List<Widget> pages = [
      HomePage(active: _currentIndex == 0),
      const StatisticsPage(),
      const ChallengesPage(),
      const AiChatPlaceholder(), // НОВАЯ ВКЛАДКА
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          selectedItemColor: Colors.tealAccent,
          unselectedItemColor: isDark 
              ? Colors.white.withOpacity(0.3) 
              : Colors.black.withOpacity(0.3),
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 0 ? Icons.grid_view_rounded : Icons.grid_view_outlined),
              label: loc.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 1 ? Icons.analytics_rounded : Icons.analytics_outlined),
              label: loc.statistics,
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 2 ? Icons.emoji_events_rounded : Icons.emoji_events_outlined),
              label: loc.challenges,
            ),
            // ИКОНКА ДЛЯ ЧАТА С ИИ
            const BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_rounded),
              label: "AI Chat",
            ),
          ],
        ),
      ),
    );
  }
}

// ПРОСТАЯ ЗАГЛУШКА ДЛЯ ЧАТА
class AiChatPlaceholder extends StatelessWidget {
  const AiChatPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.tealAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 64, color: Colors.tealAccent),
            ),
            const SizedBox(height: 24),
            const Text(
              "AI Health Assistant",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Coming Soon...",
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Currently unavailable",
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}