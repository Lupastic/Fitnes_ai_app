import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/settings_provider.dart';
import '../providers/summary_provider.dart';
import 'settings_page.dart';
import 'achievements_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final summary = context.watch<SummaryProvider>().today;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsPage())),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil('/auth_page', (route) => false);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Text(
                loc.profile,
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 22),
              ),
              centerTitle: false,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // --- AVATAR & NAME ---
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Colors.tealAccent, Colors.blueAccent]),
                    ),
                    child: const CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.person_rounded, size: 60, color: Colors.tealAccent),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    settings.name.isEmpty ? "User Name" : settings.name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  Text(user?.email ?? "", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                  const SizedBox(height: 35),

                  // --- SHOWCASE ---
                  _buildSectionHeader("Achievement Showcase", () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const AchievementsPage()));
                  }),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBadge(Icons.opacity_rounded, "Water", summary.waterCups >= 8),
                        _buildBadge(Icons.bolt_rounded, "Active", true),
                        _buildBadge(Icons.directions_walk_rounded, "Steps", summary.steps >= 10000),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  // --- STAT CARDS ---
                  _buildSectionHeader("Quick Stats", null),
                  const SizedBox(height: 16),
                  _buildInfoCard(theme, Icons.local_fire_department_rounded, "Total Burned", "${summary.calories} kcal"),
                  const SizedBox(height: 12),
                  _buildInfoCard(theme, Icons.nightlight_round, "Sleep Avg", "${summary.sleepHours.toStringAsFixed(1)} h"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        if (onTap != null)
          TextButton(onPressed: onTap, child: const Text("View All", style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String label, bool isDone) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? Colors.tealAccent.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            border: Border.all(color: isDone ? Colors.tealAccent : Colors.grey.withOpacity(0.2)),
          ),
          child: Icon(icon, color: isDone ? Colors.tealAccent : Colors.grey.withOpacity(0.4), size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDone ? Colors.white : Colors.grey)),
      ],
    );
  }

  Widget _buildInfoCard(ThemeData theme, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.tealAccent, size: 22),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.tealAccent, fontSize: 16)),
        ],
      ),
    );
  }
}