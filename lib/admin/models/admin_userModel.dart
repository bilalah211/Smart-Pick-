// admin/models/admin_user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final String? profileImage;

  AdminUserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.createdAt,
    this.lastLogin,
    this.profileImage,
  });

  factory AdminUserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return AdminUserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'user',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      lastLogin: data['lastLogin'] != null
          ? (data['lastLogin'] as Timestamp).toDate()
          : null,
      profileImage: data['profileImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'profileImage': profileImage,
    };
  }
}
