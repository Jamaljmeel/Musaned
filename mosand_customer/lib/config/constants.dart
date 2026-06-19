class AppConstants {
  static const String appName = 'مُساند';
  static const String appNameEn = 'Musaned';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String producersCollection = 'producers';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String reviewsCollection = 'reviews';
  static const String categoriesCollection = 'categories';
  static const String notificationsCollection = 'notifications';
  static const String reportsCollection = 'reports';
  static const String favoritesCollection = 'favorites';
  static const String cartCollection = 'cart';

  // Storage paths
  static const String producerImagesPath = 'producers';
  static const String productImagesPath = 'products';
  static const String userAvatarsPath = 'avatars';

  // Limits
  static const int productsPerPage = 20;
  static const int ordersPerPage = 20;

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleProducer = 'producer';
  static const String roleCustomer = 'customer';
}
