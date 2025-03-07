import 'package:flutter/material.dart';
import 'package:webtoon/screens/home_screen.dart';
import 'package:webtoon/theme/custom_theme.dart';
import 'package:webtoon/theme/custom_theme_mode.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: CustomThemeMode.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          darkTheme: CustomTheme.dark,
          theme: CustomTheme.light,
          themeMode: themeMode,
          home: HomeScreen(),
        );
      },
    );
  }
}
