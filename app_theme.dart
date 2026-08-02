import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Night Fury / Toothless inspired color system.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF11151F);
  static const Color glassFill = Color(0x1AFFFFFF); // translucent white 10%
  static const Color glassBorder = Color(0x3300FF66); // emerald 20%

  // Night Fury glow
  static const Color neonGreen = Color(0xFF00FF66);
  static const Color emerald = Color(0xFF10B981);

  // Alerts
  static const Color crimson = Color(0xFFFF2A6D);
  static const Color plasmaCyan = Color(0xFF00E5FF);

  static const Color textPrimary = Color(0xFFEAF6EF);
  static const Color textMuted = Color(0xFF8CA39A);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.orbitronTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.neonGreen,
        secondary: AppColors.plasmaCyan,
        error: AppColors.crimson,
        surface: AppColors.surface,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.neonGreen
              : AppColors.crimson,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.emerald.withOpacity(0.4)
              : AppColors.crimson.withOpacity(0.3),
        ),
      ),
    );
  }
}

/// Reusable glow box-shadow helper for the "Night Fury" neon look.
List<BoxShadow> neonGlow(Color color, {double blur = 18, double spread = 1}) {
  return [
    BoxShadow(color: color.withOpacity(0.55), blurRadius: blur, spreadRadius: spread),
    BoxShadow(color: color.withOpacity(0.25), blurRadius: blur * 2, spreadRadius: spread),
  ];
}
