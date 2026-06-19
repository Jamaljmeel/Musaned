import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;

  /// Sign In
  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
    return cred.user;
  }

  /// Sign Up
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password.trim());
    
    if (cred.user != null) {
      await _db.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': email.trim(),
        'displayName': name.trim(),
        'phone': phone.trim(),
        'role': 'customer',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return cred;
  }

  /// Upload Profile Image
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage.ref().child('users').child(uid).child('profile.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  /// Update user profile in Firestore
  Future<void> updateProfile({
    required String uid, 
    required String displayName, 
    required String phone,
    String? avatarUrl,
  }) async {
    final data = {
      'displayName': displayName,
      'phone': phone,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (avatarUrl != null) {
      data['avatarUrl'] = avatarUrl;
    }
    await _db.collection('users').doc(uid).update(data);
  }

  /// Reset Password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Re-authenticate user
  Future<void> reauthenticate(String currentPassword) async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
    }
  }

  /// Change password in Firebase Auth
  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    } else {
      throw Exception('لم يتم العثور على مستخدم مسجل');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
