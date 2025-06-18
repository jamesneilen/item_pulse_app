import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:item_pulse_app/providers/user_provider.dart';

import 'package:provider/provider.dart';

import '../dashboard/home_screen.dart';
import '../onboarding/splash_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to Firebase Auth state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // --- Case 1: Waiting for the initial auth state from Firebase ---
        // Show the splash screen while Firebase determines if a user is logged in.
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(); // <-- USE SPLASH SCREEN HERE
        }

        // --- Case 2: User is NOT logged into Firebase ---
        if (!authSnapshot.hasData) {
          // No user, so navigate to the LoginScreen.
          return const LoginScreen();
        }

        // --- Case 3: User IS logged in. Now, load their profile data. ---
        // We use a FutureBuilder to call `loadUser` and handle its loading state.
        return FutureBuilder<void>(
          future: context.read<UserProvider>().loadUser(),
          builder: (context, userSnapshot) {
            // --- While `loadUser` is running, continue showing the splash screen ---
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen(); // <-- USE SPLASH SCREEN HERE
            }

            // Check for errors during user data loading
            if (userSnapshot.hasError) {
              // Handle potential errors, e.g., Firestore permission issues.
              // Sending them back to login is a safe fallback.
              print(
                "Error in FutureBuilder while loading user: ${userSnapshot.error}",
              );
              return const LoginScreen();
            }

            // After loadUser is done, check if the user object in the provider is valid.
            // Using `watch` here to ensure the UI rebuilds if the user data changes later.
            final appUser = context.watch<UserProvider>().user;

            if (appUser != null) {
              // Both Firebase auth and Firestore profile are ready. Show the main app.
              return const HomeScreen();
            } else {
              // This can happen if auth is valid but Firestore profile is missing or failed to load.
              // Log the issue and send them back to login.
              print("Auth successful but user profile not found in provider.");
              return const LoginScreen();
            }
          },
        );
      },
    );
  }
}
