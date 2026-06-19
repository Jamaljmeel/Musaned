import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/producer_provider.dart';

class StoreProfileScreen extends StatefulWidget {
  const StoreProfileScreen({super.key});
  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameArCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _instaCtrl = TextEditingController();
  bool _isLoading = false;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final producer = context.watch<ProducerProvider>().producer;
    
      if (producer != null && _storeNameArCtrl.text.isEmpty) {
        _storeNameArCtrl.text = producer.storeNameAr;
        _descCtrl.text = producer.descriptionAr;
        _cityCtrl.text = producer.address['city'] ?? '';
        _districtCtrl.text = producer.address['district'] ?? '';
        _licenseCtrl.text = producer.businessLicense;
        _whatsappCtrl.text = producer.whatsapp;
        _instaCtrl.text = producer.instagramUrl;
      }

  }

  @override
  void dispose() {
    _storeNameArCtrl.dispose();
    _descCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _licenseCtrl.dispose();
    _whatsappCtrl.dispose();
    _instaCtrl.dispose();
    super.dispose();


  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final producerProv = context.read<ProducerProvider>();
      final uid = context.read<AuthProvider>().user!.uid;
      final currentProducer = producerProv.producer;

      await producerProv.updateStoreProfile(uid, {
        'storeNameAr': _storeNameArCtrl.text,
        'descriptionAr': _descCtrl.text,
        'businessLicense': _licenseCtrl.text,
        'whatsapp': _whatsappCtrl.text,
        'instagramUrl': _instaCtrl.text,
        'address': {

          'city': _cityCtrl.text,
          'district': _districtCtrl.text,
          'street': currentProducer?.address['street'] ?? '',
        },
      });
      if (mounted) Helpers.showSuccess(context, 'تم حفظ التعديلات بنجاح');

    } catch (e) {
      if (mounted) Helpers.showError(context, 'حدث خطأ');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final producer = context.watch<ProducerProvider>().producer;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Avatar / Logo
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceVariant,
                image: producer?.logoUrl.isNotEmpty == true
                    ? DecorationImage(
                        image: NetworkImage(producer!.logoUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: producer?.logoUrl.isEmpty == true
                  ? const Icon(Icons.store_rounded,
                      size: 50, color: AppColors.primary)
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          if (producer != null)
            Center(
              child: Text(
                'التقييم: ${producer.rating.toStringAsFixed(1)} ⭐ (${producer.reviewCount} تقييم)',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          const SizedBox(height: 24),
          CustomTextField(controller: _storeNameArCtrl, label: 'اسم المتجر', prefixIcon: Icons.store_rounded),
          const SizedBox(height: 16),
          CustomTextField(controller: _descCtrl, label: 'وصف المتجر', prefixIcon: Icons.description_rounded, maxLines: 3),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: CustomTextField(controller: _cityCtrl, label: 'المدينة', prefixIcon: Icons.location_city_rounded)),
            const SizedBox(width: 12),
            Expanded(child: CustomTextField(controller: _districtCtrl, label: 'الحي', prefixIcon: Icons.place_rounded)),
          ]),
          const SizedBox(height: 16),
          CustomTextField(controller: _whatsappCtrl, label: 'رقم الواتساب', prefixIcon: Icons.phone_android_rounded, keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          CustomTextField(controller: _instaCtrl, label: 'رابط الانستقرام', prefixIcon: Icons.camera_alt_rounded),
          const SizedBox(height: 16),
          CustomTextField(controller: _licenseCtrl, label: 'رقم السجل/الوثيقة', prefixIcon: Icons.verified_user_rounded),


          const SizedBox(height: 24),
          CustomButton(text: 'حفظ التعديلات', isLoading: _isLoading, onPressed: _save, icon: Icons.save_rounded),
        ]),
      ),
    );
  }
}
