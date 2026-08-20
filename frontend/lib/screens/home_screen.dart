import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/reminder_card.dart';
import 'add_reminder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReminderProvider>();
    final active = provider.active;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your reminders', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddReminderScreen())),
        icon: const Icon(Icons.add),
        label: const Text('New reminder'),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.refreshFromServer(),
        child: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : active.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                      Icon(Icons.location_off_outlined, size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Center(
                        child: Text('No active reminders yet', style: TextStyle(color: Colors.grey.shade600)),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text('Tap "New reminder" to create one', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: active.length,
                    itemBuilder: (context, i) => ReminderCard(reminder: active[i]),
                  ),
      ),
    );
  }
}
