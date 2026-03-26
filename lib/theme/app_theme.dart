import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF1E1E1E);
  static const Color lightGray = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00ACC1),
        primary: const Color(0xFF00ACC1),
        secondary: const Color(0xFF8E24AA),
        surface: const Color(0xFFF8FAFC),
        onSurface: const Color(0xFF0D1B3E),
        brightness: Brightness.light,
        surfaceContainerHighest: const Color(0xFFEEEEEE),
      ),
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme).copyWith(
        bodyLarge: GoogleFonts.outfit(textStyle: baseTheme.textTheme.bodyLarge)
            .copyWith(fontFamilyFallback: ['Hind Siliguri', 'sans-serif']),
        bodyMedium: GoogleFonts.outfit(textStyle: baseTheme.textTheme.bodyMedium)
            .copyWith(fontFamilyFallback: ['Hind Siliguri', 'sans-serif']),
        bodySmall: GoogleFonts.outfit(textStyle: baseTheme.textTheme.bodySmall)
            .copyWith(fontFamilyFallback: ['Hind Siliguri', 'sans-serif']),
        titleLarge: GoogleFonts.outfit(textStyle: baseTheme.textTheme.titleLarge)
            .copyWith(fontFamilyFallback: ['Hind Siliguri', 'sans-serif']),
        titleMedium: GoogleFonts.outfit(textStyle: baseTheme.textTheme.titleMedium)
            .copyWith(fontFamilyFallback: ['Hind Siliguri', 'sans-serif']),
        titleSmall: GoogleFonts.outfit(textStyle: baseTheme.textTheme.titleSmall)
            .copyWith(fontFamilyFallback: ['Hind Siliguri', 'sans-serif']),
        labelLarge: GoogleFonts.outfit(textStyle: baseTheme.textTheme.labelLarge)
            .copyWith(fontFamilyFallback: ['Hind Siliguri', 'sans-serif']),
        labelMedium: GoogleFonts.outfit(textStyle: baseTheme.textTheme.labelMedium)
            .copyWith(fontFamilyFallback: ['Hind Siliguri', 'sans-serif']),
        labelSmall: GoogleFonts.outfit(textStyle: baseTheme.textTheme.labelSmall)
            .copyWith(fontFamilyFallback: ['Hind Siliguri', 'sans-serif']),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(
          color: const Color(0xFF0D1B3E),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ).copyWith(fontFamilyFallback: [
          'Hind Siliguri',
          'sans-serif',
        ]),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: black.withValues(alpha: 0.05)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF0D1B3E),
        foregroundColor: white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        surface: const Color(0xFF0D1B3E),
        onSurface: white,
        primary: const Color(0xFF00ACC1),
        onPrimary: white,
        secondary: const Color(0xFFBA68C8),
        onSecondary: white,
        surfaceContainerLow: const Color(0xFF050B18),
        surfaceContainer: const Color(0xFF0D1B3E),
        surfaceContainerHigh: const Color(0xFF152248),
        surfaceContainerHighest: const Color(0xFF1E2E5E),
        outline: const Color(0xFF2C3E75),
        outlineVariant: const Color(0xFF1E2E5E),
        secondaryContainer: const Color(0xFF00ACC1).withValues(alpha: 0.2),
      ),
      scaffoldBackgroundColor: const Color(0xFF050B18),
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme).copyWith(
        bodyLarge: GoogleFonts.outfit(textStyle: baseTheme.textTheme.bodyLarge)
            .copyWith(
          color: white.withValues(alpha: 0.9),
          fontFamilyFallback: ['Hind Siliguri', 'sans-serif'],
        ),
        bodyMedium: GoogleFonts.outfit(textStyle: baseTheme.textTheme.bodyMedium)
            .copyWith(
          color: white.withValues(alpha: 0.8),
          fontFamilyFallback: ['Hind Siliguri', 'sans-serif'],
        ),
        bodySmall: GoogleFonts.outfit(textStyle: baseTheme.textTheme.bodySmall)
            .copyWith(
          color: white.withValues(alpha: 0.7),
          fontFamilyFallback: ['Hind Siliguri', 'sans-serif'],
        ),
        titleLarge: GoogleFonts.outfit(textStyle: baseTheme.textTheme.titleLarge)
            .copyWith(
          color: white,
          fontFamilyFallback: ['Hind Siliguri', 'sans-serif'],
        ),
        titleMedium: GoogleFonts.outfit(textStyle: baseTheme.textTheme.titleMedium)
            .copyWith(
          color: white,
          fontFamilyFallback: ['Hind Siliguri', 'sans-serif'],
        ),
        titleSmall: GoogleFonts.outfit(textStyle: baseTheme.textTheme.titleSmall)
            .copyWith(
          color: white.withValues(alpha: 0.9),
          fontFamilyFallback: ['Hind Siliguri', 'sans-serif'],
        ),
        labelLarge: GoogleFonts.outfit(textStyle: baseTheme.textTheme.labelLarge)
            .copyWith(
          color: white,
          fontFamilyFallback: ['Hind Siliguri', 'sans-serif'],
        ),
        labelMedium: GoogleFonts.outfit(textStyle: baseTheme.textTheme.labelMedium)
            .copyWith(
          color: white.withValues(alpha: 0.8),
          fontFamilyFallback: ['Hind Siliguri', 'sans-serif'],
        ),
        labelSmall: GoogleFonts.outfit(textStyle: baseTheme.textTheme.labelSmall)
            .copyWith(
          color: white.withValues(alpha: 0.7),
          fontFamilyFallback: ['Hind Siliguri', 'sans-serif'],
        ),
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
        ).copyWith(fontFamilyFallback: ['Hind Siliguri', 'sans-serif']),
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
        backgroundColor: const Color(0xFF00ACC1),
        foregroundColor: white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static Color getNoteColor(int colorValue, bool isDarkMode) {
    if (!isDarkMode) return Color(colorValue);

    // Map light colors to dark versions for Dark Mode
    switch (colorValue) {
      case 0xFFFFFFFF: return const Color(0xFF121212); // White
      case 0xFFF28B82: return const Color(0xFF3C1F1D); // Red
      case 0xFFFBBC04: return const Color(0xFF3C2F1D); // Orange
      case 0xFFFFF475: return const Color(0xFF3C3C1D); // Yellow
      case 0xFFCCFF90: return const Color(0xFF1D3C1D); // Green
      case 0xFFA7FFEB: return const Color(0xFF1D3C3C); // Teal
      case 0xFFCBF0F8: return const Color(0xFF1D2F3C); // Blue
      case 0xFFAFCBFF: return const Color(0xFF1D1F3C); // Dark Blue
      case 0xFFD7AEFB: return const Color(0xFF2F1D3C); // Purple
      case 0xFFFDCFE8: return const Color(0xFF3C1D2F); // Pink
      case 0xFFE6C9A8: return const Color(0xFF2E241A); // Brown
      case 0xFFE8EAED: return const Color(0xFF202124); // Gray
      case 0xFFF5F5DC: return const Color(0xFF2E2E20); // Beige
      case 0xFFFFE4E1: return const Color(0xFF2E1A1A); // Misty Rose
      case 0xFFE0FFFF: return const Color(0xFF1A2E2E); // Light Cyan
      case 0xFFF0F8FF: return const Color(0xFF1A1F2E); // Alice Blue
      case 0xFFFFFACD: return const Color(0xFF2E2E1A); // Lemon Chiffon
      case 0xFFFFE4B5: return const Color(0xFF2E241A); // Moccasin
      case 0xFFFFDAB9: return const Color(0xFF2E1E1A); // Peach Puff
      case 0xFFE6E6FA: return const Color(0xFF1E1A2E); // Lavender
      case 0xFFFFF0F5: return const Color(0xFF2E1A22); // Lavender Blush
      case 0xFFF0FFF0: return const Color(0xFF1A2E1A); // Honeydew
      case 0xFFFAF0E6: return const Color(0xFF2E2820); // Linen
      case 0xFFEDF2FB: return const Color(0xFF1A1B2E); // Soft Blue
      case 0xFFE2F0CB: return const Color(0xFF1E2E1A); // Soft Lime
      default:
        return Color(colorValue);
    }
  }
}
