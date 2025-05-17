import 'package:flutter/material.dart';
import 'package:item_pulse_app/core/themes.dart';

import '../../widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.1),
          Center(
            child: Column(
              children: [
                Text(
                  'Welcome to\n ItemPulse ',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    height: 1.0,
                    shadows: [
                      Shadow(color: Colors.black, offset: Offset.infinite),
                    ],
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Keep track of your belongings',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          MyButton(text: 'Sign Up', onPressed: () {}),
          SizedBox(height: 30),
          Container(
            height: 71,
            width: 322,

            decoration: BoxDecoration(
              border: Border.all(color: myTheme.primaryColor, width: 3),
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Log In',
                style: TextStyle(
                  color: myTheme.primaryColor,
                  fontSize: 32,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}
