class UserModel {
  final dynamic uid;
  final dynamic email;
  final dynamic name;
  late final String? profileImage;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.profileImage,
  });

  /// Convert Firebase User to UserModel
  factory UserModel.fromFirebaseUser(dynamic user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      profileImage: user.profileImage,
    );
  }

  /// Convert from Map (for Firestore or local DB)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      profileImage: map['profileImage'],
    );
  }

  /// Convert to Map (for Firestore or local DB)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profileImage': profileImage,
    };
  }
}
