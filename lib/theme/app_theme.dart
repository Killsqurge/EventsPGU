import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData forPalette(AppPalette palette) {
    return ThemeData(
      brightness: palette.brightness,
      scaffoldBackgroundColor: palette.bg,
      colorScheme: ColorScheme(
        brightness: palette.brightness,
        primary: palette.indigo,
        onPrimary: palette.onAccent,
        secondary: palette.amber,
        onSecondary: palette.onAccent,
        error: palette.danger,
        onError: palette.onAccent,
        surface: palette.card,
        onSurface: palette.text,
      ),
      dialogTheme: DialogThemeData(backgroundColor: palette.card),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      extensions: [palette],
    );
  }
}
