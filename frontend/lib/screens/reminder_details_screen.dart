import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../utils/app_theme.dart';

class ReminderDetailsScreen extends StatelessWidget {
  final String reminderId;
  const ReminderDetailsScreen({super.key, required this.reminderId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReminderProvider>();
    final reminder = provider.reminders.firstWhere((r) => r.id == reminderId);

    return Scaffold(
      appBar: AppBar(
        title: Text(reminder.title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'complete') {
                await provider.setStatus(reminder.id, 'completed');
              } else if (value == 'archive') {
                await provider.setStatus(reminder.id, 'archived');
              } else if (value == 'delete') {
                await provider.deleteReminder(reminder.id);
              }
              if (context.mounted) Navigator.of(context).pop();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'complete', child: Text('Mark completed')),
              PopupMenuItem(value: 'archive', child: Text('Archive')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reminder.notes != null) ...[
              Text(reminder.notes!, style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
              const SizedBox(height: 16),
            ],
            _DetailRow(icon: Icons.category_outlined, label: 'Category', value: reminder.category ?? 'None'),
            _DetailRow(icon: Icons.rule_rounded, label: 'Trigger', value: reminder.conditionType),
            _DetailRow(icon: Icons.radar_rounded, label: 'Radius', value: '${reminder.radiusMeters.round()} m'),
            _DetailRow(icon: Icons.flag_outlined, label: 'Status', value: reminder.status),
            _DetailRow(icon: Icons.update_rounded, label: 'Last updated', value: reminder.updatedAt.toLocal().toString().split('.').first),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
