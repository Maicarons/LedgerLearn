import 'package:flutter/material.dart';

enum AppColorScheme {
  blue,
  green,
  purple,
  orange,
  teal;

  String get labelKey => 'theme_color_$name';

  Color get seedColor {
    switch (this) {
      case blue:
        return const Color(0xFF1565C0);
      case green:
        return const Color(0xFF2E7D32);
      case purple:
        return const Color(0xFF6A1B9A);
      case orange:
        return const Color(0xFFE65100);
      case teal:
        return const Color(0xFF00695C);
    }
  }

  String get nameZh {
    switch (this) {
      case blue:
        return '海蓝';
      case green:
        return '翠绿';
      case purple:
        return '紫罗兰';
      case orange:
        return '暖橙';
      case teal:
        return '青碧';
    }
  }
}

class AppTheme {
  // Debit/credit indicator colors (consistent across schemes)
  static const Color debitColor = Color(0xFF1976D2);
  static const Color creditColor = Color(0xFFC62828);
  static const Color balancedColor = Color(0xFF2E7D32);
  static const Color unbalancedColor = Color(0xFFC62828);

  /// Build light theme from a seed color
  static ThemeData light(AppColorScheme scheme) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: scheme.seedColor,
      brightness: Brightness.light,
    );

    return _buildTheme(colorScheme);
  }

  /// Build dark theme from a seed color
  static ThemeData dark(AppColorScheme scheme) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: scheme.seedColor,
      brightness: Brightness.dark,
    );

    return _buildTheme(colorScheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData _buildTheme(ColorScheme cs) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      fontFamilyFallback: const ['Noto Sans SC', 'Noto Sans KR'],
      colorScheme: cs,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: cs.outline),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
