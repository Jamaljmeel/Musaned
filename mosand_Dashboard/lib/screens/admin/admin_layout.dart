import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import 'admin_dashboard.dart';
import 'producers_management/producers_list_screen.dart';
import 'products_management/products_list_screen.dart';
import 'orders_management/orders_list_screen.dart';
import 'categories_management/categories_screen.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});
  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;

  final _pages = const [
    AdminDashboard(),
    ProducersListScreen(),
    ProductsListScreen(),
    OrdersListScreen(),
    CategoriesScreen(),
  ];

  final _navItems = const [
    {'icon': Icons.dashboard_rounded, 'label': 'الرئيسية'},
    {'icon': Icons.storefront_rounded, 'label': 'المنتجين'},
    {'icon': Icons.inventory_2_rounded, 'label': 'المنتجات'},
    {'icon': Icons.shopping_bag_rounded, 'label': 'الطلبات'},
    {'icon': Icons.category_rounded, 'label': 'الفئات'},
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
              tooltip: 'تسجيل خروج',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('تسجيل الخروج',
                        textAlign: TextAlign.center),
                    content: const Text('هل تريد تسجيل الخروج؟',
                        textAlign: TextAlign.center),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('إلغاء')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error),
                        child: const Text('خروج'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  context.read<AuthProvider>().signOut();
                }
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
            items: _navItems
                .map((item) => BottomNavigationBarItem(
                      icon: Icon(item['icon'] as IconData),
                      label: item['label'] as String,
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
