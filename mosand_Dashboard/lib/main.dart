import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/producer_provider.dart';
import 'providers/category_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('ar', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ProducerProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()..loadCategories()),
      ],
      child: const MusanedApp(),
    ),
  );
}
