import 'dart:typed_data';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required this.remoteDataSource,
  });

  final ProfileRemoteDataSource remoteDataSource;

  @override
  Future<Profile?> getProfile() {
    return remoteDataSource.getProfile();
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String phone,
  }) {
    return remoteDataSource.updateProfile(name: name, phone: phone);
  }

  @override
  Future<String> uploadProfileImage(Uint8List bytes) {
    return remoteDataSource.uploadProfileImage(bytes);
  }
}