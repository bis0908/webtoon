import 'package:flutter/material.dart';

class CustomThemeMode {
  static final CustomThemeMode instance = CustomThemeMode._internal();
  static ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);
  static ValueNotifier<bool> isDark = ValueNotifier(false);
  factory CustomThemeMode() => instance;

  static void change() {
    switch (themeMode.value) {
      case ThemeMode.light:
        themeMode.value = ThemeMode.dark;
        isDark.value = true;
        break;
      case ThemeMode.dark:
        themeMode.value = ThemeMode.light;
        isDark.value = false;
        break;
      default:
        themeMode.value = ThemeMode.system;
        isDark.value = true;
    }
  }

  CustomThemeMode._internal();
}
