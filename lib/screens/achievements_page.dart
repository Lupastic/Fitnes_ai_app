import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quest.dart';
import '../providers/settings_provider.dart';
import '../providers/summary_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuestsPage extends StatelessWidget {
  const QuestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final summary = context.watch<SummaryProvider>().today;

    final List<Quest> allQuests = [
      Quest(
        id: 'water_5',
        title: 'Hydration Starter',
        description: 'Drink 5 cups of water today',
        icon: Icons.local_drink,
        difficulty: QuestDifficulty.easy,
        points: 10,
        isCompleted: (data) => (data as int) >= 5,
      ),
      Quest(
        id: 'steps_5k',
        title: 'Active Mover',
        description: 'Walk 5,000 steps',
        icon: Icons.directions_walk,
        difficulty: QuestDifficulty.easy,
        points: 15,
        isCompleted: (data) => (data as int) >= 5000,
      ),
      Quest(
        id: 'water_10',
        title: 'Aqua Master',
        description: 'Drink 10 cups of water today',
        icon: Icons.water_drop,
        difficulty: QuestDifficulty.medium,
        points: 30,
        isCompleted: (data) => (data as int) >= 10,
      ),
      Quest(
        id: 'steps_10k',
        title: 'Step Legend',
        description: 'Walk 10,000 steps',
        icon: Icons.directions_run,
        difficulty: QuestDifficulty.medium,
        points: 50,
        isCompleted: (data) => (data as int) >= 10000,
      ),
      Quest(
        id: 'sleep_8',
        title: 'Well Rested',
        description: 'Sleep for 8 hours',
        icon: Icons.bedtime,
        difficulty: QuestDifficulty.medium,
        points: 25,
        isCompleted: (data) => (data as double) >= 8.0,
      ),
      Quest(
        id: 'perfect_day',
        title: 'Ultimate Champion',
        description: 'Complete all your daily goals',
        icon: Icons.emoji_events,
        difficulty: QuestDifficulty.hard,
        points: 100,
        isCompleted: (data) {
          final s = data as dynamic;
          return s.waterCups >= 8 && s.steps >= 10000 && s.sleepHours >= 8;
        },
      ),
    ];

    // Check for completions
    for (var q in allQuests) {
      if (!settings.completedQuests.contains(q.id)) {
        dynamic data;
        if (q.id.contains('water')) data = summary.waterCups;
        else if (q.id.contains('steps')) data = summary.steps;
        else if (q.id.contains('sleep')) data = summary.sleepHours;
        else if (q.id == 'perfect_day') data = summary;

        if (data != null && q.isCompleted(data)) {
          Future.microtask(() => settings.completeQuest(q.id, q.points));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quests'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${settings.points} pts',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.tealAccent),
              ),
            ),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allQuests.length,
        itemBuilder: (context, index) {
          final quest = allQuests[index];
          final isDone = settings.completedQuests.contains(quest.id);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: isDone ? Colors.tealAccent.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                child: Icon(quest.icon, color: isDone ? Colors.tealAccent : Colors.grey),
              ),
              title: Text(quest.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quest.description),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(quest.difficulty).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${quest.difficulty.name.toUpperCase()} • ${quest.points} pts',
                      style: TextStyle(fontSize: 10, color: _getDifficultyColor(quest.difficulty), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              trailing: isDone 
                ? const Icon(Icons.check_circle, color: Colors.tealAccent)
                : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Color _getDifficultyColor(QuestDifficulty d) {
    switch (d) {
      case QuestDifficulty.easy: return Colors.green;
      case QuestDifficulty.medium: return Colors.orange;
      case QuestDifficulty.hard: return Colors.red;
    }
  }
}
