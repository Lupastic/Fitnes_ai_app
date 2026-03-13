import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final List<Map<String, dynamic>> allAchievements = [];

  String query = '';
  String filterStatus = 'All';
  List<Map<String, dynamic>> filteredAchievements = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context)!;
    allAchievements.clear();
    allAchievements.addAll([
      {'title': loc.achievementEarlyBird, 'icon': Icons.check_circle, 'done': true},
      {'title': loc.achievementHydrated, 'icon': Icons.opacity, 'value': '1/10'},
      {'title': loc.achievementWeekStreak, 'icon': Icons.star_border, 'value': '0/7'},
      {'title': loc.achievementMarathon, 'icon': Icons.directions_run},
      {'title': loc.achievementMealMaster, 'icon': Icons.restaurant, 'done': true},
      {'title': loc.achievementIntermediate, 'icon': Icons.local_fire_department},
      {'title': loc.achievementChampion, 'icon': Icons.emoji_events, 'value': '50,000 steps'},
      {'title': loc.achievementBriskWalk, 'icon': Icons.directions_walk, 'value': '0/30 mins'},
    ]);
    filteredAchievements = List.from(allAchievements);
    _rebuildKey++;
  }

  void applyFilters() {
    setState(() {
      filteredAchievements = allAchievements.where((a) {
        final matchTitle = a['title'].toString().toLowerCase().contains(query.toLowerCase());
        final matchStatus = filterStatus == 'All'
            || (filterStatus == 'Completed' && a['done'] == true)
            || (filterStatus == 'Incomplete' && a['done'] != true);
        return matchTitle && matchStatus;
      }).toList();
    });
  }

  int _rebuildKey = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : const Color(0xFFF3F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
        elevation: 0,
        centerTitle: true,
        title: Text(loc.achievements, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: loc.searchAchievements,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                query = value;
                applyFilters();
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: filterStatus,
              decoration: InputDecoration(
                labelText: loc.filterByStatus,
                filled: true,
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                DropdownMenuItem(value: 'All', child: Text(loc.filterAll)),
                DropdownMenuItem(value: 'Completed', child: Text(loc.filterCompleted)),
                DropdownMenuItem(value: 'Incomplete', child: Text(loc.filterIncomplete)),
              ],
              onChanged: (value) {
                filterStatus = value!;
                applyFilters();
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                key: ValueKey(_rebuildKey),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: filteredAchievements.length,
                itemBuilder: (context, index) {
                  final a = filteredAchievements[index];
                  return AchievementCard(
                    title: a['title'] as String,
                    icon: a['icon'] as IconData,
                    value: a['value'] as String?,
                    done: a['done'] == true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? value;
  final bool done;

  const AchievementCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final Color bgColor = done
        ? isDarkMode ? Colors.green.shade800.withOpacity(0.8) : const Color(0xFFE0F7EC)
        : isDarkMode ? Colors.grey.shade800.withOpacity(0.8) : Colors.white.withOpacity(0.8);
    final Color iconColor = done ? Colors.green.shade600 : Colors.indigo.shade400;
    final Color textColor = done
        ? (isDarkMode ? Colors.greenAccent.shade100 : Colors.green.shade900)
        : (isDarkMode ? Colors.white : Colors.black87);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(4, 6),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 38, color: iconColor)
              .animate()
              .scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOut),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (value != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                value!,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor.withOpacity(0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
