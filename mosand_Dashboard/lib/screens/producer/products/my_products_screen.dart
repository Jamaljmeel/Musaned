import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/product_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/producer_provider.dart';
import 'add_edit_product_screen.dart';

class MyProductsScreen extends StatelessWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user?.uid ?? '';
    final prov = context.read<ProducerProvider>();

    return Scaffold(
      body: StreamBuilder<List<ProductModel>>(
        stream: prov.getMyProducts(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const LoadingWidget();
          if (!snap.hasData || snap.data!.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_rounded,
              title: 'لا يوجد منتجات بعد',
              subtitle: 'أضف أول منتج لمتجرك',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snap.data!.length,
            itemBuilder: (_, i) => _productCard(context, snap.data![i], prov),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => AddEditProductScreen(producerId: uid))),
        icon: const Icon(Icons.add_rounded),
        label: const Text('إضافة منتج'),
      ),
    );
  }

  Widget _productCard(BuildContext context, ProductModel product, ProducerProvider prov) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12),
              image: product.images.isNotEmpty
                  ? DecorationImage(image: NetworkImage(product.images.first), fit: BoxFit.cover)
                  : null,
            ),
            child: product.images.isEmpty ? const Icon(Icons.image_rounded, color: AppColors.textHint) : null,
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 4),
            Text(Helpers.formatPrice(product.price),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(children: [
              _statusBadge(product.isApproved ? 'معتمد' : 'بانتظار',
                  product.isApproved ? AppColors.success : AppColors.warning),
              const SizedBox(width: 8),
              _statusBadge(product.isAvailable ? 'متاح' : 'غير متاح',
                  product.isAvailable ? AppColors.info : AppColors.textHint),
            ]),
          ])),
          Column(children: [
            // Toggle availability
            Switch(
              value: product.isAvailable,
              activeColor: AppColors.success,
              onChanged: (v) => prov.toggleProductAvailability(product.id, product.isAvailable),
            ),
            // Edit
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 20, color: AppColors.primary),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AddEditProductScreen(
                      producerId: product.producerId, product: product))),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
