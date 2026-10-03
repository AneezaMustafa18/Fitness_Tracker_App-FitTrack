import 'dart:typed_data';

import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile?> getProfile();

  Future<void> updateProfile({
    required String name,
    required String phone,
  });

  Future<String> uploadProfileImage(Uint8List bytes);
}