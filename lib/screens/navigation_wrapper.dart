// lib/screens/navigation_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/settings_provider.dart';

import 'home_page.dart';
import 'challenges_page.dart';
import 'statistics_page.dart';
import 'achievements_page.dart';
import 'profile_page.dart';
import 'settings_page.dart'; // Этот импорт нужен, но убедитесь, что SettingsPage не содержит SettingsProvider

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
    final localizations = AppLocalizations.of(context)!;

    // Инициализируем страницы, передавая HomePage active: false по умолчанию
    final List<Widget> pages = [
      const HomePage(active: false), // ИЗМЕНЕНО: HomePage теперь в списке и получает active
      const StatisticsPage(),
      const ChallengesPage(),
      const AchievementsPage(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(icon: const Icon(Icons.home), label: localizations.home),
      BottomNavigationBarItem(icon: const Icon(Icons.bar_chart), label: localizations.statistics),
      BottomNavigationBarItem(icon: const Icon(Icons.flag), label: localizations.challenges),
      BottomNavigationBarItem(icon: const Icon(Icons.emoji_events), label: localizations.achievements),
    ];

    if (!widget.isGuest) {
      pages.add(const ProfilePage());
      pages.add(const SettingsPage()); // Убедитесь, что SettingsPage имеет const конструктор
      navItems.add(BottomNavigationBarItem(icon: const Icon(Icons.person), label: localizations.profile));
      navItems.add(BottomNavigationBarItem(icon: const Icon(Icons.settings), label: localizations.settings));
    }

    if (_currentIndex >= navItems.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: widget.isGuest
          ? AppBar(
        title: const Text("Гостевой режим"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        // Обновляем параметр active для HomePage динамически
        children: pages.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget page = entry.value;
          if (page is HomePage) {
            // Создаем новую HomePage с обновленным параметром active
            return HomePage(key: page.key, active: _currentIndex == idx);
          }
          return page;
        }).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }
}