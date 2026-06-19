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
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;


  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      await auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        role: 'producer',
      );

      if (mounted) Navigator.pop(context); // Go back to login or let wrapper handle
    } catch (e) {
      if (mounted) Helpers.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppColors.primary)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('إنشاء حساب جديد', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const Text('انضم إلى منصة مساند كمنتج وابدأ ببيع منتجاتك', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 40),

              CustomTextField(
                controller: _nameCtrl, label: 'الاسم الكامل',
                prefixIcon: Icons.person_outline,
                validator: (v) => Validators.required(v, 'الاسم'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailCtrl, label: 'البريد الإلكتروني',
                prefixIcon: Icons.email_outlined,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneCtrl, label: 'رقم الجوال',
                prefixIcon: Icons.phone_android_outlined,
                // validator: Validators.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passCtrl, label: 'كلمة المرور',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (v) => Validators.required(v, 'كلمة المرور'),
              ),
              const SizedBox(height: 40),

              CustomButton(text: 'إنشاء الحساب', isLoading: _isLoading, onPressed: _register),
            ],
          ),
        ),
      ),
    );
  }
}
