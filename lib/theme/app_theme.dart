import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF1E1E1E);
  static const Color lightGray = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: black,
        primary: black,
        secondary: darkGray,
        brightness: Brightness.light,
        surfaceContainerHighest: Color(0xFFEEEEEE),
      ),
      textTheme: GoogleFonts.outfitTextTheme(),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(
          color: black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: black.withValues(alpha: 0.05)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: black,
        foregroundColor: white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF000000),
        onSurface: white,
        primary: white,
        onPrimary: black,
        secondary: Color(0xFF2C2C2E),
        onSecondary: white,
        surfaceContainerLow: Color(0xFF0A0A0A),
        surfaceContainer: Color(0xFF121212),
        surfaceContainerHigh: Color(0xFF1C1C1E),
        surfaceContainerHighest: Color(0xFF2C2C2E),
        outline: Color(0xFF3A3A3C),
        outlineVariant: Color(0xFF2C2C2E),
      ),
      scaffoldBackgroundColor: black,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: GoogleFonts.outfit(color: white.withValues(alpha: 0.9)),
        bodyMedium: GoogleFonts.outfit(color: white.withValues(alpha: 0.8)),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: white),
        titleTextStyle: GoogleFonts.outfit(
          color: white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF121212),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: white.withValues(alpha: 0.05)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
