import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/enums/approval_status.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/producer_provider.dart';

class ProducerDashboardScreen extends StatefulWidget {
  const ProducerDashboardScreen({super.key});
  @override
  State<ProducerDashboardScreen> createState() => _ProducerDashboardScreenState();
}

class _ProducerDashboardScreenState extends State<ProducerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().user?.uid ?? '';
    if (uid.isNotEmpty) {
      Future.microtask(() => context.read<ProducerProvider>().loadProducerData(uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Consumer<ProducerProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading) return const LoadingWidget(message: 'جاري التحميل...');
        final producer = prov.producer;
        final stats = prov.stats;
        final status = producer != null ? ApprovalStatus.fromString(producer.approvalStatus) : ApprovalStatus.pending;

        return RefreshIndicator(
          onRefresh: () => prov.loadProducerData(auth.user!.uid),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting + Status
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${Helpers.getGreeting()} 👋',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(producer?.storeName ?? auth.user?.displayName ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        ])),
                        // Online toggle
                        if (status == ApprovalStatus.approved)
                          GestureDetector(
                            onTap: () => prov.toggleOnlineStatus(auth.user!.uid),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: (producer?.isOnline ?? false)
                                    ? AppColors.success.withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (producer?.isOnline ?? false) ? AppColors.success : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text((producer?.isOnline ?? false) ? 'متصل' : 'غير متصل',
                                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ]),
                            ),
                          ),
                      ]),
                      const SizedBox(height: 12),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(status.icon, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text('حالة الحساب: ${status.nameAr}',
                              style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ]),
                      ),
                    ],
                  ),
                ),

                // Pending message
                if (status == ApprovalStatus.pending) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight, borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.warning),
                      SizedBox(width: 12),
                      Expanded(child: Text('حسابك قيد المراجعة. سيتم إشعارك عند القبول.',
                          style: TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                    ]),
                  ),
                ],

                if (status == ApprovalStatus.rejected) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight, borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        Icon(Icons.error_outline_rounded, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('تم رفض حسابك', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error)),
                      ]),
                      if (producer?.rejectionReason.isNotEmpty ?? false) ...[
                        const SizedBox(height: 8),
                        Text('السبب: ${producer!.rejectionReason}',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ]),
                  ),
                ],

                if (status == ApprovalStatus.approved) ...[
                  const SizedBox(height: 24),
                  const Text('إحصائياتي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 1.15,
                    children: [
                      StatCard(title: 'منتجاتي', value: '${stats['totalProducts'] ?? 0}',
                          icon: Icons.inventory_2_rounded, color: AppColors.primary),
                      StatCard(title: 'طلبات نشطة', value: '${stats['activeOrders'] ?? 0}',
                          icon: Icons.pending_actions_rounded, color: AppColors.warning),
                      StatCard(title: 'طلبات مكتملة', value: '${stats['deliveredOrders'] ?? 0}',
                          icon: Icons.check_circle_rounded, color: AppColors.success),
                      StatCard(title: 'الإيرادات', value: Helpers.formatPrice((stats['totalRevenue'] ?? 0).toDouble()),
                          icon: Icons.payments_rounded, color: const Color(0xFF26A69A)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
