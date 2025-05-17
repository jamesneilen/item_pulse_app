import 'package:flutter/material.dart';
import 'package:item_pulse_app/core/themes.dart';
import 'package:item_pulse_app/views/auth/login_screen.dart';
import 'package:item_pulse_app/views/auth/signup_screen.dart';
import 'package:item_pulse_app/views/auth/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ItemPulse',
      theme: myTheme,
      home: const SignupScreen(),
    );
  }
}
