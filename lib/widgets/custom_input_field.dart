// lib/widgets/custom_text_form_field.dart
import 'package:flutter/material.dart';

class MTextfield extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;

  const MTextfield({
    super.key,
    required this.labelText,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    // Use the context's theme for all styling.
    final theme = Theme.of(context);
    // Correctly get the input decoration theme from the main theme.
    final inputDecorationTheme = theme.inputDecorationTheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      obscureText: obscureText,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,

        // --- THIS SECTION IS NOW CORRECT ---
        // It first tries to use styles defined in your main app's inputDecorationTheme.
        // If a style is not defined there, it provides a sensible fallback.
        filled: inputDecorationTheme.filled ?? true,
        fillColor:
            inputDecorationTheme.fillColor ??
            theme.colorScheme.surfaceVariant.withOpacity(0.5),
        contentPadding:
            inputDecorationTheme.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border:
            inputDecorationTheme.border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
        enabledBorder:
            inputDecorationTheme.enabledBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
        focusedBorder:
            inputDecorationTheme.focusedBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
        errorBorder:
            inputDecorationTheme.errorBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.5,
              ),
            ),
        focusedErrorBorder:
            inputDecorationTheme.focusedErrorBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2.0,
              ),
            ),
      ),
    );
  }
}
