import 'package:flutter/material.dart';
import 'package:item_pulse_app/core/themes.dart';

class MyButton extends StatelessWidget {
  /// A custom button widget that can be used throughout the app.
  /// It takes a [text] to display and an [onPressed] callback function.

  final String text;
  double? width = 322;

  /// The width of the button. If not provided, a default width will be used.
  double? height = 71;

  /// The height of the button. If not provided, a default height will be used.
  /// The [onPressed] callback function that will be executed when the button is pressed.
  final void Function()? onPressed;

  double? fontSize = 32;
  MyButton({
    required this.text,
    required this.onPressed,
    this.height,
    this.width,
    this.fontSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,

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
            fontSize: fontSize,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
