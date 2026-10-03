import 'dart:async' show TimeoutException;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser => _auth.currentUser;

  // ============================================================
  // AUTH STATE
  // ============================================================

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  // ============================================================
  // GOOGLE
  // ============================================================

  static Future<void>? _googleInitialization;

  Future<void> _initializeGoogle() {
    return _googleInitialization ??=
        GoogleSignIn.instance.initialize();
  }

  // ============================================================
  // EMAIL SIGN UP
  // ============================================================

  Future<UserCredential?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final String cleanName = name.trim();
    final String cleanEmail = email.trim();

    debugPrint('');
    debugPrint('========================================');
    debugPrint('AUTH SERVICE: SIGNUP STARTED');
    debugPrint('EMAIL: $cleanEmail');
    debugPrint('========================================');

    // ==========================================================
    // STEP 1 - FIREBASE AUTH
    // ==========================================================

    debugPrint('STEP 1: Creating Firebase Auth account...');

    UserCredential? credential;

    try {
      credential =
      await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      debugPrint('STEP 1 SUCCESS');
      debugPrint(
        'AUTH UID: ${credential.user?.uid}',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('STEP 1 FIREBASE AUTH ERROR');
      debugPrint('CODE: ${e.code}');
      debugPrint('MESSAGE: ${e.message}');
      rethrow;
    } catch (e) {
      // ==========================================================
      // KNOWN FIREBASE AUTH BUG WORKAROUND
      // ==========================================================
      // On some Flutter/Firebase plugin version combinations
      // (especially on web), createUserWithEmailAndPassword throws
      // a type-cast error (commonly mentioning "PigeonUserDetails")
      // even though the account WAS created successfully on
      // Firebase's side. Instead of failing the whole signup, we
      // check if the account actually exists before giving up.
      debugPrint(
        'STEP 1 THREW AN ERROR, CHECKING IF ACCOUNT WAS STILL CREATED',
      );
      debugPrint('RAW ERROR: $e');

      // On web, when this Pigeon type-cast error fires, Firebase Auth's
      // JS SDK has usually already created the account and fired its
      // internal auth-state event — but `_auth.currentUser` can lag a
      // few hundred ms behind on this platform. Checking it ONCE,
      // synchronously, was the bug: it often read null even though the
      // account existed, so we rethrew and the UI showed "Signup
      // Failed" for an account that was actually created. Poll briefly
      // instead of checking once.
      final User? possibleUser = await _waitForMatchingUser(cleanEmail);

      if (possibleUser != null) {
        debugPrint(
          'ACCOUNT WAS ACTUALLY CREATED DESPITE THE ERROR — CONTINUING',
        );
      } else {
        debugPrint('STEP 1 UNKNOWN ERROR — RETHROWING');
        rethrow;
      }
    }

    final User? user = credential?.user ?? _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'signup-failed',
        message: 'Firebase user was not created.',
      );
    }

    // ==========================================================
    // STEP 2 - UPDATE DISPLAY NAME
    // ==========================================================

    debugPrint('STEP 2: Updating display name...');

    try {
      await user.updateDisplayName(cleanName);

      debugPrint('STEP 2 SUCCESS');
    } catch (e) {
      debugPrint(
        'STEP 2 FAILED BUT CONTINUING: $e',
      );
    }

    // ==========================================================
    // STEP 3 - FIRESTORE
    // ==========================================================

    debugPrint('');
    debugPrint('STEP 3: Starting Firestore user write...');
    debugPrint(
      'PATH: users/${user.uid}',
    );

    try {
      final DocumentReference<Map<String, dynamic>>
      reference =
      _firestore
          .collection('users')
          .doc(user.uid);

      debugPrint('STEP 3.1: Document reference created');

      await reference.set(
        {
          'uid': user.uid,
          'name': cleanName,
          'email': cleanEmail,
          'phone': '',
          'profileImage': '',
          'createdAt':
          FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // IMPORTANT: without this timeout, a stuck network/rules issue
          // made this Future hang FOREVER — signup() never returned,
          // the button looked frozen, the user tapped Signup again, and
          // the SECOND attempt failed with "email-already-in-use" (since
          // the account from the first tap already existed). That is
          // what actually caused "Signup Failed" to show up. Auth
          // account creation already succeeded above regardless, so we
          // just log this and move on instead of hanging.
          throw TimeoutException(
            'Firestore user-profile write timed out after 10 seconds.',
          );
        },
      );

      debugPrint('STEP 3 SUCCESS');
      debugPrint(
        'Firestore user document saved.',
      );
    } on FirebaseException catch (e) {
      debugPrint('');
      debugPrint('STEP 3 FIRESTORE ERROR');
      debugPrint('CODE: ${e.code}');
      debugPrint('MESSAGE: ${e.message}');
      debugPrint('');

      // IMPORTANT:
      // Auth account already exists.
      // Firestore failure signup ko fail nahi karega.
    } catch (e) {
      debugPrint(
        'STEP 3 UNKNOWN FIRESTORE ERROR: $e',
      );
    }

    // ==========================================================
    // STEP 4 - RETURN
    // ==========================================================

    debugPrint('');
    debugPrint('STEP 4: RETURNING SUCCESS');
    debugPrint('SIGNUP COMPLETE');
    debugPrint('========================================');
    debugPrint('');

    return credential;
  }

  // ============================================================
  // EMAIL LOGIN
  // ============================================================

  Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      // Same pigeon/type-cast workaround as signup: if the error is
      // a parsing issue but the user actually got signed in, don't
      // treat it as a failure.
      debugPrint('LOGIN THREW AN ERROR, CHECKING CURRENT USER: $e');

      final User? possibleUser =
      await _waitForMatchingUser(email.trim());

      if (possibleUser != null) {
        return null; // signals "logged in, but no credential object"
      }

      rethrow;
    }
  }

  // ============================================================
  // WAIT FOR MATCHING USER (Pigeon web bug workaround helper)
  // ============================================================
  //
  // Polls `_auth.currentUser` for up to ~2 seconds instead of checking
  // once. Needed because on Flutter Web, `currentUser` can update a
  // short moment after createUserWithEmailAndPassword /
  // signInWithEmailAndPassword throw their type-cast error.
  Future<User?> _waitForMatchingUser(
      String email, {
        int attempts = 10,
        Duration interval = const Duration(milliseconds: 200),
      }) async {
    for (int i = 0; i < attempts; i++) {
      final User? current = _auth.currentUser;

      if (current != null &&
          current.email?.toLowerCase() == email.toLowerCase()) {
        return current;
      }

      await Future.delayed(interval);
    }

    return null;
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ============================================================
  // GOOGLE SIGN IN
  // ============================================================

  Future<UserCredential?> signInWithGoogle() async {
    await _initializeGoogle();

    try {
      final GoogleSignInAccount googleUser =
      await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final String? idToken =
          googleAuth.idToken;

      if (idToken == null ||
          idToken.isEmpty) {
        throw FirebaseAuthException(
          code: 'google-id-token-missing',
          message:
          'Google ID token was not returned.',
        );
      }

      final OAuthCredential credential =
      GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(
        credential,
      );

      try {
        await _saveSocialUser(
          userCredential.user,
        );
      } catch (e) {
        debugPrint(
          'Google Firestore save failed: $e',
        );
      }

      return userCredential;
    } on GoogleSignInException {
      rethrow;
    }
  }

  // ============================================================
  // FACEBOOK SIGN IN
  // ============================================================

  Future<UserCredential?> signInWithFacebook() async {
    final LoginResult result =
    await FacebookAuth.instance.login(
      permissions: const [
        'email',
        'public_profile',
      ],
    );

    if (result.status ==
        LoginStatus.cancelled) {
      return null;
    }

    if (result.status !=
        LoginStatus.success) {
      throw FirebaseAuthException(
        code: 'facebook-login-failed',
        message: result.message ??
            'Facebook login failed.',
      );
    }

    final AccessToken? accessToken =
        result.accessToken;

    if (accessToken == null) {
      throw FirebaseAuthException(
        code: 'facebook-token-missing',
        message:
        'Facebook access token was not returned.',
      );
    }

    final String token =
        accessToken.tokenString;

    if (token.isEmpty) {
      throw FirebaseAuthException(
        code: 'facebook-token-empty',
        message:
        'Facebook access token is empty.',
      );
    }

    final OAuthCredential credential =
    FacebookAuthProvider.credential(
      token,
    );

    final UserCredential userCredential =
    await _auth.signInWithCredential(
      credential,
    );

    try {
      await _saveSocialUser(
        userCredential.user,
      );
    } catch (e) {
      debugPrint(
        'Facebook Firestore save failed: $e',
      );
    }

    return userCredential;
  }

  // ============================================================
  // SAVE SOCIAL USER
  // ============================================================

  Future<void> _saveSocialUser(
      User? user) async {
    if (user == null) return;

    final DocumentReference<Map<String, dynamic>>
    reference =
    _firestore
        .collection('users')
        .doc(user.uid);

    final DocumentSnapshot<Map<String, dynamic>>
    existing =
    await reference.get();

    if (!existing.exists) {
      await reference.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'phone': '',
        'profileImage':
        user.photoURL ?? '',
        'createdAt':
        FieldValue.serverTimestamp(),
      });

      return;
    }

    await reference.set(
      {
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'profileImage':
        user.photoURL ?? '',
      },
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // GET CURRENT USER DATA
  // ============================================================

  Future<Map<String, dynamic>?>
  getCurrentUserData() async {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      return null;
    }

    final DocumentSnapshot<
        Map<String, dynamic>> snapshot =
    await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }

  // ============================================================
  // GET CURRENT USER DOCUMENT
  // ============================================================

  Future<DocumentSnapshot<
      Map<String, dynamic>>>
  getCurrentUserDocument() async {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message:
        'No user is currently signed in.',
      );
    }

    return await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
  }

  // ============================================================
  // UPDATE USER NAME
  // ============================================================

  Future<void> updateUserName(
      String name) async {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message:
        'No user is currently signed in.',
      );
    }

    final String cleanName =
    name.trim();

    await user.updateDisplayName(
      cleanName,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(
      {
        'name': cleanName,
      },
      SetOptions(merge: true),
    );
  }
}