import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignInException;

import '../../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService =
      AuthService.instance;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  User? _user;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? get successMessage => _successMessage;

  User? get user => _user;

  bool get isLoggedIn =>
      _authService.currentUser != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  // ========================================================================
  // LOGIN
  // ========================================================================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    _errorMessage = null;
    _successMessage = null;

    try {
      debugPrint('AUTH PROVIDER: LOGIN STARTED');

      final UserCredential? credential =
      await _authService.loginWithEmail(
        email: email.trim(),
        password: password,
      );

      // credential can be null due to the pigeon/type-cast bug
      // workaround in AuthService — that still means login succeeded.
      _user = credential?.user ?? _authService.currentUser;

      _successMessage =
      'Login successful.';

      debugPrint(
        'AUTH PROVIDER: LOGIN SUCCESS',
      );

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AUTH PROVIDER LOGIN ERROR: ${e.code}',
      );

      _errorMessage =
          _getAuthErrorMessage(e);

      return false;
    } catch (e) {
      debugPrint(
        'AUTH PROVIDER LOGIN ERROR: $e',
      );

      _errorMessage =
      'Something went wrong. Please try again.';

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========================================================================
  // SIGNUP
  // ========================================================================

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    _errorMessage = null;
    _successMessage = null;

    try {
      debugPrint(
        '========================================',
      );
      debugPrint(
        'AUTH PROVIDER: SIGNUP STARTED',
      );
      debugPrint(
        'EMAIL: ${email.trim()}',
      );
      debugPrint(
        '========================================',
      );

      final UserCredential? credential =
      await _authService.signUpWithEmail(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );

      // credential can be null due to the pigeon/type-cast bug
      // workaround in AuthService — that still means the account
      // was created successfully.
      _user = credential?.user ?? _authService.currentUser;

      _successMessage =
      'Account created successfully.';

      debugPrint(
        '========================================',
      );
      debugPrint(
        'AUTH PROVIDER: SIGNUP SUCCESS',
      );
      debugPrint(
        'UID: ${_user?.uid}',
      );
      debugPrint(
        '========================================',
      );

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AUTH PROVIDER FIREBASE ERROR',
      );
      debugPrint(
        'CODE: ${e.code}',
      );
      debugPrint(
        'MESSAGE: ${e.message}',
      );

      _errorMessage =
          _getAuthErrorMessage(e);

      return false;
    } catch (e) {
      debugPrint(
        'AUTH PROVIDER SIGNUP ERROR: $e',
      );

      _errorMessage =
      'Something went wrong. Please try again.';

      return false;
    } finally {
      _setLoading(false);

      debugPrint(
        'AUTH PROVIDER: SIGNUP FINISHED',
      );
    }
  }

  // ========================================================================
  // LOGOUT
  // ========================================================================

  Future<bool> logout() async {
    _setLoading(true);

    _errorMessage = null;

    try {
      debugPrint(
        'AUTH PROVIDER: LOGOUT STARTED',
      );

      await _authService.logout();

      _user = null;

      debugPrint(
        'AUTH PROVIDER: LOGOUT SUCCESS',
      );

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage =
          _getAuthErrorMessage(e);

      return false;
    } catch (e) {
      debugPrint(
        'AUTH PROVIDER LOGOUT ERROR: $e',
      );

      _errorMessage =
      'Unable to logout. Please try again.';

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========================================================================
  // FORGOT PASSWORD
  // ========================================================================

  Future<bool> forgotPassword({
    required String email,
  }) async {
    _setLoading(true);

    _errorMessage = null;
    _successMessage = null;

    try {
      await _authService.sendPasswordResetEmail(
        email: email.trim(),
      );

      _successMessage =
      'Password reset email sent.';

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage =
          _getAuthErrorMessage(e);

      return false;
    } catch (_) {
      _errorMessage =
      'Unable to send reset email. Please try again.';

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========================================================================
  // GOOGLE
  // ========================================================================

  Future<bool> loginWithGoogle() async {
    _setLoading(true);

    _errorMessage = null;
    _successMessage = null;

    try {
      final UserCredential? credential =
      await _authService.signInWithGoogle();

      if (credential == null) {
        return false;
      }

      _user = credential.user;

      _successMessage =
      'Google login successful.';

      return true;
    } on GoogleSignInException catch (e) {
      _errorMessage =
          e.description ??
              'Google login was cancelled or failed.';

      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage =
          _getAuthErrorMessage(e);

      return false;
    } catch (_) {
      _errorMessage =
      'Unable to login with Google. Please try again.';

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========================================================================
  // FACEBOOK
  // ========================================================================

  Future<bool> loginWithFacebook() async {
    _setLoading(true);

    _errorMessage = null;
    _successMessage = null;

    try {
      final UserCredential? credential =
      await _authService.signInWithFacebook();

      if (credential == null) {
        return false;
      }

      _user = credential.user;

      _successMessage =
      'Facebook login successful.';

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage =
          _getAuthErrorMessage(e);

      return false;
    } catch (_) {
      _errorMessage =
      'Unable to login with Facebook. Please try again.';

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========================================================================
  // CURRENT USER
  // ========================================================================

  void setCurrentUser(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> refreshCurrentUser() async {
    _user = _authService.currentUser;
    notifyListeners();
  }

  // ========================================================================
  // UPDATE NAME
  // ========================================================================

  Future<bool> updateUserName(
      String name,
      ) async {
    _setLoading(true);

    _errorMessage = null;
    _successMessage = null;

    try {
      await _authService.updateUserName(
        name,
      );

      await refreshCurrentUser();

      _successMessage =
      'Name updated successfully.';

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage =
          _getAuthErrorMessage(e);

      return false;
    } catch (_) {
      _errorMessage =
      'Unable to update name. Please try again.';

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========================================================================
  // ERROR MESSAGES
  // ========================================================================

  String _getAuthErrorMessage(
      FirebaseAuthException e,
      ) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'weak-password':
        return 'Password is too weak.';

      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'no-current-user':
        return 'No user is currently signed in.';

      case 'signup-failed':
        return 'Unable to create account. Please try again.';

      default:
        return e.message ??
            'Authentication failed. Please try again.';
    }
  }
}