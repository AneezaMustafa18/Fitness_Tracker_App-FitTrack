import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.phone,
    required super.profileImage,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map, String uid) {
    return ProfileModel(
      uid: uid,
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      profileImage: (map['profileImage'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
    };
  }
}
