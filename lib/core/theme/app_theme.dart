import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Matte-black surfaces ──
  static const Color primaryDark   = Color(0xFF000000); // Pure black
  static const Color primaryMid    = Color(0xFF0A0A0A);
  static const Color primaryLight  = Color(0xFF111111); // Card bg

  // ── Single accent ──
  static const Color accentCyan    = Color(0xFF00D1B2);
  // Legacy aliases (kept so existing code compiles)
  static const Color accentPurple  = Color(0xFF00D1B2);
  static const Color accentPink    = Color(0xFFFF4444);
  static const Color accentGreen   = Color(0xFF00D1B2);
  static const Color accentOrange  = Color(0xFFE0A870);
  static const Color accentYellow  = Color(0xFFF5A623);

  // ── Category (muted) ──
  static const Color catTeaching    = Color(0xFF5B9BD5);
  static const Color catLabour      = Color(0xFFD4886C);
  static const Color catDelivery    = Color(0xFF6BBF8A);
  static const Color catCleaning    = Color(0xFF9B7EB5);
  static const Color catTech        = Color(0xFF7986CB);
  static const Color catBabysitting = Color(0xFFD4728C);
  static const Color catElectrical  = Color(0xFFD4C06A);
  static const Color catOther       = Color(0xFF8A9AA4);

  // ── Neutrals ──
  static const Color surface        = Color(0xFF111111);
  static const Color surfaceLight   = Color(0xFF1A1A1A);
  static const Color cardBg         = Color(0xFF111111);
  static const Color cardBgElevated = Color(0xFF1C1C1E);
  static const Color textPrimary    = Color(0xFFFFFFFF);
  static const Color textSecondary  = Color(0xFFA1A1AA); // Zinc-400 equivalent
  static const Color textMuted      = Color(0xFF71717A); // Zinc-500 equivalent
  static const Color divider        = Color(0x0AFFFFFF); // 4% white

  // ── Status ──
  static const Color success = Color(0xFF00D1B2);
  static const Color warning = Color(0xFFF5A623);
  static const Color error   = Color(0xFFFF453A);
  static const Color info    = Color(0xFF5B9BD5);

  // ── Glass (legacy compat) ──
  static const Color glassWhite  = Color(0x00000000);
  static const Color glassBorder = Color(0x0AFFFFFF); // 4% white

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'teaching': case 'tutor': case 'tutoring': return catTeaching;
      case 'labour': case 'labor': case 'mover': case 'helper': return catLabour;
      case 'delivery': return catDelivery;
      case 'cleaning': return catCleaning;
      case 'tech': case 'technology': return catTech;
      case 'babysitting': case 'babysitter': return catBabysitting;
      case 'electrical': case 'electrician': return catElectrical;
      default: return catOther;
    }
  }
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.primaryDark,
      primaryColor: AppColors.accentCyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentCyan,
        secondary: AppColors.accentCyan,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.primaryDark,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.8),
          displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5),
          headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3),
          headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          titleLarge:    TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          titleMedium:   TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          bodyLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
          bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
          bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted),
          labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: false),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.divider, width: 0.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.divider, width: 0.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.accentCyan, width: 1)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentCyan,
          foregroundColor: AppColors.primaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentCyan,
          side: BorderSide(color: AppColors.accentCyan, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.primaryDark,
        selectedItemColor: AppColors.accentCyan,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.accentCyan.withValues(alpha: 0.12),
        labelStyle: TextStyle(color: AppColors.textPrimary, fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      dividerTheme: DividerThemeData(color: AppColors.divider, thickness: 0.5),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentCyan,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardBgElevated,
        contentTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
