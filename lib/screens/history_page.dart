import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        print("Fetched ${firebaseHistory.length} entries from Firebase.");
      } else {
        print("User is not logged in.");
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

      print("Fetched ${localHistory.length} entries from Hive.");
      allHistory.addAll(localHistory);
    } catch (e) {
      print("Hive error: $e");
    }

    allHistory.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    setState(() {
      _history = allHistory;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text(loc.history)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? Center(child: Text(loc.noHistoryYet))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final entry = _history[index];
          final formattedDate = dateFormatter.format(entry['timestamp']);
          final source = entry['source'] == 'firebase' ? loc.synced : loc.local;

          return ListTile(
            leading: Icon(Icons.history, color: entry['source'] == 'firebase' ? Colors.blue : Colors.grey),
            title: Text(entry['title'] ?? loc.noTitle),
            subtitle: Text('$formattedDate • $source'),
          );
        },
      ),
    );
  }
}
