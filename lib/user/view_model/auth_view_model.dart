import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/user/models/auth_user_model.dart';
import 'package:ecommerceapp/user/services/cloudinary_services/cloudinary_services.dart';
import 'package:ecommerceapp/user/services/firebase_auth/auth_services.dart';
import 'package:ecommerceapp/user/services/firestore_services/firestore_services.dart';
import 'package:ecommerceapp/user/view_model/cloudinary_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/my_snackbar.dart';

class AuthViewModel {
  CloudinaryServices _cloudinaryServices = CloudinaryServices();
  FirestoreServices _firestoreServices = FirestoreServices();
  AuthServices _authServices = AuthServices();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  setLoading(bool value) {
    _isLoading = value;
  }

  Future<void> updateUserProfile({
    required String name,
    required String? imageUrl,
  }) async {
    final userId = _auth.currentUser!.uid;
    await _firestore.collection('Users').doc(userId).update({
      'name': name,
      'profileImage': imageUrl ?? '',
    });

    // // Also update Firebase Auth email if changed
    // if (email != _auth.currentUser!.email) {
    //   await _auth.currentUser!.updateEmail(email);
    // }
  }

  Future<UserModel?> signUpWithEmailAndPassword(
    String name,
    String email,
    String password,
    File? image,
  ) async {
    try {
      setLoading(true);
      final user = await _authServices.createUserWithEmailAndPassword(
        email,
        password,
      );
      if (user != null) {
        String? imageUrl;
        if (image != null) {
          imageUrl = await _cloudinaryServices.uploadImageToCloudinary(image);
        }
        final userModel = UserModel(
          uid: user.uid,
          email: user.email,
          profileImage: imageUrl,
          name: name,
        );
        await _firestoreServices.saveCurrentUser(userModel);
        return userModel;
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      if (e is FirebaseAuthException) {
        throw e; //
      } else {
        throw FirebaseAuthException(
          code: 'unknown-error',
          message: e.toString(),
        );
      }
    } finally {
      setLoading(false);
    }
  }

  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      final user = await _authServices.loginWithEmailAndPassword(
        email,
        password,
      );
      if (user != null) {
        await _firestoreServices.getCurrentUser(user.uid);
      }
      return user;
    } catch (e) {
      debugPrint(e.toString());
      if (e is FirebaseAuthException) {
        throw e; //
      } else {
        throw FirebaseAuthException(
          code: 'unknown-error',
          message: e.toString(),
        );
      }
    } finally {
      setLoading(false);
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = await _authServices.getCurrentUser();
      if (user != null) {
        return await _firestoreServices.getCurrentUser(user.uid);
      }
    } catch (e) {
      debugPrint(e.toString());
      throw FirebaseAuthException(code: e.toString());
    }
    return null;
  }

  Future<void> logoutUser() async {
    try {
      await _authServices.logoutUser();
    } catch (e) {
      debugPrint(e.toString());
      throw FirebaseAuthException(code: e.toString());
    }
  }

  Future<void> resetEmailAndPassword(String email) async {
    try {
      setLoading(true);
      await _authServices.resetEmailAndPassword(email);
    } catch (e) {
      debugPrint(e.toString());
      if (e is FirebaseAuthException) {
        throw e;
      } else {
        throw FirebaseAuthException(
          code: 'unknown-error',
          message: e.toString(),
        );
      }
    } finally {
      setLoading(false);
    }
  }
}
