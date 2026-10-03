
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
ProfileProvider({ProfileRepository? repository})
    : _repository = repository ??
ProfileRepositoryImpl(
remoteDataSource: ProfileRemoteDataSource(),
);

final ProfileRepository _repository;

bool _isLoading = false;
String? _errorMessage;
Profile? _profile;

bool get isLoading => _isLoading;

String? get errorMessage => _errorMessage;

Profile? get profile => _profile;

Future<void> loadProfile() async {
_isLoading = true;
_errorMessage = null;
notifyListeners();

try {
_profile = await _repository.getProfile();
} catch (e) {
_errorMessage = 'Unable to load profile. Please try again.';
debugPrint('PROFILE PROVIDER LOAD ERROR: $e');
} finally {
_isLoading = false;
notifyListeners();
}
}

Future<bool> updateProfile({
required String name,
required String phone,
}) async {
_isLoading = true;
_errorMessage = null;
notifyListeners();

try {
await _repository.updateProfile(
name: name,
phone: phone,
);

if (_profile != null) {
_profile = _profile!.copyWith(
name: name,
phone: phone,
);
}

return true;
} catch (e) {
_errorMessage = 'Unable to update profile. Please try again.';
debugPrint('PROFILE PROVIDER UPDATE ERROR: $e');
return false;
} finally {
_isLoading = false;
notifyListeners();
}
}

Future<bool> uploadProfileImage(Uint8List bytes) async {
if (bytes.isEmpty) {
_errorMessage = 'Please select a valid image.';
notifyListeners();
return false;
}

_isLoading = true;
_errorMessage = null;
notifyListeners();

try {
final imageUrl = await _repository.uploadProfileImage(bytes);

if (_profile != null) {
_profile = _profile!.copyWith(
profileImage: imageUrl,
);
}

return true;
} catch (e) {
_errorMessage =
'Unable to upload profile image. Please try again.';
debugPrint(
'PROFILE PROVIDER IMAGE UPLOAD ERROR: $e',
);
return false;
} finally {
_isLoading = false;
notifyListeners();
}
}

void clearError() {
if (_errorMessage == null) {
return;
}

_errorMessage = null;
notifyListeners();
}

/// Called right after logout so the next user who logs in on the same
/// device doesn't briefly see the previous user's cached profile.
void clear() {
_profile = null;
_errorMessage = null;
notifyListeners();
}
}

