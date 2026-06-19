import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../core/enums/approval_status.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/producer_model.dart';
import '../../../providers/admin_provider.dart';

class ProducersListScreen extends StatefulWidget {
  const ProducersListScreen({super.key});
  @override
  State<ProducersListScreen> createState() => _ProducersListScreenState();
}

class _ProducersListScreenState extends State<ProducersListScreen> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AdminProvider>();
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _chip('الكل', ''),
              _chip('بانتظار', 'pending'),
              _chip('معتمد', 'approved'),
              _chip('مرفوض', 'rejected'),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ProducerModel>>(
            stream: admin.getProducersStream(
              status: _filter.isEmpty ? null : _filter,
            ),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return const LoadingWidget();
              if (!snap.hasData || snap.data!.isEmpty) {
                return const EmptyState(
                  icon: Icons.storefront_rounded,
                  title: 'لا يوجد منتجين',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: snap.data!.length,
                itemBuilder: (_, i) => _card(snap.data![i]),
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
          fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _card(ProducerModel p) {
    final status = ApprovalStatus.fromString(p.approvalStatus);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: p.logoUrl.isNotEmpty
                    ? NetworkImage(p.logoUrl)
                    : null,
                child: p.logoUrl.isEmpty
                    ? Text(
                        p.storeNameAr.isNotEmpty ? p.storeNameAr[0] : '؟',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.storeNameAr.isEmpty ? p.storeName : p.storeNameAr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.address['city'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.secondary,
                ),
                onPressed: () => _showDetails(p),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: status.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.nameAr,
                  style: TextStyle(
                    fontSize: 11,
                    color: status.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              if (status != ApprovalStatus.rejected)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _reject(p.userId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('رفض / حظر'),
                  ),
                ),
              if (status != ApprovalStatus.rejected &&
                  status != ApprovalStatus.approved)
                const SizedBox(width: 12),
              if (status != ApprovalStatus.approved)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approve(p.userId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: const Text(' قبول'),
                  ),
                ),
            ],
          ),
          if (status == ApprovalStatus.approved) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('${p.totalOrders}', 'طلب'),
                _stat(p.rating.toStringAsFixed(1), 'تقييم'),
                _stat(Helpers.formatPrice(p.totalRevenue), 'إيرادات'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(String val, String label) => Column(
    children: [
      Text(
        val,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    ],
  );

  Future<void> _approve(String uid) async {
    final ok = await Helpers.showConfirmDialog(
      context,
      title: 'تأكيد',
      message: 'قبول هذا المنتج؟',
      confirmColor: AppColors.success,
    );
    if (ok && mounted) {
      await context.read<AdminProvider>().approveProducer(uid);
      if (mounted) Helpers.showSuccess(context, 'تم القبول');
    }
  }

  void _reject(String uid) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('سبب الرفض', textAlign: TextAlign.center),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            hintText: 'سبب الرفض...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isNotEmpty) {
                Navigator.pop(ctx);
                await context.read<AdminProvider>().rejectProducer(
                  uid,
                  ctrl.text,
                );
                if (mounted) Helpers.showSuccess(context, 'تم الرفض');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('رفض'),
          ),
        ],
      ),
    );
  }

  void _showDetails(ProducerModel p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: p.logoUrl.isNotEmpty
                        ? NetworkImage(p.logoUrl)
                        : null,
                    backgroundColor: AppColors.surfaceVariant,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.storeNameAr,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'منتج مُساند',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 40),
              _detailItem(
                Icons.description_rounded,
                'وصف المتجر',
                p.descriptionAr.isEmpty ? 'لا يوجد وصف' : p.descriptionAr,
              ),
              _detailItem(
                Icons.location_on_rounded,
                'العنوان',
                '${p.address['city']} - ${p.address['district']}',
              ),
              _detailItem(
                Icons.phone_rounded,
                'واتساب',
                p.whatsapp.isEmpty ? 'غير محدد' : p.whatsapp,
              ),
              _detailItem(
                Icons.camera_alt_rounded,
                'انستقرام',
                p.instagramUrl.isEmpty ? 'غير محدد' : p.instagramUrl,
              ),
              _detailItem(
                Icons.verified_user_rounded,
                'رقم السجل/الوثيقة',
                p.businessLicense.isEmpty ? 'غير محدد' : p.businessLicense,
              ),
              _detailItem(
                Icons.calendar_today_rounded,
                'تاريخ الانضمام',
                Helpers.formatDate(p.createdAt),
              ),
              const SizedBox(height: 30),
              CustomButton(text: 'إغلاق', onPressed: () => Navigator.pop(ctx)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
