import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../utils/app_constants.dart';
import '../utils/form_validators.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = true;
  bool _isSubmitting = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final result = _isSignUp
        ? await auth.signUp(
            email: _emailController.text,
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
          )
        : await auth.login(
            email: _emailController.text,
            password: _passwordController.text,
          );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showAppSnackBar(context, result.message);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.two_wheeler,
                      size: 56,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    CustomText.title(
                      _isSignUp ? "Create Account" : "Welcome Back",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    CustomText.subtitle(
                      _isSignUp
                          ? "Sign up first using your Gmail account."
                          : "Log in with your saved Gmail and password.",
                      textAlign: TextAlign.center,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 28),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.person_add_alt_1_outlined),
                          label: Text("Sign Up"),
                        ),
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.login),
                          label: Text("Login"),
                        ),
                      ],
                      selected: {_isSignUp},
                      onSelectionChanged: (selection) {
                        setState(() => _isSignUp = selection.first);
                      },
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      controller: _emailController,
                      label: "Gmail",
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: FormValidators.required,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _passwordController,
                      label: "Password",
                      prefixIcon: Icons.lock_outline,
                      obscureText: _hidePassword,
                      textInputAction: _isSignUp
                          ? TextInputAction.next
                          : TextInputAction.done,
                      suffixIcon: _passwordToggleButton(
                        isHidden: _hidePassword,
                        onPressed: () {
                          setState(() => _hidePassword = !_hidePassword);
                        },
                      ),
                      validator: FormValidators.required,
                      onFieldSubmitted: (_) {
                        if (!_isSignUp) _submit();
                      },
                    ),
                    if (_isSignUp) ...[
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: "Confirm Password",
                        prefixIcon: Icons.lock_reset_outlined,
                        obscureText: _hideConfirmPassword,
                        textInputAction: TextInputAction.done,
                        suffixIcon: _passwordToggleButton(
                          isHidden: _hideConfirmPassword,
                          onPressed: () {
                            setState(
                              () =>
                                  _hideConfirmPassword = !_hideConfirmPassword,
                            );
                          },
                        ),
                        validator: FormValidators.required,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                    ],
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: _isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: _isSubmitting
                          ? const AppLoading()
                          : Icon(_isSignUp ? Icons.person_add : Icons.login),
                      label: Text(_isSignUp ? "Sign Up" : "Login"),
                    ),
                    if (!_isSignUp && !auth.hasAccount) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => setState(() => _isSignUp = true),
                        child: const Text("No account yet? Sign up first"),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordToggleButton({
    required bool isHidden,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: isHidden ? "Show password" : "Hide password",
      onPressed: onPressed,
      icon: Icon(
        isHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
    );
  }
}
