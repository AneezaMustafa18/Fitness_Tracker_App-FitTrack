import 'package:firebase_auth/firebase_auth.dart';

import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl {
  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
      remoteDataSource ?? AuthRemoteDataSource();

  final AuthRemoteDataSource _remoteDataSource;

  // ============================================================
  // LOGIN
  // ============================================================

  // NOTE: nullable now — see AuthService for why (pigeon bug
  // workaround). Null does not mean failure; check currentUser.
  Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _remoteDataSource.loginWithEmail(
      email: email,
      password: password,
    );
  }

  // ============================================================
  // SIGNUP
  // ============================================================

  Future<UserCredential?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    return await _remoteDataSource.signUpWithEmail(
      name: name,
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
    await _remoteDataSource.sendPasswordResetEmail(
      email: email,
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _remoteDataSource.logout();
  }

  // ============================================================
  // GOOGLE
  // ============================================================

  Future<UserCredential?> signInWithGoogle() async {
    return await _remoteDataSource.signInWithGoogle();
  }

  // ============================================================
  // FACEBOOK
  // ============================================================

  Future<UserCredential?> signInWithFacebook() async {
    return await _remoteDataSource.signInWithFacebook();
  }

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser =>
      _remoteDataSource.currentUser;

  Stream<User?> get authStateChanges =>
      _remoteDataSource.authStateChanges;

  // ============================================================
  // CURRENT USER DATA
  // ============================================================

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    return await _remoteDataSource.getCurrentUserData();
  }

  // ============================================================
  // UPDATE NAME
  // ============================================================

  Future<void> updateUserName(
      String name,
      ) async {
    await _remoteDataSource.updateUserName(name);
  }
}