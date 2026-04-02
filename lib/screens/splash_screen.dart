import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'about_screen.dart';
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

    final bool termsAccepted = prefs.getBool('termsAccepted') ?? false;

    if (!termsAccepted) {
      _showTermsDialog(prefs);
    } else {
      _proceedToApp(prefs);
    }
  }

  void _showTermsDialog(SharedPreferences prefs) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          title: Text(
            'Terms & Conditions',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(
              'By using Advanced Notepad, you agree to store your data securely in Cloud Firestore and handle your account responsibility. We respect your privacy and do not share your notes with third parties.',
              style: GoogleFonts.outfit(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await prefs.setBool('termsAccepted', true);
                Navigator.pop(context);
                _showInfoAndProceed(prefs);
              },
              child: Text(
                'Accept & Continue',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInfoAndProceed(SharedPreferences prefs) {
    // Show Information screen then go home
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
    
    // Note: User will have to manually navigate back or we can add a 'Start' button in AboutScreen
    // But since AboutScreen has a back button, it might go back to a dead splash.
    // Better: Navigate to About with a flag or just push it.
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
              AppLoadingWidget(
                color: isDark ? Colors.white70 : Colors.blueAccent,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
