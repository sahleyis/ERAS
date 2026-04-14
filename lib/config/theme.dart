import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ERAS Design System — "Panic-Proof" UI
///
/// Design principles:
/// 1. High contrast (dark background, vivid foreground)
/// 2. Large touch targets (minimum 48dp, SOS button 160dp)
/// 3. Minimal cognitive load (2 taps max to trigger SOS)
/// 4. Clear visual hierarchy with emergency-appropriate colors
class ErasTheme {
  ErasTheme._();

  // ─── Brand Colors ───────────────────────────────────────────
  static const Color sosRed = Color(0xFFE53935);
  static const Color sosRedDark = Color(0xFFB71C1C);
  static const Color sosRedLight = Color(0xFFFF6F60);
  static const Color sosRedGlow = Color(0x40E53935);

  static const Color medicalBlue = Color(0xFF1565C0);
  static const Color medicalBlueDark = Color(0xFF003C8F);
  static const Color medicalBlueLight = Color(0xFF5E92F3);

  static const Color successGreen = Color(0xFF2E7D32);
  static const Color successGreenLight = Color(0xFF60AD5E);

  static const Color warningAmber = Color(0xFFF9A825);
  static const Color warningAmberDark = Color(0xFFC17900);

  // ─── Neutral Palette ────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF242424);
  static const Color surfaceCard = Color(0xFF2A2A2A);
  static const Color borderSubtle = Color(0xFF3A3A3A);
  static const Color borderMedium = Color(0xFF555555);

  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF757575);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnRed = Color(0xFFFFFFFF);

  // ─── Emergency Type Colors ──────────────────────────────────
  static const Color cardiacColor = Color(0xFFE53935);
  static const Color traumaColor = Color(0xFFFF6F00);
  static const Color respiratoryColor = Color(0xFF1565C0);
  static const Color burnColor = Color(0xFFE65100);
  static const Color chokingColor = Color(0xFF6A1B9A);
  static const Color otherColor = Color(0xFF546E7A);

  // ─── Verification Badge Colors ──────────────────────────────
  static const Color verifiedColor = Color(0xFF1E88E5);
  static const Color pendingColor = Color(0xFF9E9E9E);
  static const Color rejectedColor = Color(0xFFE53935);

  // ─── Sizing ─────────────────────────────────────────────────
  static const double sosButtonSize = 160.0;
  static const double sosButtonInnerSize = 120.0;
  static const double minTouchTarget = 48.0;
  static const double borderRadiusSm = 8.0;
  static const double borderRadiusMd = 12.0;
  static const double borderRadiusLg = 16.0;
  static const double borderRadiusXl = 24.0;
  static const double borderRadiusFull = 999.0;

  // ─── Spacing ────────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacing2xl = 48.0;
  static const double spacing3xl = 64.0;

  // ─── Shadows ────────────────────────────────────────────────
  static List<BoxShadow> get sosGlow => [
        BoxShadow(
          color: sosRedGlow,
          blurRadius: 40,
          spreadRadius: 10,
        ),
        BoxShadow(
          color: sosRed.withOpacity(0.2),
          blurRadius: 80,
          spreadRadius: 20,
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  // ─── Text Styles ────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -1.0,
        height: 1.1,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textTertiary,
        letterSpacing: 0.5,
      );

  static TextStyle get sosText => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: textOnRed,
        letterSpacing: 8,
      );

  static TextStyle get emergencyTypeLabel => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get statusText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      );

  // ─── Button Styles ──────────────────────────────────────────
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
        backgroundColor: medicalBlue,
        foregroundColor: textOnDark,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
        textStyle: labelLarge,
        elevation: 0,
      );

  static ButtonStyle get dangerButton => ElevatedButton.styleFrom(
        backgroundColor: sosRed,
        foregroundColor: textOnRed,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
        textStyle: labelLarge,
        elevation: 0,
      );

  static ButtonStyle get ghostButton => OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
        side: const BorderSide(color: borderMedium, width: 1.5),
        textStyle: labelLarge,
      );

  static ButtonStyle get acceptButton => ElevatedButton.styleFrom(
        backgroundColor: successGreen,
        foregroundColor: textOnDark,
        minimumSize: const Size(140, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
        textStyle: labelLarge,
        elevation: 0,
      );

  static ButtonStyle get declineButton => ElevatedButton.styleFrom(
        backgroundColor: surfaceCard,
        foregroundColor: textSecondary,
        minimumSize: const Size(140, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
        side: const BorderSide(color: borderSubtle),
        textStyle: labelLarge,
        elevation: 0,
      );

  // ─── Input Decoration ──────────────────────────────────────
  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: labelMedium,
      hintStyle: bodyMedium.copyWith(color: textTertiary),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: textSecondary, size: 22)
          : null,
      suffix: suffix,
      filled: true,
      fillColor: surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingMd,
        vertical: spacingMd,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
        borderSide: const BorderSide(color: borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
        borderSide: const BorderSide(color: borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
        borderSide: const BorderSide(color: medicalBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMd),
        borderSide: const BorderSide(color: sosRed, width: 1.5),
      ),
    );
  }

  // ─── ThemeData ──────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: medicalBlue,
          secondary: sosRed,
          surface: surfaceDark,
          error: sosRed,
          onPrimary: textOnDark,
          onSecondary: textOnRed,
          onSurface: textPrimary,
          onError: textOnRed,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: titleMedium,
          iconTheme: const IconThemeData(color: textPrimary, size: 24),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surfaceDark,
          selectedItemColor: medicalBlue,
          unselectedItemColor: textTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: surfaceCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusLg),
            side: const BorderSide(color: borderSubtle, width: 0.5),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingSm,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surfaceElevated,
          selectedColor: medicalBlue.withOpacity(0.2),
          labelStyle: labelSmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusFull),
          ),
          side: const BorderSide(color: borderSubtle),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingSm,
            vertical: spacingXs,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: borderSubtle,
          thickness: 0.5,
          space: 0,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return successGreen;
            }
            return textTertiary;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return successGreen.withOpacity(0.3);
            }
            return surfaceElevated;
          }),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: surfaceElevated,
          contentTextStyle: bodyMedium.copyWith(color: textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMd),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusXl),
          ),
          titleTextStyle: headlineMedium,
          contentTextStyle: bodyLarge,
        ),
      );
}
