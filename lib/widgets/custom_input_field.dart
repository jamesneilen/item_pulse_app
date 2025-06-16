import 'package:flutter/material.dart';

import '../core/themes.dart';

// ignore: must_be_immutable
class MTextfield extends StatelessWidget {
  TextEditingController? controller;
  TextInputType? keyboardType;
  String? Function(String?) validator;
  void Function(String?) onSaved;
  Function(String?)? onChanged;
  bool obscureText;
  Widget? suffixIcon;

  MTextfield({
    this.controller,
    this.keyboardType,
    required this.validator,
    required this.onSaved,
    this.onChanged,
    this.suffixIcon,
    this.obscureText = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        suffixIcon: suffixIcon,
        focusColor: Colors.white,
        fillColor: myColorScheme.onPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: myTheme.primaryColor),
        ),
      ),
    );
  }
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
