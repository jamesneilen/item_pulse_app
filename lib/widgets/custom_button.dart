import 'package:flutter/material.dart';
import 'package:item_pulse_app/core/themes.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  const MyButton({required this.text, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 71,
      width: 322,

      decoration: BoxDecoration(
        color: myTheme.primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
