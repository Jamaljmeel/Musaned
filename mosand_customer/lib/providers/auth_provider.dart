import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthState _state = AuthState.initial;
  UserModel? _user;
  String _errorMessage = '';

  AuthState get state => _state;
  UserModel? get user => _user;
  User? get firebaseUser => _authService.currentUser;
  UserModel? get userModel => _user;
  String get errorMessage => _errorMessage;

  Future<void> initialize() async {
    final fbUser = _authService.currentUser;
    if (fbUser != null) {
      _state = AuthState.loading;
      notifyListeners();
      await _loadUserData(fbUser.uid);
    } else {
      _state = AuthState.unauthenticated;
      notifyListeners();
    }
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

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      _state = AuthState.loading;
      _errorMessage = '';
      notifyListeners();
      
      final cred = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      
      if (cred.user != null) {
        await _loadUserData(cred.user!.uid);
        return true;
      }
      
      _state = AuthState.unauthenticated;
      _errorMessage = 'فشل إنشاء الحساب';
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
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    final fbUser = _authService.currentUser;
    if (fbUser != null) {
      await _loadUserData(fbUser.uid);
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      _user = await _firestoreService.getUser(uid);
      if (_user != null) {
        if (!_user!.isActive) {
          await _authService.signOut();
          _state = AuthState.error;
          _errorMessage = 'حسابك موقوف. تواصل مع الإدارة';
          _user = null;
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
