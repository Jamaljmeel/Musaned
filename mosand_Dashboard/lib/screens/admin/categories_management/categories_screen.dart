import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/category_model.dart';
import '../../../services/firestore_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<CategoryModel>>(
        stream: _firestore.getCategoriesStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const LoadingWidget();
          if (!snap.hasData || snap.data!.isEmpty) {
            return const EmptyState(
              icon: Icons.category_rounded,
              title: 'لا يوجد فئات',
              subtitle: 'أضف فئات لتنظيم المنتجات',
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snap.data!.length,
            onReorder: (oldI, newI) {},
            itemBuilder: (_, i) {
              final cat = snap.data![i];
              return Container(
                key: ValueKey(cat.id),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
                ),
                child: ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.category_rounded, color: AppColors.primary),
                  ),
                  title: Text(cat.nameAr, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(cat.name, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: cat.isActive,
                        activeColor: AppColors.success,
                        onChanged: (v) => _firestore.updateCategory(cat.id, {'isActive': v}),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                        onPressed: () async {
                          final ok = await Helpers.showConfirmDialog(context,
                              title: 'حذف', message: 'حذف هذه الفئة؟', confirmColor: AppColors.error);
                          if (ok) await _firestore.deleteCategory(cat.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('إضافة فئة'),
      ),
    );
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final nameArCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة فئة جديدة', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameArCtrl, textDirection: TextDirection.rtl,
                decoration: const InputDecoration(labelText: 'الاسم بالعربي', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'الاسم بالإنجليزي', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (nameArCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
                await _firestore.addCategory(CategoryModel(
                  id: '', name: nameCtrl.text, nameAr: nameArCtrl.text, order: 99,
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) Helpers.showSuccess(context, 'تم إضافة الفئة');
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
