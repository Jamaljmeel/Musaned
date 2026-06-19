import 'package:cloud_firestore/cloud_firestore.dart';

class ProducerModel {
  final String userId;
  final String storeName;
  final String storeNameAr;
  final String description;
  final String descriptionAr;
  final String category;
  final String logoUrl;
  final String instagramUrl;
  final String whatsapp;
  final Map<String, dynamic> address;


  final String businessLicense;
  final String healthCertificate;
  final bool isApproved;
  final String approvalStatus;
  final String rejectionReason;
  final double qualityScore;
  final int totalOrders;
  final double totalRevenue;
  final double rating;
  final int reviewCount;
  final bool isOnline;
  final Map<String, dynamic> workingHours;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Transient field for displaying user info
  final String? email;
  final String? displayName;
  final String? phone;

  ProducerModel({
    required this.userId,
    required this.storeName,
    this.storeNameAr = '',
    this.description = '',
    this.descriptionAr = '',
    this.category = 'food',
    this.logoUrl = '',
    this.instagramUrl = '',
    this.whatsapp = '',
    this.address = const {},

    this.businessLicense = '',
    this.healthCertificate = '',
    this.isApproved = false,
    this.approvalStatus = 'pending',
    this.rejectionReason = '',
    this.qualityScore = 0,
    this.totalOrders = 0,
    this.totalRevenue = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.isOnline = false,
    this.workingHours = const {},
    required this.createdAt,
    required this.updatedAt,
    this.email,
    this.displayName,
    this.phone,
  });

  factory ProducerModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProducerModel(
      userId: docId,
      storeName: map['storeName'] ?? '',
      storeNameAr: map['storeNameAr'] ?? '',
      description: map['description'] ?? '',
      descriptionAr: map['descriptionAr'] ?? '',
      category: map['category'] ?? 'food',
      logoUrl: map['logoUrl'] ?? '',
      instagramUrl: map['instagramUrl'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      address: Map<String, dynamic>.from(map['address'] ?? {}),

      businessLicense: map['businessLicense'] ?? '',
      healthCertificate: map['healthCertificate'] ?? '',
      isApproved: map['isApproved'] ?? false,
      approvalStatus: map['approvalStatus'] ?? 'pending',
      rejectionReason: map['rejectionReason'] ?? '',
      qualityScore: (map['qualityScore'] ?? 0).toDouble(),
      totalOrders: map['totalOrders'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isOnline: map['isOnline'] ?? false,
      workingHours: Map<String, dynamic>.from(map['workingHours'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      email: map['email'],
      displayName: map['displayName'],
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeName': storeName,
      'storeNameAr': storeNameAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'category': category,
      'logoUrl': logoUrl,
      'instagramUrl': instagramUrl,
      'whatsapp': whatsapp,
      'address': address,

      'businessLicense': businessLicense,
      'healthCertificate': healthCertificate,
      'isApproved': isApproved,
      'approvalStatus': approvalStatus,
      'rejectionReason': rejectionReason,
      'qualityScore': qualityScore,
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'rating': rating,
      'reviewCount': reviewCount,
      'isOnline': isOnline,
      'workingHours': workingHours,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  String get categoryAr {
    switch (category) {
      case 'food':
        return 'طعام';
      case 'crafts':
        return 'حرف يدوية';
      case 'products':
        return 'منتجات';
      default:
        return category;
    }
  }

  String get cityName => address['city'] ?? '';
  String get districtName => address['district'] ?? '';
  String get fullAddress => '${address['city'] ?? ''}, ${address['district'] ?? ''}';

  ProducerModel copyWith({
    String? storeName,
    String? storeNameAr,
    String? description,
    String? descriptionAr,
    String? category,
    String? logoUrl,
    Map<String, dynamic>? address,
    String? businessLicense,
    String? healthCertificate,
    bool? isApproved,
    String? approvalStatus,
    String? rejectionReason,
    double? qualityScore,
    bool? isOnline,
    Map<String, dynamic>? workingHours,
  }) {
    return ProducerModel(
      userId: userId,
      storeName: storeName ?? this.storeName,
      storeNameAr: storeNameAr ?? this.storeNameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      category: category ?? this.category,
      logoUrl: logoUrl ?? this.logoUrl,
      address: address ?? this.address,
      businessLicense: businessLicense ?? this.businessLicense,
      healthCertificate: healthCertificate ?? this.healthCertificate,
      isApproved: isApproved ?? this.isApproved,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      qualityScore: qualityScore ?? this.qualityScore,
      totalOrders: totalOrders,
      totalRevenue: totalRevenue,
      rating: rating,
      reviewCount: reviewCount,
      isOnline: isOnline ?? this.isOnline,
      workingHours: workingHours ?? this.workingHours,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      email: email,
      displayName: displayName,
      phone: phone,
    );
  }
}
