import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../core/utils/helpers.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AdminProvider>().loadDashboardStats());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        if (admin.isLoading) {
          return const LoadingWidget(message: 'جاري تحميل الإحصائيات...');
        }
        final stats = admin.stats;
        return RefreshIndicator(
          onRefresh: () => admin.loadDashboardStats(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${Helpers.getGreeting()} 👋',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              auth.user?.displayName ?? 'مدير النظام',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'لوحة التحكم الرئيسية',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.admin_panel_settings_rounded,
                            color: Colors.white, size: 32),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Grid
                const Text('نظرة عامة',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.15,
                  children: [
                    StatCard(
                      title: 'إجمالي المنتجين',
                      value: '${stats['totalProducers'] ?? 0}',
                      icon: Icons.storefront_rounded,
                      color: AppColors.primary,
                    ),
                    StatCard(
                      title: 'بانتظار الموافقة',
                      value: '${stats['pendingProducers'] ?? 0}',
                      icon: Icons.pending_actions_rounded,
                      color: AppColors.warning,
                    ),
                    StatCard(
                      title: 'إجمالي الطلبات',
                      value: '${stats['totalOrders'] ?? 0}',
                      icon: Icons.shopping_bag_rounded,
                      color: AppColors.info,
                    ),
                    StatCard(
                      title: 'طلبات مكتملة',
                      value: '${stats['deliveredOrders'] ?? 0}',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                    ),
                    StatCard(
                      title: 'إجمالي المنتجات',
                      value: '${stats['totalProducts'] ?? 0}',
                      icon: Icons.inventory_2_rounded,
                      color: const Color(0xFF7E57C2),
                    ),
                    StatCard(
                      title: 'الإيرادات',
                      value: Helpers.formatPrice(
                          (stats['totalRevenue'] ?? 0).toDouble()),
                      icon: Icons.payments_rounded,
                      color: const Color(0xFF26A69A),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                // Quick actions
                const Text('إجراءات سريعة',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                _buildQuickAction(
                  icon: Icons.person_add_rounded,
                  title: 'طلبات المنتجين الجدد',
                  subtitle: '${stats['pendingProducers'] ?? 0} طلب بانتظار المراجعة',
                  color: AppColors.warning,
                  onTap: () {
                    // Navigate to producers management
                  },
                ),
                const SizedBox(height: 10),
                _buildQuickAction(
                  icon: Icons.inventory_rounded,
                  title: 'منتجات بانتظار الموافقة',
                  subtitle: '${stats['pendingProducts'] ?? 0} منتج جديد',
                  color: AppColors.info,
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _buildQuickAction(
                  icon: Icons.receipt_long_rounded,
                  title: 'طلبات جديدة',
                  subtitle: '${stats['pendingOrders'] ?? 0} طلب قيد الانتظار',
                  color: AppColors.secondary,
                  onTap: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
