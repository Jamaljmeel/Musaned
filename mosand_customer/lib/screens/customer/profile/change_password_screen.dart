import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      
      // 1. Re-authenticate first to avoid requires-recent-login error
      await authService.reauthenticate(_currentPasswordCtrl.text);
      
      // 2. Change password
      await authService.changePassword(_newPasswordCtrl.text);

      if (mounted) {
        Helpers.showSuccess(context, 'تم تغيير كلمة المرور بنجاح');
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error changing password: $e');
      String msg = 'حدث خطأ أثناء تغيير كلمة المرور';
      
      if (e is FirebaseAuthException) {
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          msg = 'كلمة المرور الحالية غير صحيحة';
        } else if (e.code == 'weak-password') {
          msg = 'كلمة المرور الجديدة ضعيفة جداً';
        }
      } else {
        msg = 'حدث خطأ: $e';
      }
      
      if (mounted) Helpers.showError(context, msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('تغيير كلمة المرور'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15)],
                ),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _currentPasswordCtrl,
                      label: 'كلمة المرور الحالية',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      validator: (v) => Validators.required(v, 'كلمة المرور الحالية'),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _newPasswordCtrl,
                      label: 'كلمة المرور الجديدة',
                      prefixIcon: Icons.lock_reset_rounded,
                      obscureText: true,
                      validator: (v) => Validators.password(v),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _confirmPasswordCtrl,
                      label: 'تأكيد كلمة المرور الجديدة',
                      prefixIcon: Icons.lock_reset_rounded,
                      obscureText: true,
                      validator: (v) => Validators.confirmPassword(v, _newPasswordCtrl.text),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'تحديث كلمة المرور',
                isLoading: _isLoading,
                onPressed: _changePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
