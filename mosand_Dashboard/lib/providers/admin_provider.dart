import 'package:flutter/material.dart';
import '../models/producer_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

class AdminProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String _error = '';

  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadDashboardStats() async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      _stats = await _firestoreService.getAdminDashboardStats();
    } catch (e) {
      _error = 'فشل تحميل الإحصائيات';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> approveProducer(String uid) async {
    await _firestoreService.approveProducer(uid);
    await loadDashboardStats();
  }

  Future<void> rejectProducer(String uid, String reason) async {
    await _firestoreService.rejectProducer(uid, reason);
    await loadDashboardStats();
  }

  Future<void> approveProduct(String id) async {
    await _firestoreService.approveProduct(id);
  }

  Future<void> rejectProduct(String id) async {
    await _firestoreService.rejectProduct(id);
  }

  Stream<List<ProducerModel>> getProducersStream({String? status}) {
    return _firestoreService.getProducersStream(statusFilter: status);
  }

  Stream<List<ProductModel>> getProductsStream({bool? isApproved}) {
    return _firestoreService.getProductsStream(isApproved: isApproved);
  }

  Stream<List<OrderModel>> getOrdersStream({String? status}) {
    return _firestoreService.getOrdersStream(status: status);
  }
}
