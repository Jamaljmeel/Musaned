import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 1,
      price: (map['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  double get total => price * quantity;
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final String producerId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final Map<String, dynamic> deliveryAddress;
  final String notes;
  final DateTime? estimatedDelivery;
  final DateTime? acceptedAt;
  final DateTime? preparedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Transient
  final String? customerName;
  final String? producerName;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.producerId,
    this.items = const [],
    required this.subtotal,
    this.deliveryFee = 0,
    required this.totalAmount,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    this.deliveryAddress = const {},
    this.notes = '',
    this.estimatedDelivery,
    this.acceptedAt,
    this.preparedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason = '',
    required this.createdAt,
    required this.updatedAt,
    this.customerName,
    this.producerName,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return OrderModel(
      id: docId,
      orderNumber: map['orderNumber'] ?? '',
      customerId: map['customerId'] ?? '',
      producerId: map['producerId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      deliveryAddress: Map<String, dynamic>.from(map['deliveryAddress'] ?? {}),
      notes: map['notes'] ?? '',
      estimatedDelivery: (map['estimatedDelivery'] as Timestamp?)?.toDate(),
      acceptedAt: (map['acceptedAt'] as Timestamp?)?.toDate(),
      preparedAt: (map['preparedAt'] as Timestamp?)?.toDate(),
      deliveredAt: (map['deliveredAt'] as Timestamp?)?.toDate(),
      cancelledAt: (map['cancelledAt'] as Timestamp?)?.toDate(),
      cancellationReason: map['cancellationReason'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      customerName: map['customerName'],
      producerName: map['producerName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'customerId': customerId,
      'producerId': producerId,
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'deliveryAddress': deliveryAddress,
      'notes': notes,
      'estimatedDelivery': estimatedDelivery != null
          ? Timestamp.fromDate(estimatedDelivery!)
          : null,
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'preparedAt': preparedAt != null ? Timestamp.fromDate(preparedAt!) : null,
      'deliveredAt':
          deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'cancelledAt':
          cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancellationReason': cancellationReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  int get totalItems => items.fold(0, (total, item) => total + item.quantity);

  String get paymentMethodAr => 'الدفع عند الاستلام';
}
