import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/producer_model.dart';
import '../../models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/firestore_service.dart';
import 'store_detail_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Premium Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${Helpers.getGreeting()} 👋', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                auth.user?.displayName ?? 'زائرنا الكريم',
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        _buildHeaderAction(
                          context,
                          icon: Icons.shopping_cart_rounded,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                          badgeCount: context.watch<CartProvider>().itemCount,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Search Bar (Now Functional)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        textDirection: TextDirection.rtl,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن متجر...',
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
                          suffixIcon: _searchQuery.isNotEmpty 
                              ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                }) 
                              : null,
                          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Categories Bar
                    _buildCategoriesBar(firestoreService),
                  ],
                ),
              ),
            ),
          ),

          // Stores List
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionHeader(_searchQuery.isNotEmpty ? 'نتائج البحث' : (_selectedCategory == null ? 'المتاجر المميزة' : 'نتائج الفئة')),
                const SizedBox(height: 16),
                StreamBuilder<List<ProducerModel>>(
                  stream: firestoreService.getApprovedProducersStream(category: _selectedCategory),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) return const Center(child: LoadingWidget());
                    
                    var producers = snap.data ?? [];
                    
                    // Filter locally for search
                    if (_searchQuery.isNotEmpty) {
                      producers = producers.where((p) => 
                        p.storeNameAr.contains(_searchQuery) || 
                        p.storeName.toLowerCase().contains(_searchQuery.toLowerCase())
                      ).toList();
                    }

                    if (producers.isEmpty) {
                      return const EmptyState(icon: Icons.search_off_rounded, title: 'لا توجد نتائج مطابقة');
                    }
                    
                    return Column(
                      children: producers.map((p) => _StoreCard(producer: p)).toList(),
                    );
                  },
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildCategoriesBar(FirestoreService fs) {
    return SizedBox(
      height: 40,
      child: StreamBuilder<List<CategoryModel>>(
        stream: fs.getCategoriesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final categories = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final cat = isAll ? null : categories[index - 1];
              final isSelected = isAll ? _selectedCategory == null : _selectedCategory == cat!.id;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = isAll ? null : cat!.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondary : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isAll ? 'الكل' : cat!.nameAr,
                      style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeaderAction(BuildContext context, {required IconData icon, required VoidCallback onTap, int badgeCount = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          if (badgeCount > 0)
            Positioned(
              right: 0, top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }
}

class _StoreCard extends StatelessWidget {
  final ProducerModel producer;
  const _StoreCard({required this.producer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoreDetailScreen(producer: producer))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(colors: [Colors.grey.shade200, Colors.grey.shade100]),
              ),
              child: producer.logoUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: CachedNetworkImage(imageUrl: producer.logoUrl, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.storefront_rounded, size: 50, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producer.storeNameAr.isNotEmpty ? producer.storeNameAr : producer.storeName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.accent, size: 18),
                            const SizedBox(width: 4),
                            Text(producer.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 16),
                            const SizedBox(width: 4),
                            Text(producer.cityName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
