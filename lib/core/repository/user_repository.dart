import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class UserRepository {
  /// Get the current user profile from Firebase
  Future<UserProfile?> currentUser() async {
    try {
      final uid = AuthService.currentUserId;
      if (uid == null) return null;
      return await getUserById(uid);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return AuthService.isAuthenticated;
  }

  /// Get current user role
  String? getCurrentRole() {
    // This will be handled by the auth providers now
    return null;
  }

  /// Get user profile by ID
  Future<UserProfile?> getUserById(String userId) async {
    try {
      final userDoc =
          await FirebaseService.firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return null;
      }

      return UserProfile.fromFirestore(userDoc);
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  /// Get multiple users by IDs
  Future<Map<String, UserProfile>> getUsersByIds(List<String> userIds) async {
    try {
      final users = <String, UserProfile>{};

      // Firestore 'in' queries are limited to 10 items
      const batchSize = 10;

      for (int i = 0; i < userIds.length; i += batchSize) {
        final batch = userIds.skip(i).take(batchSize).toList();

        final querySnapshot = await FirebaseService.firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (final doc in querySnapshot.docs) {
          users[doc.id] = UserProfile.fromFirestore(doc);
        }
      }

      return users;
    } catch (e) {
      print('Error getting users by IDs: $e');
      return {};
    }
  }

  /// Set user role (deprecated - use AuthService.updateUserRole instead)
  @Deprecated('Use AuthService.updateUserRole instead')
  Future<void> setRole(String role) async {
    await AuthService.updateUserRole(role);
  }

  /// Login user (deprecated - use AuthService instead)
  @Deprecated('Use AuthService.signInWithEmailAndPassword instead')
  Future<UserProfile?> login(String email, String password) async {
    try {
      await AuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await currentUser();
    } catch (e) {
      rethrow;
    }
  }

  /// Register user (deprecated - use AuthService instead)
  @Deprecated('Use AuthService.createUserWithEmailAndPassword instead')
  Future<UserProfile?> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? companyName,
  }) async {
    try {
      await AuthService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );

      // Update role if different from default
      if (role != 'job_seeker') {
        await AuthService.updateUserRole(role);
      }

      return await currentUser();
    } catch (e) {
      rethrow;
    }
  }

  /// Logout user (deprecated - use AuthService instead)
  @Deprecated('Use AuthService.signOut instead')
  Future<void> logout() async {
    await AuthService.signOut();
  }

  /// Stream a user profile by ID
  Stream<UserProfile?> streamUser(String userId) {
    return FirebaseService.firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  /// Update user document with partial data
  Future<void> updateUser(String userId, Map<String, dynamic> partial) async {
    await FirebaseService.firestore
        .collection('users')
        .doc(userId)
        .set(partial, SetOptions(merge: true));
  }
}
