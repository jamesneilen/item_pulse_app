import 'package:flutter/material.dart';
import 'package:item_pulse_app/core/themes.dart';
import 'package:item_pulse_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../widgets/custom_input_field.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _email = '';
  String _password = '';

  void _login() async {
    if (_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().signInWithEmail(_email, _password);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().signInWithGoogle();
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
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
                fieldLabel('Email'),
                MTextfield(
                  keyboardType: TextInputType.emailAddress,

                  ///validator
                  validator:
                      (value) =>
                          value == null || !value.contains('@')
                              ? 'Enter a valid email'
                              : null,

                  onSaved: (value) => _email = value!.trim(),
                ),

                const SizedBox(height: 30),
                fieldLabel('Password'),
                MTextfield(
                  keyboardType: TextInputType.text,
                  validator:
                      (value) =>
                          value == null || value.length < 6
                              ? 'Password too short'
                              : null,
                  onSaved: (value) => _password = value!,
                  onChanged: (p0) => setState(() => _password = p0!),
                  obscureText: true,
                ),
                const SizedBox(height: 60),
                Center(child: MyButton(text: 'Login', onPressed: _login)),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: const Text('Don\'t have an account? Sign up'),
                  ),
                ),
                const Divider(color: Colors.black, height: 32, thickness: 1),
                ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  label: Text('Sign in with Google'),
                  icon: const Icon(Icons.g_mobiledata),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
