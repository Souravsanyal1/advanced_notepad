import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/archive_screen.dart';
import 'screens/trash_screen.dart';
import 'screens/about_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/developer_info_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/donation_screen.dart';

import 'theme/app_theme.dart';
import 'services/theme_service.dart';

import 'package:get/get.dart';
import 'controllers/note_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize Services & Controllers
  Get.put(ThemeService());
  Get.put(NoteController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return Obx(() => GetMaterialApp(
      title: 'Advanced Notepad',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/favorites', page: () => const FavoritesScreen()),
        GetPage(name: '/archive', page: () => const ArchiveScreen()),
        GetPage(name: '/trash', page: () => const TrashScreen()),
        GetPage(name: '/about', page: () => const AboutScreen()),
        GetPage(name: '/developer-info', page: () => const DeveloperInfoScreen()),
        GetPage(name: '/donation', page: () => const DonationScreen()),
      ],
    ));
  }
}
