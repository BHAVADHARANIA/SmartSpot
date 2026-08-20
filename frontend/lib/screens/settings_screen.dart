import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'archive_screen.dart';
import 'completed_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          if (user != null)
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(user['name'] ?? 'SmartSpot user'),
              subtitle: Text(user['email'] ?? ''),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: const Text('Completed reminders'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CompletedScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: const Text('Archived reminders'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ArchiveScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
