import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/favorites_provider.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SmartSpotApp());
}

class SmartSpotApp extends StatelessWidget {
  const SmartSpotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..bootstrap()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'SmartSpot',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
