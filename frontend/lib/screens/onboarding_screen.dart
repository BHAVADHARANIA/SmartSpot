import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String body;
  const _OnboardingPage(this.icon, this.title, this.body);
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardingPage(
      Icons.place_outlined,
      'Reminders that know where you are',
      'Set a reminder for a place, not just a time. Get nudged the moment you arrive or leave.',
    ),
    _OnboardingPage(
      Icons.star_outline_rounded,
      'Save your favorite spots',
      'Home, work, the gym \u2014 save the places you visit often for one-tap reminders.',
    ),
    _OnboardingPage(
      Icons.insights_outlined,
      'See your patterns',
      'SmartSpot learns from your visits and surfaces useful suggestions over time.',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(onPressed: _finish, child: const Text('Skip')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(p.icon, size: 64, color: AppTheme.primary),
                        ),
                        const SizedBox(height: 36),
                        Text(p.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Text(p.body, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.4)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i ? AppTheme.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_page == _pages.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                    }
                  },
                  child: Text(_page == _pages.length - 1 ? 'Get started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
