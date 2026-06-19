import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedStatus = 'all';

  final List<Map<String, String>> _statusFilters = [
    {'id': 'all', 'label': 'الكل'},
    {'id': 'pending', 'label': 'قيد الانتظار'},
    {'id': 'accepted', 'label': 'تم القبول'},
    {'id': 'prepared', 'label': 'جاري التجهيز'},
    {'id': 'delivered', 'label': 'تم التوصيل'},
    {'id': 'cancelled', 'label': 'ملغي'},
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('طلباتي', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Premium Filter Bar
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _statusFilters.length,
              itemBuilder: (context, index) {
                final filter = _statusFilters[index];
                final isSelected = _selectedStatus == filter['id'];
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedStatus = filter['id']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected 
                          ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))]
                          : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        filter['label']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Orders List
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: firestoreService.getCustomerOrdersStream(auth.user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingWidget());
                }
                
                var orders = snapshot.data ?? [];
                if (_selectedStatus != 'all') {
                  orders = orders.where((o) => o.status == _selectedStatus).toList();
                }

                if (orders.isEmpty) {
                  return const EmptyState(
                    icon: Icons.assignment_rounded,
                    title: 'لا توجد طلبات',
                    subtitle: 'لم نجد أي طلبات مطابقة لهذه الحالة',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: orders.length,
                  itemBuilder: (context, index) => _OrderCard(order: orders[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = Helpers.getOrderStatusColor(order.status);
    final statusText = Helpers.getOrderStatusArabic(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          // Top Info Row
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('طلب #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        const SizedBox(height: 4),
                        Text(Helpers.formatDate(order.createdAt), style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Store Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('من متجر', style: TextStyle(color: AppColors.textHint, fontSize: 11)),
                          Text(order.producerName ?? 'متجر مساند', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('الإجمالي', style: TextStyle(color: AppColors.textHint, fontSize: 11)),
                        Text(Helpers.formatPrice(order.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // View Details Action
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order))),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.surfaceVariant.withValues(alpha: 0.5))),
                color: AppColors.primary.withValues(alpha: 0.02),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('عرض تفاصيل الطلب كاملة', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
