import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';

class CategoryProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _error = '';

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadCategories({bool activeOnly = true}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _categories = await _firestoreService.getCategories(activeOnly: activeOnly);
    } catch (e) {
      _error = 'فشل تحميل الفئات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Stream version if needed
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestoreService.getCategoriesStream();
  }
}
