import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/order_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();
    if (cart.items.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final firstItem = cart.items.values.first;
      final order = OrderModel(
        id: '',
        orderNumber: Helpers.generateOrderNumber(),
        customerId: auth.user!.uid,
        customerName: auth.user!.displayName,
        producerId: firstItem.product.producerId,
        producerName: firstItem.product.producerName ?? 'متجر غير معروف',
        items: cart.items.values
            .map(
              (item) => OrderItem(
                productId: item.product.id,
                name: item.product.nameAr,
                quantity: item.quantity,
                price: item.product.price,
              ),
            )
            .toList(),
        subtotal: cart.totalAmount,
        deliveryFee: 0,
        totalAmount: cart.totalAmount,
        status: 'pending',
        deliveryAddress: {
          'city': _cityCtrl.text,
          'street': _addressCtrl.text,
          'phone': _phoneCtrl.text,
        },
        notes: _notesCtrl.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirestoreService().createOrder(order);

      if (mounted) {
        cart.clear();
        _showSuccessSheet();
      }
    } catch (e) {
      if (mounted) Helpers.showError(context, 'حدث خطأ أثناء إرسال الطلب');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(30),
        height: 400,
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'تم إرسال طلبك بنجاح!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'شكراً لثقتك بنا، سيقوم المتجر بتجهيز طلبك قريباً.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const Spacer(),
            CustomButton(
              text: 'العودة للرئيسية',
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(Icons.location_on_rounded, 'معلومات التوصيل'),
              _buildFormContainer([
                CustomTextField(
                  controller: _cityCtrl,
                  label: 'المدينة',
                  prefixIcon: Icons.location_city_rounded,
                  validator: (v) => Validators.required(v, 'المدينة'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _addressCtrl,
                  label: 'العنوان بالتفصيل',
                  prefixIcon: Icons.map_rounded,
                  validator: (v) => Validators.required(v, 'العنوان'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneCtrl,
                  label: 'رقم التواصل',
                  prefixIcon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  // validator: Validators.phone,
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle(Icons.receipt_long_rounded, 'ملخص الطلب'),
              _buildFormContainer([
                _summaryRow('عدد المنتجات', '${cart.itemCount}'),
                _summaryRow(
                  'سعر المنتجات',
                  Helpers.formatPrice(cart.totalAmount),
                ),
                const Divider(height: 30),
                _summaryRow(
                  'المبلغ الإجمالي',
                  Helpers.formatPrice(cart.totalAmount),
                  isBold: true,
                  fontSize: 18,
                ),
              ]),
              const SizedBox(height: 40),
              CustomButton(
                text: 'تأكيد الطلب والدفع عند الاستلام',
                isLoading: _isLoading,
                onPressed: _placeOrder,
                icon: Icons.send_rounded,
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContainer(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 14,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color:
                  valueColor ??
                  (isBold ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
