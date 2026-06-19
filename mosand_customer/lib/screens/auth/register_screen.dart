import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final success = await auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );
      if (success && mounted) {
        Helpers.showSuccess(context, 'تم إنشاء حسابك بنجاح!');
        Navigator.pop(context);
      } else if (mounted) {
        Helpers.showError(context, auth.errorMessage);
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
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'انضم لمُساند',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  'اكتشف منتجات الأسر المنتجة',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 30),

                CustomTextField(
                  controller: _nameCtrl,
                  label: 'الاسم الكامل',
                  prefixIcon: Icons.person_outlined,
                  validator: (v) => Validators.required(v, 'الاسم'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailCtrl,
                  label: 'البريد الإلكتروني',
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneCtrl,
                  label: 'رقم الهاتف',
                  prefixIcon: Icons.phone_outlined,
                  // validator: Validators.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passCtrl,
                  label: 'كلمة المرور',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPassCtrl,
                  label: 'تأكيد كلمة المرور',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) =>
                      Validators.confirmPassword(v, _passCtrl.text),
                ),
                const SizedBox(height: 30),

                CustomButton(
                  text: 'إنشاء حساب',
                  isLoading: _isLoading,
                  onPressed: _register,
                  icon: Icons.person_add_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
