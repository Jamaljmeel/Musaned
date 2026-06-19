import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/order_model.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final FirestoreService _firestore = FirestoreService();
  final Map<String, bool> _reviewedItems = {};

  @override
  void initState() {
    super.initState();
    _checkReviews();
  }

  Future<void> _checkReviews() async {
    if (widget.order.status != 'delivered') return;
    
    // Check store review
    bool storeReviewed = await _firestore.hasReviewed(widget.order.id, widget.order.producerId);
    if (mounted) setState(() => _reviewedItems[widget.order.producerId] = storeReviewed);

    // Check items reviews
    for (var item in widget.order.items) {
      bool itemReviewed = await _firestore.hasReviewed(widget.order.id, item.productId);
      if (mounted) setState(() => _reviewedItems[item.productId] = itemReviewed);
    }
  }

  void _showRatingDialog(String targetId, String targetName, String type) {
    double rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('تقييم $targetName', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => GestureDetector(
                  onTap: () => setDialogState(() => rating = index + 1.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppColors.accent,
                      size: 34,
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'اكتب رأيك هنا (اختياري)',
                  filled: true,
                  fillColor: AppColors.surfaceVariant.withValues(alpha: 0.3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final auth = context.read<AuthProvider>();
                final review = ReviewModel(
                  id: '',
                  orderId: widget.order.id,
                  customerId: auth.user!.uid,
                  customerName: auth.user!.displayName ?? 'عميل مُساند',
                  targetId: targetId,
                  type: type,
                  rating: rating,
                  comment: commentController.text,
                  createdAt: DateTime.now(),
                );
                await _firestore.submitReview(review);
                if (mounted) {
                  setState(() => _reviewedItems[targetId] = true);
                  Navigator.pop(context);
                  Helpers.showSuccess(context, 'شكراً لتقييمك! ✨');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('إرسال التقييم'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('تفاصيل الطلب #${widget.order.orderNumber}'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('المنتجات'),
            _buildItemsCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('معلومات التوصيل'),
            _buildAddressCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('ملخص الدفع'),
            _buildSummaryCard(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final statusColor = Helpers.getOrderStatusColor(widget.order.status);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('حالة الطلب الحالية', style: TextStyle(color: statusColor.withValues(alpha: 0.7), fontSize: 12)),
                Text(Helpers.getOrderStatusArabic(widget.order.status), style: TextStyle(color: statusColor, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(right: 8, bottom: 12), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
  }

  Widget _buildItemsCard() {
    bool canRate = widget.order.status == 'delivered';
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.order.producerName ?? 'متجر مساند', style: const TextStyle(fontWeight: FontWeight.bold))),
                if (canRate)
                  _reviewedItems[widget.order.producerId] == true
                      ? const Text('تم التقييم ✅', style: TextStyle(color: Colors.green, fontSize: 12))
                      : TextButton.icon(
                          onPressed: () => _showRatingDialog(widget.order.producerId, widget.order.producerName ?? 'المتجر', 'producer'),
                          icon: const Icon(Icons.star_rounded, size: 16),
                          label: const Text('تقييم المتجر', style: TextStyle(fontSize: 12)),
                        ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.order.items.length,
            separatorBuilder: (_, __) => const Divider(indent: 20, endIndent: 20),
            itemBuilder: (context, index) {
              final item = widget.order.items[index];
              return ListTile(
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('الكمية: ${item.quantity}', style: const TextStyle(fontSize: 12)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(Helpers.formatPrice(item.price * item.quantity), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    if (canRate)
                      _reviewedItems[item.productId] == true
                          ? const Text('قيمت', style: TextStyle(color: Colors.green, fontSize: 10))
                          : InkWell(
                              onTap: () => _showRatingDialog(item.productId, item.name, 'product'),
                              child: const Text('تقييم المنتج', style: TextStyle(color: AppColors.primary, fontSize: 10, decoration: TextDecoration.underline)),
                            ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(Icons.location_city_rounded, 'المدينة', widget.order.deliveryAddress['city'] ?? 'غير محدد'),
          const SizedBox(height: 12),
          _infoRow(Icons.map_rounded, 'العنوان', widget.order.deliveryAddress['address'] ?? 'غير محدد'),
          const SizedBox(height: 12),
          _infoRow(Icons.phone_rounded, 'رقم التواصل', widget.order.deliveryAddress['phone'] ?? 'غير محدد'),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          _priceRow('المجموع الفرعي', widget.order.subtotal),
          // _priceRow('رسوم التوصيل', widget.order.deliveryFee),
          const Divider(height: 30),
          _priceRow('الإجمالي', widget.order.totalAmount, isBold: true),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textHint),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
      ],
    );
  }

  Widget _priceRow(String label, double price, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(Helpers.formatPrice(price), style: TextStyle(fontWeight: FontWeight.bold, fontSize: isBold ? 18 : 14, color: isBold ? AppColors.primary : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
