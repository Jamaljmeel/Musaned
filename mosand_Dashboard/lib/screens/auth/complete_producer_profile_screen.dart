import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/producer_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/producer_model.dart';
import '../../models/category_model.dart';

class CompleteProducerProfileScreen extends StatefulWidget {
  const CompleteProducerProfileScreen({super.key});
  @override
  State<CompleteProducerProfileScreen> createState() =>
      _CompleteProducerProfileScreenState();
}

class _CompleteProducerProfileScreenState
    extends State<CompleteProducerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic Info
  final _storeNameCtrl = TextEditingController();
  final _storeNameArCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _selectedCategoryId;
  File? _logo;

  // Location Info
  final _cityCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();

  // Legal & Contact (Optional)
  final _licenseCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _instaCtrl = TextEditingController();

  // Working Hours
  TimeOfDay _openTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 22, minute: 0);

  bool _isLoading = false;

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _storeNameArCtrl.dispose();
    _descCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _streetCtrl.dispose();
    _licenseCtrl.dispose();
    _whatsappCtrl.dispose();
    _instaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) setState(() => _logo = File(picked.path));
  }

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime ? _openTime : _closeTime,
    );
    if (picked != null) {
      setState(() => isOpenTime ? _openTime = picked : _closeTime = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final producerProv = context.read<ProducerProvider>();

      final producer = ProducerModel(
        userId: auth.user!.uid,
        storeName: _storeNameCtrl.text.trim(),
        storeNameAr: _storeNameArCtrl.text.trim().isEmpty
            ? _storeNameCtrl.text.trim()
            : _storeNameArCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        descriptionAr: _descCtrl.text.trim(),
        category: _selectedCategoryId ?? '',
        address: {
          'city': _cityCtrl.text.trim(),
          'district': _districtCtrl.text.trim(),
          'street': _streetCtrl.text.trim(),
        },
        businessLicense: _licenseCtrl.text.trim(),
        workingHours: {
          'open': '${_openTime.hour}:${_openTime.minute}',
          'close': '${_closeTime.hour}:${_closeTime.minute}',
        },
        phone: _whatsappCtrl.text.trim().isEmpty
            ? (auth.userModel?.phone ?? '')
            : _whatsappCtrl.text.trim(),
        whatsapp: _whatsappCtrl.text.trim(),
        instagramUrl: _instaCtrl.text.trim(),
        email: auth.user!.email ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await producerProv.completeProfile(producer, _logo);
      // Re-initialize auth to make sure the wrapper sees the new data
      await auth.initialize();
      // If the wrapper didn't catch it automatically, we can pop or navigate
      if (mounted) {
        Helpers.showSuccess(context, 'تم تجهيز متجرك بنجاح!');
      }
    } catch (e) {
      if (mounted) Helpers.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('إعداد المتجر الاحترافي'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),

              _sectionTitle('1. الهوية البصرية'),
              _buildLogoPicker(),

              const SizedBox(height: 30),
              _sectionTitle('2. البيانات الأساسية'),
              CustomTextField(
                controller: _storeNameArCtrl,
                label: 'اسم المتجر',
                prefixIcon: Icons.store_rounded,
                validator: (v) => Validators.required(v, 'الاسم'),
              ),
              const SizedBox(height: 16),
              Consumer<CategoryProvider>(
                builder: (context, catProv, _) {
                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'فئة النشاط',
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    hint: const Text('اختر فئة المتجر'),
                    items: catProv.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.nameAr),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                    validator: (v) => v == null ? 'يرجى اختيار الفئة' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descCtrl,
                label: 'وصف المتجر والمنتجات',
                prefixIcon: Icons.description_rounded,
                maxLines: 3,
              ),

              const SizedBox(height: 30),
              _sectionTitle('3. العنوان والموقع'),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityCtrl,
                      label: 'المدينة',
                      prefixIcon: Icons.location_city_rounded,
                      validator: (v) => Validators.required(v, 'المدينة'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _districtCtrl,
                      label: 'الحي',
                      prefixIcon: Icons.place_rounded,
                      validator: (v) => Validators.required(v, 'الحي'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _streetCtrl,
                label: 'اسم الشارع (اختياري)',
                prefixIcon: Icons.add_road_rounded,
              ),

              const SizedBox(height: 30),
              _sectionTitle('4. التراخيص والتواصل (اختياري)'),
              CustomTextField(
                controller: _licenseCtrl,
                label: 'رقم السجل التجاري / وثيقة العمل الحر',
                prefixIcon: Icons.verified_user_rounded,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _whatsappCtrl,
                label: 'رقم الواتساب للطلبات',
                prefixIcon: Icons.phone_enabled_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _instaCtrl,
                label: 'رابط الانستقرام',
                prefixIcon: Icons.camera_alt_rounded,
              ),

              const SizedBox(height: 30),
              _sectionTitle('5. أوقات العمل'),
              Row(
                children: [
                  Expanded(
                    child: _timeTile(
                      'من الساعة',
                      _openTime,
                      () => _selectTime(context, true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _timeTile(
                      'إلى الساعة',
                      _closeTime,
                      () => _selectTime(context, false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),
              CustomButton(
                text: 'إطلاق المتجر الآن',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مرحباً بك في مُساند!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'لنقم بتجهيز متجرك ليكون جاهزاً لاستقبال العملاء بأفضل صورة ممكنة.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildLogoPicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
                image: _logo != null
                    ? DecorationImage(
                        image: FileImage(_logo!),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _logo == null
                  ? const Icon(
                      Icons.add_a_photo_rounded,
                      size: 40,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeTile(String label, TimeOfDay time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(12),
        ),
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
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
