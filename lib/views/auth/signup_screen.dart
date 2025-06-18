import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Your app's imports
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input_field.dart';
import 'login_screen.dart';

// --- ENHANCEMENT 2: Enum for Password Strength ---
enum PasswordStrength { None, Weak, Fair, Strong }

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

  // --- State variables for real-time feedback ---
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _emailErrorText;
  PasswordStrength _strength = PasswordStrength.None;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    // --- Add listeners to controllers to trigger real-time updates ---
    _emailController.addListener(_validateEmailRealtime);
    _passwordController.addListener(_updatePasswordStrength);
    // Listen to both fields to check for matches
    _passwordController.addListener(_checkPasswordMatch);
    _confirmPasswordController.addListener(_checkPasswordMatch);
  }

  @override
  void dispose() {
    // --- Always remove listeners and dispose controllers! ---
    _emailController.removeListener(_validateEmailRealtime);
    _passwordController.removeListener(_updatePasswordStrength);
    _passwordController.removeListener(_checkPasswordMatch);
    _confirmPasswordController.removeListener(_checkPasswordMatch);

    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Real-time Validation Logic ---

  void _validateEmailRealtime() {
    final email = _emailController.text;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    setState(() {
      if (email.isEmpty || emailRegex.hasMatch(email)) {
        _emailErrorText = null; // No error if empty or valid
      } else {
        _emailErrorText = 'Please enter a valid email address';
      }
    });
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    setState(() {
      _strength = _getPasswordStrength(password);
    });
  }

  void _checkPasswordMatch() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    // Only show match status if confirm password has been touched
    if (confirmPassword.isEmpty) {
      setState(() => _passwordsMatch = false);
      return;
    }
    setState(() {
      _passwordsMatch = (password == confirmPassword);
    });
  }

  PasswordStrength _getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.None;
    if (password.length < 8) return PasswordStrength.Weak;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (hasUppercase && hasDigits && hasSpecialChars) {
      return PasswordStrength.Strong;
    }
    if ((hasUppercase && hasDigits) ||
        (hasUppercase && hasSpecialChars) ||
        (hasDigits && hasSpecialChars)) {
      return PasswordStrength.Fair;
    }
    return PasswordStrength.Weak;
  }

  // --- Main Sign-Up Logic ---

  Future<void> _signUp() async {
    // Final validation before submitting
    if (!_formKey.currentState!.validate()) return;
    if (_emailErrorText != null) return; // Don't submit if email is invalid

    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().signUpWithEmail(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Navigation handled by root auth listener
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                          const SizedBox(height: 40),
                          Text(
                            "Create Account",
                            textAlign: TextAlign.center,
                            style: textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Let's get you started!",
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // --- Name Field ---
                          MTextfield(
                            controller: _nameController,
                            labelText: 'Full Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            validator:
                                (value) =>
                                    value!.isNotEmpty
                                        ? null
                                        : "Please enter your name",
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),

                          // --- ENHANCEMENT 1: Real-time Email Field ---
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

                          // --- ENHANCEMENT 2: Password Field with Strength Meter ---
                          MTextfield(
                            controller: _passwordController,
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            obscureText: !_isPasswordVisible,
                            validator:
                                (value) =>
                                    _strength == PasswordStrength.Weak
                                        ? 'Password is too weak'
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
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 8),
                          _buildStrengthIndicator(_strength),
                          const SizedBox(height: 12),

                          // --- ENHANCEMENT 3: Confirm Password with Match Indicator ---
                          MTextfield(
                            controller: _confirmPasswordController,
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              if (value != _passwordController.text)
                                return 'Passwords do not match';
                              return null;
                            },
                            // Show checkmark when passwords match, otherwise the visibility toggle
                            suffixIcon:
                                _confirmPasswordController.text.isNotEmpty &&
                                        _passwordsMatch
                                    ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                    : IconButton(
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
                            onFieldSubmitted: (_) => _signUp(),
                          ),
                          const SizedBox(height: 40),

                          MyButton(text: 'Sign Up', onPressed: _signUp),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account?"),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Sign In'),
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

  /// A helper widget to build the password strength indicator UI.
  Widget _buildStrengthIndicator(PasswordStrength strength) {
    return Row(
      children: [
        Expanded(
          child: _IndicatorBar(color: _getColorForStrength(strength, 1)),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _IndicatorBar(color: _getColorForStrength(strength, 2)),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _IndicatorBar(color: _getColorForStrength(strength, 3)),
        ),
      ],
    );
  }

  Color _getColorForStrength(PasswordStrength strength, int barIndex) {
    switch (strength) {
      case PasswordStrength.None:
        return Colors.grey.shade300;
      case PasswordStrength.Weak:
        return barIndex == 1 ? Colors.red : Colors.grey.shade300;
      case PasswordStrength.Fair:
        return barIndex <= 2 ? Colors.orange : Colors.grey.shade300;
      case PasswordStrength.Strong:
        return Colors.green;
    }
  }
}

// A simple widget for one of the bars in the strength indicator
class _IndicatorBar extends StatelessWidget {
  final Color color;
  const _IndicatorBar({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
