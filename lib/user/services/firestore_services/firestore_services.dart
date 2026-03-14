import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/user/models/auth_user_model.dart';

class FirestoreServices {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> saveCurrentUser(UserModel userModel) async {
    await _firebaseFirestore
        .collection('Users')
        .doc(userModel.uid)
        .set(userModel.toMap());
  }

  Future<UserModel?> getCurrentUser(String uid) async {
    final doc = await _firebaseFirestore.collection('Users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }
}
