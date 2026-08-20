import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../widgets/reminder_card.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final archived = context.watch<ReminderProvider>().archived;
    return Scaffold(
      appBar: AppBar(title: const Text('Archive')),
      body: archived.isEmpty
          ? Center(child: Text('No archived reminders', style: TextStyle(color: Colors.grey.shade600)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: archived.length,
              itemBuilder: (context, i) => ReminderCard(reminder: archived[i]),
            ),
    );
  }
}
