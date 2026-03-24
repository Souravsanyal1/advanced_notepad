import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
 import 'screens/archive_screen.dart';
import 'screens/trash_screen.dart';
import 'screens/about_screen.dart';
import 'screens/splash_screen.dart';

import 'theme/app_theme.dart';
import 'services/theme_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) {
        return MaterialApp(
          title: 'Advanced Notepad',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeService().themeMode,
          routes: {
             '/': (context) => const SplashScreen(),
            '/home': (context) => const HomeScreen(),
            '/archive': (context) => const ArchiveScreen(),
            '/trash': (context) => const TrashScreen(),
            '/about': (context) => const AboutScreen(),


          },
        );
      },
    );
  }
}
