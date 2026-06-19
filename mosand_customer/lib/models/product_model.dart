import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String producerId;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final String category;
  final String subcategory;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final bool isAvailable;
  final bool isApproved;
  final int preparationTime;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final int orderCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Transient
  final String? producerName;

  ProductModel({
    required this.id,
    required this.producerId,
    required this.name,
    this.nameAr = '',
    this.description = '',
    this.descriptionAr = '',
    this.category = '',
    this.subcategory = '',
    required this.price,
    this.discountPrice,
    this.images = const [],
    this.isAvailable = true,
    this.isApproved = false,
    this.preparationTime = 30,
    this.tags = const [],
    this.rating = 0,
    this.reviewCount = 0,
    this.orderCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.producerName,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      producerId: map['producerId'] ?? '',
      name: map['name'] ?? '',
      nameAr: map['nameAr'] ?? '',
      description: map['description'] ?? '',
      descriptionAr: map['descriptionAr'] ?? '',
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: map['discountPrice'] != null
          ? (map['discountPrice']).toDouble()
          : null,
      images: List<String>.from(map['images'] ?? []),
      isAvailable: map['isAvailable'] ?? true,
      isApproved: map['isApproved'] ?? false,
      preparationTime: map['preparationTime'] ?? 30,
      tags: List<String>.from(map['tags'] ?? []),
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      orderCount: map['orderCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      producerName: map['producerName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'producerId': producerId,
      'name': name,
      'nameAr': nameAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'category': category,
      'subcategory': subcategory,
      'price': price,
      'discountPrice': discountPrice,
      'images': images,
      'isAvailable': isAvailable,
      'isApproved': isApproved,
      'preparationTime': preparationTime,
      'tags': tags,
      'rating': rating,
      'reviewCount': reviewCount,
      'orderCount': orderCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  double get effectivePrice => hasDiscount ? discountPrice! : price;

  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((price - discountPrice!) / price * 100);
  }

  String get imageUrl => images.isNotEmpty ? images.first : '';
  String get categoryNameAr => category;

  ProductModel copyWith({
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    String? category,
    String? subcategory,
    double? price,
    double? discountPrice,
    List<String>? images,
    bool? isAvailable,
    bool? isApproved,
    int? preparationTime,
    List<String>? tags,
    String? producerName,
  }) {
    return ProductModel(
      id: id,
      producerId: producerId,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      images: images ?? this.images,
      isAvailable: isAvailable ?? this.isAvailable,
      isApproved: isApproved ?? this.isApproved,
      preparationTime: preparationTime ?? this.preparationTime,
      tags: tags ?? this.tags,
      rating: rating,
      reviewCount: reviewCount,
      orderCount: orderCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      producerName: producerName ?? this.producerName,
    );
  }
}
