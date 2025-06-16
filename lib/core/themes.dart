// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

// Your custom ColorScheme
final ColorScheme myColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: const Color(0xff0C3E49), // Deep Blue/Teal - Main color for app
  onPrimary: Colors.white, // Text/icon color on primary
  primaryContainer: const Color(
    0xff115c6e,
  ), // A slightly lighter shade for containers

  secondary: const Color(
    0xFF00CC99,
  ), // Mint Green - Accent color for FABs, etc.
  onSecondary: Colors.white, // Text/icon on secondary
  secondaryContainer: const Color(0xff99ffde),

  error: const Color(0xFFB00020),
  onError: Colors.white,

  surface: const Color(
    0xffF0FFF3,
  ), // A very light, pleasant green for backgrounds
  onSurface: const Color(0xFF1a1c1a), // Dark text color on surface
  // You must define all required colors. Here are some defaults.
  background: const Color(0xffF0FFF3),
  onBackground: const Color(0xFF1a1c1a),
  surfaceVariant: Colors.grey.shade200,
  onSurfaceVariant: Colors.black,
  outline: Colors.grey.shade400,
  inversePrimary: Colors.white,
  inverseSurface: const Color(0xFF1a1c1a),
  onInverseSurface: const Color(0xffF0FFF3),
);

// Your custom ThemeData
final ThemeData myTheme = ThemeData(
  colorScheme: myColorScheme,
  useMaterial3: true,
  scaffoldBackgroundColor: myColorScheme.surface,

  // --- Component Themes ---
  appBarTheme: AppBarTheme(
    backgroundColor: myColorScheme.primary,
    foregroundColor: myColorScheme.onPrimary, // For icons and back button
    titleTextStyle: TextStyle(
      // Explicitly style the title
      color: myColorScheme.onPrimary,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),

  cardTheme: CardTheme(
    elevation: 2,
    color: Colors.white, // Make cards stand out from the scaffold background
    surfaceTintColor: Colors.white, // Prevents M3 tinting
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: myColorScheme.secondary,
    foregroundColor: myColorScheme.onSecondary,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: myColorScheme.primary,
      foregroundColor: myColorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),

  // --- Text Theme ---
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xFF1a1c1a), fontSize: 14),
    headlineSmall: TextStyle(
      color: Color(0xFF1a1c1a),
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: Color(0xFF1a1c1a),
      fontWeight: FontWeight.bold,
    ),
  ),
);
// Custom ColorScheme for the Dark Theme
final ColorScheme myDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  // Primary colors are now lighter to stand out on a dark background
  primary: const Color(
    0xff58C3D7,
  ), // A lighter, soft teal for buttons/highlights
  onPrimary: const Color(0xff002025), // Very dark text on the light primary
  // Secondary (accent) is slightly desaturated
  secondary: const Color(0xff38D9A9), // A pleasant, still vibrant mint
  onSecondary: const Color(0xff00382B), // Very dark text on the mint accent
  // Surface colors define the layering
  surface: const Color(0xff1a2c30), // The main dark background (dark teal/grey)
  onSurface: const Color(0xffe2e8e9), // Off-white for body text
  // A slightly lighter surface for elevated components like Cards
  surfaceVariant: const Color(0xff223d45),
  onSurfaceVariant: const Color(0xffe2e8e9),

  // Error colors
  error: const Color(0xffcf6679), // Standard Material dark error color
  onError: Colors.black,

  // You must define all required colors.
  background: const Color(0xff1a2c30),
  onBackground: const Color(0xffe2e8e9),
  outline: Colors.grey.shade600,
  inversePrimary: const Color(0xff0C3E49),
  inverseSurface: const Color(0xffe2e8e9),
  onInverseSurface: const Color(0xff1a2c30),
);

// Custom ThemeData for the Dark Theme
final ThemeData myDarkTheme = ThemeData(
  colorScheme: myDarkColorScheme,
  useMaterial3: true,
  scaffoldBackgroundColor: myDarkColorScheme.surface,

  // --- Component Themes for Dark Mode ---
  appBarTheme: AppBarTheme(
    backgroundColor:
        myDarkColorScheme.surfaceVariant, // Slightly lighter than scaffold
    foregroundColor: myDarkColorScheme.onSurface, // For icons and back button
    titleTextStyle: TextStyle(
      color: myDarkColorScheme.onSurface,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),

  cardTheme: CardTheme(
    elevation: 1,
    color:
        myDarkColorScheme
            .surfaceVariant, // Cards are lighter than the background
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: myDarkColorScheme.secondary,
    foregroundColor: myDarkColorScheme.onSecondary,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: myDarkColorScheme.primary,
      foregroundColor: myDarkColorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),

  // --- Text Theme for Dark Mode ---
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: myDarkColorScheme.onSurface),
    headlineSmall: TextStyle(
      color: myDarkColorScheme.onSurface,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: myDarkColorScheme.onSurface,
      fontWeight: FontWeight.bold,
    ),
  ),

  // Other minor tweaks
  dividerTheme: const DividerThemeData(color: Colors.white24),
  iconTheme: IconThemeData(color: myDarkColorScheme.onSurface),
);
