import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentAdmin => _auth.currentUser;

  Future<User?> loginAdmin(String email, String password) async {
    try {
      print('🔄 Attempting to login admin: $email');

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? adminUser = userCredential.user;

      print('✅ Admin login successful: ${adminUser?.email}');
      print('🔐 User UID: ${adminUser?.uid}');

      return adminUser;
    } on FirebaseAuthException catch (e) {
      print('❌ Login error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ Admin signed out successfully');
    } catch (e) {
      print('❌ Sign out error: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent to: $email');
    } catch (e) {
      print('❌ Error sending reset email: $e');
      rethrow;
    }
  }

  Future<bool> checkExistingAdmin() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        print('📱 Found existing admin: ${user.email}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error checking existing admin: $e');
      return false;
    }
  }

  // Get total user count from Firestore
  Future<int> getTotalUserCount() async {
    try {
      final QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .get();

      final int userCount = userSnapshot.docs.length;
      print('👥 Total users count: $userCount');

      return userCount;
    } catch (e) {
      print('❌ Error getting user count: $e');
      return 0;
    }
  }

  // Get today's new user registrations
  Future<int> getTodaysNewUsers() async {
    try {
      final DateTime today = DateTime.now();
      final DateTime startOfDay = DateTime(today.year, today.month, today.day);

      final QuerySnapshot newUsersSnapshot = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .get();

      final int todaysUsers = newUsersSnapshot.docs.length;
      print('📅 Today\'s new users: $todaysUsers');

      return todaysUsers;
    } catch (e) {
      print('❌ Error getting today\'s users: $e');
      return 0;
    }
  }

  // Get active users (users who signed in today)
  Future<int> getActiveUsersCount() async {
    try {
      final DateTime today = DateTime.now();
      final DateTime startOfDay = DateTime(today.year, today.month, today.day);

      final QuerySnapshot activeUsersSnapshot = await _firestore
          .collection('users')
          .where('lastSignIn', isGreaterThanOrEqualTo: startOfDay)
          .get();

      final int activeUsers = activeUsersSnapshot.docs.length;
      print('🎯 Active users today: $activeUsers');

      return activeUsers;
    } catch (e) {
      print('❌ Error getting active users: $e');
      return 0;
    }
  }

  // Get all users data for admin
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .get();

      final List<Map<String, dynamic>> users = userSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'email': data['email'] ?? 'No Email',
          'name': data['name'] ?? 'No Name',
          'createdAt': data['createdAt']?.toDate() ?? DateTime.now(),
          'lastSignIn': data['lastSignIn']?.toDate(),
          'isActive': data['isActive'] ?? true,
        };
      }).toList();

      print('📊 Retrieved ${users.length} users data');
      return users;
    } catch (e) {
      print('❌ Error getting users data: $e');
      return [];
    }
  }
}
