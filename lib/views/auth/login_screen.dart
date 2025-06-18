import 'package:flutter/material.dart';
import 'package:item_pulse_app/widgets/custom_input_field.dart';
import 'package:provider/provider.dart';

// Your app's imports
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- OPTIMIZATION 1: Use TextEditingControllers ---
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // --- OPTIMIZATION 2: Removed explicit navigation ---
      // Navigation should be handled by a root-level StreamBuilder listening to authStateChanges.
      // This makes the app's navigation flow much more robust.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().signInWithGoogle();
      // Navigation is handled by the root auth listener.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- OPTIMIZATION 3: Use Theme for consistent styling ---
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            "Welcome Back!",
                            textAlign: TextAlign.center,
                            style: textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Log in to continue your journey.",
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 50),

                          // --- Email Field ---
                          MTextfield(
                            // <-- Using your optimized widget
                            controller: _emailController,
                            labelText: 'Email Address',
                            prefixIcon: const Icon(Icons.email_outlined),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please enter an email';
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(value))
                                return 'Enter a valid email address';
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),

                          // --- Password Field ---
                          MTextfield(
                            controller: _passwordController,
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            obscureText: !_isPasswordVisible,
                            validator:
                                (value) =>
                                    value!.length < 6
                                        ? 'Password must be at least 6 characters'
                                        : null,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed:
                                  () => setState(
                                    () =>
                                        _isPasswordVisible =
                                            !_isPasswordVisible,
                                  ),
                            ),
                            onFieldSubmitted: (_) => _login(),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                /* TODO: Implement Forgot Password */
                              },
                              child: const Text('Forgot Password?'),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- Login Button ---
                          MyButton(text: 'Login', onPressed: _login),
                          const SizedBox(height: 20),

                          // --- Third-Party Login ---
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text('OR', style: textTheme.bodySmall),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 20),

                          ElevatedButton.icon(
                            onPressed: _signInWithGoogle,
                            icon: const Icon(Icons.g_mobiledata),
                            label: const Text('Continue with Google'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              elevation: 1,
                              side: BorderSide(
                                color: colorScheme.outline.withOpacity(0.5),
                              ),
                            ),
                          ),

                          // --- Navigate to Sign Up ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?"),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignupScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Sign Up'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
