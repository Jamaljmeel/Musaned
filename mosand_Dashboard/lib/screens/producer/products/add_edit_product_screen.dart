import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/product_model.dart';
import '../../../providers/producer_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  final String producerId;
  final ProductModel? product;
  const AddEditProductScreen({super.key, required this.producerId, this.product});
  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _picker = ImagePicker();

  File? _newImage;
  String? _existingImageUrl;

  bool _isAvailable = true;
  bool _isLoading = false;


  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final p = widget.product!;
      _nameCtrl.text = p.name;
      _descCtrl.text = p.description;
      _priceCtrl.text = p.price.toString();
      _isAvailable = p.isAvailable;
      _existingImageUrl = p.images.isNotEmpty ? p.images.first : null;

    }

  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();

  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _newImage = File(picked.path);
      });
    }
  }


  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final prov = context.read<ProducerProvider>();
      if (isEditing) {
        await prov.updateProduct(
          widget.product!.id,
          {
            'name': _nameCtrl.text,
            'nameAr': _nameCtrl.text,
            'description': _descCtrl.text,
            'descriptionAr': _descCtrl.text,
            'price': double.parse(_priceCtrl.text),
            'category': prov.producer?.category ?? 'other',
            'preparationTime': 0,
            'isAvailable': _isAvailable,
          },
          imageFile: _newImage,
        );


      } else {
        final product = ProductModel(
          id: '',
          producerId: widget.producerId,
          name: _nameCtrl.text,
          nameAr: _nameCtrl.text,
          description: _descCtrl.text,
          descriptionAr: _descCtrl.text,
          category: prov.producer?.category ?? 'other',
          price: double.parse(_priceCtrl.text),
          preparationTime: 0,
          isAvailable: _isAvailable,


          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await prov.addProduct(product, _newImage != null ? [_newImage!] : []);
      }

      if (mounted) {
        Helpers.showSuccess(context, isEditing ? 'تم تحديث المنتج' : 'تم إضافة المنتج');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) Helpers.showError(context, 'حدث خطأ: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(isEditing ? 'تعديل المنتج' : 'إضافة منتج جديد')),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Images
              const Text('صورة المنتج', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 150, height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                      image: _newImage != null 
                        ? DecorationImage(image: FileImage(_newImage!), fit: BoxFit.cover)
                        : (_existingImageUrl != null 
                            ? DecorationImage(image: NetworkImage(_existingImageUrl!), fit: BoxFit.cover)
                            : null),
                    ),
                    child: (_newImage == null && _existingImageUrl == null)
                      ? const Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 40)
                      : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              CustomTextField(
                controller: _nameCtrl, label: 'اسم المنتج',
                prefixIcon: Icons.label_rounded,
                validator: (v) => Validators.required(v, 'اسم المنتج'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descCtrl, label: 'الوصف',
                prefixIcon: Icons.description_rounded, maxLines: 3,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _priceCtrl, label: 'السعر (ر.س)',
                prefixIcon: Icons.payments_rounded,
                keyboardType: TextInputType.number,
                validator: Validators.price,
              ),

              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('المنتج متاح', style: TextStyle(fontSize: 14)),
                value: _isAvailable,
                activeColor: AppColors.success,
                onChanged: (v) => setState(() => _isAvailable = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              CustomButton(text: isEditing ? 'حفظ التعديلات' : 'إضافة المنتج', isLoading: _isLoading, onPressed: _save),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _imageThumb({String? networkUrl, File? file}) {
    return Container(
      width: 100, height: 100,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: file != null ? FileImage(file) : NetworkImage(networkUrl!),
        ),
      ),
    );
  }
}
