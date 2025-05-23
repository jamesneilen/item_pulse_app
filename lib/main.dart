import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:item_pulse_app/core/themes.dart';
import 'package:item_pulse_app/views/auth/login_screen.dart';
import 'package:item_pulse_app/views/auth/signup_screen.dart';
import 'package:item_pulse_app/views/auth/welcome_screen.dart';
import 'package:item_pulse_app/views/onboarding/splash_screen.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/item_provider.dart';
import 'services/auth_service.dart';
import 'views/auth/auth_gate.dart';
import 'views/dashboard/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ItemPulse',
      theme: myTheme,
      home: SplashScreen(),
    );
  }
}
