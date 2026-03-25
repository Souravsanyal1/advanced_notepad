import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    Widget nextScreen = isFirstLaunch ? const OnboardingScreen() : const HomeScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,

      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                isDark ? 'assets/splash_dark.png' : 'assets/splash_light.png',
                width: 280,
                // Removed fixed height to maintain aspect ratio
              ),

              const SizedBox(height: 32),
              Text(
                'Advanced Notepad',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 12),
              Text(
                'Sync your thoughts, beautifully.',
                style: TextStyle(
                  fontSize: 16,
                  color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.7),

                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 64),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.white70 : Colors.blueAccent),

                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
