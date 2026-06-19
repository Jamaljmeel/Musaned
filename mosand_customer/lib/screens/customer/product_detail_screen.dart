import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../core/widgets/custom_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final bool isFav = favorites.isFavorite(widget.product.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              color: isFav ? Colors.red : AppColors.textPrimary,
            ),
            onPressed: () => favorites.toggleFavorite(widget.product.id),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Hero
            Hero(
              tag: 'product_${widget.product.nameAr}',
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  image: widget.product.imageUrl.isNotEmpty
                      ? DecorationImage(image: CachedNetworkImageProvider(widget.product.imageUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: widget.product.imageUrl.isEmpty ? const Icon(Icons.fastfood_rounded, size: 80, color: Colors.grey) : null,
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.nameAr,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        Helpers.formatPrice(widget.product.price),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.accent, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.product.rating.toStringAsFixed(1)} (${widget.product.reviewCount} تقييم)',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Icon(Icons.verified_user_rounded, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      const Text('منتج موثق', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text('وصف المنتج', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.descriptionAr,
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 15),
                  ),
                  const SizedBox(height: 40),
                  
                  // Quantity Selector
                  const Text('الكمية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildQuantitySelector(),
                  
                  const SizedBox(height: 40),
                  CustomButton(
                    text: 'إضافة إلى السلة',
                    icon: Icons.add_shopping_cart_rounded,
                    onPressed: () {
                      cart.addItem(widget.product, quantity: _quantity);
                      Helpers.showSuccess(context, 'تمت الإضافة للسلة بنجاح');
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qButton(Icons.remove, () {
            if (_quantity > 1) setState(() => _quantity--);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _qButton(Icons.add, () => setState(() => _quantity++)),
        ],
      ),
    );
  }

  Widget _qButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}
