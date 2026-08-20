import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reminder.dart';
import '../providers/reminder_provider.dart';
import '../utils/app_theme.dart';
import '../screens/reminder_details_screen.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  const ReminderCard({super.key, required this.reminder});

  IconData get _conditionIcon {
    switch (reminder.conditionType) {
      case 'leave':
        return Icons.logout_rounded;
      case 'time':
        return Icons.schedule_rounded;
      case 'combo':
        return Icons.rule_rounded;
      default:
        return Icons.login_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ReminderProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReminderDetailsScreen(reminderId: reminder.id))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(_conditionIcon, color: AppTheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reminder.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    if (reminder.notes != null && reminder.notes!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(reminder.notes!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                    if (reminder.category != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                        child: Text(reminder.category!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(reminder.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    color: reminder.isFavorite ? AppTheme.accent : Colors.grey.shade400),
                onPressed: () => provider.toggleFavorite(reminder.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
