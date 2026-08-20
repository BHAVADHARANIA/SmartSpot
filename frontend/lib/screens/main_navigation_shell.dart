import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'favorites_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    MapScreen(),
    FavoritesScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().load();
      context.read<FavoritesProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: AppTheme.primary.withOpacity(0.15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
