import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'favorites_screen.dart';
import 'profile/profile_screen.dart';

class CustomerLayout extends StatefulWidget {
  const CustomerLayout({super.key});

  @override
  State<CustomerLayout> createState() => _CustomerLayoutState();
}

class _CustomerLayoutState extends State<CustomerLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FavoritesScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.storefront_rounded), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'المفضلة'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'طلباتي'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'حسابي'),
          ],
        ),
      ),
    );
  }
}
