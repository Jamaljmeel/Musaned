import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _userRole;
  bool _isProfileComplete = false;
  String _errorMessage = '';

  AuthState get state => _state;
  UserModel? get user => _user;
  UserModel? get userModel => _user;
  String? get userRole => _userRole;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isAdmin => _userRole == 'admin';
  bool get isProducer => _userRole == 'producer';
  bool get isProfileComplete => _isProfileComplete;

  Future<void> initialize() async {
    _state = AuthState.loading;
    notifyListeners();
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      // 1. Get basic user data
      _user = await _firestoreService.getUser(currentUser.uid);
      _userRole = _user?.role;
      
      // 2. If he is a producer, we MUST know if his profile is complete
      if (_user?.role == 'producer') {
        final producer = await _firestoreService.getProducer(currentUser.uid);
        // We consider it complete if it exists and has a store name
        _isProfileComplete = producer != null && producer.storeNameAr.isNotEmpty;
      }
      
      if (_user != null) {
        if (!_user!.isActive) {
          await _authService.signOut();
          _state = AuthState.error;
          _errorMessage = 'حسابك موقوف. تواصل مع الإدارة';
          _user = null;
          _userRole = null;
          notifyListeners();
          return;
        }
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _state = AuthState.loading;
      _errorMessage = '';
      notifyListeners();
      final user = await _authService.signIn(email, password);
      if (user != null) {
        await _loadUserData(user.uid);
        return true;
      }
      _state = AuthState.unauthenticated;
      _errorMessage = 'فشل تسجيل الدخول';
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _state = AuthState.error;
      _errorMessage = _getArabicError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'حدث خطأ غير متوقع';
      notifyListeners();
      return false;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      _state = AuthState.loading;
      _errorMessage = '';
      notifyListeners();
      await _authService.signUp(
        email: email, password: password, name: name, phone: phone, role: role,
      );
      await initialize();
    } on FirebaseAuthException catch (e) {
      _state = AuthState.error;
      _errorMessage = _getArabicError(e.code);
      notifyListeners();
      rethrow;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'حدث خطأ غير متوقع';
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> registerProducer({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required String storeName,
    required String category,
    required String city,
    required String district,
  }) async {
    try {
      _state = AuthState.loading;
      _errorMessage = '';
      notifyListeners();
      final user = await _authService.registerProducer(
        email: email, password: password, displayName: displayName,
        phone: phone, storeName: storeName, category: category,
        city: city, district: district,
      );
      if (user != null) {
        await _loadUserData(user.uid);
        return true;
      }
      _state = AuthState.unauthenticated;
      _errorMessage = 'فشل التسجيل';
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _state = AuthState.error;
      _errorMessage = _getArabicError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'حدث خطأ غير متوقع';
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _userRole = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  Future<void> _loadUserData(String uid) async {
    try {
      _user = await _firestoreService.getUser(uid);
      _userRole = _user?.role;
      
      // Check if producer profile is complete
      if (_user?.role == 'producer') {
        final producer = await _firestoreService.getProducer(uid);
        _isProfileComplete = producer != null && producer.storeNameAr.isNotEmpty;
      }

      if (_user != null) {
        if (!_user!.isActive) {
          await _authService.signOut();
          _state = AuthState.error;
          _errorMessage = 'حسابك موقوف. تواصل مع الإدارة';
          _user = null;
          _userRole = null;
          notifyListeners();
          return;
        }
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
      notifyListeners();
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'فشل تحميل بيانات المستخدم';
      notifyListeners();
    }
  }

  String _getArabicError(String code) {
    switch (code) {
      case 'user-not-found': return 'لا يوجد حساب بهذا البريد';
      case 'wrong-password': return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use': return 'البريد مستخدم بالفعل';
      case 'weak-password': return 'كلمة المرور ضعيفة';
      case 'invalid-email': return 'بريد إلكتروني غير صالح';
      case 'too-many-requests': return 'محاولات كثيرة. حاول لاحقاً';
      case 'network-request-failed': return 'تحقق من الإنترنت';
      case 'invalid-credential': return 'بيانات الدخول غير صحيحة';
      default: return 'حدث خطأ: $code';
    }
  }
}
