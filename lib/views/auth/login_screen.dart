import 'package:flutter/material.dart';
import 'package:item_pulse_app/core/themes.dart';
import 'package:item_pulse_app/widgets/custom_button.dart';

import '../../widgets/custom_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Widget _fieldLabel(String text) {
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
                    "Log In",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Inter',
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                _fieldLabel('Email'),
                myTextfield(
                  _emailController,
                  TextInputType.emailAddress,
                  (value) =>
                      value!.contains('@') ? null : 'Enter a valid email',
                  false,
                ),

                const SizedBox(height: 30),
                _fieldLabel('Password'),
                myTextfield(
                  _passwordController,
                  TextInputType.text,
                  (value) =>
                      value!.length >= 6 ? null : 'Minimum of 6 characters',
                  true,
                ),
                const SizedBox(height: 60),
                Center(child: MyButton(text: 'Login', onPressed: () {})),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(fontSize: 20, fontFamily: 'Inter'),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text('Don\'t have an account? Sign up'),
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
