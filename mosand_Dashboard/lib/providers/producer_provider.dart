import 'dart:io';
import 'package:flutter/material.dart';
import '../models/producer_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../config/constants.dart';

class ProducerProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  ProducerModel? _producer;
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  bool _initialized = false;
  String _error = '';


  ProducerModel? get producer => _producer;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  bool get initialized => _initialized;
  String get error => _error;


  Future<void> completeProfile(ProducerModel producer, File? logo) async {
    _isLoading = true;
    notifyListeners();
    try {
      String logoUrl = '';
      if (logo != null) {
        logoUrl = await _storageService.uploadFile(
          file: logo,
          path: 'stores/${producer.userId}/logo.png',
        );
      }
      
      final updatedProducer = producer.copyWith(
        logoUrl: logoUrl,
        approvalStatus: 'pending', // Reset to pending for admin approval
      );

      await _firestoreService.saveProducer(updatedProducer);
      _producer = updatedProducer;
      _initialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProducerData(String uid) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _initialized = false;
    
    try {
      _producer = await _firestoreService.getProducer(uid);
      if (_producer != null) {
        _stats = await _firestoreService.getProducerDashboardStats(uid);
      }
      _error = '';
    } catch (e) {
      _error = 'فشل تحميل البيانات';
    } finally {
      _isLoading = false;
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> updateStoreProfile(String uid, Map<String, dynamic> data) async {
    await _firestoreService.updateProducer(uid, data);
    _producer = await _firestoreService.getProducer(uid);
    notifyListeners();
  }

  Future<void> toggleOnlineStatus(String uid) async {
    if (_producer == null) return;
    await _firestoreService.updateProducer(uid, {
      'isOnline': !_producer!.isOnline,
    });
    _producer = await _firestoreService.getProducer(uid);
    notifyListeners();
  }

  // Products
  Stream<List<ProductModel>> getMyProducts(String producerId) {
    return _firestoreService.getProductsStream(producerId: producerId);
  }

  Future<String> addProduct(ProductModel product, List<File> imageFiles) async {
    List<String> imageUrls = [];
    if (imageFiles.isNotEmpty) {
      imageUrls = await _storageService.uploadFiles(
        files: imageFiles,
        path: '${AppConstants.productImagesPath}/${product.producerId}',
      );
    }
    final productWithImages = ProductModel(
      id: '',
      producerId: product.producerId,
      name: product.name,
      nameAr: product.nameAr,
      description: product.description,
      descriptionAr: product.descriptionAr,
      category: product.category,
      subcategory: product.subcategory,
      price: product.price,
      discountPrice: product.discountPrice,
      images: imageUrls,
      isAvailable: product.isAvailable,
      isApproved: false,
      preparationTime: product.preparationTime,
      tags: product.tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return await _firestoreService.addProduct(productWithImages);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data, {File? imageFile}) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (imageFile != null) {
        // Upload the single image
        final String url = await _storageService.uploadFile(
          file: imageFile,
          path: '${AppConstants.productImagesPath}/${_producer?.userId ?? "unknown"}',
        );
        data['images'] = [url];
      }
      await _firestoreService.updateProduct(id, data);
      
      // Refresh local stats if needed
      if (_producer != null) {
        // We don't necessarily need to reload everything, but it helps consistency
        // await loadProducerData(_producer!.userId);
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    await _firestoreService.deleteProduct(id);
  }

  Future<void> toggleProductAvailability(String id, bool current) async {
    await _firestoreService.updateProduct(id, {'isAvailable': !current});
  }

  // Orders
  Stream<List<OrderModel>> getMyOrders(String producerId, {String? status}) {
    return _firestoreService.getOrdersStream(
        producerId: producerId, status: status);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestoreService.updateOrderStatus(orderId, status);
    if (_producer != null) {
      _stats = await _firestoreService.getProducerDashboardStats(_producer!.userId);
      notifyListeners();
    }
  }
}
