import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/challenge.dart';
import '../providers/settings_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  final List<Challenge> _challengeTemplates = [
    const Challenge(id: 'water', title: 'Drink Water', frequency: 'Daily', unit: 'cups', target: 8, icon: Icons.local_drink_rounded),
    const Challenge(id: 'steps', title: 'Walk Steps', frequency: 'Daily', unit: 'steps', target: 10000, icon: Icons.directions_walk_rounded),
    const Challenge(id: 'sleep', title: 'Sleep Quality', frequency: 'Daily', unit: 'h', target: 8, icon: Icons.nightlight_round),
    const Challenge(id: 'calories', title: 'Active Burn', frequency: 'Daily', unit: 'kcal', target: 2000, icon: Icons.bolt_rounded),
  ];

  String _getTranslatedTitle(String id, AppLocalizations loc) {
    switch (id) {
      case 'water': return loc.drinkWater;
      case 'steps': return loc.walkSteps;
      case 'sleep': return loc.sleepQuality;
      case 'calories': return loc.activeBurn;
      default: return id;
    }
  }

  String _getTranslatedUnit(String id, AppLocalizations loc) {
    switch (id) {
      case 'water': return loc.cups;
      case 'steps': return loc.steps;
      case 'sleep': return loc.hours;
      case 'calories': return "kcal";
      default: return "";
    }
  }

  void _showEditGoalDialog(BuildContext context, String id, int currentGoal, String unitLabel) {
    final TextEditingController controller = TextEditingController(text: currentGoal.toString());
    final loc = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.editGoalFor(unitLabel)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(suffixText: unitLabel),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.cancel)),
          ElevatedButton(
            onPressed: () {
              final newVal = int.tryParse(controller.text);
              if (newVal != null) {
                context.read<SettingsProvider>().updateGoal(id, newVal);
                Navigator.pop(context);
              }
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
    final settings = context.watch<SettingsProvider>();
    final isDark = theme.brightness == Brightness.dark;

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
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Text(
                loc.challenges,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              centerTitle: false,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final ch = _challengeTemplates[i];
                  final isSelected = settings.selectedChallengeIds.contains(ch.id);
                  final currentTarget = settings.goals[ch.id] ?? ch.target;
                  
                  final translatedTitle = _getTranslatedTitle(ch.id, loc);
                  final translatedUnit = _getTranslatedUnit(ch.id, loc);
                  final translatedFreq = ch.frequency == 'Daily' ? loc.daily : loc.weekly;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isSelected ? Colors.tealAccent.withOpacity(0.5) : Colors.white.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.tealAccent.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(ch.icon, color: isSelected ? Colors.tealAccent : Colors.grey, size: 26),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showEditGoalDialog(context, ch.id, currentTarget, translatedUnit),
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  translatedTitle, 
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "$translatedFreq • ${loc.goalLabel}: $currentTarget $translatedUnit",
                                        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.edit, size: 14, color: theme.hintColor),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                            color: isSelected ? Colors.tealAccent : Colors.grey.withOpacity(0.5),
                            size: 28,
                          ),
                          onPressed: () => settings.toggleChallenge(ch.id),
                        ),
                      ],
                    ),
                  );
                },
                childCount: _challengeTemplates.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
