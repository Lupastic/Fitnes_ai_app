import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/summary_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  String query = '';
  String filterStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    // Получаем текущие данные из провайдера
    final summary = context.watch<SummaryProvider>().today;

    // Список достижений, зависящий от реальных данных
    final List<Map<String, dynamic>> allAchievements = [
      {
        'id': 'early_bird',
        'title': loc.achievementEarlyBird, 
        'icon': Icons.wb_sunny, 
        'done': true // Заглушка: всегда выполнено
      },
      {
        'id': 'hydrated',
        'title': loc.achievementHydrated, 
        'icon': Icons.opacity, 
        'value': '${summary.waterCups}/8',
        'done': summary.waterCups >= 8 // ДИНАМИЧЕСКИ: выполнено, если выпито 8 стаканов
      },
      {
        'id': 'steps_master',
        'title': "10k Steps Master", 
        'icon': Icons.directions_walk, 
        'value': '${summary.steps}/10000',
        'done': summary.steps >= 10000
      },
      {
        'id': 'marathon',
        'title': loc.achievementMarathon, 
        'icon': Icons.stars,
        'done': false
      },
    ];

    final filteredAchievements = allAchievements.where((a) {
      final matchTitle = a['title'].toString().toLowerCase().contains(query.toLowerCase());
      final matchStatus = filterStatus == 'All'
          || (filterStatus == 'Completed' && a['done'] == true)
          || (filterStatus == 'Incomplete' && a['done'] != true);
      return matchTitle && matchStatus;
    }).toList();

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
              onChanged: (value) => setState(() => query = value),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: done 
          ? (isDarkMode ? Colors.teal.shade900 : Colors.teal.shade50)
          : (isDarkMode ? Colors.grey.shade800 : Colors.white),
        border: done ? Border.all(color: Colors.tealAccent, width: 2) : null,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: done ? Colors.tealAccent : Colors.grey),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: done ? (isDarkMode ? Colors.white : Colors.teal.shade900) : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          if (value != null)
            Text(value!, style: const TextStyle(fontSize: 12, color: Colors.blueAccent)),
          if (done) 
            const Icon(Icons.check_circle, color: Colors.tealAccent, size: 20).animate().scale(),
        ],
      ),
    );
  }
}