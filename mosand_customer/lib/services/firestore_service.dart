import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import '../models/producer_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== USERS ====================

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> createUser(UserModel user) async {
    await _db.collection(AppConstants.usersCollection).doc(user.uid).set(user.toMap());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection(AppConstants.usersCollection).doc(uid).update(data);
  }

  // ==================== CATEGORIES ====================

  Stream<List<CategoryModel>> getCategoriesStream() {
    return _db.collection(AppConstants.categoriesCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _db.collection(AppConstants.categoriesCollection)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ==================== PRODUCERS ====================

  Future<ProducerModel?> getProducer(String uid) async {
    final doc = await _db.collection(AppConstants.producersCollection).doc(uid).get();
    if (doc.exists) {
      return ProducerModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  /// Get all approved producers
  Stream<List<ProducerModel>> getApprovedProducersStream({String? category}) {
    Query query = _db.collection(AppConstants.producersCollection)
        .where('isApproved', isEqualTo: true);
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ProducerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  /// Get a single producer's products
  Stream<List<ProductModel>> getProducerProductsStream(String producerId) {
    return _db.collection(AppConstants.productsCollection)
        .where('producerId', isEqualTo: producerId)
        .where('isApproved', isEqualTo: true)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ==================== PRODUCTS ====================

  /// Get all approved products (for browsing)
  Stream<List<ProductModel>> getApprovedProductsStream({String? category}) {
    Query query = _db.collection(AppConstants.productsCollection)
        .where('isApproved', isEqualTo: true)
        .where('isAvailable', isEqualTo: true);
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    return query.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList(),
        );
  }

  /// Get a single product by ID
  Future<ProductModel?> getProductById(String productId) async {
    final doc = await _db.collection(AppConstants.productsCollection).doc(productId).get();
    if (doc.exists) {
      return ProductModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  /// Search products by name
  Future<List<ProductModel>> searchProducts(String query) async {
    final snapshot = await _db.collection(AppConstants.productsCollection)
        .where('isApproved', isEqualTo: true)
        .where('isAvailable', isEqualTo: true)
        .get();
    
    final results = snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .where((p) =>
            p.name.contains(query) ||
            p.nameAr.contains(query) ||
            p.description.contains(query))
        .toList();
    return results;
  }

  // ==================== ORDERS ====================

  /// Create a new order
  Future<String> createOrder(OrderModel order) async {
    final doc = await _db.collection(AppConstants.ordersCollection).add(order.toMap());
    return doc.id;
  }

  /// Get customer orders
  Stream<List<OrderModel>> getCustomerOrdersStream(String userId) {
    return _db
        .collection(AppConstants.ordersCollection)
        .where('customerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<OrderModel> orders = [];
      for (var doc in snapshot.docs) {
        var order = OrderModel.fromMap(doc.data(), doc.id);
        // Fetch actual producer name if it's missing or generic
        if (order.producerName == null || order.producerName == 'متجر مساند' || order.producerName == 'متجر الأسرة') {
          final pDoc = await _db.collection(AppConstants.producersCollection).doc(order.producerId).get();
          if (pDoc.exists) {
            final pData = pDoc.data();
            final realName = pData?['storeNameAr'] ?? pData?['storeName'] ?? 'متجر مُساند';
            order = order.copyWith(producerName: realName);
          }
        }
        orders.add(order);
      }
      return orders;
    });
  }

  /// Check if a review exists for an order and target
  Future<bool> hasReviewed(String orderId, String targetId) async {
    final snap = await _db.collection('reviews')
        .where('orderId', isEqualTo: orderId)
        .where('targetId', isEqualTo: targetId)
        .get();
    return snap.docs.isNotEmpty;
  }

  /// Submit a review and update target rating
  Future<void> submitReview(ReviewModel review) async {
    // 1. Add review document
    await _db.collection('reviews').add(review.toMap());

    // 2. Update target stats (Producer or Product)
    final collection = review.type == 'producer' ? AppConstants.producersCollection : AppConstants.productsCollection;
    final docRef = _db.collection(collection).doc(review.targetId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        final data = snapshot.data()!;
        double oldRating = (data['rating'] ?? 0).toDouble();
        int oldCount = (data['reviewCount'] ?? 0).toInt();

        double newRating = ((oldRating * oldCount) + review.rating) / (oldCount + 1);
        transaction.update(docRef, {
          'rating': newRating,
          'reviewCount': oldCount + 1,
        });
      }
    });
  }

  /// Cancel an order
  Future<void> cancelOrder(String orderId) async {
    await _db.collection(AppConstants.ordersCollection).doc(orderId).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== REVIEWS ====================

  Future<void> addReview({
    required String productId,
    required String producerId,
    required String customerId,
    required String customerName,
    required double rating,
    required String comment,
  }) async {
    await _db.collection(AppConstants.reviewsCollection).add({
      'productId': productId,
      'producerId': producerId,
      'customerId': customerId,
      'customerName': customerName,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update producer rating
    final reviewsSnap = await _db.collection(AppConstants.reviewsCollection)
        .where('producerId', isEqualTo: producerId)
        .get();
    
    if (reviewsSnap.docs.isNotEmpty) {
      double totalRating = 0;
      for (final doc in reviewsSnap.docs) {
        totalRating += (doc.data()['rating'] as num).toDouble();
      }
      final avgRating = totalRating / reviewsSnap.docs.length;
      
      await _db.collection(AppConstants.producersCollection).doc(producerId).update({
        'rating': avgRating,
        'reviewCount': reviewsSnap.docs.length,
      });
    }
  }

  // ==================== FAVORITES ====================

  Future<void> toggleFavorite(String customerId, String productId) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(customerId)
        .collection(AppConstants.favoritesCollection)
        .doc(productId)
        .get();

    if (doc.exists) {
      await doc.reference.delete();
    } else {
      await doc.reference.set({
        'productId': productId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<String>> getFavoriteIds(String customerId) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(customerId)
        .collection(AppConstants.favoritesCollection)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }
}
