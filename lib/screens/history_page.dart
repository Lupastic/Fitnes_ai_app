import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_data_service.dart';
import '../models/history_entry.dart';
import 'package:finallapp/generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userDataService = context.read<UserDataService>();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.history),
        centerTitle: true,
      ),
      body: FutureBuilder<List<HistoryEntry>>(
        future: userDataService.getUserHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final history = snapshot.data ?? [];
          if (history.isEmpty) {
            return Center(child: Text(loc.noHistoryYet));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.tealAccent,
                    child: Icon(Icons.history_rounded, color: Colors.black),
                  ),
                  title: Text(
                    entry.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy - HH:mm').format(entry.timestamp),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
