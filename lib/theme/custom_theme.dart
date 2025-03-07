import 'package:flutter/material.dart';

class CustomTheme {
  static final ThemeData dark = ThemeData(
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.grey[300],
    ),
    scaffoldBackgroundColor: Colors.grey[700],
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.grey[800]!,
      onPrimary: Colors.grey[300]!,
      secondary: Colors.grey[700]!,
      onSecondary: Colors.grey[300]!,
      error: Colors.grey[900]!,
      onError: Colors.grey[300]!,
      surface: Colors.green[800]!,
      onSurface: Colors.grey[400]!,
    ),
  );
  static final ThemeData light = ThemeData(
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.green,
    ),
    scaffoldBackgroundColor: Colors.white,
  );
}
