import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    this.createdAt,
  });

  // ============================================================
  // FROM FIREBASE USER
  // ============================================================

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      profileImage: user.photoURL ?? '',
      createdAt: null,
    );
  }

  // ============================================================
  // FROM FIRESTORE
  // ============================================================

  factory UserModel.fromMap(
      Map<String, dynamic> map,
      ) {
    DateTime? date;

    final dynamic createdAtValue =
    map['createdAt'];

    if (createdAtValue is DateTime) {
      date = createdAtValue;
    } else if (createdAtValue != null &&
        createdAtValue.runtimeType.toString() ==
            'Timestamp') {
      try {
        date = createdAtValue.toDate();
      } catch (_) {
        date = null;
      }
    }

    return UserModel(
      uid: map['uid']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      profileImage:
      map['profileImage']?.toString() ?? '',
      createdAt: date,
    );
  }

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': createdAt,
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage:
      profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}