import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const seed = Color(0xFF129488);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seed),
      scaffoldBackgroundColor: const Color(0xFFF6F7F5),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          color: const Color(0xFF13292E),
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color: const Color(0xFF1A3338),
          fontWeight: FontWeight.w700,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          color: const Color(0xFF1A3338),
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: const Color(0xFF2E474D),
          height: 1.35,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF425D63),
          height: 1.35,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: const Color(0xFF73848A),
          height: 1.3,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shadowColor: Color(0x1A102021),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide.none,
        backgroundColor: const Color(0xFFEFF3F4),
        selectedColor: const Color(0xFFDCF1EE),
        labelStyle: base.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF325259),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE3F4F0),
        height: 68,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? const Color(0xFF0E7C72) : const Color(0xFF7A8A90),
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? const Color(0xFF0E6D64) : const Color(0xFF65767D),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: base.textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF8A989F),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF8ED4CB)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: Color(0xFFD8E1E4)),
          foregroundColor: const Color(0xFF1D4B52),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF128C80),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
