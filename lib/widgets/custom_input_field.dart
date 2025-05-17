import 'package:flutter/material.dart';

import '../core/themes.dart';

Widget myTextfield(
  TextEditingController controller,
  TextInputType keyboardType,
  String? Function(String?) validator,
  bool obscureText,
) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    obscureText: obscureText,
    decoration: InputDecoration(
      filled: true,
      focusColor: Colors.white,
      fillColor: myColorScheme.onPrimary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: myTheme.primaryColor),
      ),
    ),
  );
}

Widget fieldLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6.0),

    child: Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 20,
        fontFamily: 'Inter',
      ),
    ),
  );
}
