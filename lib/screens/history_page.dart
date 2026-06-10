
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:finallapp/generated/l10n/app_localizations.dart';

import '../models/history_entry.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    List<Map<String, dynamic>> allHistory = [];

    try {
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('history')
            .orderBy('timestamp', descending: true)
            .get();

        final firebaseHistory = snapshot.docs.map((doc) {
          final timestamp = doc['timestamp'];
          return {
            'title': doc['title'],
            'timestamp': timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
            'source': 'firebase',
          };
        }).toList();

        allHistory.addAll(firebaseHistory);
      }
    } catch (e) {
      print("Firebase error: $e");
    }

    try {
      final box = await Hive.openBox<HistoryEntry>('history');
      final localHistory = box.values.map((entry) {
        return {
          'title': entry.title,
          'timestamp': entry.timestamp,
          'source': 'local',
        };
      }).toList();
      allHistory.addAll(localHistory);
    } catch (e) {
      print("Hive error: $e");
    }

    // Удаление дубликатов по заголовку и времени (с точностью до минуты)
    final seen = <String>{};
    final uniqueHistory = <Map<String, dynamic>>[];

    allHistory.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    for (var entry in allHistory) {
      final ts = entry['timestamp'] as DateTime;
      final key = "${entry['title']}_${ts.year}${ts.month}${ts.day}${ts.hour}${ts.minute}";
      if (!seen.contains(key)) {
        seen.add(key);
        uniqueHistory.add(entry);
      }
    }

    setState(() {
      _history = uniqueHistory;
      _loading = false;
    });
  }

  String _translateHistoryTitle(String? title, AppLocalizations loc) {
    if (title == null) return loc.noTitle;

    // Check for encoded format: TYPE:ID:VALUE:UNIT
    if (title.startsWith("LOG:")) {
      final parts = title.split(":");
      if (parts.length >= 4) {
        final id = parts[1];
        final val = parts[2];
        final unitKey = parts[3];

        String label = id;
        if (id == 'water') label = loc.water;
        else if (id == 'steps') label = loc.steps;
        else if (id == 'sleep') label = loc.sleep;
        else if (id == 'calories') label = loc.calories;

        String unit = unitKey;
        if (unitKey == 'cups') unit = loc.cups;
        else if (unitKey == 'steps') unit = loc.steps;
        else if (unitKey == 'h') unit = loc.hours;
        else if (unitKey == 'kcal') unit = loc.kcal;

        return "$label: +$val $unit";
      }
    }

    if (title.startsWith("ONB:")) {
      final goal = title.replaceFirst("ONB:", "");
      String translatedGoal = goal;
      if (goal == 'Lose Weight') translatedGoal = loc.loseWeight;
      else if (goal == 'Gain Weight') translatedGoal = loc.gainWeight;
      else if (goal == 'Get Fit') translatedGoal = loc.getFit;
      return "${loc.profileUpdated}: $translatedGoal";
    }

    if (title.startsWith("QST:")) {
      final parts = title.split(":");
      if (parts.length >= 3) {
        final questTitle = parts[1]; // We should have saved the key really
        final pts = parts[2];
        return "${loc.questCompleted}: $questTitle (+$pts ${loc.pts})";
      }
    }

    return title;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormatter = DateFormat('dd MMM, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.history, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off_rounded, size: 64, color: theme.disabledColor),
                  const SizedBox(height: 16),
                  Text(loc.noHistoryYet, style: TextStyle(color: theme.disabledColor, fontSize: 16)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _history.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = _history[index];
                  final DateTime ts = entry['timestamp'];
                  final bool isSynced = entry['source'] == 'firebase';

                  return Container(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSynced ? Colors.tealAccent.withOpacity(0.1) : Colors.transparent),
                      boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: isSynced ? Colors.tealAccent.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        child: Icon(
                          isSynced ? Icons.cloud_done_rounded : Icons.access_time_rounded,
                          color: isSynced ? Colors.tealAccent : Colors.grey,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        _translateHistoryTitle(entry['title'], loc),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        dateFormatter.format(ts),
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSynced ? Colors.tealAccent.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isSynced ? loc.synced : loc.local,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSynced ? Colors.tealAccent : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}