import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Theme Provider — manages dark/light mode state
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark);

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setDark() => state = ThemeMode.dark;
  void setLight() => state = ThemeMode.light;
  void setSystem() => state = ThemeMode.system;

  bool get isDark => state == ThemeMode.dark;
}

/// Provides the current ThemeData based on theme mode
ThemeData getThemeData(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.dark:
      return DarkTheme.theme;
    case ThemeMode.light:
      return LightTheme.theme;
    case ThemeMode.system:
      return DarkTheme.theme; // Default to dark
  }
}
