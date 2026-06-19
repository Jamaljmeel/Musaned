import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  bool _isLoading = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() => _imageFile = File(image.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      String? avatarUrl;

      // 1. Upload image if selected
      if (_imageFile != null) {
        avatarUrl = await AuthService().uploadProfileImage(auth.user!.uid, _imageFile!);
      }

      // 2. Update profile in Firestore
      await AuthService().updateProfile(
        uid: auth.user!.uid,
        displayName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        avatarUrl: avatarUrl,
      );
      
      // 3. Refresh local user data
      await auth.refreshUser();

      if (mounted) {
        Helpers.showSuccess(context, 'تم حفظ التعديلات بنجاح');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) Helpers.showError(context, 'حدث خطأ أثناء الحفظ: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('تعديل الملف الشخصي')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Profile Image Picker
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 4,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.surfaceVariant,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (user?.avatarUrl != null &&
                                      user!.avatarUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(user.avatarUrl)
                                        as ImageProvider
                                  : null),
                        child:
                            _imageFile == null &&
                                (user?.avatarUrl == null ||
                                    user!.avatarUrl.isEmpty)
                            ? const Icon(
                                Icons.person_rounded,
                                size: 60,
                                color: AppColors.textHint,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Inputs Container
              Container(
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
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameCtrl,
                      label: 'الاسم الكامل',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) => Validators.required(v, 'الاسم'),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _phoneCtrl,
                      label: 'رقم الهاتف',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      // validator: Validators.phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'حفظ التغييرات',
                isLoading: _isLoading,
                onPressed: _save,
                icon: Icons.check_circle_outline_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
