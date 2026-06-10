import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:finallapp/generated/l10n/app_localizations.dart';

import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/summary_provider.dart';
import 'settings_page.dart';
import 'achievements_page.dart';
import 'onboarding_page.dart';

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
                  // Передаем context для корректной очистки данных
                  await context.read<AppAuthProvider>().signOut(context);
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  }
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
                    settings.name.isEmpty ? loc.nameNotSet : settings.name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  Text(user?.email ?? "", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                  const SizedBox(height: 25),

                  // КНОПКА РЕДАКТИРОВАНИЯ ДАННЫХ ТЕЛА
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const OnboardingPage()),
                    ),
                    icon: const Icon(Icons.edit_note_rounded, size: 20),
                    label: Text(loc.editBodyMetricsGoals),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent.withOpacity(0.1),
                      foregroundColor: Colors.tealAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 35),

                  // --- SHOWCASE ---
                  _buildSectionHeader(loc.questsAndProgress, loc, () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const QuestsPage()));
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
                        _buildBadge(Icons.emoji_events_rounded, "${settings.points} ${loc.points}", true),
                        _buildBadge(Icons.task_alt_rounded, "${settings.completedQuests.length} ${loc.quests}", settings.completedQuests.isNotEmpty),
                        _buildBadge(Icons.leaderboard_rounded, loc.globalRank, true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  // --- STAT CARDS ---
                  _buildSectionHeader(loc.quickStats, loc, null),
                  const SizedBox(height: 16),
                  _buildInfoCard(theme, Icons.fitness_center_rounded, loc.currentGoal, _getLocalizedGoal(settings.goalType, loc)),
                  const SizedBox(height: 12),
                  _buildInfoCard(theme, Icons.monitor_weight_rounded, loc.weight, "${settings.weight ?? '--'} ${settings.weightUnit ?? 'kg'}"),
                  const SizedBox(height: 12),
                  _buildInfoCard(theme, Icons.height_rounded, loc.height, "${settings.height ?? '--'} ${settings.heightUnit ?? 'cm'}"),
                  const SizedBox(height: 12),
                  _buildInfoCard(theme, Icons.local_fire_department_rounded, loc.totalBurned, "${summary.calories} kcal"),
                  const SizedBox(height: 12),
                  _buildInfoCard(theme, Icons.nightlight_round, loc.sleepAvg, "${summary.sleepHours.toStringAsFixed(1)} ${loc.hours}"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedGoal(String? goal, AppLocalizations loc) {
    if (goal == null) return loc.notSet;
    switch (goal) {
      case 'Lose Weight': return loc.goalLoseWeight;
      case 'Gain Weight': return loc.goalGainWeight;
      case 'Get Fit': return loc.goalGetFit;
      default: return goal;
    }
  }

  Widget _buildSectionHeader(String title, AppLocalizations loc, VoidCallback? onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
        if (onTap != null)
          TextButton(onPressed: onTap, child: Text(loc.viewAll, style: const TextStyle(fontWeight: FontWeight.bold))),
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
