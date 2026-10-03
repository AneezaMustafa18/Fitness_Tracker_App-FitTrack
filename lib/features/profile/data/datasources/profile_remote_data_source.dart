import 'dart:async' show TimeoutException;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/profile_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance,
        storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  Future<ProfileModel?> getProfile() async {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found. Please login again.');
    }

    final doc = await firestore
        .collection('users')
        .doc(user.uid)
        .get()
        .timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException(
        'Firestore read timed out after 10 seconds.',
      ),
    );

    if (!doc.exists || doc.data() == null) {
      // Fall back to whatever Firebase Auth itself knows, so the screen
      // still shows something even if the Firestore doc write (at signup)
      // failed for some reason.
      return ProfileModel(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        phone: '',
        profileImage: user.photoURL ?? '',
      );
    }

    return ProfileModel.fromMap(doc.data()!, user.uid);
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found. Please login again.');
    }

    // Keep FirebaseAuth's displayName in sync too (used as a fallback
    // elsewhere in the app, e.g. right after signup).
    await user.updateDisplayName(name);

    await firestore.collection('users').doc(user.uid).set(
      {
        'name': name,
        'phone': phone,
      },
      SetOptions(merge: true),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException(
        'Firestore write timed out after 10 seconds.',
      ),
    );
  }

  /// Uploads [bytes] as the user's profile picture to Firebase Storage
  /// and saves the resulting download URL on their Firestore profile doc.
  /// Returns the download URL.
  Future<String> uploadProfileImage(Uint8List bytes) async {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found. Please login again.');
    }

    final ref = storage.ref().child('profile_images/${user.uid}.jpg');

    await ref
        .putData(bytes, SettableMetadata(contentType: 'image/jpeg'))
        .timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException(
        'Image upload timed out after 30 seconds.',
      ),
    );

    final downloadUrl = await ref.getDownloadURL();

    await user.updatePhotoURL(downloadUrl);

    await firestore.collection('users').doc(user.uid).set(
      {'profileImage': downloadUrl},
      SetOptions(merge: true),
    );

    return downloadUrl;
  }
}