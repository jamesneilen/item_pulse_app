import 'package:flutter/material.dart';
import 'package:item_pulse_app/core/themes.dart';
import 'package:item_pulse_app/widgets/custom_button.dart';

import '../../widgets/custom_input_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _SignUp() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                Center(
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Inter',
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                fieldLabel('Name'),
                myTextfield(
                  _nameController,
                  TextInputType.name,
                  (value) => value!.isNotEmpty ? null : "Enter your name",
                  false,
                ),
                SizedBox(height: 30),
                fieldLabel('Email'),
                myTextfield(
                  _emailController,
                  TextInputType.emailAddress,
                  (value) =>
                      value!.contains('@') ? null : 'Enter a valid email',
                  false,
                ),

                const SizedBox(height: 30),
                fieldLabel('Password'),
                myTextfield(
                  _passwordController,
                  TextInputType.text,
                  (value) =>
                      value!.length >= 6 ? null : 'Minimum of 6 characters',
                  true,
                ),

                const SizedBox(height: 30),
                fieldLabel('Confirm Password'),
                myTextfield(
                  _confirmPasswordController,
                  TextInputType.text,
                  (value) =>
                      value == _passwordController.text
                          ? null
                          : "Passwords don't match",
                  true,
                ),
                const SizedBox(height: 60),
                Center(child: MyButton(text: 'Sign Up', onPressed: _SignUp)),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Already have an account?'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
