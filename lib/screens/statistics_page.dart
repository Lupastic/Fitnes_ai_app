import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final List<Map<String, dynamic>> allStats = [];
  List<Map<String, dynamic>> filteredStats = [];
  String query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context)!;

    allStats.clear();
    allStats.addAll([
      {'title': loc.water, 'value': '1.8 L', 'icon': Icons.local_drink},
      {'title': loc.sleep, 'value': '9 hr', 'icon': Icons.bedtime},
      {'title': loc.calories, 'value': '2,407 kcal', 'icon': Icons.local_fire_department},
      {'title': 'Yoga', 'value': '2 sessions', 'icon': Icons.self_improvement},
      {'title': 'Running', 'value': '12 km', 'icon': Icons.directions_run},
      {'title': 'Plank', 'value': '4 min', 'icon': Icons.accessibility_new},
      {'title': 'Meditation', 'value': '8 min', 'icon': Icons.spa},
      {'title': 'Sugar-Free Days', 'value': '3 days', 'icon': Icons.no_food},
    ]);

    filteredStats = List.from(allStats);
  }

  void filterStats(String input) {
    setState(() {
      query = input;
      filteredStats = allStats
          .where((stat) =>
          stat['title'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : const Color(0xFFF3F6FA),
      appBar: AppBar(
        title: Text(loc.statistics),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor:
        isDarkMode ? Colors.tealAccent.shade100 : Colors.teal.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: loc.search ?? 'Search...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: filterStats,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredStats.isEmpty
                  ? Center(
                child: Text(
                  loc.nothingFound ?? 'Nothing found',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.black45,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: filteredStats.length,
                itemBuilder: (context, index) {
                  final stat = filteredStats[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.white.withOpacity(0.85),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.shade300,
                                  Colors.tealAccent.shade100
                                ],
                              ),
                            ),
                            child: Icon(stat['icon'] as IconData,
                                color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stat['title'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc.lastWeekData,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDarkMode
                                        ? Colors.grey.shade400
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            stat['value'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          )
                        ],
                      ),
                    ),
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
