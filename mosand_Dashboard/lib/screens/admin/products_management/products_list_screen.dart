import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/product_model.dart';
import '../../../providers/admin_provider.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});
  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  int _tabIndex = 0; // 0=all, 1=pending, 2=approved

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AdminProvider>();
    bool? approvedFilter = _tabIndex == 0 ? null : _tabIndex == 2;

    return Column(
      children: [
        // Tabs
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _tab('الكل', 0),
              _tab('بانتظار الموافقة', 1),
              _tab('معتمد', 2),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ProductModel>>(
            stream: admin.getProductsStream(isApproved: approvedFilter),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const LoadingWidget();
              if (!snap.hasData || snap.data!.isEmpty) {
                return const EmptyState(icon: Icons.inventory_2_rounded, title: 'لا يوجد منتجات');
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: snap.data!.length,
                itemBuilder: (_, i) => _productCard(snap.data![i]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _tab(String label, int index) {
    final sel = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                color: sel ? Colors.white : AppColors.textSecondary,
              )),
        ),
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              image: product.images.isNotEmpty
                  ? DecorationImage(image: NetworkImage(product.images.first), fit: BoxFit.cover)
                  : null,
            ),
            child: product.images.isEmpty
                ? const Icon(Icons.image_rounded, color: AppColors.textHint)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(Helpers.formatPrice(product.price),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(product.isApproved ? Icons.verified_rounded : Icons.pending_rounded,
                      size: 14, color: product.isApproved ? AppColors.success : AppColors.warning),
                  const SizedBox(width: 4),
                  Text(product.isApproved ? 'معتمد' : 'بانتظار الموافقة',
                      style: TextStyle(fontSize: 11,
                          color: product.isApproved ? AppColors.success : AppColors.warning)),
                ]),
              ],
            ),
          ),
          Column(
            children: [
              if (!product.isApproved)
                IconButton(
                  tooltip: 'اعتماد المنتج',
                  icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
                  onPressed: () async {
                    await context.read<AdminProvider>().approveProduct(product.id);
                    if (mounted) Helpers.showSuccess(context, 'تم اعتماد المنتج بنجاح');
                  },
                ),
              if (product.isApproved)
                IconButton(
                  tooltip: 'إلغاء اعتماد المنتج',
                  icon: const Icon(Icons.block_rounded, color: AppColors.error),
                  onPressed: () async {
                    await context.read<AdminProvider>().rejectProduct(product.id);
                    if (mounted) Helpers.showSuccess(context, 'تم إلغاء اعتماد المنتج');
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
