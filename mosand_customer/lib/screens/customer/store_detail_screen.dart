import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/producer_model.dart';
import '../../models/product_model.dart';
import '../../services/firestore_service.dart';
import 'product_detail_screen.dart';

class StoreDetailScreen extends StatelessWidget {
  final ProducerModel producer;
  const StoreDetailScreen({super.key, required this.producer});

  Future<void> _launchWhatsApp() async {
    if (producer.whatsapp.isEmpty) return;
    final url = 'https://wa.me/${producer.whatsapp}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchMaps() async {
    if (producer.fullAddress.isEmpty) return;
    final query = Uri.encodeComponent(producer.fullAddress);
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Dynamic Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  producer.logoUrl.isNotEmpty
                      ? CachedNetworkImage(imageUrl: producer.logoUrl, fit: BoxFit.cover)
                      : Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]))),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.7)]))),
                  Positioned(
                    bottom: 20, left: 20, right: 20,
                    child: Column(
                      children: [
                        Text(
                          producer.storeNameAr.isNotEmpty ? producer.storeNameAr : producer.storeName,
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actionable Store Info
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(40))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _infoBadge(Icons.star_rounded, producer.rating.toStringAsFixed(1), 'التقييم', AppColors.accent),
                      _infoBadge(Icons.verified_rounded, 'موثق', 'الحالة', Colors.blue),
                      _infoBadge(Icons.access_time_rounded, '9am-10pm', 'الدوام', AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Location Button
                  _actionTile(
                    icon: Icons.map_rounded,
                    title: 'موقعنا على الخريطة',
                    subtitle: producer.fullAddress.isNotEmpty ? producer.fullAddress : 'اضغط للعثور علينا',
                    color: Colors.red,
                    onTap: _launchMaps,
                  ),
                  const SizedBox(height: 16),
                  
                  // WhatsApp Button
                  _actionTile(
                    icon: Icons.chat_bubble_rounded,
                    title: 'تواصل معنا واتساب',
                    subtitle: producer.whatsapp.isNotEmpty ? producer.whatsapp : 'رقم المتجر المباشر',
                    color: Colors.green,
                    onTap: _launchWhatsApp,
                  ),
                  
                  if (producer.descriptionAr.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.surfaceVariant.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('عن المتجر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(producer.descriptionAr, style: const TextStyle(color: AppColors.textSecondary, height: 1.6)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Products List
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 16),
              child: Text('منتجاتنا المميزة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ),

          StreamBuilder<List<ProductModel>>(
            stream: firestoreService.getProducerProductsStream(producer.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const SliverToBoxAdapter(child: Center(child: LoadingWidget()));
              final products = snapshot.data?.where((p) => p.isApproved).map((p) => p.copyWith(producerName: producer.storeNameAr)).toList() ?? [];
              
              if (products.isEmpty) {
                return const SliverToBoxAdapter(child: EmptyState(icon: Icons.inventory_2_outlined, title: 'لا توجد منتجات حالياً'));
              }
              
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ProductCard(product: products[index]),
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
      ],
    );
  }

  Widget _actionTile({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(24),
          color: color.withValues(alpha: 0.02),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.open_in_new_rounded, color: color.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
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
              child: Container(
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
                      Text(Helpers.formatPrice(product.price), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15)),
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
