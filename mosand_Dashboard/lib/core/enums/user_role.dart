enum UserRole {
  admin,
  producer,
  customer;

  String get nameAr {
    switch (this) {
      case UserRole.admin:
        return 'مدير النظام';
      case UserRole.producer:
        return 'منتج';
      case UserRole.customer:
        return 'عميل';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.customer,
    );
  }
}
