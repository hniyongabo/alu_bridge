import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, startup, admin }

extension UserRoleX on UserRole {
  String get value => name;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.student,
    );
  }
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.createdAt,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      role: UserRoleX.fromString(map['role'] as String? ?? 'student'),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.value,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
