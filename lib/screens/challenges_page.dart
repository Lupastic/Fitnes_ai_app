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
  static const List<Challenge> _allChallenges = [
    Challenge(id: 'water', title: 'Drink Water', frequency: 'Daily', unit: 'cups', target: 8, icon: Icons.local_drink_rounded),
    Challenge(id: 'steps', title: 'Walk Steps', frequency: 'Daily', unit: 'steps', target: 10000, icon: Icons.directions_walk_rounded),
    Challenge(id: 'sleep', title: 'Sleep Quality', frequency: 'Daily', unit: 'h', target: 8, icon: Icons.nightlight_round),
    Challenge(id: 'calories', title: 'Active Burn', frequency: 'Daily', unit: 'kcal', target: 2000, icon: Icons.bolt_rounded),
    Challenge(id: 'yoga', title: 'Yoga Session', frequency: 'Weekly', unit: 'sess', target: 3, icon: Icons.self_improvement_rounded),
    Challenge(id: 'running', title: 'Long Run', frequency: 'Weekly', unit: 'km', target: 15, icon: Icons.speed_rounded),
  ];

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
                  final ch = _allChallenges[i];
                  final isSelected = settings.selectedChallengeIds.contains(ch.id);

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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ch.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                              Text(
                                "${ch.frequency} • Goal: ${ch.target} ${ch.unit}",
                                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                              ),
                            ],
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
                childCount: _allChallenges.length, // ИСПРАВЛЕНО
              ),
            ),
          ),
        ],
      ),
    );
  }
}