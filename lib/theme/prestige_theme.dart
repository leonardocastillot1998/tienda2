import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrestigeColors {
  static const Color primary = Color(0xFF000000);
  static const Color primaryContainer = Color(0xFF0D1C32);
  static const Color secondary = Color(0xFF7C5800);
  static const Color secondaryContainer = Color(0xFFFEB700);
  static const Color onSecondaryContainer = Color(0xFF6B4B00);
  static const Color background = Color(0xFFF7F9FB);
  static const Color surface = Color(0xFFF7F9FB);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E5);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF44474D);
  static const Color outlineVariant = Color(0xFFC5C6CD);
}

ThemeData buildPrestigeTheme() {
  final base = ThemeData(useMaterial3: true);
  final colorScheme =
      const ColorScheme(
        brightness: Brightness.light,
        primary: PrestigeColors.primary,
        onPrimary: Colors.white,
        secondary: PrestigeColors.secondary,
        onSecondary: Colors.white,
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
        surface: PrestigeColors.surface,
        onSurface: PrestigeColors.onSurface,
      ).copyWith(
        primaryContainer: PrestigeColors.primaryContainer,
        secondaryContainer: PrestigeColors.secondaryContainer,
        onSecondaryContainer: PrestigeColors.onSecondaryContainer,
        surfaceContainerLow: PrestigeColors.surfaceContainerLow,
        surfaceContainerLowest: PrestigeColors.surfaceContainerLowest,
        surfaceContainerHigh: PrestigeColors.surfaceContainerHigh,
        surfaceContainerHighest: PrestigeColors.surfaceContainerHighest,
        outlineVariant: PrestigeColors.outlineVariant,
        onSurfaceVariant: PrestigeColors.onSurfaceVariant,
      );

  final bodyTextTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: PrestigeColors.onSurface,
    displayColor: PrestigeColors.onSurface,
  );

  final textTheme = bodyTextTheme.copyWith(
    displayLarge: GoogleFonts.manrope(
      fontSize: 48,
      fontWeight: FontWeight.w800,
      height: 1.04,
      letterSpacing: -1.2,
      color: PrestigeColors.onSurface,
    ),
    headlineMedium: GoogleFonts.manrope(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      color: PrestigeColors.onSurface,
    ),
    titleLarge: GoogleFonts.manrope(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
      color: PrestigeColors.primary,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.8,
      color: PrestigeColors.onSurfaceVariant,
    ),
  );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: PrestigeColors.background,
    textTheme: textTheme,
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      filled: false,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: textTheme.labelSmall,
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: PrestigeColors.outlineVariant.withValues(alpha: 0.5),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: PrestigeColors.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: PrestigeColors.secondaryContainer,
          width: 2,
        ),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFBA1A1A), width: 1.25),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFBA1A1A), width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PrestigeColors.secondaryContainer,
        foregroundColor: PrestigeColors.onSecondaryContainer,
        textStyle: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        minimumSize: const Size.fromHeight(58),
        shape: const StadiumBorder(),
        elevation: 0,
        shadowColor: PrestigeColors.onSurface.withValues(alpha: 0.06),
      ),
    ),
  );
}
