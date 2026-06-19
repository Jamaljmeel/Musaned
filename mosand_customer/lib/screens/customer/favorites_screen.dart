import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/product_model.dart';
import '../../providers/favorites_provider.dart';
import '../../services/firestore_service.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final fs = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('المفضلة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: favorites.favoriteIds.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_outline_rounded,
              title: 'قائمة مفضلاتك فارغة',
              subtitle: 'أضف المنتجات التي تعجبك لتجدها هنا لاحقاً',
            )
          : FutureBuilder<List<ProductModel>>(
              future: _loadFavoriteProducts(fs, favorites.favoriteIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingWidget());
                }
                
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return const EmptyState(icon: Icons.search_off_rounded, title: 'لا توجد بيانات');
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) => _ProductCard(product: products[index]),
                );
              },
            ),
    );
  }

  Future<List<ProductModel>> _loadFavoriteProducts(FirestoreService fs, List<String> ids) async {
    List<ProductModel> products = [];
    for (String id in ids) {
      final p = await fs.getProductById(id);
      if (p != null) products.add(p);
    }
    return products;
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      image: product.imageUrl.isNotEmpty
                          ? DecorationImage(image: CachedNetworkImageProvider(product.imageUrl), fit: BoxFit.cover)
                          : null,
                      color: AppColors.surfaceVariant,
                    ),
                    child: product.imageUrl.isEmpty ? const Icon(Icons.fastfood_rounded, color: Colors.grey) : null,
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.favorite_rounded, color: Colors.red, size: 18),
                        onPressed: () => context.read<FavoritesProvider>().toggleFavorite(product.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.nameAr, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(Helpers.formatPrice(product.price), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.accent, size: 14),
                          Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
