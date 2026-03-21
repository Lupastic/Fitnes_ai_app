import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_summary.dart';
import '../services/user_data_service.dart';
import 'package:intl/intl.dart';

class StatDetailsPage extends StatelessWidget {
  final String title;
  final String statKey; // 'water', 'steps', 'calories', 'sleep'
  final IconData icon;

  const StatDetailsPage({
    super.key,
    required this.title,
    required this.statKey,
    required this.icon,
  });

  double _getValue(DailySummary summary) {
    switch (statKey) {
      case 'water': return summary.waterCups.toDouble();
      case 'steps': return summary.steps.toDouble();
      case 'calories': return summary.calories.toDouble();
      case 'sleep': return summary.sleepHours;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDataService = context.read<UserDataService>();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<DailySummary>>(
        future: userDataService.getSummariesForLastDays(7),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data for the last 7 days"));
          }

          final data = snapshot.data!;
          final maxVal = data.map(_getValue).fold(1.0, (prev, curr) => curr > prev ? curr : prev);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 40, color: Colors.tealAccent),
                    const SizedBox(width: 12),
                    Text("Weekly Progress", style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: data.map((s) {
                      final val = _getValue(s);
                      final heightFactor = val / maxVal;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(val.toStringAsFixed(statKey == 'sleep' ? 1 : 0), 
                               style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Container(
                            width: 30,
                            height: (MediaQuery.of(context).size.height * 0.4) * heightFactor,
                            decoration: BoxDecoration(
                              color: Colors.tealAccent.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(DateFormat('E').format(s.date), 
                               style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 40),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text("Average Value"),
                    trailing: Text((data.map(_getValue).reduce((a, b) => a + b) / data.length).toStringAsFixed(1)),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}