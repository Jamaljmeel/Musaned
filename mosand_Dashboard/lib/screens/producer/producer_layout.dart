import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import 'producer_dashboard.dart';
import 'products/my_products_screen.dart';
import 'orders/producer_orders_screen.dart';
import 'store_profile_screen.dart';

class ProducerLayout extends StatefulWidget {
  const ProducerLayout({super.key});
  @override
  State<ProducerLayout> createState() => _ProducerLayoutState();
}

class _ProducerLayoutState extends State<ProducerLayout> {
  int _selectedIndex = 0;

  final _pages = const [
    ProducerDashboardScreen(),
    MyProductsScreen(),
    ProducerOrdersScreen(),
    StoreProfileScreen(),
  ];

  final _navItems = const [
    {'icon': Icons.dashboard_rounded, 'label': 'الرئيسية'},
    {'icon': Icons.inventory_2_rounded, 'label': 'منتجاتي'},
    {'icon': Icons.shopping_bag_rounded, 'label': 'الطلبات'},
    {'icon': Icons.store_rounded, 'label': 'متجري'},
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_navItems[_selectedIndex]['label'] as String),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('تسجيل الخروج', textAlign: TextAlign.center),
                    content: const Text('هل تريد تسجيل الخروج؟', textAlign: TextAlign.center),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        child: const Text('خروج'),
                      ),
                    ],
                  ),
                );
                if (ok == true && mounted) context.read<AuthProvider>().signOut();
              },
            ),
          ],
        ),
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
            items: _navItems.map((item) => BottomNavigationBarItem(
              icon: Icon(item['icon'] as IconData),
              label: item['label'] as String,
            )).toList(),
          ),
        ),
      ),
    );
  }
}
