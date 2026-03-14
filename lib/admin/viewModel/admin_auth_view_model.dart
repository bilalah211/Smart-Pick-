import 'package:firebase_auth/firebase_auth.dart';

import '../services/admin_auth_services.dart';

class AdminAuthViewModel {
  final AdminAuthService _authService = AdminAuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<User?> loginAdmin(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      final user = await _authService.loginAdmin(email, password);
      return user;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e);
      return null;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      return null;
    } finally {
      _isLoading = false;
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No admin found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This admin account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<bool> checkExistingAdmin() async {
    return await _authService.checkExistingAdmin();
  }
}
