import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as user_model;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state changes stream
  Stream<auth.User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  auth.User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Sign up with email and password
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Create user with Firebase Auth
      auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      auth.User? user = result.user;

      if (user != null) {
        // Create user document in Firestore
        await _createUserDocument(
          userId: user.uid,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          address: address,
          latitude: latitude,
          longitude: longitude,
        );

        return {
          'success': true,
          'message': 'Account created successfully',
          'user': user,
        };
      }

      return {
        'success': false,
        'message': 'Failed to create account',
      };
    } on auth.FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      auth.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      auth.User? user = result.user;

      if (user != null) {
        // Update last login timestamp
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': Timestamp.now(),
        });

        return {
          'success': true,
          'message': 'Login successful',
          'user': user,
        };
      }

      return {
        'success': false,
        'message': 'Failed to sign in',
      };
    } on auth.FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent successfully',
      };
    } on auth.FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // Get user data from Firestore
  Future<user_model.User?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return user_model.User.fromJson(data as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Update user data in Firestore
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? name,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
    user_model.NotificationSettings? notificationSettings,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (name != null) updateData['name'] = name;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (address != null) updateData['address'] = address;
      if (latitude != null) updateData['latitude'] = latitude;
      if (longitude != null) updateData['longitude'] = longitude;
      if (notificationSettings != null) {
        updateData['notificationSettings'] = notificationSettings.toJson();
      }

      updateData['updatedAt'] = Timestamp.now();

      await _firestore.collection('users').doc(userId).update(updateData);

      return {
        'success': true,
        'message': 'Profile updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update profile: ${e.toString()}',
      };
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument({
    required String userId,
    required String name,
    required String email,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    user_model.User user = user_model.User(
      id: userId,
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      address: address,
      latitude: latitude,
      longitude: longitude,
      isAdmin: false,
      notificationSettings: user_model.NotificationSettings.defaultSettings(),
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(userId).set(user.toJson());
  }

  // Get error message from Firebase Auth error code
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Signing in with Email and Password is not enabled.';
      default:
        return 'An authentication error occurred: $errorCode';
    }
  }

  // Check if user is admin
  Future<bool> isUserAdmin(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return data['isAdmin'] ?? false;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
