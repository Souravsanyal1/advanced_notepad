import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import '../widgets/loading_widget.dart';
import 'package:google_fonts/google_fonts.dart';

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
    
    // Total wait time for splash animation
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    _proceedToApp(prefs);
  }

  void _proceedToApp(SharedPreferences prefs) {
    final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
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
                width: 250,
              ),

              const SizedBox(height: 24),
              Text(
                'Advance NotePad',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 8),
              Text(
                'Sync your thoughts, beautifully.',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 64),
              AppLoadingWidget(
                color: isDark ? const Color(0xFFFF9800) : const Color(0xFFFF5722),
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
