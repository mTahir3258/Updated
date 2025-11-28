import 'package:flutter/material.dart';

/// Authentication provider
class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Login method (placeholder for future implementation)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock validation - accept any email/password for UI demo
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Forgot password method (placeholder for future implementation)
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock success - in real app, this would send reset email
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to send reset email. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout method
  Future<void> logout() async {
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Check if user is logged in (for future implementation)
  Future<void> checkAuthStatus() async {
    // TODO: Check stored auth token
    // For now, always return not authenticated
    _isAuthenticated = false;
    notifyListeners();
  }
}
