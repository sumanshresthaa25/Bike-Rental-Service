import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _emailKey = "user_email";
  static const _loggedInKey = "is_logged_in";
  static const _gmailDomain = "@gmail.com";
  static const _minimumPasswordLength = 6;

  final AuthService _authService;

  String? _email;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService() {
    _loadSavedAuth();
  }

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasAccount => _email != null;
  String? get email => _email;

  Future<void> _loadSavedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _email = prefs.getString(_emailKey);
    _isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
    _isLoading = false;
    notifyListeners();
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (!_isValidEmail(normalizedEmail)) {
      return AuthResult(false, "Enter a valid Gmail address.");
    }

    if (!normalizedEmail.endsWith(_gmailDomain)) {
      return AuthResult(false, "Please sign up using a Gmail account.");
    }

    if (password.length < _minimumPasswordLength) {
      return AuthResult(false, "Password must be at least 6 characters.");
    }

    if (password != confirmPassword) {
      return AuthResult(false, "Passwords do not match.");
    }

    try {
      final existingUser = await _authService.findUserByEmail(normalizedEmail);
      if (existingUser != null) {
        return AuthResult(false, "This Gmail already has an account.");
      }

      final user = await _authService.createUser(
        email: normalizedEmail,
        password: password,
      );

      await _saveSession(user.email);

      return AuthResult(true, "Account created.");
    } catch (error) {
      debugPrint("Sign up failed: $error");
      return AuthResult(false, "Failed to save account on this device.");
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      final user = await _authService.findUserByEmail(normalizedEmail);
      if (user == null) {
        return AuthResult(false, "Please sign up first.");
      }

      if (!_authService.passwordMatches(user, password)) {
        return AuthResult(false, "Invalid Gmail or password.");
      }

      await _saveSession(user.email);

      return AuthResult(true, "Logged in.");
    } catch (error) {
      debugPrint("Login failed: $error");
      return AuthResult(false, "Failed to login from this device.");
    }
  }

  Future<void> _saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setBool(_loggedInKey, true);

    _email = email;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
    _isLoggedIn = false;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email);
  }
}

class AuthResult {
  final bool success;
  final String message;

  const AuthResult(this.success, this.message);
}
