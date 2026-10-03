import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({
    AuthService? authService,
  }) : _authService = authService ?? AuthService.instance;

  final AuthService _authService;

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser => _authService.currentUser;

  // ============================================================
  // AUTH STATE
  // ============================================================

  Stream<User?> get authStateChanges =>
      _authService.authStateChanges;

  // ============================================================
  // EMAIL SIGN UP
  // ============================================================

  // NOTE: return type is nullable now. AuthService can return null
  // when the Firebase Auth "pigeon" type-cast bug fires even though
  // the account was created successfully — check `currentUser`
  // afterwards if you get null here instead of treating it as a
  // failure.
  Future<UserCredential?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    return await _authService.signUpWithEmail(
      name: name,
      email: email,
      password: password,
    );
  }

  // ============================================================
  // EMAIL LOGIN
  // ============================================================

  Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _authService.loginWithEmail(
      email: email,
      password: password,
    );
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await _authService.sendPasswordResetEmail(
      email: email,
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _authService.logout();
  }

  // ============================================================
  // GOOGLE
  // ============================================================

  Future<UserCredential?> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  // ============================================================
  // FACEBOOK
  // ============================================================

  Future<UserCredential?> signInWithFacebook() async {
    return await _authService.signInWithFacebook();
  }

  // ============================================================
  // CURRENT USER DATA
  // ============================================================

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    return await _authService.getCurrentUserData();
  }

  // ============================================================
  // CURRENT USER DOCUMENT
  // ============================================================

  Future<DocumentSnapshot<Map<String, dynamic>>>
  getCurrentUserDocument() async {
    return await _authService.getCurrentUserDocument();
  }

  // ============================================================
  // UPDATE USER NAME
  // ============================================================

  Future<void> updateUserName(String name) async {
    await _authService.updateUserName(name);
  }
}