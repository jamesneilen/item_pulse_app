import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:item_pulse_app/core/themes.dart';
import 'package:item_pulse_app/views/dashboard/home_screen.dart';
import 'package:item_pulse_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../widgets/custom_input_field.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // void _signUp() async {
  //   if (!_formKey.currentState!.validate()) {
  //     _formKey.currentState!.save();

  //     if (_password != _confirmPassword) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
  //       return;
  //     }
  //     setState(() => _isLoading = true);
  //     try {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const HomeScreen()),
  //       );
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
  //       );
  //     } finally {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }
  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_password != _confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authResult = await context.read<AuthService>().registerWithEmail(
        _email,
        _password,
      );

      await FirebaseAuth.instance.currentUser!.updateDisplayName(_name);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(authResult.user!.uid)
          .set({
            'uid': authResult.user!.uid,
            'email': _email,
            'name': _name,
            'createdAt': FieldValue.serverTimestamp(),
          });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                        SizedBox(height: 20),
                        fieldLabel('Name'),
                        MTextfield(
                          keyboardType: TextInputType.name,
                          validator:
                              (value) =>
                                  value!.isNotEmpty ? null : "Enter your name",
                          onSaved: (value) => _name = value!,
                        ),
                        SizedBox(height: 20),
                        fieldLabel('Email'),
                        MTextfield(
                          keyboardType: TextInputType.emailAddress,
                          validator:
                              (value) =>
                                  !value!.contains('@')
                                      ? 'Enter a valid email'
                                      : null,
                          onSaved: (value) => _email = value!.trim(),
                        ),

                        const SizedBox(height: 20),
                        fieldLabel('Password'),
                        MTextfield(
                          keyboardType: TextInputType.text,
                          validator:
                              (value) =>
                                  value!.length >= 6
                                      ? null
                                      : 'Minimum of 6 characters',
                          onSaved: (value) => _password = value!,
                          onChanged:
                              (value) => setState(() => _password = value!),
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),
                        fieldLabel('Confirm Password'),
                        MTextfield(
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm password';
                            }
                            if (value != _password) {
                              return 'Passwords do not match';
                            } else {
                              return null;
                            }
                          },
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              );
                            },
                          ),
                          onSaved: (value) => _confirmPassword = value!,
                        ),
                        const SizedBox(height: 60),
                        Center(
                          child: MyButton(text: 'Sign Up', onPressed: _signUp),
                        ),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Already have an account? Sign in',
                            ),
                          ),
                        ),
                        const Divider(height: 32),
                        ElevatedButton.icon(
                          onPressed: _signInWithGoogle,
                          icon: const Icon(Icons.login),
                          label: const Text('Continue with Google'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
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
