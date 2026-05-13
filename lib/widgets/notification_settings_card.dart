import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../services/notification_service.dart' as ns;

class NotificationSettingsCard extends StatelessWidget {
  const NotificationSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();

    if (notifProvider.isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final s = notifProvider.settings;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_rounded,
                      color: Colors.tealAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Reminders',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Allow'),
                    onPressed: () async {
                      await notifProvider.requestPermissions();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification permission requested'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _NotifRow(
              icon: Icons.local_drink_rounded,
              iconColor: Colors.blueAccent,
              label: 'Water reminder',
              enabled: s.waterEnabled,
              time: s.waterTime,
              onToggle: (v) => notifProvider.updateSettings(
                s.copyWith(waterEnabled: v),
              ),
              onTimePicked: (t) => notifProvider.updateSettings(
                s.copyWith(waterEnabled: true, waterTime: t),
              ),
            ),
            _NotifRow(
              icon: Icons.directions_run_rounded,
              iconColor: Colors.green,
              label: 'Steps reminder',
              enabled: s.stepsEnabled,
              time: s.stepsTime,
              onToggle: (v) => notifProvider.updateSettings(
                s.copyWith(stepsEnabled: v),
              ),
              onTimePicked: (t) => notifProvider.updateSettings(
                s.copyWith(stepsEnabled: true, stepsTime: t),
              ),
            ),
            _NotifRow(
              icon: Icons.nightlight_round,
              iconColor: Colors.deepPurple,
              label: 'Sleep reminder',
              enabled: s.sleepEnabled,
              time: s.sleepTime,
              onToggle: (v) => notifProvider.updateSettings(
                s.copyWith(sleepEnabled: v),
              ),
              onTimePicked: (t) => notifProvider.updateSettings(
                s.copyWith(sleepEnabled: true, sleepTime: t),
              ),
            ),
            _NotifRow(
              icon: Icons.local_fire_department_rounded,
              iconColor: Colors.orange,
              label: 'Calories reminder',
              enabled: s.caloriesEnabled,
              time: s.caloriesTime,
              onToggle: (v) => notifProvider.updateSettings(
                s.copyWith(caloriesEnabled: v),
              ),
              onTimePicked: (t) => notifProvider.updateSettings(
                s.copyWith(caloriesEnabled: true, caloriesTime: t),
              ),
            ),
            _NotifRow(
              icon: Icons.bar_chart_rounded,
              iconColor: Colors.tealAccent,
              label: 'Daily summary',
              enabled: s.summaryEnabled,
              time: s.summaryTime,
              onToggle: (v) => notifProvider.updateSettings(
                s.copyWith(summaryEnabled: v),
              ),
              onTimePicked: (t) => notifProvider.updateSettings(
                s.copyWith(summaryEnabled: true, summaryTime: t),
              ),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool enabled;
  final TimeOfDay time;
  final ValueChanged<bool> onToggle;
  final ValueChanged<TimeOfDay> onTimePicked;
  final bool isLast;

  const _NotifRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.enabled,
    required this.time,
    required this.onToggle,
    required this.onTimePicked,
    this.isLast = false,
  });

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.15),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(label),
          subtitle: enabled
              ? GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: time,
                    );
                    if (picked != null) onTimePicked(picked);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.tealAccent),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(time),
                        style: const TextStyle(
                          color: Colors.tealAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('· tap to change',
                          style: TextStyle(fontSize: 11)),
                    ],
                  ),
                )
              : const Text('Off'),
          trailing: Switch(
            value: enabled,
            activeColor: Colors.tealAccent,
            onChanged: onToggle,
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}