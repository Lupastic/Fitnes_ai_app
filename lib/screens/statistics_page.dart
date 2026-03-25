import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/summary_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'stat_details_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final summary = context.watch<SummaryProvider>().today;

    final List<Map<String, dynamic>> stats = [
      {
        'id': 'water', 
        'title': loc.water, 
        'value': '${summary.waterCups} ${loc.cups}', 
        'icon': Icons.local_drink_rounded, 
        'color': Colors.lightBlueAccent
      },
      {
        'id': 'sleep', 
        'title': loc.sleep, 
        'value': '${summary.sleepHours.toStringAsFixed(1)} ${loc.hours}', 
        'icon': Icons.nightlight_round, 
        'color': Colors.purpleAccent
      },
      {
        'id': 'calories', 
        'title': loc.calories, 
        'value': '${summary.calories} kcal', 
        'icon': Icons.bolt_rounded, 
        'color': Colors.orangeAccent
      },
      {
        'id': 'steps', 
        'title': loc.steps, 
        'value': '${summary.steps}', 
        'icon': Icons.directions_walk_rounded, 
        'color': Colors.greenAccent
      },
    ];

    final filteredStats = stats.where((s) => s['title'].toString().toLowerCase().contains(query.toLowerCase())).toList();

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
                icon: const Icon(Icons.leaderboard_rounded, color: Colors.tealAccent),
                onPressed: () => Navigator.pushNamed(context, '/leaderboard'),
                tooltip: 'Leaderboard',
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Text(
                loc.statistics,
                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 22),
              ),
              centerTitle: false,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final s = filteredStats[index];
                  final color = s['color'] as Color;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(s['icon'], color: color, size: 26),
                      ),
                      title: Text(s['title'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                      subtitle: Text(loc.lastWeekData, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(s['value'], style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
                          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color.withOpacity(0.5)),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StatDetailsPage(
                              title: s['title'],
                              statKey: s['id'],
                              icon: s['icon'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: filteredStats.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
