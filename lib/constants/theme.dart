import 'package:flutter/material.dart';

class AppTheme {
  // Dynamically updated colors used by widgets that need direct color access
  static Color primary = const Color(0xFFCC7861);
  static Color primaryLight = const Color(0xFFE8A996);
  static Color background = const Color(0xFFFFF5F0);
  static Color surface = Colors.white;
  static Color cardColor = const Color(0xFFFDEDE6);
  static Color textPrimary = const Color(0xFF1A1A1A);
  static Color textSecondary = const Color(0xFF666666);
  static bool isDark = false;

  // Fixed semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color accent = Color(0xFF6C63FF);

  // Preset color palette
  static const List<Color> presetColors = [
    Color(0xFFCC7861), // Salmon
    Color(0xFF7C4DFF), // Purple
    Color(0xFF1976D2), // Blue
    Color(0xFF00897B), // Teal
    Color(0xFFE65100), // Orange
    Color(0xFFC2185B), // Pink
    Color(0xFF388E3C), // Green
    Color(0xFF5C6BC0), // Indigo
  ];

  static void update(Color newPrimary, bool dark) {
    primary = newPrimary;
    isDark = dark;
    final hsl = HSLColor.fromColor(newPrimary);
    primaryLight =
        hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor();

    if (dark) {
      background = const Color(0xFF121212);
      surface = const Color(0xFF1E1E1E);
      cardColor = const Color(0xFF2A2A2A);
      textPrimary = const Color(0xFFF0F0F0);
      textSecondary = const Color(0xFFAAAAAA);
    } else {
      final bgHsl = HSLColor.fromColor(newPrimary);
      background = bgHsl.withLightness(0.97).withSaturation(0.4).toColor();
      surface = Colors.white;
      cardColor = bgHsl.withLightness(0.93).withSaturation(0.35).toColor();
      textPrimary = const Color(0xFF1A1A1A);
      textSecondary = const Color(0xFF666666);
    }
  }

  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: isDark ? Brightness.dark : Brightness.light,
    ).copyWith(primary: primary, surface: surface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ).copyWith(backgroundColor: primary, foregroundColor: Colors.white),
      cardTheme: CardThemeData(
        color: surface,
        elevation: isDark ? 0 : 2,
        shadowColor: primary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark
              ? BorderSide(color: Colors.white.withValues(alpha: 0.08))
              : BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : primaryLight.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : primaryLight.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.6)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dividerTheme: DividerThemeData(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : primary.withValues(alpha: 0.1),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return primary;
            return isDark
                ? Colors.white.withValues(alpha: 0.06)
                : cardColor;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return textPrimary;
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: primary.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }
}
