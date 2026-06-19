import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';
import '../models/user_model.dart';
import '../models/producer_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/category_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== USERS ====================

  Future<void> createUser(UserModel user) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap());
  }


  Future<UserModel?> getUser(String uid) async {
    final doc =
        await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection(AppConstants.usersCollection).doc(uid).update(data);
  }

  // ==================== PRODUCERS ====================

  Stream<List<ProducerModel>> getProducersStream({String? statusFilter}) {
    Query query = _db.collection(AppConstants.producersCollection);
    if (statusFilter != null && statusFilter.isNotEmpty) {
      query = query.where('approvalStatus', isEqualTo: statusFilter);
    }
    return query.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ProducerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList(),
        );
  }

  Future<List<ProducerModel>> getProducers({String? statusFilter}) async {
    Query query = _db.collection(AppConstants.producersCollection);
    if (statusFilter != null && statusFilter.isNotEmpty) {
      query = query.where('approvalStatus', isEqualTo: statusFilter);
    }
    final snapshot = await query.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => ProducerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<ProducerModel?> getProducer(String uid) async {
    final doc =
        await _db.collection(AppConstants.producersCollection).doc(uid).get();
    if (doc.exists) {
      return ProducerModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> saveProducer(ProducerModel producer) async {
    await _db
        .collection(AppConstants.producersCollection)
        .doc(producer.userId)
        .set(producer.toMap());
  }

  Future<void> updateProducer(String uid, Map<String, dynamic> data) async {

    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db
        .collection(AppConstants.producersCollection)
        .doc(uid)
        .update(data);
  }

  Future<void> approveProducer(String uid) async {
    final batch = _db.batch();
    
    batch.update(_db.collection(AppConstants.producersCollection).doc(uid), {
      'isApproved': true,
      'approvalStatus': 'approved',
      'rejectionReason': '',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.update(_db.collection(AppConstants.usersCollection).doc(uid), {
      'isVerified': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> rejectProducer(String uid, String reason) async {
    final batch = _db.batch();

    batch.update(_db.collection(AppConstants.producersCollection).doc(uid), {
      'isApproved': false,
      'approvalStatus': 'rejected',
      'rejectionReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.update(_db.collection(AppConstants.usersCollection).doc(uid), {
      'isVerified': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ==================== PRODUCTS ====================

  Stream<List<ProductModel>> getProductsStream({
    String? producerId,
    bool? isApproved,
  }) {
    Query query = _db.collection(AppConstants.productsCollection);
    if (producerId != null) {
      query = query.where('producerId', isEqualTo: producerId);
    }
    if (isApproved != null) {
      query = query.where('isApproved', isEqualTo: isApproved);
    }
    return query.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList(),
        );
  }

  Future<List<ProductModel>> getProducts({
    String? producerId,
    bool? isApproved,
  }) async {
    Query query = _db.collection(AppConstants.productsCollection);
    if (producerId != null) {
      query = query.where('producerId', isEqualTo: producerId);
    }
    if (isApproved != null) {
      query = query.where('isApproved', isEqualTo: isApproved);
    }
    final snapshot = await query.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<String> addProduct(ProductModel product) async {
    final doc = await _db
        .collection(AppConstants.productsCollection)
        .add(product.toMap());
    return doc.id;
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db
        .collection(AppConstants.productsCollection)
        .doc(id)
        .update(data);
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection(AppConstants.productsCollection).doc(id).delete();
  }

  Future<void> approveProduct(String id) async {
    await _db.collection(AppConstants.productsCollection).doc(id).update({
      'isApproved': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectProduct(String id) async {
    await _db.collection(AppConstants.productsCollection).doc(id).update({
      'isApproved': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== ORDERS ====================

  Stream<List<OrderModel>> getOrdersStream({
    String? producerId,
    String? status,
  }) {
    Query query = _db.collection(AppConstants.ordersCollection);
    if (producerId != null) {
      query = query.where('producerId', isEqualTo: producerId);
    }
    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }
    return query.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList(),
        );
  }

  Future<List<OrderModel>> getOrders({
    String? producerId,
    String? status,
  }) async {
    Query query = _db.collection(AppConstants.ordersCollection);
    if (producerId != null) {
      query = query.where('producerId', isEqualTo: producerId);
    }
    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }
    final snapshot = await query.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final Map<String, dynamic> data = {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    // Set timestamp for specific status changes
    switch (status) {
      case 'accepted':
        data['acceptedAt'] = FieldValue.serverTimestamp();
        break;
      case 'ready':
        data['preparedAt'] = FieldValue.serverTimestamp();
        break;
      case 'delivered':
        data['deliveredAt'] = FieldValue.serverTimestamp();
        data['paymentStatus'] = 'paid';
        break;
      case 'cancelled':
        data['cancelledAt'] = FieldValue.serverTimestamp();
        break;
    }
    await _db.collection(AppConstants.ordersCollection).doc(orderId).update(data);
  }

  // ==================== CATEGORIES ====================

  Stream<List<CategoryModel>> getCategoriesStream() {
    return _db
        .collection(AppConstants.categoriesCollection)
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<List<CategoryModel>> getCategories({bool activeOnly = true}) async {
    Query query = _db.collection(AppConstants.categoriesCollection).orderBy('order');
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<String> addCategory(CategoryModel category) async {
    final doc = await _db
        .collection(AppConstants.categoriesCollection)
        .add(category.toMap());
    return doc.id;
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.categoriesCollection)
        .doc(id)
        .update(data);
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection(AppConstants.categoriesCollection).doc(id).delete();
  }

  // ==================== DASHBOARD STATS ====================

  Future<Map<String, dynamic>> getAdminDashboardStats() async {
    final producers =
        await _db.collection(AppConstants.producersCollection).get();
    final products =
        await _db.collection(AppConstants.productsCollection).get();
    final orders = await _db.collection(AppConstants.ordersCollection).get();

    final pendingProducers = producers.docs
        .where((d) => d.data()['approvalStatus'] == 'pending')
        .length;
    final approvedProducers = producers.docs
        .where((d) => d.data()['approvalStatus'] == 'approved')
        .length;
    final pendingProducts = products.docs
        .where((d) => d.data()['isApproved'] == false)
        .length;
    
    double totalRevenue = 0;
    int deliveredOrders = 0;
    int pendingOrders = 0;
    for (final doc in orders.docs) {
      final data = doc.data();
      if (data['status'] == 'delivered') {
        totalRevenue += (data['totalAmount'] ?? 0).toDouble();
        deliveredOrders++;
      }
      if (data['status'] == 'pending') {
        pendingOrders++;
      }
    }

    return {
      'totalProducers': producers.docs.length,
      'pendingProducers': pendingProducers,
      'approvedProducers': approvedProducers,
      'totalProducts': products.docs.length,
      'pendingProducts': pendingProducts,
      'totalOrders': orders.docs.length,
      'deliveredOrders': deliveredOrders,
      'pendingOrders': pendingOrders,
      'totalRevenue': totalRevenue,
    };
  }

  Future<Map<String, dynamic>> getProducerDashboardStats(
      String producerId) async {
    final products = await _db
        .collection(AppConstants.productsCollection)
        .where('producerId', isEqualTo: producerId)
        .get();
    final orders = await _db
        .collection(AppConstants.ordersCollection)
        .where('producerId', isEqualTo: producerId)
        .get();

    double totalRevenue = 0;
    int deliveredOrders = 0;
    int pendingOrders = 0;
    int activeOrders = 0;

    for (final doc in orders.docs) {
      final data = doc.data();
      final status = data['status'] ?? '';
      if (status == 'delivered') {
        totalRevenue += (data['totalAmount'] ?? 0).toDouble();
        deliveredOrders++;
      }
      if (status == 'pending') pendingOrders++;
      if (status != 'delivered' && status != 'cancelled') activeOrders++;
    }

    return {
      'totalProducts': products.docs.length,
      'activeProducts':
          products.docs.where((d) => d.data()['isAvailable'] == true).length,
      'totalOrders': orders.docs.length,
      'deliveredOrders': deliveredOrders,
      'pendingOrders': pendingOrders,
      'activeOrders': activeOrders,
      'totalRevenue': totalRevenue,
    };
  }
}
