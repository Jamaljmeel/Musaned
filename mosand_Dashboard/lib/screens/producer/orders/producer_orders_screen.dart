import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../core/enums/order_status.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/order_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/producer_provider.dart';

class ProducerOrdersScreen extends StatefulWidget {
  const ProducerOrdersScreen({super.key});
  @override
  State<ProducerOrdersScreen> createState() => _ProducerOrdersScreenState();
}

class _ProducerOrdersScreenState extends State<ProducerOrdersScreen> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user?.uid ?? '';
    final prov = context.read<ProducerProvider>();
    return Column(children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          _chip('الكل', ''), _chip('جديدة', 'pending'),
          _chip('تحضير', 'preparing'), _chip('جاهزة', 'ready'),
          _chip('مكتملة', 'delivered'),
        ]),
      ),
      Expanded(
        child: StreamBuilder<List<OrderModel>>(
          stream: prov.getMyOrders(uid, status: _filter.isEmpty ? null : _filter),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) return const LoadingWidget();
            if (!snap.hasData || snap.data!.isEmpty) {
              return const EmptyState(icon: Icons.shopping_bag_rounded, title: 'لا يوجد طلبات');
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: snap.data!.length,
              itemBuilder: (_, i) => _card(snap.data![i], prov),
            );
          },
        ),
      ),
    ]);
  }

  Widget _chip(String label, String value) {
    final sel = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(label: Text(label), selected: sel,
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: TextStyle(color: sel ? AppColors.primary : AppColors.textSecondary,
          fontWeight: sel ? FontWeight.w600 : FontWeight.normal, fontSize: 13)),
    );
  }

  Widget _card(OrderModel order, ProducerProvider prov) {
    final st = OrderStatus.fromString(order.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: st.backgroundColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(st.icon, color: st.color, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('#${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(Helpers.formatDateTime(order.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: st.backgroundColor, borderRadius: BorderRadius.circular(20)),
            child: Text(st.nameAr, style: TextStyle(fontSize: 11, color: st.color, fontWeight: FontWeight.w600))),
        ]),
        const Divider(height: 20),
        ...order.items.map((item) => Padding(padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Text('${item.quantity}x ', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
            Expanded(child: Text(item.name, style: const TextStyle(fontSize: 13))),
            Text(Helpers.formatPrice(item.total), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ]))),
        const Divider(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(order.paymentMethodAr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(Helpers.formatPrice(order.totalAmount),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
        ]),
        if (_canAct(order.status)) ...[const SizedBox(height: 14), _actions(order, prov)],
      ]),
    );
  }

  bool _canAct(String s) => s == 'pending' || s == 'accepted' || s == 'preparing' || s == 'ready';

  Widget _actions(OrderModel o, ProducerProvider p) {
    if (o.status == 'pending') {
      return Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => p.updateOrderStatus(o.id, 'cancelled'),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
          child: const Text('رفض'))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(onPressed: () => p.updateOrderStatus(o.id, 'accepted'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success), child: const Text('قبول'))),
      ]);
    }
    final next = o.status == 'accepted' ? 'preparing' : o.status == 'preparing' ? 'ready' : 'delivered';
    final labels = {'preparing': 'بدء التحضير', 'ready': 'جاهز للتوصيل', 'delivered': 'تم التسليم'};
    return SizedBox(width: double.infinity, child: ElevatedButton(
      onPressed: () => p.updateOrderStatus(o.id, next), child: Text(labels[next] ?? next)));
  }
}
