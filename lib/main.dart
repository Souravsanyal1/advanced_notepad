import 'package:flutter/material.dart';
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
import 'services/local_database_service.dart';
import 'controllers/note_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'controllers/developer_controller.dart';
import 'controllers/auth_controller.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Local Database (Hive)
  final localDb = LocalDatabaseService();
  await localDb.init();
  Get.put(localDb);

  // Initialize Services & Controllers
  Get.put(ThemeService());
  
  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  Get.put(notificationService);

  Get.put(AuthController());
  Get.put(NoteController());
  Get.lazyPut(() => DeveloperController());
  
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
        GetPage(
          name: '/developer-info', 
          page: () => const DeveloperInfoScreen(),
          binding: BindingsBuilder(() => Get.lazyPut(() => DeveloperController())),
        ),
        GetPage(name: '/donation', page: () => const DonationScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
      ],
    ));
  }
}
