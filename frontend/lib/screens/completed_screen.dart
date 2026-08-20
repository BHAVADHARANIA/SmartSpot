import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../widgets/reminder_card.dart';

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final completed = context.watch<ReminderProvider>().completed;
    return Scaffold(
      appBar: AppBar(title: const Text('Completed')),
      body: completed.isEmpty
          ? Center(child: Text('No completed reminders', style: TextStyle(color: Colors.grey.shade600)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completed.length,
              itemBuilder: (context, i) => ReminderCard(reminder: completed[i]),
            ),
    );
  }
}
