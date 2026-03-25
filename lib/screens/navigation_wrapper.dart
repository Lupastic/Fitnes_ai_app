// lib/screens/navigation_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/settings_provider.dart';

import 'home_page.dart';
import 'challenges_page.dart';
import 'statistics_page.dart';
import 'ai_chat_page.dart';

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

    final List<Widget> pages = [
      HomePage(active: _currentIndex == 0),
      const StatisticsPage(),
      const ChallengesPage(),
      const AiChatPage(), 
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
            BottomNavigationBarItem(
              icon: const Icon(Icons.auto_awesome_rounded),
              label: loc.aiChat,
            ),
          ],
        ),
      ),
    );
  }
}
