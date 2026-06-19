import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Date Formatting for Arabic
  await initializeDateFormatting('ar_SA', null);
  
  // Note: Firebase initialization will require google-services.json/firebase_options.dart
  // which you mentioned you will handle later.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase not initialized yet: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const MusanedCustomerApp(),
    ),
  );
}
