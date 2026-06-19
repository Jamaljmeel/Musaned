import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();


  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return result.user;
  }

  /// Register a new producer account
  Future<User?> registerProducer({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required String storeName,
    required String category,
    required String city,
    required String district,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = result.user;
    if (user == null) return null;

    await user.updateDisplayName(displayName);

    // Create user document
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set({
      'email': email.trim(),
      'displayName': displayName,
      'phone': phone,
      'role': AppConstants.roleProducer,
      'avatarUrl': '',
      'isActive': true,
      'isVerified': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Create producer document
    await _db
        .collection(AppConstants.producersCollection)
        .doc(user.uid)
        .set({
      'storeName': storeName,
      'storeNameAr': storeName,
      'description': '',
      'descriptionAr': '',
      'category': category,
      'address': {
        'city': city,
        'district': district,
        'street': '',
        'lat': 0.0,
        'lng': 0.0,
      },
      'businessLicense': '',
      'healthCertificate': '',
      'isApproved': false,
      'approvalStatus': 'pending',
      'rejectionReason': '',
      'qualityScore': 0,
      'totalOrders': 0,
      'totalRevenue': 0,
      'rating': 0,
      'reviewCount': 0,
      'isOnline': false,
      'workingHours': {
        'from': '08:00',
        'to': '22:00',
        'days': ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'],
      },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return user;
  }

  /// Get user role from Firestore
  Future<String?> getUserRole(String uid) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (doc.exists) {
      return doc.data()?['role'] as String?;
    }
    return null;
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Sign out
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (cred.user != null) {
      final user = UserModel(
        uid: cred.user!.uid,
        email: email,
        displayName: name,
        phone: phone,
        role: role,
        isActive: true,
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestoreService.createUser(user);


    }
    return cred;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
