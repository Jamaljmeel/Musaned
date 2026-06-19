class CategoryModel {
  final String id;
  final String name;
  final String nameAr;
  final String icon;
  final String image;
  final bool isActive;
  final int order;
  final int productsCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.nameAr,
    this.icon = '',
    this.image = '',
    this.isActive = true,
    this.order = 0,
    this.productsCount = 0,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return CategoryModel(
      id: docId,
      name: map['name'] ?? '',
      nameAr: map['nameAr'] ?? '',
      icon: map['icon'] ?? '',
      image: map['image'] ?? '',
      isActive: map['isActive'] ?? true,
      order: map['order'] ?? 0,
      productsCount: map['productsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameAr': nameAr,
      'icon': icon,
      'image': image,
      'isActive': isActive,
      'order': order,
      'productsCount': productsCount,
    };
  }
}
