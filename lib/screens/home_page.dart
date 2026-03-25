import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/settings_provider.dart';
import '../providers/summary_provider.dart';
import '../providers/step_counter_provider.dart';
import '../models/challenge.dart';
import 'profile_page.dart';
import '../widgets/network_icon.dart';
import '../widgets/offline_banner.dart';

class HomePage extends StatefulWidget {
  final bool active;
  const HomePage({super.key, required this.active});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // We keep the IDs but will translate titles and units in the UI
  static const List<Challenge> _allTypes = [
    Challenge(id: 'water', title: 'Water', frequency: 'Daily', unit: 'cups', target: 8, icon: Icons.local_drink_rounded),
    Challenge(id: 'steps', title: 'Steps', frequency: 'Daily', unit: 'steps', target: 10000, icon: Icons.directions_run_rounded),
    Challenge(id: 'sleep', title: 'Sleep', frequency: 'Daily', unit: 'h', target: 8, icon: Icons.nightlight_round),
    Challenge(id: 'calories', title: 'Calories', frequency: 'Daily', unit: 'kcal', target: 2000, icon: Icons.local_fire_department_rounded),
  ];

  String _getTranslatedTitle(String id, AppLocalizations loc) {
    switch (id) {
      case 'water': return loc.water;
      case 'steps': return loc.steps;
      case 'sleep': return loc.sleep;
      case 'calories': return loc.calories;
      default: return id;
    }
  }

  String _getTranslatedUnit(String id, AppLocalizations loc) {
    switch (id) {
      case 'water': return loc.cups;
      case 'steps': return loc.steps; // or loc.stepsUnit if available
      case 'sleep': return loc.hours;
      case 'calories': return "kcal";
      default: return "";
    }
  }

  void _showManualInputDialog(Challenge ch, SummaryProvider provider, AppLocalizations loc) {
    final TextEditingController controller = TextEditingController();
    final title = _getTranslatedTitle(ch.id, loc);
    final unit = _getTranslatedUnit(ch.id, loc);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${loc.save} $title"),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: "${loc.email} ($unit)", // Using email as a proxy for 'Amount' if not available, but let's just use text
            hintText: "...",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 0;
              if (val > 0) {
                if (ch.id == 'water') provider.update(water: val.toInt(), add: true);
                if (ch.id == 'steps') provider.update(steps: val.toInt(), add: true);
                if (ch.id == 'sleep') provider.update(sleep: val, add: true);
                if (ch.id == 'calories') provider.update(cal: val.toInt(), add: true);
              }
              Navigator.pop(context);
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final summaryProv = context.watch<SummaryProvider>();
    final summary = summaryProv.today;

    final selectedChallenges = _allTypes.where((c) => settings.selectedChallengeIds.contains(c.id)).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [
              isDark ? Colors.tealAccent.withOpacity(0.05) : Colors.blueAccent.withOpacity(0.1),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const OfflineBanner(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.goodMorning,
                                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "${settings.name}!",
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const NetworkIcon(),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfilePage())),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(colors: [Colors.tealAccent, isDark ? Colors.blueAccent : Colors.teal]),
                              ),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundColor: theme.scaffoldBackgroundColor,
                                child: Icon(Icons.person_rounded, color: isDark ? Colors.tealAccent : Colors.teal, size: 30),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      _buildMotivationCard(isDark, loc),
                      const SizedBox(height: 35),

                      Text(
                        loc.yourProgress,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 20),

                      if (selectedChallenges.isEmpty)
                        _buildEmptyState(isDark)
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 18,
                            mainAxisSpacing: 18,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: selectedChallenges.length,
                          itemBuilder: (context, index) {
                            final ch = selectedChallenges[index];
                            return _buildMetricCard(ch, summary, summaryProv, isDark, theme, loc);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationCard(bool isDark, AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
        gradient: isDark ? null : LinearGradient(colors: [Colors.teal.shade50, Colors.blue.shade50]),
        border: Border.all(color: isDark ? Colors.tealAccent.withOpacity(0.2) : Colors.teal.withOpacity(0.1)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: Colors.tealAccent, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "\"${loc.motivationQuote}\"",
              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(Challenge ch, dynamic summary, SummaryProvider provider, bool isDark, ThemeData theme, AppLocalizations loc) {
    Color accentColor;
    switch (ch.id) {
      case 'water': accentColor = Colors.lightBlueAccent; break;
      case 'steps': accentColor = Colors.greenAccent; break;
      case 'sleep': accentColor = Colors.purpleAccent; break;
      case 'calories': accentColor = Colors.orangeAccent; break;
      default: accentColor = Colors.tealAccent;
    }

    double currentVal = 0;
    if (ch.id == 'water') currentVal = summary.waterCups.toDouble();
    if (ch.id == 'steps') currentVal = summary.steps.toDouble();
    if (ch.id == 'sleep') currentVal = summary.sleepHours;
    if (ch.id == 'calories') currentVal = summary.calories.toDouble();

    double progress = (currentVal / ch.target).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => _showManualInputDialog(ch, provider, loc),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
          boxShadow: isDark ? [] : [
            BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 10)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 6,
                  color: accentColor.withOpacity(0.1),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: accentColor,
                        boxShadow: [BoxShadow(color: accentColor.withOpacity(0.5), blurRadius: 8)],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(ch.icon, color: accentColor, size: 24),
                    ),
                    const Spacer(),
                    Text(
                      _getTranslatedTitle(ch.id, loc),
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currentVal.toStringAsFixed(currentVal is double && currentVal % 1 != 0 ? 1 : 0),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              "/ ${ch.target}",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white24 : Colors.black26),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _getTranslatedUnit(ch.id, loc),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accentColor, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.add_circle_outline_rounded, size: 80, color: isDark ? Colors.white10 : Colors.black12),
          const SizedBox(height: 20),
          const Text("Your Dashboard is Empty", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const Text("Add goals from the Challenges tab", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}
