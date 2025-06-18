// File: lib/screens/auth/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screen.dart';
import '../dashboard/home_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    // Listen to authentication state changes instead of a one-time check.
    // This is more robust and reactive.
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      // Add a small delay to ensure the splash animation is visible
      // and the transition feels smooth, not jarring.
      Future.delayed(const Duration(milliseconds: 1500), () {
        _navigate(user);
      });
    });
  }

  /// Safely navigates to the next screen based on the user's auth state.
  Future<void> _navigate(User? user) async {
    // This check is crucial. If the widget was disposed (e.g., user backs out)
    // before the async operation completes, we should not use its context.
    if (!mounted) return;

    if (user != null) {
      // User is logged in. Load their data.
      // We use context.read inside the check to ensure context is valid.
      await context.read<UserProvider>().loadUser();

      // Check again for mounted status after the async call.
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // User is not logged in.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _authSubscription
        .cancel(); // Don't forget to cancel the stream subscription!
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    const double logoSize = 120.0;
    const double logoPadding = 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: logoSize,
                width: logoSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.05),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(logoPadding),
                  child: SvgPicture.asset(
                    'assets/images/itemPulse.svg',
                    semanticsLabel: 'ItemPulse Logo',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "ItemPulse",
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Finding what matters most...",
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
