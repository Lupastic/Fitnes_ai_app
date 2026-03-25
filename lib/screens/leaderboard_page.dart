import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_data_service.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userDataService = context.read<UserDataService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Leaderboard'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: userDataService.getLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final leaderboard = snapshot.data ?? [];
          if (leaderboard.isEmpty) {
            return const Center(child: Text('No users found yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final user = leaderboard[index];
              final isTop3 = index < 3;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isTop3 ? Colors.amber : Colors.teal.withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isTop3 ? Colors.black : Colors.teal,
                      ),
                    ),
                  ),
                  title: Text(
                    user['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    '${user['points']} pts',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.tealAccent,
                      fontSize: 16,
                    ),
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
