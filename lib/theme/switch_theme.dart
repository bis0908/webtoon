import 'package:flutter/material.dart';
import 'package:webtoon/theme/custom_theme_mode.dart';

IconButton switchTheme() {
  return IconButton(
    onPressed: () {
      CustomThemeMode.change();
    },
    icon: ValueListenableBuilder<bool>(
      valueListenable: CustomThemeMode.isDark,
      builder: (context, isDark, child) {
        return Icon(
          isDark ? Icons.dark_mode : Icons.light_mode,
        );
      },
    ),
  );
}
