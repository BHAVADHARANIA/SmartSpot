import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'main_navigation_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final auth = context.read<AuthProvider>();

    // wait for auth bootstrap + a brief minimum splash time
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 700)),
      _waitForAuthResolved(auth),
    ]);

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

    if (!seenOnboarding) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OnboardingScreen()));
      return;
    }

    if (auth.status == AuthStatus.loggedIn) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigationShell()));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  Future<void> _waitForAuthResolved(AuthProvider auth) async {
    while (auth.status == AuthStatus.unknown) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_rounded, color: Colors.white, size: 72),
            SizedBox(height: 16),
            Text(
              'SmartSpot',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
