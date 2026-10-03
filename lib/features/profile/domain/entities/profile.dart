class Profile {
  const Profile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final String profileImage;

  Profile copyWith({
    String? name,
    String? phone,
    String? profileImage,
  }) {
    return Profile(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
