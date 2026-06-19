import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../core/enums/order_status.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/order_model.dart';
import '../../../providers/admin_provider.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});
  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AdminProvider>();
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            _chip('الكل', ''),
            _chip('في الانتظار', 'pending'),
            _chip('قيد التحضير', 'preparing'),
            _chip('تم التوصيل', 'delivered'),
            _chip('ملغي', 'cancelled'),
          ]),
        ),
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: admin.getOrdersStream(status: _filter.isEmpty ? null : _filter),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const LoadingWidget();
              if (!snap.hasData || snap.data!.isEmpty) {
                return const EmptyState(icon: Icons.shopping_bag_rounded, title: 'لا يوجد طلبات');
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: snap.data!.length,
                itemBuilder: (_, i) => _orderCard(snap.data![i]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final sel = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(label),
        selected: sel,
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: sel ? AppColors.primary : AppColors.textSecondary,
          fontWeight: sel ? FontWeight.w600 : FontWeight.normal, fontSize: 13,
        ),
      ),
    );
  }

  Widget _orderCard(OrderModel order) {
    final status = OrderStatus.fromString(order.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: status.backgroundColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(status.icon, color: status.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('#${order.orderNumber}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(Helpers.formatDateTime(order.createdAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: status.backgroundColor, borderRadius: BorderRadius.circular(20)),
              child: Text(status.nameAr,
                  style: TextStyle(fontSize: 11, color: status.color, fontWeight: FontWeight.w600)),
            ),
          ]),
          const Divider(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${order.totalItems} منتج', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            Text(order.paymentMethodAr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text(Helpers.formatPrice(order.totalAmount),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
          ]),
        ],
      ),
    );
  }
}
