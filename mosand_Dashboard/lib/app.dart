import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/complete_producer_profile_screen.dart';
import 'screens/admin/admin_layout.dart';
import 'screens/producer/producer_layout.dart';
import 'providers/producer_provider.dart';

class MusanedApp extends StatelessWidget {
  const MusanedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مُساند',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar', 'SA'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const AuthWrapper(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/admin': (_) => const AdminLayout(),
        '/producer': (_) => const ProducerLayout(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.state) {
          case AuthState.initial:
          case AuthState.loading:
            return _buildSplash();
          case AuthState.authenticated:
            if (auth.isAdmin) return const AdminLayout();
            if (auth.isProducer) {
              // Check if profile is complete from AuthProvider (determined during initialize)
              if (!auth.isProfileComplete) {
                return const CompleteProducerProfileScreen();
              }

              // Profile is complete, show the layout
              return Consumer<ProducerProvider>(
                builder: (context, producerProv, _) {
                  // Ensure data is loaded in the provider for the layout
                  if (!producerProv.initialized && !producerProv.isLoading) {
                    Future.microtask(() => producerProv.loadProducerData(auth.user!.uid));
                  }
                  
                  return const ProducerLayout();
                },
              );
            }
            return const Scaffold(body: Center(child: Text('حساب غير مدعوم')));
          case AuthState.unauthenticated:
          case AuthState.error:
            return const LoginScreen();
        }
      },
    );
  }

  Widget _buildSplash() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              clipBehavior: Clip.antiAlias, // Ensures the image is clipped to the circle
              child: Image.asset(
                'assets/images/loge.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 30),
            const Text('مُساند', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
            const Text('منصة الأسر المنتجة', style: TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 50),
            const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          ],
        ),
      ),
    );
  }
}

