import 'package:flutter/material.dart';

final ColorScheme myColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xff0C3E49), // Main color for app
  onPrimary: Colors.white, // Text/icon color on primary
  secondary: Color(0xFF00CC99), // Accent color
  onSecondary: Colors.white,
  error: Colors.red,
  onError: Colors.white,

  surface: Color(0xffbdebc0),
  onSurface: Colors.black,
);

final ThemeData myTheme = ThemeData(
  colorScheme: myColorScheme,
  useMaterial3: true, // Enable Material 3 if needed
  scaffoldBackgroundColor: myColorScheme.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: myColorScheme.primary,
    foregroundColor: myColorScheme.onPrimary,
  ),
  textTheme: TextTheme(bodyMedium: TextStyle(color: myColorScheme.onSurface)),
);
